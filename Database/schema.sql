USE Enroll;

CREATE TABLE IF NOT EXISTS Students (
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    StudentID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100) NOT NULL,
    student_address VARCHAR(255) NOT NULL,
    student_phonenumber VARCHAR(15) NOT NULL,
    Mothers_phonenumber VARCHAR(15),
    Fathers_phonenumber VARCHAR(15),
    date_of_birth DATE NOT NULL,
    student_semester INT NOT NULL CHECK (student_semester BETWEEN 1 AND 8),
    email VARCHAR(100) UNIQUE,
    INDEX idx_student_name (Name),
    INDEX idx_student_semester (student_semester)
);

CREATE TABLE IF NOT EXISTS Faculty (
    FacultyID INT PRIMARY KEY AUTO_INCREMENT,
    FacultyName VARCHAR(100) NOT NULL,
    FacultyPhoneNumber VARCHAR(15) NOT NULL,
    FacultyDateOfBirth DATE NOT NULL,
    email VARCHAR(100) UNIQUE,
    department VARCHAR(100),
    INDEX idx_faculty_name (FacultyName)
);

CREATE TABLE IF NOT EXISTS Courses (
    CourseID INT PRIMARY KEY AUTO_INCREMENT,
    CourseName VARCHAR(100) NOT NULL,
    CourseCode VARCHAR(20) UNIQUE NOT NULL,
    Credits INT NOT NULL CHECK (Credits BETWEEN 1 AND 5),
    FacultyID INT,
    SemesterOffered INT CHECK (SemesterOffered BETWEEN 1 AND 8),
    FOREIGN KEY (FacultyID) REFERENCES Faculty(FacultyID),
    INDEX idx_course_name (CourseName)
);

CREATE TABLE IF NOT EXISTS Enrollments (
    EnrollmentID INT PRIMARY KEY AUTO_INCREMENT,
    StudentID INT NOT NULL,
    CourseID INT NOT NULL,
    enroll_status ENUM('active', 'completed', 'dropped', 'failed') DEFAULT 'active',
    EnrollmentDate DATE NOT NULL,
    CompletionDate DATE,
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
    FOREIGN KEY (CourseID) REFERENCES Courses(CourseID),
    UNIQUE KEY unique_enrollment (StudentID, CourseID),
    INDEX idx_enrollment_status (enroll_status)
);

CREATE TABLE IF NOT EXISTS Grades (
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    GradeID INT PRIMARY KEY AUTO_INCREMENT,
    StudentID INT NOT NULL,
    CourseID INT NOT NULL,
    Grade CHAR(2) CHECK (Grade IN ('A+', 'A', 'A-', 'B+', 'B', 'B-', 'C+', 'C', 'C-', 'D+', 'D', 'F')),
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
    FOREIGN KEY (CourseID) REFERENCES Courses(CourseID),
    UNIQUE KEY unique_grade (StudentID, CourseID),
    INDEX idx_grade (Grade)
);

CREATE TABLE IF NOT EXISTS FacultyAdvisor (
    FA_id INT PRIMARY KEY AUTO_INCREMENT,
    FA_name VARCHAR(100) NOT NULL,
    FA_phonenumber VARCHAR(15) NOT NULL,
    FA_class VARCHAR(100),
    FacultyID INT,
    FOREIGN KEY (FacultyID) REFERENCES Faculty(FacultyID),
    INDEX idx_advisor_name (FA_name)
);

CREATE TABLE IF NOT EXISTS ChangeLog (
    LogID INT PRIMARY KEY AUTO_INCREMENT,
    TableName VARCHAR(50) NOT NULL,
    RecordID INT NOT NULL,
    Action VARCHAR(10) NOT NULL,
    ChangedBy VARCHAR(100),
    ChangeTimestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    OldValues JSON,
    NewValues JSON
);

