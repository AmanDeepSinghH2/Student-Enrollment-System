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

CREATE TRIGGER after_insert_enrollments
AFTER INSERT ON Enrollments
FOR EACH ROW
BEGIN
    INSERT INTO Courses (CourseName, FacultyID)
    SELECT 'General Course', FacultyID
    FROM Faculty
    WHERE FacultyID = 1;
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

DELIMITER $$

CREATE PROCEDURE GetStudentEnrollments(IN student_id INT)
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE enrollment_id INT;
    DECLARE course_name VARCHAR(100);
    DECLARE cur CURSOR FOR 
        SELECT Enrollments.EnrollmentID, Courses.CourseName
        FROM Enrollments
        JOIN Courses ON Enrollments.StudentID = student_id AND Courses.FacultyID IS NOT NULL;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO enrollment_id, course_name;
        IF done THEN
            LEAVE read_loop;
        END IF;
        SELECT enrollment_id, course_name;
    END LOOP;
    CLOSE cur;
END $$

DELIMITER ;
