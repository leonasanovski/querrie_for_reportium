--enumeration - type of institution
CREATE TYPE institution_type AS ENUM ('Primary School', 'High School', 'University', 'Academy');
--institution entity table
CREATE TABLE Institution (
    institution_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address VARCHAR(100),
    city VARCHAR(50),
    type institution_type NOT NULL,
    year_established INT CHECK (year_established >= 1800 AND year_established <= EXTRACT(YEAR FROM CURRENT_DATE)),
	CONSTRAINT unique_institution_name_city UNIQUE (name, city)
);

--functions for triggers:
--function for capitalizing city and name of the institution
CREATE OR REPLACE FUNCTION format_institution_fields()
RETURNS TRIGGER AS $$
BEGIN
    NEW.name := INITCAP(NEW.name);
    NEW.city := INITCAP(NEW.city);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
--function for validating year
CREATE OR REPLACE FUNCTION validate_institution_year()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.year_established > EXTRACT(YEAR FROM CURRENT_DATE) THEN
        RAISE EXCEPTION 'Institution cannot be established in the future.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
--trigger1
CREATE TRIGGER trg_validate_year_established
BEFORE INSERT OR UPDATE ON Institution
FOR EACH ROW
EXECUTE FUNCTION validate_institution_year();
--trigger2
CREATE TRIGGER trg_format_institution_fields
BEFORE INSERT OR UPDATE ON Institution
FOR EACH ROW
EXECUTE FUNCTION format_institution_fields();

INSERT INTO Institution (name, address, city, type, year_established)
VALUES
--primary schools
('OOU Ljuben Lape', 'Ul. Jane Sandanski bb', 'Skopje', 'Primary School', 1986),
('OOU Koco Racin', 'Mladinska bb', 'Bitola', 'Primary School', 1975),
('OOU Goce Delcev', 'Goce Delcev bb', 'Kumanovo', 'Primary School', 1968),
('OOU Goce Delcev', 'ul. Gratski Dzid', 'Skopje', 'Primary School', 1993),
--high schools
('SUGS Rade Jovchevski Korchagin', 'Partizanski Odredi bb', 'Skopje', 'High School', 1957),
('SUGS Orce Nikolov', 'Ul. Marsal Tito 77', 'Strumica', 'High School', 1965),
('SOU Josip Broz Tito', 'Blvd. Goce Delcev', 'Bitola', 'High School', 1970),
('Yahya Kemal', 'Ul. Varsavska 23', 'Skopje', 'High School', 1996),
--universities
('Ss. Cyril and Methodius University', 'Blvd. Goce Delcev bb', 'Skopje', 'University', 1949),
('St. Clement of Ohrid University', 'Partizanska bb', 'Bitola', 'University', 1979),
('Goce Delchev University', 'Krste Misirkov bb', 'Shtip', 'University', 2007),
('South East European University', 'Ilindenska bb', 'Tetovo', 'University', 2001),
--academies
('Faculty of Dramatic Arts - UKIM', 'Goce Delchev bb', 'Skopje', 'Academy', 1969),
('Faculty of Music Arts - UKIM', 'Ilindenska bb', 'Skopje', 'Academy', 1966),
('Faculty of Fine Arts - UKIM', 'Partizanski Odredi bb', 'Skopje', 'Academy', 1972),
('Brainster Academy', 'ul. Vasil Gjorgov', 'Skopje', 'Academy', 2015);
