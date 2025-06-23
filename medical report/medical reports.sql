--diagnosis table
create table Diagnosis(
    diagnosis_id serial primary key,
    short_description text not null,
    therapy text,
    is_chronic boolean default false,
    severity VARCHAR(10),
    constraint check_severity CHECK (severity in ('LOW','MEDIUM','HIGH'))
);

--specialization options
CREATE TYPE doctor_specialization_options AS ENUM (
    'General Practitioner',
    'Cardiologist',
    'Neurologist',
    'Pediatrician',
    'Dermatologist',
    'Psychiatrist',
    'Orthopedic',
    'Oncologist',
    'Endocrinologist',
    'Gynecologist',
    'Radiologist',
    'Urologist'
);

--doctor table
CREATE TABLE Doctor (
    doctor_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    surname VARCHAR(100) NOT NULL,
    specialization doctor_specialization_options NOT NULL,
    years_of_experience INT CHECK (years_of_experience >= 0),
    is_active BOOLEAN DEFAULT TRUE
);

--medical report table
CREATE TABLE MedicalReport (
    report_id INT PRIMARY KEY REFERENCES Report(report_id) ON DELETE CASCADE,
    doctor_id INT REFERENCES Doctor(doctor_id) ON DELETE SET NULL,
    next_control_date DATE
);

--medical report with diagnosis (one report can have many diagnoses, and one diagnose can be included in many reports)
CREATE TABLE MedicalReport_Diagnosis (
    id SERIAL PRIMARY KEY,
    report_id INT NOT NULL REFERENCES MedicalReport(report_id) ON DELETE CASCADE,
    diagnosis_id INT NOT NULL REFERENCES Diagnosis(diagnosis_id) ON DELETE CASCADE,
    added_on DATE DEFAULT CURRENT_DATE,
    CONSTRAINT unique_report_diagnosis UNIQUE (report_id, diagnosis_id)
);


--inserting some doctors
INSERT INTO Doctor (name, surname, specialization, years_of_experience, is_active) VALUES
('Elena', 'Mitrevska', 'Cardiologist', 12, TRUE),
('Marko', 'Stojanovski', 'Neurologist', 8, TRUE),
('Ana', 'Petrova', 'Pediatrician', 5, TRUE),
('Vladimir', 'Ilievski', 'Dermatologist', 15, TRUE),
('Kristina', 'Jovanovska', 'Psychiatrist', 10, FALSE),
('Bojan', 'Trajkovski', 'Orthopedic', 7, TRUE),
('Simona', 'Nikoloska', 'Oncologist', 9, TRUE),
('Goran', 'Stefanovski', 'Endocrinologist', 6, TRUE),
('Ivana', 'Georgieva', 'Gynecologist', 11, TRUE),
('Dejan', 'Tasevski', 'Radiologist', 13, TRUE),
('Marija', 'Popovska', 'Urologist', 4, TRUE),
('Petar', 'Ristovski', 'General Practitioner', 3, TRUE);

--creating reports first
INSERT INTO Report (report_id, report_type, summary, created_at, person_id) VALUES
(600, 'Medical', 'Kristina Mitrevska was treated for chronic conditions.', '2018-06-10', 6),
(601, 'Medical', 'Kristina Mitrevska follow-up before passing.', '2018-08-25', 6),
(602, 'Medical', 'Milena Jovanovska underwent regular checkup.', '2020-10-15', 7),
(603, 'Medical', 'Milena Jovanovska neurological review.', '2020-12-01', 7),
(604, 'Medical', 'Vladimir Cvetkov skin condition diagnosis.', '2019-11-20', 8),
(605, 'Medical', 'Vladimir Cvetkov respiratory infection treatment.', '2020-04-10', 8),
(606, 'Medical', 'Stefan Stefkovski pediatric exam.', '2020-08-01', 14);
--creating the medical reports
INSERT INTO MedicalReport (report_id, doctor_id, next_control_date) VALUES
(600, 1, '2018-09-01'),
(601, 2, NULL),
(602, 3, '2020-11-15'),
(603, 4, NULL),
(604, 1, NULL),
(605, 2, NULL),
(606, 3, NULL);
--now I need the diagnosis
INSERT INTO Diagnosis (diagnosis_id, short_description, therapy, is_chronic, severity) VALUES
(1, 'Hypertension', 'Lifestyle changes and antihypertensive medication', true, 'MEDIUM'),
(2, 'Anxiety', 'Cognitive behavioral therapy and anxiolytics', true, 'MEDIUM'),
(3, 'Type 2 Diabetes', 'Insulin therapy and dietary management', true, 'HIGH'),
(4, 'Seasonal Allergies', 'Antihistamines and avoiding allergens', false, 'LOW'),
(5, 'Psoriasis', 'Topical corticosteroids and light therapy', true, 'MEDIUM'),
(6, 'Heart Arrhythmia', 'Beta-blockers and possible ablation therapy', true, 'HIGH'),
(7, 'Bronchitis', 'Rest, fluids, and bronchodilators', false, 'MEDIUM'),
(8, 'Migraine', 'Analgesics and triptans', true, 'MEDIUM'),
(9, 'Delayed Growth', 'Nutritional support and hormone therapy', true, 'MEDIUM'),
(10, 'Gastritis', 'Antacids and dietary adjustments', false, 'LOW');
--then I insert them to table med_rep - diagnosis
INSERT INTO MedicalReport_Diagnosis (report_id, diagnosis_id) VALUES
(600, 1),
(600, 3),
(601, 6),
(602, 2),
(603, 8),
(604, 5),
(605, 7),
(606, 9);



--now some data for people who have medical report, but they are alive (not dead)
-- Reports for Simona, Bojan, Goran, Leon, Vladislav, Klara
INSERT INTO Report (report_id, report_type, summary, created_at, person_id) VALUES
(700, 'Medical', 'Simona Miloshevska diagnosed with asthma.', '2024-06-01', 5),
(701, 'Medical', 'Bojan Tasevski general checkup.', '2024-05-10', 9),
(702, 'Medical', 'Goran Naumovski diagnosed with elevated cholesterol.', '2024-06-08', 10),
(703, 'Medical', 'Leon Asanovski had seasonal allergies.', '2024-06-05', 11),
(704, 'Medical', 'Vladislav Nastovski routine checkup.', '2024-04-22', 12),
(705, 'Medical', 'Klara Volak pediatric evaluation.', '2024-06-12', 13);

INSERT INTO MedicalReport (report_id, doctor_id, next_control_date) VALUES
(700, 2, '2025-09-01'),
(701, 3, NULL),
(702, 1, '2025-12-01'),
(703, 4, '2025-08-01'),
(704, 1, NULL),
(705, 3, NULL);

INSERT INTO Diagnosis (diagnosis_id, short_description, therapy, is_chronic, severity) VALUES
(11, 'Asthma', 'Inhaled corticosteroids and bronchodilators', true, 'MEDIUM'),
(12, 'High Cholesterol', 'Dietary changes and statins', true, 'MEDIUM'),
(13, 'Seasonal Allergies', 'Antihistamines', false, 'LOW');

INSERT INTO MedicalReport_Diagnosis (report_id, diagnosis_id) VALUES
(700, 11),
(702, 12),
(703, 13);