CREATE VIEW StudentEnrollmentSummary AS
SELECT 
    s.StudentID, 
    s.Name, 
    COUNT(e.EnrollmentID) AS TotalCourses,
    SUM(CASE WHEN e.enroll_status = 'active' THEN 1 ELSE 0 END) AS ActiveCourses,
    SUM(CASE WHEN e.enroll_status = 'completed' THEN 1 ELSE 0 END) AS CompletedCourses
FROM Students s
LEFT JOIN Enrollments e ON s.StudentID = e.StudentID
GROUP BY s.StudentID, s.Name;


CREATE VIEW FacultyCourseLoad AS
SELECT 
    f.FacultyID,
    f.FacultyName,
    COUNT(c.CourseID) AS TotalCourses,
    GROUP_CONCAT(c.CourseName SEPARATOR ', ') AS CoursesTeaching
FROM Faculty f
LEFT JOIN Courses c ON f.FacultyID = c.FacultyID
GROUP BY f.FacultyID, f.FacultyName;

CREATE VIEW GradeDistribution AS
SELECT 
    c.CourseID,
    c.CourseName,
    g.Grade,
    COUNT(g.GradeID) AS GradeCount
FROM Courses c
JOIN Grades g ON c.CourseID = g.CourseID
GROUP BY c.CourseID, c.CourseName, g.Grade
ORDER BY c.CourseID, 
    CASE g.Grade
        WHEN 'A+' THEN 1
        WHEN 'A' THEN 2
        WHEN 'A-' THEN 3
        WHEN 'B+' THEN 4
        WHEN 'B' THEN 5
        WHEN 'B-' THEN 6
        WHEN 'C+' THEN 7
        WHEN 'C' THEN 8
        WHEN 'C-' THEN 9
        WHEN 'D+' THEN 10
        WHEN 'D' THEN 11
        WHEN 'F' THEN 12
        ELSE 13
    END;

DELIMITER //
CREATE TRIGGER validate_student_age
BEFORE INSERT ON Enrollments
FOR EACH ROW
BEGIN
    DECLARE student_age INT;
    DECLARE min_age INT DEFAULT 16;
    
    SELECT TIMESTAMPDIFF(YEAR, s.date_of_birth, CURDATE()) INTO student_age
    FROM Students s
    WHERE s.StudentID = NEW.StudentID;
    
    IF student_age < min_age THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Student must be at least 16 years old to enroll';
    END IF;
END//
DELIMITER ;

DELIMITER //
CREATE TRIGGER log_grade_changes
AFTER UPDATE ON Grades
FOR EACH ROW
BEGIN
    IF OLD.Grade != NEW.Grade THEN
        INSERT INTO ChangeLog (TableName, RecordID, Action, OldValues, NewValues)
        VALUES ('Grades', NEW.GradeID, 'UPDATE',
                JSON_OBJECT('Grade', OLD.Grade),
                JSON_OBJECT('Grade', NEW.Grade));
    END IF;
END//
DELIMITER ;

