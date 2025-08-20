CREATE DATABASE StudentDB;
USE StudentDB;

/* CREATE TABLES */

/* Students Table */
CREATE TABLE Students (
    StudentID INT PRIMARY KEY AUTO_INCREMENT,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    DOB DATE,
    Gender VARCHAR(10)
);

 /* Courses Table */
CREATE TABLE Courses (
    CourseID INT PRIMARY KEY AUTO_INCREMENT,
    CourseName VARCHAR(100),
    CourseCode VARCHAR(10)
);

/* Marks Table */
CREATE TABLE Marks (
    MarkID INT PRIMARY KEY AUTO_INCREMENT,
    StudentID INT,
    CourseID INT,
    MarksObtained INT,
    MaxMarks INT DEFAULT 100,
    ExamDate DATE,
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
    FOREIGN KEY (CourseID) REFERENCES Courses(CourseID)
);

ALTER TABLE Students ADD Email VARCHAR(100);


INSERT INTO Students (FirstName, LastName, DOB, Gender, Email)
VALUES 
('Ravi', 'Pakala', '2005-06-15', 'male', 'ravi@example.com'),
('Arun', 'Smith', '2004-08-20', 'Male', 'arun@example.com'),
('Sruthi', 'Brown', '2005-01-10', 'FeMale', 'sruthi@example.com');



INSERT INTO Courses (CourseName, CourseCode)
VALUES 
('Mathematics', 'MATH101'),
('Science', 'SCI101'),
('English', 'ENG101');


INSERT INTO Marks (StudentID, CourseID, MarksObtained, ExamDate)
VALUES
(1, 1, 85, '2007-07-25'),
(1, 2, 78, '2010-05-24'),
(1, 3, 92, '2011-02-24'),
(2, 1, 65, '2023-03-12'),
(2, 2, 70, '2005-06-16'),
(2, 3, 80, '2004-08-28'),
(3, 1, 95, '2005-04-13'),
(3, 2, 88, '2025-08-01'),
(3, 3, 91, '2001-05-11');


 /*  UPDATE RECORDS */
UPDATE Students
SET Email = 'ravi.pakala@example.com'
WHERE StudentID = 1;


/* DELETE RECORDS */
DELETE FROM Marks WHERE MarksObtained < 60;


/*  WHERE, LIKE */
SELECT * FROM Students
WHERE FirstName LIKE 'A%';


/* AGGREGATE FUNCTIONS, GROUP BY, HAVING */
SELECT 
    S.StudentID,
    CONCAT(S.FirstName, ' ', S.LastName) AS StudentName,
    ROUND(AVG(M.MarksObtained), 2) AS AverageMarks
FROM Students S
JOIN Marks M ON S.StudentID = M.StudentID
GROUP BY S.StudentID
HAVING AVG(M.MarksObtained) > 80;



/* SUBQUERIES */
SELECT FirstName, LastName
FROM Students
WHERE StudentID IN (
    SELECT StudentID
    FROM Marks
    WHERE CourseID = (SELECT CourseID FROM Courses WHERE CourseName = 'Mathematics')
    AND MarksObtained > (
        SELECT AVG(MarksObtained)
        FROM Marks
        WHERE CourseID = (SELECT CourseID FROM Courses WHERE CourseName = 'Mathematics')
    )
);


/* STORED PROCEDURE */
DELIMITER $$
CREATE PROCEDURE GetStudentReportCard(IN stu_id INT)
BEGIN
    SELECT 
        S.StudentID,
        CONCAT(S.FirstName, ' ', S.LastName) AS StudentName,
        C.CourseName,
        M.MarksObtained,
        M.MaxMarks,
        ROUND((M.MarksObtained * 100.0 / M.MaxMarks), 2) AS Percentage
    FROM Students S
    JOIN Marks M ON S.StudentID = M.StudentID
    JOIN Courses C ON M.CourseID = C.CourseID
    WHERE S.StudentID = stu_id;
END$$

DELIMITER ;
CALL GetStudentReportCard(3);


/* TRIGGERS */
CREATE TABLE ScoreLog (
    LogID INT PRIMARY KEY AUTO_INCREMENT,
    StudentID INT,
    CourseID INT,
    MarksObtained INT,
    LoggedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


DELIMITER $$
CREATE TRIGGER LogHighScores
AFTER INSERT ON Marks
FOR EACH ROW
BEGIN
    IF NEW.MarksObtained >= 90 THEN
        INSERT INTO ScoreLog (StudentID, CourseID, MarksObtained)
        VALUES (NEW.StudentID, NEW.CourseID, NEW.MarksObtained);
    END IF;
END$$

DELIMITER ;


INSERT INTO Marks (StudentID, CourseID, MarksObtained, ExamDate)
VALUES (2, 1, 95, '2025-08-10');

SELECT * FROM ScoreLog;
