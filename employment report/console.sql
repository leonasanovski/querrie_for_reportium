--creating the employment report table
CREATE TABLE EmploymentReport (
    report_id INT PRIMARY KEY,
    start_date DATE NOT NULL,
    end_date DATE,
    job_role VARCHAR(100),
    income_per_month DECIMAL(10,2),
    CONSTRAINT fk_report_id FOREIGN KEY (report_id) REFERENCES Report(report_id) ON DELETE CASCADE,
    CONSTRAINT check_employment_dates CHECK (end_date IS NULL OR end_date > start_date),
    CONSTRAINT check_income_positive CHECK (income_per_month >= 0)
);

--check if the employment report is made for legally adult people 1
CREATE OR REPLACE FUNCTION check_if_person_is_adult()
RETURNS TRIGGER AS $$
DECLARE
    person_date_of_birth DATE;
    person_date_of_death DATE;
    person_is_alive_status BOOLEAN;
    created_at_report_date DATE;
BEGIN
    --I need the data so I can make the checks
    SELECT p.date_of_birth, p.is_alive, p.date_of_death, r.created_at
    INTO person_date_of_birth, person_is_alive_status, person_date_of_death, created_at_report_date
    FROM report r
    JOIN person p ON r.person_id = p.person_id
    WHERE r.report_id = NEW.report_id;
    IF person_is_alive_status IS TRUE THEN
        IF EXTRACT(YEAR FROM age(created_at_report_date, person_date_of_birth)) < 18 THEN
            RAISE EXCEPTION 'Person must be adult to have an employment report!';
        END IF;
    ELSIF person_is_alive_status IS FALSE THEN
        IF EXTRACT(YEAR FROM age(created_at_report_date, person_date_of_birth)) < 18 THEN
            RAISE EXCEPTION 'Person was not adult at the time of report creation!';
        ELSIF created_at_report_date > person_date_of_death THEN
            RAISE EXCEPTION 'The report cannot be created after the person''s death!';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
--trigger to activate the function above
CREATE TRIGGER trg_check_if_person_adult
BEFORE INSERT OR UPDATE ON EmploymentReport
FOR EACH ROW
EXECUTE FUNCTION check_if_person_is_adult();

--filling the employment tables
INSERT INTO Report (report_type, summary, created_at, person_id)
VALUES
('Employment', 'Simona Miloshevska started work at HealthPlus.', '2020-03-01', 5),
('Employment', 'Bojan Tasevski joined TechNova as developer.', '2018-06-01', 9),
('Employment', 'Goran Naumovski began role as sales manager.', '2016-09-15', 10),
('Employment', 'Leon Asanovski employed at DigitalSpark.', '2022-07-01', 11),
('Employment', 'Klara Volak got a teaching assistant job.', '2023-01-15', 13);

INSERT INTO EmploymentReport (report_id, start_date, end_date, job_role, income_per_month)
VALUES
(1, '2020-03-01', NULL, 'Nurse Assistant', 450.00),
(2, '2018-06-01', '2022-05-31', 'Software Developer', 1100.00),
(3, '2016-09-15', NULL, 'Sales Manager', 1350.50),
(4, '2022-07-01', NULL, 'Junior QA Engineer', 720.00),
(5, '2023-01-15', NULL, 'Teaching Assistant', 610.00);