DELIMITER //
CREATE TRIGGER prevent_duplicate_enrollment
BEFORE INSERT ON Enrollments
FOR EACH ROW
BEGIN
    DECLARE existing_count INT;
    
    SELECT COUNT(*) INTO existing_count
    FROM Enrollments
    WHERE StudentID = NEW.StudentID AND CourseID = NEW.CourseID;
    
    IF existing_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Student is already enrolled in this course';
    END IF;
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE UpdateStudentStatus()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE student_id INT;
    DECLARE fail_count INT;
    DECLARE cur CURSOR FOR 
        SELECT s.StudentID
        FROM Students s;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur;
    
    read_loop: LOOP
        FETCH cur INTO student_id;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        SELECT COUNT(*) INTO fail_count
        FROM Grades
        WHERE StudentID = student_id AND Grade = 'F';
        
        IF fail_count > 2 THEN
            UPDATE Enrollments
            SET enroll_status = 'failed'
            WHERE StudentID = student_id AND enroll_status = 'active';
        END IF;
    END LOOP;
    
    CLOSE cur;
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE CalculateSemesterGPA(IN student_id INT, IN semester INT)
BEGIN
    DECLARE total_points DECIMAL(10,2) DEFAULT 0;
    DECLARE total_credits INT DEFAULT 0;
    DECLARE gpa DECIMAL(3,2);
    DECLARE grade CHAR(2);
    DECLARE credits INT;
    DECLARE done INT DEFAULT FALSE;
    
    DECLARE grade_cursor CURSOR FOR
        SELECT g.Grade, c.Credits
        FROM Grades g
        JOIN Courses c ON g.CourseID = c.CourseID
        JOIN Enrollments e ON g.StudentID = e.StudentID AND g.CourseID = e.CourseID
        WHERE g.StudentID = student_id AND e.enroll_status = 'completed';
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN grade_cursor;
    
    grade_loop: LOOP
        FETCH grade_cursor INTO grade, credits;
        IF done THEN
            LEAVE grade_loop;
        END IF;
        
        CASE grade
            WHEN 'A+' THEN SET total_points = total_points + (4.3 * credits);
            WHEN 'A' THEN SET total_points = total_points + (4.0 * credits);
            WHEN 'A-' THEN SET total_points = total_points + (3.7 * credits);
            WHEN 'B+' THEN SET total_points = total_points + (3.3 * credits);
            WHEN 'B' THEN SET total_points = total_points + (3.0 * credits);
            WHEN 'B-' THEN SET total_points = total_points + (2.7 * credits);
            WHEN 'C+' THEN SET total_points = total_points + (2.3 * credits);
            WHEN 'C' THEN SET total_points = total_points + (2.0 * credits);
            WHEN 'C-' THEN SET total_points = total_points + (1.7 * credits);
            WHEN 'D+' THEN SET total_points = total_points + (1.3 * credits);
            WHEN 'D' THEN SET total_points = total_points + (1.0 * credits);
            WHEN 'F' THEN SET total_points = total_points + (0.0 * credits);
        END CASE;
        
        SET total_credits = total_credits + credits;
    END LOOP;
    
    CLOSE grade_cursor;
    
    IF total_credits > 0 THEN
        SET gpa = total_points / total_credits;
        SELECT CONCAT('Student ID: ', student_id, ' | Semester GPA: ', ROUND(gpa, 2)) AS Result;
    ELSE
        SELECT 'No completed courses found for this student' AS Result;
    END IF;
END//
DELIMITER ;

INSERT INTO Students (Name, student_address, student_phonenumber, date_of_birth, student_semester, email)
VALUES ('John Doe', '123 Main St', '555-1234', '2000-01-15', 3, 'john.doe@example.com');

UPDATE Students
SET student_address = '456 Oak Ave', student_phonenumber = '555-5678'
WHERE StudentID = 1;

DELETE FROM Students WHERE StudentID = 1;

SELECT * FROM Students WHERE student_semester = 3;

SELECT s.StudentID, s.Name, AVG(
    CASE g.Grade
        WHEN 'A+' THEN 4.3
        WHEN 'A' THEN 4.0
        WHEN 'A-' THEN 3.7
        WHEN 'B+' THEN 3.3
        WHEN 'B' THEN 3.0
        WHEN 'B-' THEN 2.7
        WHEN 'C+' THEN 2.3
        WHEN 'C' THEN 2.0
        WHEN 'C-' THEN 1.7
        WHEN 'D+' THEN 1.3
        WHEN 'D' THEN 1.0
        WHEN 'F' THEN 0.0
    END
) AS GPA
FROM Students s
JOIN Grades g ON s.StudentID = g.StudentID
GROUP BY s.StudentID, s.Name
HAVING GPA > (
    SELECT AVG(
        CASE Grade
            WHEN 'A+' THEN 4.3
            WHEN 'A' THEN 4.0
            WHEN 'A-' THEN 3.7
            WHEN 'B+' THEN 3.3
            WHEN 'B' THEN 3.0
            WHEN 'B-' THEN 2.7
            WHEN 'C+' THEN 2.3
            WHEN 'C' THEN 2.0
            WHEN 'C-' THEN 1.7
            WHEN 'D+' THEN 1.3
            WHEN 'D' THEN 1.0
            WHEN 'F' THEN 0.0
        END
    )
    FROM Grades
);

