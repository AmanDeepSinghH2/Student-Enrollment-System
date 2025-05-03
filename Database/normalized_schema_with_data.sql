-- Students Table
CREATE TABLE Students (
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    StudentID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100) NOT NULL,
    Address VARCHAR(255),
    PhoneNumber VARCHAR(9),
    DOB DATE,
    Semester INT,
    EmailID VARCHAR(100) NOT NULL UNIQUE,
    Username VARCHAR(100) NOT NULL UNIQUE,
    PasswordHash VARCHAR(255) NOT NULL
);
-- 1NF: Atomic fields (split names, phones, etc.)
-- 2NF: No partial dependencies (only one key: StudentID)
-- 3NF: Removed multivalued phone numbers (Mother/Father) to separate table

CREATE TABLE StudentParents (
    ParentID INT PRIMARY KEY AUTO_INCREMENT,
    StudentID INT,
    ParentType ENUM('Mother', 'Father'),
    PhoneNumber VARCHAR(9),
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID)
);
-- 1NF: Atomic parent info
-- 2NF & 3NF: No transitive dependencies; clean referencing

-- Faculty Table
CREATE TABLE Faculty (
    FacultyID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100) NOT NULL,
    PhoneNumber VARCHAR(9),
    DOB DATE,
    EmailID VARCHAR(100) NOT NULL UNIQUE,
    Username VARCHAR(100) NOT NULL UNIQUE,
    PasswordHash VARCHAR(255) NOT NULL
);
-- 1NF: Atomic fields
-- 2NF: Single-key table
-- 3NF: Removed FacultyClasses into Course-Faculty relationship table

-- Courses Table
CREATE TABLE Courses (
    CourseID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100) NOT NULL
);

-- Mapping Table for Course-Faculty
CREATE TABLE CourseFaculty (
    ID INT PRIMARY KEY AUTO_INCREMENT,
    CourseID INT,
    FacultyID INT,
    FOREIGN KEY (CourseID) REFERENCES Courses(CourseID),
    FOREIGN KEY (FacultyID) REFERENCES Faculty(FacultyID)
);
-- 1NF, 2NF, 3NF satisfied

-- Enrollments Table
CREATE TABLE Enrollments (
    EnrollmentID INT PRIMARY KEY AUTO_INCREMENT,
    StudentID INT,
    Status ENUM('Pending', 'Enrolled'),
    EnrollmentDate DATE,
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID)
);
-- 3NF: No transitive dependencies

-- Grades Table
CREATE TABLE Grades (
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    GradeID INT PRIMARY KEY AUTO_INCREMENT,
    StudentID INT NOT NULL,
    CourseID INT NOT NULL,
    Grade VARCHAR(2) NOT NULL CHECK (Grade IN ('A+', 'A', 'B+', 'B', 'C+', 'C', 'D', 'F')),
    GradeDate DATE,
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
    FOREIGN KEY (CourseID) REFERENCES Courses(CourseID),
    UNIQUE (StudentID, CourseID)
);
-- Normalized to 3NF: all dependencies directly relate to primary key

-- Views
CREATE VIEW EnrollmentDetails AS
SELECT 
    e.EnrollmentID,
    s.Name AS StudentName,
    e.Status,
    e.EnrollmentDate
FROM Enrollments e
JOIN Students s ON e.StudentID = s.StudentID;
-- View derived from 3NF tables

CREATE VIEW CourseDetails AS
SELECT 
    c.CourseID,
    c.Name AS CourseName,
    f.Name AS FacultyName,
    f.PhoneNumber
FROM Courses c
JOIN CourseFaculty cf ON c.CourseID = cf.CourseID
JOIN Faculty f ON cf.FacultyID = f.FacultyID;
-- View normalized via join tabl

-- Users Table for authentication (removed)
-- CREATE TABLE Users (
--     UserID INT PRIMARY KEY AUTO_INCREMENT,
--     Username VARCHAR(100) NOT NULL UNIQUE,
--     PasswordHash VARCHAR(255) NOT NULL,
--     Role ENUM('student', 'faculty', 'admin') NOT NULL DEFAULT 'student',
--     CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
-- );
