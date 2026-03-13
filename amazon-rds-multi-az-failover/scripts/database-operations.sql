-- All SQL commands used
-- Create database
CREATE DATABASE auroro_db;
USE auroro_db;

-- Create table
CREATE TABLE students (
    subject_id INT AUTO_INCREMENT,
    subject_name VARCHAR(255) NOT NULL,
    teacher VARCHAR(255),
    start_date DATE,
    lesson TEXT,
    PRIMARY KEY (subject_id)
);

-- Insert data
INSERT INTO students(subject_name, teacher) VALUES 
    ('English', 'John Taylor'),
    ('Science', 'Mary Smith'),
    ('Maths', 'Ted Miller'),
    ('Arts', 'Suzan Carpenter');