




--academic reports creating entity
CREATE TABLE AcademicReport (
    report_id INT PRIMARY KEY,
    institution_id INT NOT NULL,
    academic_field VARCHAR(100),
    description_of_report TEXT,
    CONSTRAINT fk_report_id FOREIGN KEY (report_id) REFERENCES Report(report_id) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT fk_institution_id FOREIGN KEY (institution_id) REFERENCES Institution(institution_id) ON DELETE CASCADE ON UPDATE CASCADE
);

--this function ensures that the id used to create this report is for academic report1
CREATE OR REPLACE FUNCTION validate_academic_report()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Report WHERE report_id = NEW.report_id AND report_type = 'Academic')
	THEN
    	RAISE EXCEPTION 'Report with ID % is not of type Academic!', NEW.report_id;
	END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
--the trigger1
CREATE TRIGGER trg_check_academic_report_correctness
BEFORE INSERT ON AcademicReport
FOR EACH ROW
EXECUTE FUNCTION validate_academic_report();

--function to check if the age is correct so the person can go or went in the right age at the type of school2
CREATE OR REPLACE FUNCTION validate_academic_age_for_institution()
RETURNS TRIGGER AS $$
DECLARE
    institution_type institution_type;
    person_birth_date DATE;
    report_date DATE;
    person_age INT;
    pers_id INT;
BEGIN
    -- get institution type
    SELECT type INTO institution_type
    FROM Institution
    WHERE institution_id = NEW.institution_id;
    -- get person's birth date and report date
    SELECT p.date_of_birth, r.created_at
    INTO person_birth_date, report_date
    FROM Report r
    JOIN Person p ON r.person_id = p.person_id
    WHERE r.report_id = NEW.report_id;
    -- get person_id for message
    SELECT r.person_id INTO pers_id
    FROM Report r
    WHERE r.report_id = NEW.report_id;
    -- calculate age
    person_age := DATE_PART('year', age(report_date, person_birth_date));
    -- validations
    IF institution_type = 'Primary School' AND (person_age < 5 OR person_age > 16) THEN
        RAISE EXCEPTION 'Person with ID % is not within valid age range for Primary School (actual: %)', pers_id, person_age;
    ELSIF institution_type = 'High School' AND (person_age < 14 OR person_age > 19) THEN
        RAISE EXCEPTION 'Person with ID % is not within valid age range for High School (actual: %)', pers_id, person_age;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
--trigger2
CREATE TRIGGER trg_validate_academic_report_person_age
BEFORE INSERT ON AcademicReport
FOR EACH ROW
EXECUTE FUNCTION validate_academic_age_for_institution();


--function and trigger for preventing academic reports after persons death3
CREATE OR REPLACE FUNCTION prevent_academic_reports_after_death()
RETURNS TRIGGER AS $$
DECLARE
    death_date DATE;
    is_dead BOOLEAN;
    type_check VARCHAR;
BEGIN
    SELECT date_of_death, is_alive INTO death_date, is_dead FROM Person WHERE person_id = NEW.person_id;
    IF NEW.report_type = 'Academic' THEN
        IF is_dead = false AND death_date IS NOT NULL AND NEW.created_at > death_date THEN
            RAISE EXCEPTION
                'Cannot create academic report for deceased person (death: %, report date: %)',
                death_date, NEW.created_at;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
--trigger3
CREATE TRIGGER trg_prevent_academic_report_after_death
BEFORE INSERT ON Report
FOR EACH ROW
EXECUTE FUNCTION prevent_academic_reports_after_death();

--filling the tables
INSERT INTO Report (report_id, report_type, summary, created_at, person_id) VALUES
(201, 'Academic', 'Stefan Ristovski - started Primary School', '1996-09-01', 1),
(202, 'Academic', 'Stefan Ristovski - finished Primary School', '2005-06-10', 1),
(203, 'Academic', 'Stefan Ristovski - started High School', '2005-09-01', 1),
(204, 'Academic', 'Stefan Ristovski - finished High School', '2009-06-10', 1),
(205, 'Academic', 'Stefan Ristovski - started University studies at FINKI', '2009-10-01', 1),
(206, 'Academic', 'Stefan Ristovski - finished University studies at FINKI', '2014-06-10', 1),

