CREATE TABLE ReportiumUser (
    user_id SERIAL PRIMARY KEY,
    name varchar(30) NOT NULL,
    surname varchar(30) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

--roles
CREATE TABLE Role (
    role_id SERIAL PRIMARY KEY,
    role_name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT
);

--user profile
CREATE TABLE UserProfile (
    profile_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES ReportiumUser (user_id) ON DELETE CASCADE,
    role_id INT NOT NULL REFERENCES Role(role_id) ON DELETE RESTRICT,
    username VARCHAR(100),
    profile_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

--function that allows creating profile when a user registers to the system
CREATE FUNCTION create_profile_automatically_when_user_comes() RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO UserProfile (user_id, role_id, username)
    VALUES (NEW.user_id, 2, NEW.name || ' ' || NEW.surname);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_create_profile_for_user
AFTER INSERT ON ReportiumUser
FOR EACH ROW
EXECUTE FUNCTION create_profile_automatically_when_user_comes();

INSERT INTO Role (role_name, description)
VALUES
    ('ADMIN', 'Administrator with full access to all features'),
    ('USER', 'Regular user with limited access');

--password is #Admin123
insert into ReportiumUser (name, surname, email, password_hash) values ('Leon',
                                                                 'Asanovski',
                                                                 'leonasanovski@gmail.com',
                                                                 '$2a$12$K6nU72I.HFRDCQEqhF6GPOxZ7KaF6tnEaPvbdGAT8j1yvYPc/yW5y');


--I will see what to do with this
--TODO
CREATE TABLE UserProfileLog (
    log_id SERIAL PRIMARY KEY,
    profile_id INT NOT NULL REFERENCES UserProfile(profile_id) ON DELETE CASCADE,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    change_description TEXT
);


--Admin -> leonasanovski@gmail.com #Admin123
--User -> saraasanovska@gmail.com #Sara123