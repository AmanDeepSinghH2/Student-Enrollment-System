USE Enroll;

CREATE TABLE Students (
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    StudentID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100) NOT NULL,
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

CREATE TABLE Grades (
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    GradeID INT PRIMARY KEY AUTO_INCREMENT,
    StudentID INT,
    CourseID INT,
    Grade CHAR(2),
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
    FOREIGN KEY (CourseID) REFERENCES Courses(CourseID)
);

CREATE TABLE FacultyAdvisor (
    FA_id INT PRIMARY KEY AUTO_INCREMENT,
    FA_name VARCHAR(100) NOT NULL,
    FA_phonenumber VARCHAR(15),
    FA_class VARCHAR(100)
);

CREATE TABLE GradeChangeLog (
    LogID INT PRIMARY KEY AUTO_INCREMENT,
    GradeID INT,
    OldGrade CHAR(2),
    NewGrade CHAR(2),
    ChangeDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (GradeID) REFERENCES Grades(GradeID)
);

CREATE TRIGGER log_grade_change
AFTER UPDATE ON Grades
FOR EACH ROW
BEGIN
    INSERT INTO GradeChangeLog (GradeID, OldGrade, NewGrade)
    VALUES (OLD.GradeID, OLD.Grade, NEW.Grade);
END;

DELIMITER $$

CREATE TRIGGER log_grade_change
AFTER UPDATE ON Grades
FOR EACH ROW
BEGIN
    INSERT INTO GradeChangeLog (GradeID, OldGrade, NewGrade) 
    VALUES (OLD.GradeID, OLD.Grade, NEW.Grade);
END $$

DELIMITER ;
