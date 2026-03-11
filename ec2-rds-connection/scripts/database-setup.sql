-- Database Setup 

--Create Database

CREATE DATABASE SchoolDB;

--Verify creation:
SHOW DATABASES;


-- Create Table 

USE SchoolDB ;


CREATE TABLE IF NOT EXISTS subjects (subject_id INT AUTO_INCREMENT,subject_name VARCHAR(255) NOT NULL,teacher VARCHAR(255),start_date DATE,lesson TEXT,PRIMARY KEY (subject_id)) ENGINE=INNODB;

-- Insert some details into the table:**

INSERT INTO subjects(subject_name, teacher) VALUES ('English', 'John Taylor');
INSERT INTO subjects(subject_name, teacher) VALUES ('Science', 'Mary Smith');
INSERT INTO subjects(subject_name, teacher) VALUES ('Maths', 'Ted Miller');
INSERT INTO subjects(subject_name, teacher) VALUES ('Arts', 'Suzan Carpenter');
```

--Let's check the items we added into the table:

select * from subjects;