SELECT c.CourseID, c.CourseName
FROM Courses c
WHERE c.CourseID NOT IN (
    SELECT DISTINCT CourseID
    FROM Enrollments
);

SELECT f.FacultyID, f.FacultyName, COUNT(c.CourseID) AS CourseCount
FROM Faculty f
JOIN Courses c ON f.FacultyID = c.FacultyID
GROUP BY f.FacultyID, f.FacultyName
HAVING CourseCount = (
    SELECT MAX(CourseCount)
    FROM (
        SELECT COUNT(CourseID) AS CourseCount
        FROM Courses
        GROUP BY FacultyID
    ) AS MaxCourses
);

SELECT 
    c.CourseName,
    g.Grade,
    COUNT(*) AS GradeCount,
    ROUND(COUNT() * 100.0 / SUM(COUNT()) OVER (PARTITION BY c.CourseID), 2) AS Percentage
FROM Courses c
JOIN Grades g ON c.CourseID = g.CourseID
GROUP BY c.CourseID, c.CourseName, g.Grade
ORDER BY c.CourseName, 
    CASE g.Grade
        WHEN 'A+' THEN 1
        WHEN 'A' THEN 2
        WHEN 'A-' THEN 3
        WHEN 'B+' THEN 4
        WHEN 'B' THEN 5
        WHEN 'B-' THEN 6
        WHEN 'C+' THEN 7
        WHEN 'C' THEN 8
        WHEN 'C-' THEN 9
        WHEN 'D+' THEN 10
        WHEN 'D' THEN 11
        WHEN 'F' THEN 12
        ELSE 13
    END;

SELECT 
    s.student_semester,
    COUNT(DISTINCT s.StudentID) AS StudentCount,
    AVG(
        CASE g.Grade
            WHEN 'A+' THEN 4.3
            WHEN 'A' THEN 4.0
            WHEN 'A-' THEN 3.7
            WHEN 'B+' THEN 3.3
            WHEN 'B' THEN 3.0
            WHEN 'B-' THEN 2.7
            WHEN 'C+' THEN 2.3
            WHEN 'C' THEN 2.0
            WHEN 'C-' THEN 1.7
            WHEN 'D+' THEN 1.3
            WHEN 'D' THEN 1.0
            WHEN 'F' THEN 0.0
        END
    ) AS AvgGPA
FROM Students s
LEFT JOIN Grades g ON s.StudentID = g.StudentID
GROUP BY s.student_semester
ORDER BY s.student_semester;

SELECT 
    f.FacultyID,
    f.FacultyName,
    COUNT(DISTINCT g.StudentID) AS StudentsTaught,
    AVG(
        CASE g.Grade
            WHEN 'A+' THEN 4.3
            WHEN 'A' THEN 4.0
            WHEN 'A-' THEN 3.7
            WHEN 'B+' THEN 3.3
            WHEN 'B' THEN 3.0
            WHEN 'B-' THEN 2.7
            WHEN 'C+' THEN 2.3
            WHEN 'C' THEN 2.0
            WHEN 'C-' THEN 1.7
            WHEN 'D+' THEN 1.3
            WHEN 'D' THEN 1.0
            WHEN 'F' THEN 0.0
        END
    ) AS AvgGradePoints
FROM Faculty f
JOIN Courses c ON f.FacultyID = c.FacultyID
JOIN Grades g ON c.CourseID = g.CourseID
GROUP BY f.FacultyID, f.FacultyName
ORDER BY AvgGradePoints DESC;
