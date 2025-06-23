CREATE TABLE FilterSession (
    session_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES reportiumuser (user_id) ON DELETE CASCADE,
    filter_description TEXT NOT NULL,
    searched_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE ExportLog (
    export_id SERIAL PRIMARY KEY,
    session_id INT NOT NULL REFERENCES FilterSession(session_id) ON DELETE CASCADE,
    file_name VARCHAR(100) NOT NULL,
    filter_summary TEXT,
    export_format VARCHAR(20) default 'CSV' CHECK (export_format IN ('CSV', 'PDF')),
    export_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE ExportLog (
    export_id SERIAL PRIMARY KEY,
    session_id INT NOT NULL REFERENCES FilterSession(session_id) ON DELETE CASCADE,
    file_name VARCHAR(100) NOT NULL,
    filter_summary TEXT,
    export_format VARCHAR(20) default 'CSV' CHECK (export_format IN ('CSV', 'PDF')),
    export_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
UPDATE Person SET gender = UPPER(gender);
