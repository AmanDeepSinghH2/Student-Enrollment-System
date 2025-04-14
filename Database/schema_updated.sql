SHOW databases;
CREATE database Enroll;
USE Enroll;

CREATE TABLE Students (
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    StudentID INT PRIMARY KEY AUTO_INCREMENT,
    Names VARCHAR(100) NOT NULL,
    student_address VARCHAR(255),
    student_phonenumber VARCHAR(15),
    Mothers_phonenumber VARCHAR(15),
    Fathers_phonenumber VARCHAR(15),
    date_of_birth DATE,
    student_semester INT
);


CREATE TABLE Faculty (
    FacultyID INT PRIMARY KEY AUTO_INCREMENT,
    FacultyName VARCHAR(100) NOT NULL,
    FacultyPhoneNumber VARCHAR(15),
    FacultyDateOfBirth DATE,
    FacultyClasses VARCHAR(100)
);
INSERT INTO Faculty (FacultyName, FacultyPhoneNumber, FacultyDateOfBirth, FacultyClasses)
VALUES
('Dr. Jane Smith', '2345678901', '1980-02-20', 'Mathematics, Statistics'),
('Dr. Emily Davis', '3456789012', '1985-03-25', 'Biology, Environmental Science'),
('Dr. Michael Brown', '4567890123', '1978-04-30', 'Computer Science, Data Science'),
('Dr. Sarah Wilson', '5678901234', '1982-05-10', 'History, Political Science'),
('Dr. David Johnson', '6789012345', '1979-06-15', 'Economics, Business Studies'),
('Dr. Laura Martinez', '7890123456', '1983-07-20', 'English, Literature'),
('Dr. Robert Garcia', '8901234567', '1977-08-25', 'Engineering, Robotics'),
('Dr. Linda Anderson', '9012345678', '1981-09-30', 'Psychology, Sociology'),
('Dr. James Thomas', '0123456789', '1984-10-05', 'Philosophy, Ethics');

CREATE TABLE Courses (
    CourseID INT PRIMARY KEY AUTO_INCREMENT,
    CourseName VARCHAR(100) NOT NULL,
    FacultyID INT,
    FOREIGN KEY (FacultyID) REFERENCES Faculty(FacultyID)
);

INSERT INTO Courses (CourseName)
VALUES
('Introduction to Mathematics'),
('Advanced Statistics'),
('Biology 101'),
('Environmental Science Basics'),
('Introduction to Computer Science'),
('Data Science Fundamentals'),
('World History Overview'),
('Political Science Concepts'),
('Principles of Economics'),
('Business Studies Essentials');

CREATE TABLE Enrollments (
    EnrollmentID INT PRIMARY KEY AUTO_INCREMENT,
    StudentID INT,
    enroll_status VARCHAR(50),
    EnrollmentDate DATE,
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID)
);

DELIMITER $$
CREATE TRIGGER after_insert_students
AFTER INSERT ON Students
FOR EACH ROW
BEGIN
    INSERT INTO Enrollments (StudentID, enroll_status, EnrollmentDate)
    VALUES (NEW.StudentID, 'Pending', CURDATE());
END $$

CREATE TRIGGER after_insert_faculty
AFTER INSERT ON Faculty
FOR EACH ROW
BEGIN
    INSERT INTO Courses (CourseName, FacultyID)
    VALUES (CONCAT('Default Course for ', NEW.FacultyName), NEW.FacultyID);
END $$

-- Removed the after_insert_courses trigger to avoid conflicts with the Courses table
-- If needed, implement the logic outside of the trigger using a stored procedure or separate script.

CREATE TRIGGER after_insert_enrollments
AFTER INSERT ON Enrollments
FOR EACH ROW
BEGIN
    INSERT INTO Courses (CourseName, FacultyID)
    SELECT 'General Course', FacultyID
    FROM Faculty
    WHERE FacultyID = 1;
END $$

DELIMITER ;

DELIMITER $$


CREATE PROCEDURE GetStudentEnrollments(IN student_id INT)
BEGIN
    -- Declare a variable to signal the end of the cursor
    DECLARE done INT DEFAULT 0;

    -- Declare variables to hold the data fetched from the cursor
    DECLARE enrollment_id INT;
    DECLARE course_name VARCHAR(100);

    -- Define a cursor to select enrollment ID and course name for the given student ID
    DECLARE cur CURSOR FOR 
        SELECT Enrollments.EnrollmentID, Courses.CourseName
        FROM Enrollments
        JOIN Courses ON Enrollments.StudentID = student_id AND Courses.FacultyID IS NOT NULL;

    -- Define a handler to set the 'done' variable when the cursor reaches the end
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    -- Open the cursor
    OPEN cur;

    -- Loop to fetch and process each row from the cursor
    read_loop: LOOP
        FETCH cur INTO enrollment_id, course_name; -- Fetch the next row into variables
        IF done THEN
            LEAVE read_loop; -- Exit the loop if no more rows are available
        END IF;
        -- Process each row (example: output the enrollment ID and course name)
        SELECT enrollment_id, course_name;
    END LOOP;

    -- Close the cursor after processing all rows
    CLOSE cur;
