
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

-- Insert data into Students table
INSERT INTO Students (Name, Address, PhoneNumber, DOB, Semester) VALUES
('Alice Johnson', '123 Maple St', '555-1234', '2000-01-15', 1),
('Bob Smith', '456 Oak St', '555-5678', '1999-05-22', 2),
('Charlie Brown', '789 Pine St', '555-9101', '2001-03-10', 1),
('Diana Prince', '321 Elm St', '555-1122', '1998-07-30', 3),
('Eve Adams', '654 Cedar St', '555-3344', '2000-11-25', 2),
('Frank Castle', '987 Birch St', '555-5566', '1997-09-18', 4),
('Grace Hopper', '159 Spruce St', '555-7788', '2001-12-05', 1),
('Hank Pym', '753 Willow St', '555-9900', '1999-02-14', 2),
('Ivy Green', '852 Fir St', '555-2233', '2000-06-20', 3),
('Jack White', '951 Palm St', '555-4455', '1998-10-10', 4);

-- Insert data into StudentParents table
INSERT INTO StudentParents (StudentID, ParentType, PhoneNumber) VALUES
(1, 'Mother', '555-1111'),
(1, 'Father', '555-2222'),
(2, 'Mother', '555-3333'),
(2, 'Father', '555-4444'),
(3, 'Mother', '555-5555'),
(3, 'Father', '555-6666'),
(4, 'Mother', '555-7777'),
(4, 'Father', '555-8888'),
(5, 'Mother', '555-9999'),
(5, 'Father', '555-0000');

-- Insert data into Faculty table
INSERT INTO Faculty (Name, PhoneNumber, DOB) VALUES
('Dr. Alan Turing', '555-1010', '1970-06-23'),
('Dr. Barbara Liskov', '555-2020', '1969-11-07'),
('Dr. Charles Babbage', '555-3030', '1965-12-26'),
('Dr. Dennis Ritchie', '555-4040', '1971-09-09'),
('Dr. Edith Clarke', '555-5050', '1972-08-10'),
('Dr. Frances Allen', '555-6060', '1973-07-15'),
('Dr. Grace Hopper', '555-7070', '1974-05-20'),
('Dr. Howard Aiken', '555-8080', '1975-04-25'),
('Dr. Ivan Sutherland', '555-9090', '1976-03-30'),
('Dr. John von Neumann', '555-0001', '1977-02-14');

-- Insert data into Courses table
INSERT INTO Courses (Name) VALUES
('Mathematics'),
('Physics'),
('Chemistry'),
('Biology'),
('Computer Science'),
('History'),
('Geography'),
('Philosophy'),
('Economics'),
('Literature');

-- Insert data into CourseFaculty table
INSERT INTO CourseFaculty (CourseID, FacultyID) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10);

-- Insert data into Enrollments table
INSERT INTO Enrollments (StudentID, Status, EnrollmentDate) VALUES
(1, 'Active', '2023-01-01'),
(2, 'Active', '2023-01-02'),
(3, 'Active', '2023-01-03'),
(4, 'Active', '2023-01-04'),
(5, 'Active', '2023-01-05'),
(6, 'Active', '2023-01-06'),
(7, 'Active', '2023-01-07'),
(8, 'Active', '2023-01-08'),
(9, 'Active', '2023-01-09'),
(10, 'Active', '2023-01-10');

-- Insert data into Grades table
INSERT INTO Grades (Grade, GradeDate) VALUES
('A', '2023-02-01'),
('B+', '2023-02-02'),
('A+', '2023-02-03'),
('B', '2023-02-04'),
('C+', '2023-02-05'),
('A', '2023-02-06'),
('B+', '2023-02-07'),
('A+', '2023-02-08'),
('B', '2023-02-09'),
('C', '2023-02-10');



-- Update Students table to use 9-digit phone numbers
ALTER TABLE Students MODIFY PhoneNumber VARCHAR(9);

-- Update StudentParents table to use 9-digit phone numbers
ALTER TABLE StudentParents MODIFY PhoneNumber VARCHAR(9);

-- Update Faculty table to use 9-digit phone numbers
ALTER TABLE Faculty MODIFY PhoneNumber VARCHAR(9);

-- Update Enrollments table to restrict Status to 'Pending' or 'Enrolled'
ALTER TABLE Enrollments MODIFY Status ENUM('Pending', 'Enrolled');

-- Insert data into Students table with 9-digit phone numbers
INSERT INTO Students (Name, Address, PhoneNumber, DOB, Semester) VALUES
('Alice Johnson', '123 Maple St', '555123456', '2000-01-15', 1),
('Bob Smith', '456 Oak St', '555567890', '1999-05-22', 2),
('Charlie Brown', '789 Pine St', '555910111', '2001-03-10', 1),
('Diana Prince', '321 Elm St', '555112233', '1998-07-30', 3),
('Eve Adams', '654 Cedar St', '555334455', '2000-11-25', 2),
('Frank Castle', '987 Birch St', '555556677', '1997-09-18', 4),
('Grace Hopper', '159 Spruce St', '555778899', '2001-12-05', 1),
('Hank Pym', '753 Willow St', '555990000', '1999-02-14', 2),
('Ivy Green', '852 Fir St', '555223344', '2000-06-20', 3),
('Jack White', '951 Palm St', '555445566', '1998-10-10', 4);

-- Insert data into StudentParents table with 9-digit phone numbers
INSERT INTO StudentParents (StudentID, ParentType, PhoneNumber) VALUES
(1, 'Mother', '555111222'),
(1, 'Father', '555333444'),
(2, 'Mother', '555555666'),
(2, 'Father', '555777888'),
(3, 'Mother', '555999000'),
(3, 'Father', '555123123'),
(4, 'Mother', '555456456'),
(4, 'Father', '555789789'),
(5, 'Mother', '555101010'),
(5, 'Father', '555202020');

-- Insert data into Faculty table with 9-digit phone numbers
INSERT INTO Faculty (Name, PhoneNumber, DOB) VALUES
('Dr. Alan Turing', '555303030', '1970-06-23'),
('Dr. Barbara Liskov', '555404040', '1969-11-07'),
('Dr. Charles Babbage', '555505050', '1965-12-26'),
('Dr. Dennis Ritchie', '555606060', '1971-09-09'),
('Dr. Edith Clarke', '555707070', '1972-08-10'),
('Dr. Frances Allen', '555808080', '1973-07-15'),
('Dr. Grace Hopper', '555909090', '1974-05-20'),
('Dr. Howard Aiken', '555000111', '1975-04-25'),
('Dr. Ivan Sutherland', '555222333', '1976-03-30'),
('Dr. John von Neumann', '555444555', '1977-02-14');

-- Insert data into Enrollments table with restricted Status
INSERT INTO Enrollments (StudentID, Status, EnrollmentDate) VALUES
(1, 'Enrolled', '2023-01-01'),
(2, 'Pending', '2023-01-02'),
(3, 'Enrolled', '2023-01-03'),
(4, 'Pending', '2023-01-04'),
(5, 'Enrolled', '2023-01-05'),
(6, 'Pending', '2023-01-06'),
(7, 'Enrolled', '2023-01-07'),
(8, 'Pending', '2023-01-08'),
(9, 'Enrolled', '2023-01-09'),
(10, 'Pending', '2023-01-10');
