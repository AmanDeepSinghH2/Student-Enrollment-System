CREATE TABLE Students (
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    StudentID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Courses (
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CourseID INT PRIMARY KEY AUTO_INCREMENT,
    CourseName VARCHAR(100) NOT NULL,
    Credits INT NOT NULL,
    Prerequisites VARCHAR(255)
);

CREATE TABLE Enrollments (
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    EnrollmentID INT PRIMARY KEY AUTO_INCREMENT,
    StudentID INT,
    CourseID INT,
    EnrollmentDate DATE,
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
    FOREIGN KEY (CourseID) REFERENCES Courses(CourseID)
);

CREATE TABLE Faculty (
    FacultyID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100) NOT NULL,
    Department VARCHAR(100)
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

CREATE TABLE Timetable (
    TimetableID INT PRIMARY KEY AUTO_INCREMENT,
    CourseID INT,
    ClassTime DATETIME,
    Location VARCHAR(100),
    FOREIGN KEY (CourseID) REFERENCES Courses(CourseID)
);

CREATE TABLE Departments (
    DepartmentID INT PRIMARY KEY AUTO_INCREMENT,
    DepartmentName VARCHAR(100) NOT NULL
);