END $$

CREATE TRIGGER after_drop_students
AFTER DELETE ON Students
FOR EACH ROW
BEGIN
    DELETE FROM Enrollments WHERE StudentID = OLD.StudentID;
END $$

CREATE TRIGGER after_drop_faculty
AFTER DELETE ON Faculty
FOR EACH ROW
BEGIN
    DELETE FROM Courses WHERE FacultyID = OLD.FacultyID;
END $$

CREATE TRIGGER after_drop_courses
AFTER DELETE ON Courses
FOR EACH ROW
BEGIN
    DELETE FROM Enrollments WHERE EnrollmentID IN (
        SELECT EnrollmentID
        FROM Enrollments
        JOIN Students ON Enrollments.StudentID = Students.StudentID
        WHERE Students.student_semester = 1
    );
END $$

DELIMITER ;

CREATE VIEW EnrollmentDetails AS
SELECT 
    Enrollments.EnrollmentID,
    Students.Names AS StudentName,
    Enrollments.enroll_status,
    Enrollments.EnrollmentDate
FROM 
    Enrollments
JOIN 
    Students ON Enrollments.StudentID = Students.StudentID;

CREATE VIEW CourseDetails AS
    SELECT 
        Courses.CourseID,
        Courses.CourseName,
        Faculty.FacultyName,
        Faculty.FacultyPhoneNumber
    FROM 
        Courses
    JOIN 
        Faculty ON Courses.FacultyID = Faculty.FacultyID;

-- Continue from your schema
CREATE TABLE IF NOT EXISTS Grades (
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    GradeID INT PRIMARY KEY AUTO_INCREMENT,
    StudentID INT NOT NULL,
    CourseID INT NOT NULL,
    Grade VARCHAR(2) NOT NULL CHECK (Grade IN ('A+', 'A', 'B+', 'B', 'C+', 'C', 'D', 'F')),
    GradeDate DATE,
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
    FOREIGN KEY (CourseID) REFERENCES Courses(CourseID),
    UNIQUE KEY unique_grade (StudentID, CourseID)
);
INSERT INTO Grades (StudentID, CourseID, Grade, GradeDate)
VALUES
(1, 1, 'A', '2023-01-15'),
(2, 2, 'B+', '2023-02-20'),
(3, 3, 'A+', '2023-03-25'),
(4, 4, 'B', '2023-04-30'),
(5, 5, 'C+', '2023-05-10'),
(6, 6, 'A', '2023-06-15'),
(7, 7, 'B', '2023-07-20'),
(8, 8, 'A+', '2023-08-25'),
(9, 9, 'C', '2023-09-30'),
(10, 10, 'B+', '2023-10-05');


INSERT INTO Students (Names, student_address, student_phonenumber, Mothers_phonenumber, Fathers_phonenumber, date_of_birth, student_semester)
VALUES 
('Alice Smith', '456 Elm St', '2345678901', '1234567890', '2233445566', '2001-02-15', 2),
('Bob Johnson', '789 Oak St', '3456789012', '2345678901', '3344556677', '2002-03-20', 3),
('Charlie Brown', '101 Pine St', '4567890123', '3456789012', '4455667788', '2003-04-25', 4),
('Diana Prince', '202 Maple St', '5678901234', '4567890123', '5566778899', '2004-05-30', 1),
('Eve Adams', '303 Birch St', '6789012345', '5678901234', '6677889900', '2005-06-10', 2),
('Frank Castle', '404 Cedar St', '7890123456', '6789012345', '7788990011', '2006-07-15', 3),
('Grace Hopper', '505 Walnut St', '8901234567', '7890123456', '8899001122', '2007-08-20', 4),
('Hank Pym', '606 Chestnut St', '9012345678', '8901234567', '9900112233', '2008-09-25', 1),
('Ivy League', '707 Ash St', '0123456789', '9012345678', '0011223344', '2009-10-30', 2),
('Jack Sparrow', '808 Willow St', '1234567890', '0123456789', '1122334455', '2010-11-05', 3);

-- To remove a trigger in MySQL Workbench, you can use the DROP TRIGGER statement.
-- For example, to remove the `after_insert_students` trigger:


-- Similarly, you can remove other triggers by specifying their names.