(207, 'Academic', 'Teodora Ilievska - started Primary School', '1994-09-01', 2),
(208, 'Academic', 'Teodora Ilievska - finished Primary School', '2003-06-10', 2),
(209, 'Academic', 'Teodora Ilievska - started High School', '2003-09-01', 2),
(210, 'Academic', 'Teodora Ilievska - finished High School', '2007-06-10', 2),
(211, 'Academic', 'Teodora Ilievska - started Academy for Visual Arts', '2007-10-01', 2),
(212, 'Academic', 'Teodora Ilievska - finished Academy for Visual Arts', '2009-06-10', 2),

(213, 'Academic', 'Aleksandar Kostov - started Primary School', '1999-09-01', 3),
(214, 'Academic', 'Aleksandar Kostov - finished Primary School', '2008-06-10', 3),
(215, 'Academic', 'Aleksandar Kostov - started High School', '2008-09-01', 3),
(216, 'Academic', 'Aleksandar Kostov - finished High School', '2012-06-10', 3),
(217, 'Academic', 'Aleksandar Kostov - started University studies', '2012-10-01', 3),
(218, 'Academic', 'Aleksandar Kostov - finished University studies', '2017-06-10', 3),

(219, 'Academic', 'Filip Zdravkovski - started Primary School', '2003-09-01', 4),
(220, 'Academic', 'Filip Zdravkovski - finished Primary School', '2012-06-10', 4),
(221, 'Academic', 'Filip Zdravkovski - started High School', '2012-09-01', 4),
(222, 'Academic', 'Filip Zdravkovski - finished High School', '2016-06-10', 4),
(223, 'Academic', 'Filip Zdravkovski - started Academy for Film', '2016-10-01', 4),
(224, 'Academic', 'Filip Zdravkovski - finished Academy for Film', '2018-06-10', 4),

(225, 'Academic', 'Simona Miloshevska - started Primary School', '2007-09-01', 5),
(226, 'Academic', 'Simona Miloshevska - finished Primary School', '2016-06-10', 5),
(227, 'Academic', 'Simona Miloshevska - started High School', '2016-09-01', 5),
(228, 'Academic', 'Simona Miloshevska - finished High School', '2020-06-10', 5),

(229, 'Academic', 'Kristina Mitrevska - started Primary School', '1983-09-01', 6),
(230, 'Academic', 'Kristina Mitrevska - finished Primary School', '1992-06-10', 6),
(231, 'Academic', 'Kristina Mitrevska - started High School', '1992-09-01', 6),
(232, 'Academic', 'Kristina Mitrevska - finished High School', '1996-06-10', 6),
(233, 'Academic', 'Kristina Mitrevska - started University studies at Psychology', '1996-10-01', 6),
(234, 'Academic', 'Kristina Mitrevska - finished University studies at Psychology', '2001-06-10', 6),

(235, 'Academic', 'Milena Jovanovska - started Primary School', '1992-09-01', 7),
(236, 'Academic', 'Milena Jovanovska - finished Primary School', '2001-06-10', 7),
(237, 'Academic', 'Milena Jovanovska - started High School', '2001-09-01', 7),
(238, 'Academic', 'Milena Jovanovska - finished High School', '2005-06-10', 7),
(239, 'Academic', 'Milena Jovanovska - started Academy for Acting', '2005-10-01', 7),
(240, 'Academic', 'Milena Jovanovska - finished Academy for Acting', '2007-06-10', 7),

(241, 'Academic', 'Vladimir Cvetkov - started Primary School', '1986-09-01', 8),
(242, 'Academic', 'Vladimir Cvetkov - finished Primary School', '1995-06-10', 8),
(243, 'Academic', 'Vladimir Cvetkov - started High School', '1995-09-01', 8),
(244, 'Academic', 'Vladimir Cvetkov - finished High School', '1999-06-10', 8),
(245, 'Academic', 'Vladimir Cvetkov - started University studies', '1999-10-01', 8),
(246, 'Academic', 'Vladimir Cvetkov - finished University studies', '2004-06-10', 8),

(247, 'Academic', 'Bojan Tasevski - started Primary School', '1997-09-01', 9),
(248, 'Academic', 'Bojan Tasevski - finished Primary School', '2006-06-10', 9),
(249, 'Academic', 'Bojan Tasevski - started High School', '2006-09-01', 9),
(250, 'Academic', 'Bojan Tasevski - finished High School', '2010-06-10', 9),
(251, 'Academic', 'Bojan Tasevski - started University studies', '2010-10-01', 9),
(252, 'Academic', 'Bojan Tasevski - finished University studies', '2015-06-10', 9),

