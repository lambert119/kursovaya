-- ВАЖНО: работаем в UTF-8
\encoding UTF8
SET client_encoding TO 'UTF8';

-- ==== СТРУКТУРА ===========================================

DROP TABLE IF EXISTS grades;
DROP TABLE IF EXISTS subjects;
DROP TABLE IF EXISTS teachers;
DROP TABLE IF EXISTS students;
DROP TABLE IF EXISTS groups;

CREATE TABLE groups (
    group_id   SERIAL PRIMARY KEY,
    group_name VARCHAR(50) NOT NULL
);

CREATE TABLE students (
    student_id   SERIAL PRIMARY KEY,
    full_name    VARCHAR(100) NOT NULL,
    birth_date   DATE NOT NULL,
    group_id     INT REFERENCES groups(group_id) ON DELETE SET NULL
);

CREATE TABLE teachers (
    teacher_id SERIAL PRIMARY KEY,
    full_name  VARCHAR(100) NOT NULL,
    position   VARCHAR(50)
);

CREATE TABLE subjects (
    subject_id   SERIAL PRIMARY KEY,
    subject_name VARCHAR(100) NOT NULL,
    teacher_id   INT REFERENCES teachers(teacher_id) ON DELETE SET NULL
);

CREATE TABLE grades (
    grade_id   SERIAL PRIMARY KEY,
    student_id INT REFERENCES students(student_id) ON DELETE CASCADE,
    subject_id INT REFERENCES subjects(subject_id) ON DELETE CASCADE,
    grade      INT CHECK (grade BETWEEN 2 AND 5),
    grade_date DATE DEFAULT CURRENT_DATE
);

-- ==== ДАННЫЕ ==============================================

INSERT INTO groups (group_name) VALUES
('ПИ-101'),
('ПИ-102'),
('ИС-201');

INSERT INTO students (full_name, birth_date, group_id) VALUES
('Иванов Иван Иванович', '2004-05-12', 1),
('Петров Пётр Петрович', '2003-11-23', 1),
('Сидорова Анна Сергеевна', '2004-02-01', 2),
('Кузнецова Мария Ивановна', '2003-09-15', 2),
('Смирнов Алексей Павлович', '2002-12-30', 3);

INSERT INTO teachers (full_name, position) VALUES
('Александров Александр Викторович', 'Доцент'),
('Иванова Ольга Николаевна', 'Старший преподаватель'),
('Сергеев Дмитрий Петрович', 'Профессор');

INSERT INTO subjects (subject_name, teacher_id) VALUES
('Базы данных', 1),
('Программирование', 2),
('Математический анализ', 3);

INSERT INTO grades (student_id, subject_id, grade, grade_date) VALUES
(1, 1, 5, '2025-01-15'),
(1, 2, 4, '2025-02-10'),
(2, 1, 3, '2025-01-20'),
(2, 3, 4, '2025-02-05'),
(3, 2, 5, '2025-01-25'),
(4, 1, 2, '2025-02-12'),
(5, 3, 5, '2025-02-18');

-- Быстрая проверка
SELECT 'students:', COUNT(*) FROM students;
SELECT 'grades  :', COUNT(*) FROM grades;
