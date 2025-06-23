--function for validating embg format
CREATE OR REPLACE FUNCTION validate_embg_format()
RETURNS TRIGGER AS $$
DECLARE
    date_part TEXT;
    gender_code TEXT;
BEGIN
    date_part := TO_CHAR(NEW.date_of_birth, 'DD')
	|| TO_CHAR(NEW.date_of_birth, 'MM')
	|| RIGHT(TO_CHAR(EXTRACT(YEAR FROM NEW.date_of_birth)::INT,'9999'),3);
	--this is going to fetch the last 3 digits from the year
	--example: if it is 1990 -> it fetches 990
    IF SUBSTRING(NEW.embg FROM 1 FOR 7) <> date_part THEN
        RAISE EXCEPTION 'EMBG date part does not match the date of birth!';
    END IF;
	--gender check
    gender_code := SUBSTRING(NEW.embg FROM 8 FOR 3);
    IF (NEW.gender = 'Male' AND gender_code <> '450') OR
       (NEW.gender = 'Female' AND gender_code <> '455') THEN
        RAISE EXCEPTION 'EMBG gender code does not match gender!';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


--this is the trigger that checks the embg
CREATE TRIGGER check_embg_format
BEFORE INSERT OR UPDATE ON Person
FOR EACH ROW
EXECUTE FUNCTION validate_embg_format();


--functions for alive status
CREATE OR REPLACE FUNCTION alive_status_check()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.date_of_death IS NOT NULL THEN
        NEW.is_alive := FALSE;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--trigger for alive status
CREATE TRIGGER alive_status_check
BEFORE INSERT OR UPDATE ON Person
FOR EACH ROW
EXECUTE FUNCTION alive_status_check();

--enumeration for gender
CREATE TYPE gender_enum AS ENUM ('Male','Female');
--entity for Person with all the attributes
CREATE TABLE Person(
	person_id SERIAL PRIMARY KEY,
	embg varchar(16) UNIQUE NOT NULL,
	name varchar(50) NOT NULL,
	surname varchar(50) NOT NULL,
	gender gender_enum NOT NULL,
	date_of_birth date NOT NULL,
	is_alive BOOLEAN DEFAULT TRUE,
    date_of_death DATE,
	address varchar(80) NOT NULL,
	contact_phone varchar(20) NOT NULL
);


--alive are with null on date_of_death and dead are with value there
INSERT INTO Person (embg, name, surname, gender, date_of_birth, date_of_death, address, contact_phone) VALUES
('0503990450032', 'Stefan', 'Ristovski', 'Male', '1990-03-05', NULL, 'Karposh 4, Skopje, Macedonia', '071123456'),
('1812988455101', 'Teodora', 'Ilievska', 'Female', '1988-12-18', NULL, 'Trpejca, Ohrid, Macedonia', '072654321'),
('2304993450345', 'Aleksandar', 'Kostov', 'Male', '1993-04-23', NULL, 'Bitola, Macedonia', '078222333'),
('1408997450654', 'Filip', 'Zdravkovski', 'Male', '1997-08-14', NULL, 'Veles, Macedonia', '077445566'),
('2007001455534', 'Simona', 'Miloshevska', 'Female', '2001-07-20', NULL, 'Negotino, Macedonia', '076556677'),
('1006977455742', 'Kristina', 'Mitrevska', 'Female', '1977-06-10', '2018-09-19', 'Kumanovo, Macedonia', '070112233'),
('2701986455119', 'Milena', 'Jovanovska', 'Female', '1986-01-27', '2021-01-13', 'Struga, Macedonia', '079778899'),
('0605980450722', 'Vladimir', 'Cvetkov', 'Male', '1980-05-06', '2020-06-22', 'Prilep, Macedonia', '074334455'),
('0904991450097', 'Bojan', 'Tasevski', 'Male', '1991-04-09', NULL, 'Kavadarci, Macedonia', '071998877'),
('3110980450451', 'Goran', 'Naumovski', 'Male', '1980-10-31', NULL, 'Tetovo, Macedonia', '075223344'),
('1104003450027', 'Leon', 'Asanovski', 'Male', '2003-04-11', NULL, 'Aerodrom, Skopje, Macedonia', '074584632'),
('2406972450231', 'Vladislav', 'Nastovski', 'Male', '1972-06-24', NULL, 'Novo Lisice, Skopje, Macedonia', '072548987'),
('1003003455218', 'Klara', 'Volak', 'Female', '2003-03-10', NULL, 'Karposh 3, Skopje, Macedonia', '071458710'),
('2308005450687', 'Stefan', 'Stefkovski', 'Male', '2005-08-23', '2021-06-29', 'Makedonski Brod, Macedonia', '078954125');



