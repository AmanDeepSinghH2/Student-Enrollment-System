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

CREATE TABLE Courses (
    CourseID INT PRIMARY KEY AUTO_INCREMENT,
    CourseName VARCHAR(100) NOT NULL,
    faculty_id INT,
    FOREIGN KEY (faculty_id) REFERENCES Faculty(FacultyID)
);

CREATE TABLE Enrollments (
    EnrollmentID INT PRIMARY KEY AUTO_INCREMENT,
    StudentID INT,
    enroll_status VARCHAR(50),
    EnrollmentDate DATE,
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID)
);

CREATE TABLE Faculty (
    FacultyID INT PRIMARY KEY AUTO_INCREMENT,
    Faculty_name VARCHAR(100) NOT NULL,
    Faculty_phonenumber VARCHAR(15),
    Faculty_date_of_birth DATE,
    Faculty_classes VARCHAR(100)
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