(253, 'Academic', 'Goran Naumovski - started Primary School', '1986-09-01', 10),
(254, 'Academic', 'Goran Naumovski - finished Primary School', '1995-06-10', 10),
(255, 'Academic', 'Goran Naumovski - started High School', '1995-09-01', 10),
(256, 'Academic', 'Goran Naumovski - finished High School', '1999-06-10', 10),
(257, 'Academic', 'Goran Naumovski - started Academy for IT', '1999-10-01', 10),
(258, 'Academic', 'Goran Naumovski - finished Academy for IT', '2001-06-10', 10),

(259, 'Academic', 'Leon Asanovski - started Primary School', '2009-09-01', 11),
(260, 'Academic', 'Leon Asanovski - finished Primary School', '2018-06-10', 11),
(261, 'Academic', 'Leon Asanovski - started High School', '2018-09-01', 11),
(262, 'Academic', 'Leon Asanovski - finished High School', '2022-06-10', 11),
(263, 'Academic', 'Leon Asanovski - started University at FINKI', '2022-10-02', 11),

(264, 'Academic', 'Vladislav Nastovski - started Primary School', '1978-09-01', 12),
(265, 'Academic', 'Vladislav Nastovski - finished Primary School', '1987-06-10', 12),
(266, 'Academic', 'Vladislav Nastovski - started High School', '1987-09-01', 12),
(267, 'Academic', 'Vladislav Nastovski - finished High School', '1991-06-10', 12),
(268, 'Academic', 'Vladislav Nastovski - started University studies at FEIT', '1991-10-01', 12),
(269, 'Academic', 'Vladislav Nastovski - finished University studies at FEIT', '1996-06-10', 12),

(270, 'Academic', 'Klara Volak - started Primary School', '2009-09-01', 13),
(271, 'Academic', 'Klara Volak - finished Primary School', '2018-06-10', 13),
(272, 'Academic', 'Klara Volak - started High School', '2018-09-01', 13),
(273, 'Academic', 'Klara Volak - finished High School', '2022-06-10', 13),
(274, 'Academic', 'Klara Volak - started University at FINKI', '2022-10-02', 11),

(275, 'Academic', 'Stefan Stefkovski - started Primary School', '2011-09-01', 14),
(276, 'Academic', 'Stefan Stefkovski - finished Primary School', '2020-06-10', 14),
(277, 'Academic', 'Stefan Stefkovski - started High School', '2020-09-01', 14);


INSERT INTO AcademicReport (report_id, institution_id, academic_field, description_of_report) VALUES
(201, 1, 'General Education', 'Started primary school at OOU Ljuben Lape'),
(202, 1, 'General Education', 'Finished primary school at OOU Ljuben Lape'),
(203, 5, 'High School Studies', 'Started high school at SUGS Rade Jovchevski Korchagin'),
(204, 5, 'High School Studies', 'Finished high school at SUGS Rade Jovchevski Korchagin'),
(205, 9, 'Computer Science', 'Started university studies at FINKI'),
(206, 9, 'Computer Science', 'Finished university studies at FINKI'),

(207, 4, 'General Education', 'Started primary school at OOU Goce Delcev'),
(208, 4, 'General Education', 'Finished primary school at OOU Goce Delcev'),
(209, 6, 'High School Studies', 'Started high school at SUGS Orce Nikolov'),
(210, 6, 'High School Studies', 'Finished high school at SUGS Orce Nikolov'),
(211, 15, 'Visual Arts', 'Started academy for Visual Arts'),
(212, 15, 'Visual Arts', 'Finished academy for Visual Arts'),

(213, 2, 'General Education', 'Started primary school at OOU Koco Racin'),
(214, 2, 'General Education', 'Finished primary school at OOU Koco Racin'),
(215, 7, 'High School Studies', 'Started high school at SOU Josip Broz Tito'),
(216, 7, 'High School Studies', 'Finished high school at SOU Josip Broz Tito'),
(217, 11, 'Economics', 'Started university studies'),
(218, 11, 'Economics', 'Finished university studies'),

(219, 3, 'General Education', 'Started primary school at OOU Goce Delcev'),
(220, 3, 'General Education', 'Finished primary school at OOU Goce Delcev'),
(221, 8, 'High School Studies', 'Started high school at Yahya Kemal'),
(222, 8, 'High School Studies', 'Finished high school at Yahya Kemal'),
(223, 14, 'Film Studies', 'Started academy for Film'),
(224, 14, 'Film Studies', 'Finished academy for Film'),

