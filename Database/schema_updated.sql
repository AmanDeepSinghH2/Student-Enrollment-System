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

INSERT INTO Students (Names, student_address, student_phonenumber, Mothers_phonenumber, Fathers_phonenumber, date_of_birth, student_semester)
VALUES ('John Doe', '123 Main St', '1234567890', '0987654321', '1122334455', '2000-01-01', 1);

CREATE TABLE Faculty (
    FacultyID INT PRIMARY KEY AUTO_INCREMENT,
    FacultyName VARCHAR(100) NOT NULL,
    FacultyPhoneNumber VARCHAR(15),
    FacultyDateOfBirth DATE,
    FacultyClasses VARCHAR(100)
);

CREATE TABLE Courses (
    CourseID INT PRIMARY KEY AUTO_INCREMENT,
    CourseName VARCHAR(100) NOT NULL,
    FacultyID INT,
    FOREIGN KEY (FacultyID) REFERENCES Faculty(FacultyID)
);

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

CREATE TRIGGER after_insert_courses
AFTER INSERT ON Courses
FOR EACH ROW
BEGIN
    INSERT INTO Enrollments (StudentID, enroll_status, EnrollmentDate)
    SELECT StudentID, 'Enrolled', CURDATE()
    FROM Students
    WHERE student_semester = 1;
END $$

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