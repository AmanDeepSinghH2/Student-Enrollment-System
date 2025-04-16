CREATE DATABASE IF NOT EXISTS Enroll;
USE Enroll;


CREATE TABLE Students (
    StudentID INT PRIMARY KEY AUTO_INCREMENT,  -- Unique student ID
    Name VARCHAR(100) NOT NULL,                -- Replaced 'Names' with 'Name' for clarity
    Address VARCHAR(255),
    PhoneNumber VARCHAR(15),
    MotherPhoneNumber VARCHAR(15),
    FatherPhoneNumber VARCHAR(15),
    DateOfBirth DATE,
    Semester INT,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
/*
 Changes from original:
- Atomic attributes (1NF): Name, PhoneNumbers, and Address are all single-valued.
- Removed direct dependency of students on enrollments by separating into a dedicated table.
*/

CREATE TABLE Faculty (
    FacultyID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100) NOT NULL,
    PhoneNumber VARCHAR(15),
    DateOfBirth DATE
);
/*
 Changes from original:
- Removed 'FacultyClasses' (was a comma-separated list = not atomic).
- Teaching responsibilities are now handled through the Courses table, creating a proper one-to-many relationship.
*/


CREATE TABLE Courses (
    CourseID INT PRIMARY KEY AUTO_INCREMENT,
    CourseName VARCHAR(100) NOT NULL,
    FacultyID INT, -- Links course to its instructor
    FOREIGN KEY (FacultyID) REFERENCES Faculty(FacultyID)
);
/*
 Changes from original:
- Courses now linked to Faculty via foreign key rather than string description.
- Eliminates redundancy and inconsistency in assigning faculty.
*/

CREATE TABLE Enrollments (
    EnrollmentID INT PRIMARY KEY AUTO_INCREMENT,
    StudentID INT NOT NULL,
    CourseID INT NOT NULL,
    Status VARCHAR(50), -- e.g., Pending, Enrolled, Completed
    EnrollmentDate DATE,
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
    FOREIGN KEY (CourseID) REFERENCES Courses(CourseID)
);
/*
 Changes from original:
- This table now acts as a proper bridge (many-to-many) between Students and Courses.
- Earlier, enrollments were not tied to specific courses, making them meaningless.
- Now we can track which student is in which course and their enrollment status.
*/


CREATE TABLE Grades (
    GradeID INT PRIMARY KEY AUTO_INCREMENT,
    StudentID INT NOT NULL,
    CourseID INT NOT NULL,
    Grade VARCHAR(2) NOT NULL CHECK (Grade IN ('A+', 'A', 'B+', 'B', 'C+', 'C', 'D', 'F')),
    GradeDate DATE,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
    FOREIGN KEY (CourseID) REFERENCES Courses(CourseID),
    UNIQUE (StudentID, CourseID) -- Ensures no duplicate grades for same course
);
/*
 Changes from original:
- Links grades to specific student-course pairs.
- Removed redundancy (grades were previously not normalized).
- Ensures single grade per student per course using UNIQUE constraint.
*/


CREATE VIEW StudentEnrollmentDetails AS
SELECT 
    e.EnrollmentID,
    s.Name AS StudentName,
    c.CourseName,
    f.Name AS FacultyName,
    e.Status,
    e.EnrollmentDate
FROM Enrollments e
JOIN Students s ON e.StudentID = s.StudentID
JOIN Courses c ON e.CourseID = c.CourseID
JOIN Faculty f ON c.FacultyID = f.FacultyID;

CREATE VIEW CourseDetails AS
SELECT 
    c.CourseID,
    c.CourseName,
    f.Name AS FacultyName,
    f.PhoneNumber AS FacultyPhone
FROM Courses c
JOIN Faculty f ON c.FacultyID = f.FacultyID;
/*
 Views added:
- For simplified querying of student-course-faculty relationships.
- Keep complex joins out of application code.
*/

