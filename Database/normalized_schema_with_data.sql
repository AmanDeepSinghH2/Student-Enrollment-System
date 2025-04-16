
-- Students Table
CREATE TABLE Students (
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    StudentID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100) NOT NULL,
    Address VARCHAR(255),
    PhoneNumber VARCHAR(15),
    DOB DATE,
    Semester INT
);
-- 1NF: Atomic fields (split names, phones, etc.)
-- 2NF: No partial dependencies (only one key: StudentID)
-- 3NF: Removed multivalued phone numbers (Mother/Father) to separate table

CREATE TABLE StudentParents (
    ParentID INT PRIMARY KEY AUTO_INCREMENT,
    StudentID INT,
    ParentType ENUM('Mother', 'Father'),
    PhoneNumber VARCHAR(15),
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID)
);
-- 1NF: Atomic parent info
-- 2NF & 3NF: No transitive dependencies; clean referencing

-- Faculty Table
CREATE TABLE Faculty (
    FacultyID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100) NOT NULL,
    PhoneNumber VARCHAR(15),
    DOB DATE
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
    Status VARCHAR(50),
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
-- View normalized via join tables

-- Trigger
DELIMITER $$
CREATE TRIGGER after_insert_students
AFTER INSERT ON Students
FOR EACH ROW
BEGIN
    INSERT INTO StudentParents (StudentID, ParentType, PhoneNumber)
    VALUES (NEW.StudentID, 'Mother', '0000000000'),
           (NEW.StudentID, 'Father', '0000000000');
END$$
DELIMITER ;
-- Trigger adheres to 3NF structure and separates concern

-- Insert sample data (10 rows each table)

-- Students
INSERT INTO Students (Name, Address, PhoneNumber, DOB, Semester) VALUES
('Alice Johnson', '123 Apple St', '9123456789', '2001-05-21', 2),
('Bob Smith', '234 Banana Ave', '9234567890', '2002-08-12', 3),
('Carol Lee', '345 Cherry Blvd', '9345678901', '2000-11-30', 1),
('David Kim', '456 Date Dr', '9456789012', '2003-02-15', 4),
('Eva Chen', '567 Elder Rd', '9567890123', '2001-07-07', 5),
('Frank Roy', '678 Fig Ln', '9678901234', '2002-03-17', 6),
('Grace Lin', '789 Grape Ct', '9789012345', '2003-01-09', 7),
('Henry Liu', '890 Honey St', '9890123456', '2001-06-25', 8),
('Ivy Wong', '901 Ivy Way', '9901234567', '2000-10-10', 2),
('Jack Zhou', '1010 Jack Rd', '9012345678', '2002-04-18', 3);

-- Parents
INSERT INTO StudentParents (StudentID, ParentType, PhoneNumber) VALUES
(1, 'Mother', '8000000001'), (1, 'Father', '8000000002'),
(2, 'Mother', '8000000003'), (2, 'Father', '8000000004'),
(3, 'Mother', '8000000005'), (3, 'Father', '8000000006'),
(4, 'Mother', '8000000007'), (4, 'Father', '8000000008'),
(5, 'Mother', '8000000009'), (5, 'Father', '8000000010');

-- Faculty
INSERT INTO Faculty (Name, PhoneNumber, DOB) VALUES
('Dr. Green', '9876543210', '1975-03-12'),
('Dr. Brown', '9765432109', '1980-06-23'),
('Dr. White', '9654321098', '1985-08-19'),
('Dr. Black', '9543210987', '1972-12-01'),
('Dr. Blue', '9432109876', '1990-07-14'),
('Dr. Red', '9321098765', '1978-11-11'),
('Dr. Gray', '9210987654', '1983-05-22'),
('Dr. Pink', '9109876543', '1976-09-05'),
('Dr. Orange', '9008765432', '1982-02-28'),
('Dr. Purple', '8897654321', '1988-04-04');

-- Courses
INSERT INTO Courses (Name) VALUES
('Math'), ('Physics'), ('Chemistry'), ('Biology'), ('History'),
('English'), ('Computer Science'), ('Economics'), ('Psychology'), ('Philosophy');

-- Course-Faculty
INSERT INTO CourseFaculty (CourseID, FacultyID) VALUES
(1, 1), (2, 2), (3, 3), (4, 4), (5, 5),
(6, 6), (7, 7), (8, 8), (9, 9), (10, 10);

-- Enrollments
INSERT INTO Enrollments (StudentID, Status, EnrollmentDate) VALUES
(1, 'Active', '2024-01-10'), (2, 'Active', '2024-01-11'),
(3, 'Inactive', '2023-09-12'), (4, 'Active', '2024-01-15'),
(5, 'Active', '2024-02-20'), (6, 'Inactive', '2023-10-01'),
(7, 'Active', '2024-03-03'), (8, 'Active', '2024-03-10'),
(9, 'Inactive', '2023-08-05'), (10, 'Active', '2024-04-01');

-- Grades
INSERT INTO Grades (StudentID, CourseID, Grade, GradeDate) VALUES
(1, 1, 'A', '2024-03-10'), (2, 2, 'B+', '2024-03-11'),
(3, 3, 'C', '2024-03-12'), (4, 4, 'B', '2024-03-13'),
(5, 5, 'A+', '2024-03-14'), (6, 6, 'C+', '2024-03-15'),
(7, 7, 'B+', '2024-03-16'), (8, 8, 'D', '2024-03-17'),
(9, 9, 'F', '2024-03-18'), (10, 10, 'A', '2024-03-19');