(225, 1, 'General Education', 'Started primary school at OOU Ljuben Lape'),
(226, 1, 'General Education', 'Finished primary school at OOU Ljuben Lape'),
(227, 5, 'High School Studies', 'Started high school at SUGS Rade Jovchevski Korchagin'),
(228, 5, 'High School Studies', 'Finished high school at SUGS Rade Jovchevski Korchagin'),

(229, 3, 'General Education', 'Started primary school at OOU Goce Delcev'),
(230, 3, 'General Education', 'Finished primary school at OOU Goce Delcev'),
(231, 5, 'High School Studies', 'Started high school at SUGS Rade Jovchevski Korchagin'),
(232, 5, 'High School Studies', 'Finished high school at SUGS Rade Jovchevski Korchagin'),
(233, 9, 'Psychology', 'Started university studies at Psychology'),
(234, 9, 'Psychology', 'Finished university studies at Psychology'),

(235, 1, 'General Education', 'Started primary school at OOU Ljuben Lape'),
(236, 1, 'General Education', 'Finished primary school at OOU Ljuben Lape'),
(237, 6, 'High School Studies', 'Started high school at SUGS Orce Nikolov'),
(238, 6, 'High School Studies', 'Finished high school at SUGS Orce Nikolov'),
(239, 13, 'Acting', 'Started academy for Acting'),
(240, 13, 'Acting', 'Finished academy for Acting'),

(241, 2, 'General Education', 'Started primary school at OOU Koco Racin'),
(242, 2, 'General Education', 'Finished primary school at OOU Koco Racin'),
(243, 7, 'High School Studies', 'Started high school at SOU Josip Broz Tito'),
(244, 7, 'High School Studies', 'Finished high school at SOU Josip Broz Tito'),
(245, 10, 'Law', 'Started university studies'),
(246, 10, 'Law', 'Finished university studies'),

(247, 4, 'General Education', 'Started primary school at OOU Goce Delcev'),
(248, 4, 'General Education', 'Finished primary school at OOU Goce Delcev'),
(249, 5, 'High School Studies', 'Started high school at SUGS Rade Jovchevski Korchagin'),
(250, 5, 'High School Studies', 'Finished high school at SUGS Rade Jovchevski Korchagin'),
(251, 9, 'Software Engineering', 'Started university studies'),
(252, 9, 'Software Engineering', 'Finished university studies'),

(253, 3, 'General Education', 'Started primary school at OOU Goce Delcev'),
(254, 3, 'General Education', 'Finished primary school at OOU Goce Delcev'),
(255, 6, 'High School Studies', 'Started high school at SUGS Orce Nikolov'),
(256, 6, 'High School Studies', 'Finished high school at SUGS Orce Nikolov'),
(257, 16, 'IT Studies', 'Started academy for IT'),
(258, 16, 'IT Studies', 'Finished academy for IT'),

(259, 4, 'General Education', 'Started primary school at OOU Goce Delcev'),
(260, 4, 'General Education', 'Finished primary school at OOU Goce Delcev'),
(261, 8, 'High School Studies', 'Started high school at Yahya Kemal'),
(262, 8, 'High School Studies', 'Finished high school at Yahya Kemal'),
(263, 9, 'Computer Science', 'Started university at FINKI'),

(264, 2, 'General Education', 'Started primary school at OOU Koco Racin'),
(265, 2, 'General Education', 'Finished primary school at OOU Koco Racin'),
(266, 7, 'High School Studies', 'Started high school at SOU Josip Broz Tito'),
(267, 7, 'High School Studies', 'Finished high school at SOU Josip Broz Tito'),
(268, 9, 'Electrical Engineering', 'Started university at FEIT'),
(269, 9, 'Electrical Engineering', 'Finished university at FEIT'),

(270, 1, 'General Education', 'Started primary school at OOU Ljuben Lape'),
(271, 1, 'General Education', 'Finished primary school at OOU Ljuben Lape'),
(272, 5, 'High School Studies', 'Started high school at SUGS Rade Jovchevski Korchagin'),
(273, 5, 'High School Studies', 'Finished high school at SUGS Rade Jovchevski Korchagin'),
(274, 9, 'Computer Science', 'Started university at FINKI'),

(275, 2, 'General Education', 'Started primary school at OOU Koco Racin'),
(276, 2, 'General Education', 'Finished primary school at OOU Koco Racin'),
(277, 6, 'High School Studies', 'Started high school at SUGS Orce Nikolov');


