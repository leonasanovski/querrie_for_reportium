--creating report table
CREATE TABLE Report (
    report_id SERIAL PRIMARY KEY,
    report_type VARCHAR(50) NOT NULL,
    summary VARCHAR(255),
    created_at DATE NOT NULL,
    person_id INT,
	CONSTRAINT fk_person_id FOREIGN KEY (person_id) REFERENCES Person(person_id) ON DELETE SET NULL ON UPDATE CASCADE,
	CONSTRAINT check_report_type CHECK (report_type IN ('Medical', 'Criminal', 'Academic', 'Employment'))
);


