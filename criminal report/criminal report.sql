--creating criminal type table
CREATE TABLE CrimeType (
    crime_type_id SERIAL PRIMARY KEY,
    label VARCHAR(100) NOT NULL,
	severity_level VARCHAR(10) NOT NULL,
    constraint check_severity CHECK (severity_level IN ('LOW', 'MEDIUM', 'HIGH'))
);
--criminalReport table
CREATE TABLE CriminalReport (
    report_id INT PRIMARY KEY REFERENCES Report(report_id) ON DELETE CASCADE,
    location VARCHAR(100),
    created_at DATE DEFAULT CURRENT_DATE,
    resolved BOOLEAN DEFAULT FALSE,
    crime_type_id INT REFERENCES CrimeType(crime_type_id) ON DELETE SET NULL,
    descriptive_punishment TEXT
);

--punishment table
CREATE TABLE Punishment (
    punishment_id SERIAL PRIMARY KEY,
    report_id INT UNIQUE NOT NULL,
    value_unit VARCHAR(20) NOT NULL,
    punishment_type VARCHAR(50) NOT NULL,
    fine_to_pay DECIMAL(10,2),
    release_date DATE,
    CONSTRAINT check_punishment_type CHECK (punishment_type IN ('fine', 'prison')),
    CONSTRAINT check_value_unit CHECK (value_unit IN ('euros', 'years')),
    CONSTRAINT fk_report_id FOREIGN KEY (report_id) REFERENCES CriminalReport(report_id) ON DELETE CASCADE
);


ALTER TABLE employmentreport
ALTER COLUMN income_per_month TYPE DOUBLE PRECISION;

--function for the criminal report function 1
CREATE OR REPLACE FUNCTION update_criminal_report_description()
RETURNS TRIGGER AS $$
DECLARE
    deadline_date DATE;
    report_date DATE;
    formatted_fine TEXT;
BEGIN
    SELECT created_at INTO report_date
    FROM CriminalReport
    WHERE report_id = NEW.report_id;

    IF NEW.punishment_type = 'fine' THEN
        deadline_date := report_date + INTERVAL '1 month';
        formatted_fine := TO_CHAR(NEW.fine_to_pay, 'FM999999990.00');

        UPDATE CriminalReport
        SET descriptive_punishment = FORMAT(
            'The fine to be paid is %s euros, and shall be paid within one month after the report is made (until %s).',
            formatted_fine,
            TO_CHAR(deadline_date, 'YYYY-MM-DD')
        )
        WHERE report_id = NEW.report_id;

    ELSIF NEW.punishment_type = 'prison' THEN
        UPDATE CriminalReport
        SET descriptive_punishment = FORMAT(
            'The accused shall be in prison until %s.',
            TO_CHAR(NEW.release_date, 'YYYY-MM-DD')
        )
        WHERE report_id = NEW.report_id;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;
--triggering the function 1
CREATE TRIGGER trg_update_description_on_punishment_insert
AFTER INSERT OR UPDATE ON Punishment
FOR EACH ROW
EXECUTE FUNCTION update_criminal_report_description();




--function that sets the value depending on the type of the punishment 2
CREATE OR REPLACE FUNCTION setting_punishment_depending_on_type()
RETURNS TRIGGER AS $$
DECLARE
BEGIN
    IF NEW.punishment_type = 'fine' THEN
        NEW.value_unit := 'euros';
        IF NEW.fine_to_pay IS NULL THEN
            RAISE EXCEPTION 'Fine punishment must include fine_to_pay amount.';
        END IF;
        IF NEW.release_date IS NOT NULL THEN
            RAISE EXCEPTION 'Fine punishment must not have a release_date.';
        END IF;
    ELSIF NEW.punishment_type = 'prison' THEN
        NEW.value_unit := 'years';
        IF NEW.release_date IS NULL THEN
            RAISE EXCEPTION 'Prison punishment must include release_date.';
        END IF;
        IF NEW.fine_to_pay IS NOT NULL THEN
            RAISE EXCEPTION 'Prison punishment must not include fine_to_pay.';
        END IF;
    ELSE
        RAISE EXCEPTION 'Invalid punishment_type: %', NEW.punishment_type;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
--trigger for the function 2
CREATE TRIGGER trg_set_punishment_unit
BEFORE INSERT OR UPDATE ON Punishment
FOR EACH ROW
EXECUTE FUNCTION setting_punishment_depending_on_type();



--filling the tables
INSERT INTO CrimeType (label, severity_level) VALUES
('Theft', 'MEDIUM'),
('Public Fight', 'LOW'),
('Assault', 'MEDIUM'),
('Fraud', 'MEDIUM'),
('Drug Possession', 'HIGH'),
('Homicide', 'HIGH'),
('Vandalism', 'LOW'),
('Cybercrime', 'MEDIUM');

INSERT INTO Report (report_id, report_type, summary, created_at, person_id) VALUES
(500, 'Criminal','Aleksandar Kostov was involved in a criminal act.', '2023-10-06', 3),
(501, 'Criminal','Kristina Mitrevska was involved in a criminal act.','2023-12-09', 6),
(502, 'Criminal','Kristina Mitrevska was involved in a criminal act.','2023-10-30', 6),
(503, 'Criminal','Milena Jovanovska was involved in a criminal act.','2022-12-23', 7),
(504, 'Criminal','Teodora Ilievska was involved in a criminal act.','2023-06-08', 2),
(505, 'Criminal','Aleksandar Kostov was involved in a criminal act.','2023-09-27', 3),
(506, 'Criminal','Aleksandar Kostov was involved in a criminal act.','2022-11-06', 3),
(507, 'Criminal','Aleksandar Kostov was involved in a criminal act.','2023-10-11', 3),
(508, 'Criminal','Teodora Ilievska was involved in a criminal act.','2022-09-28', 2),
(509, 'Criminal','Aleksandar Kostov was involved in a criminal act.','2023-07-05', 3);



INSERT INTO CriminalReport (report_id, location, created_at, resolved, crime_type_id) VALUES
(500, 'Ohrid', '2023-10-06', TRUE, 3),
(501, 'Kumanovo', '2023-12-09', FALSE, 6),
(502, 'Skopje', '2023-10-30', TRUE, 6),
(503, 'Tetovo', '2022-12-23', TRUE, 7),
(504, 'Bitola', '2023-06-08', TRUE, 2),
(505, 'Bitola', '2023-09-27', TRUE, 3),
(506, 'Ohrid', '2022-11-06', TRUE, 3),
(507, 'Skopje', '2023-10-11', TRUE, 3),
(508, 'Skopje', '2022-09-28', TRUE, 2),
(509, 'Veles', '2023-07-05', FALSE, 3);

INSERT INTO Punishment (punishment_id, report_id, punishment_type, value_unit, fine_to_pay, release_date) VALUES
(100,500, 'prison', 'years', NULL, '2028-10-06'),
(101,501, 'prison', 'years', NULL, '2028-12-08'),
(102,502, 'prison', 'years', NULL, '2027-10-30'),
(103,503, 'fine', 'euros', 492.15, NULL),
(104,504, 'fine', 'euros', 706.24, NULL),
(105,505, 'prison', 'years', NULL, '2027-09-26'),
(106,506, 'fine', 'euros', 968.62, NULL),
(107,507, 'fine', 'euros', 473.88, NULL),
(108,508, 'fine', 'euros', 822.74, NULL),
(109,509, 'fine', 'euros', 331.93, NULL);