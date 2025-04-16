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
 Normalization:
- 1NF: Atomic attributes (Name, PhoneNumbers, Address are single-valued).
- 2NF: No partial dependency as StudentID is the primary key and all attributes depend on it.
- 3NF: No transitive dependency; all non-key attributes depend only on the primary key.
*/

CREATE TABLE Faculty (
    FacultyID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100) NOT NULL,
    PhoneNumber VARCHAR(15),
    DateOfBirth DATE
);
/*
 Normalization:
- 1NF: Atomic attributes (Name, PhoneNumber are single-valued).
- 2NF: No partial dependency as FacultyID is the primary key and all attributes depend on it.
- 3NF: No transitive dependency; all non-key attributes depend only on the primary key.
*/

CREATE TABLE Courses (
    CourseID INT PRIMARY KEY AUTO_INCREMENT,
    CourseName VARCHAR(100) NOT NULL,
    FacultyID INT, -- Links course to its instructor
    FOREIGN KEY (FacultyID) REFERENCES Faculty(FacultyID)
);
/*
 Normalization:
- 1NF: Atomic attributes (CourseName is single-valued).
- 2NF: No partial dependency as CourseID is the primary key and all attributes depend on it.
- 3NF: No transitive dependency; FacultyID is a foreign key, not a derived attribute.
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
 Normalization:
- 1NF: Atomic attributes (Status, EnrollmentDate are single-valued).
- 2NF: No partial dependency as EnrollmentID is the primary key and all attributes depend on it.
- 3NF: No transitive dependency; StudentID and CourseID are foreign keys, not derived attributes.
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
 Normalization:
- 1NF: Atomic attributes (Grade, GradeDate are single-valued).
- 2NF: No partial dependency as GradeID is the primary key and all attributes depend on it.
- 3NF: No transitive dependency; StudentID and CourseID are foreign keys, not derived attributes.
*/
-- Insert values into Students table
INSERT INTO Students (Name, Address, PhoneNumber, MotherPhoneNumber, FatherPhoneNumber, DateOfBirth, Semester) VALUES
('Alice Johnson', '123 Elm St', '1234567890', '9876543210', '8765432109', '2000-01-15', 1),
('Bob Smith', '456 Oak St', '2345678901', '8765432108', '7654321098', '1999-05-20', 2),
('Charlie Brown', '789 Pine St', '3456789012', '7654321097', '6543210987', '2001-03-10', 1),
('Diana Prince', '321 Maple St', '4567890123', '6543210986', '5432109876', '1998-07-25', 3),
('Eve Adams', '654 Birch St', '5678901234', '5432109875', '4321098765', '2002-11-30', 1),
('Frank Castle', '987 Cedar St', '6789012345', '4321098764', '3210987654', '1997-09-15', 4),
('Grace Hopper', '159 Spruce St', '7890123456', '3210987653', '2109876543', '2000-12-05', 2),
('Hank Pym', '753 Willow St', '8901234567', '2109876542', '1098765432', '1996-04-18', 5),
('Ivy League', '951 Aspen St', '9012345678', '1098765431', '0987654321', '2003-06-22', 1),
('Jack Ryan', '357 Redwood St', '0123456789', '0987654320', '9876543210', '1995-02-14', 6);

-- Insert values into Faculty table
INSERT INTO Faculty (Name, PhoneNumber, DateOfBirth) VALUES
('Dr. John Doe', '1234567890', '1975-03-15'),
('Dr. Jane Smith', '2345678901', '1980-07-20'),
('Dr. Emily Davis', '3456789012', '1985-11-10'),
('Dr. Michael Brown', '4567890123', '1978-05-25'),
('Dr. Sarah Wilson', '5678901234', '1982-09-30'),
('Dr. Robert Taylor', '6789012345', '1976-01-15'),
('Dr. Laura Martinez', '7890123456', '1988-12-05'),
('Dr. James Anderson', '8901234567', '1979-04-18'),
('Dr. Karen Thomas', '9012345678', '1983-06-22'),
('Dr. William Moore', '0123456789', '1977-02-14');

-- Insert values into Courses table
INSERT INTO Courses (CourseName, FacultyID) VALUES
('Mathematics', 1),
('Physics', 2),
('Chemistry', 3),
('Biology', 4),
('Computer Science', 5),
('History', 6),
('Geography', 7),
('English Literature', 8),
('Philosophy', 9),
('Economics', 10);

-- Insert values into Enrollments table
INSERT INTO Enrollments (StudentID, CourseID, Status, EnrollmentDate) VALUES
(1, 1, 'Enrolled', '2023-01-10'),
(2, 2, 'Enrolled', '2023-01-11'),
(3, 3, 'Completed', '2023-01-12'),
(4, 4, 'Pending', '2023-01-13'),
(5, 5, 'Enrolled', '2023-01-14'),
(6, 6, 'Completed', '2023-01-15'),
(7, 7, 'Pending', '2023-01-16'),
(8, 8, 'Enrolled', '2023-01-17'),
(9, 9, 'Completed', '2023-01-18'),
(10, 10, 'Enrolled', '2023-01-19');

-- Insert values into Grades table
INSERT INTO Grades (StudentID, CourseID, Grade, GradeDate) VALUES
(1, 1, 'A', '2023-02-10'),
(2, 2, 'B+', '2023-02-11'),
(3, 3, 'A+', '2023-02-12'),
(4, 4, 'B', '2023-02-13'),
(5, 5, 'C+', '2023-02-14'),
(6, 6, 'A', '2023-02-15'),
(7, 7, 'B+', '2023-02-16'),
(8, 8, 'A+', '2023-02-17'),
(9, 9, 'C', '2023-02-18'),
(10, 10, 'B', '2023-02-19');