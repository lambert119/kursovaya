-- ==========================
-- КУРСОВАЯ "ДЕКАНАТ"
-- Полный SQL-скрипт: структура + данные + отчёты
-- ==========================

\encoding UTF8
SET client_encoding TO 'UTF8';

-- ---------- Чистка (на случай повторного запуска)
DROP TABLE IF EXISTS grades;
DROP TABLE IF EXISTS subjects;
DROP TABLE IF EXISTS teachers;
DROP TABLE IF EXISTS students;
DROP TABLE IF EXISTS groups;

-- ---------- Структура БД
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

-- ---------- Демо-данные
INSERT INTO groups (group_name) VALUES
('ПИ-101'),
('ПИ-102'),
('ИС-201');

INSERT INTO students (full_name, birth_date, group_id) VALUES
('Иванов Иван Иванович',      '2004-05-12', 1),
('Петров Пётр Петрович',      '2003-11-23', 1),
('Сидорова Анна Сергеевна',   '2004-02-01', 2),
('Кузнецова Мария Ивановна',  '2003-09-15', 2),
('Смирнов Алексей Павлович',  '2002-12-30', 3);

INSERT INTO teachers (full_name, position) VALUES
('Александров Александр Викторович', 'Доцент'),
('Иванова Ольга Николаевна',         'Старший преподаватель'),
('Сергеев Дмитрий Петрович',         'Профессор');

INSERT INTO subjects (subject_name, teacher_id) VALUES
('Базы данных',           1),
('Программирование',      2),
('Математический анализ', 3);

INSERT INTO grades (student_id, subject_id, grade, grade_date) VALUES
(1, 1, 5, '2025-01-15'),
(1, 2, 4, '2025-02-10'),
(2, 1, 3, '2025-01-20'),
(2, 3, 4, '2025-02-05'),
(3, 2, 5, '2025-01-25'),
(4, 1, 2, '2025-02-12'),
(5, 3, 5, '2025-02-18');

-- ---------- Факультеты (для отчётов по заданию)
ALTER TABLE groups ADD COLUMN faculty VARCHAR(100) NOT NULL DEFAULT 'ИПТИП';
UPDATE groups SET faculty = 'ИПТИП' WHERE group_name IN ('ПИ-101', 'ПИ-102');
-- если будет группа ПИ-201 — пример для второго факультета:
-- INSERT INTO groups (group_name, faculty) VALUES ('ПИ-201', 'ФКТИ');
UPDATE groups SET faculty = 'ИВТИ'  WHERE group_name IN ('ИС-201');

-- ---------- Быстрые проверки наполняемости
SELECT 'students:', COUNT(*) FROM students;
SELECT 'grades  :', COUNT(*) FROM grades;

-- ==========================
-- ДЕМОНСТРАЦИОННЫЕ ЗАПРОСЫ
-- ==========================

-- 1. Список всех студентов с указанием группы
SELECT s.full_name, g.group_name
FROM students s
JOIN groups g ON s.group_id = g.group_id
ORDER BY g.group_name, s.full_name;

-- 2. Список предметов и преподавателей
SELECT sub.subject_name, t.full_name AS teacher
FROM subjects sub
JOIN teachers t ON sub.teacher_id = t.teacher_id
ORDER BY sub.subject_name;

-- 3. Все оценки конкретного студента (пример: Иванов Иван Иванович)
SELECT s.full_name, sub.subject_name, gr.grade, gr.grade_date
FROM grades gr
JOIN students s ON gr.student_id = s.student_id
JOIN subjects sub ON gr.subject_id = sub.subject_id
WHERE s.full_name = 'Иванов Иван Иванович'
ORDER BY gr.grade_date;

-- 4. Средний балл каждого студента
SELECT s.full_name, ROUND(AVG(gr.grade), 2) AS avg_grade
FROM grades gr
JOIN students s ON gr.student_id = s.student_id
GROUP BY s.full_name
ORDER BY s.full_name;

-- 5. Средний балл по каждому предмету
SELECT sub.subject_name, ROUND(AVG(gr.grade), 2) AS avg_grade
FROM grades gr
JOIN subjects sub ON gr.subject_id = sub.subject_id
GROUP BY sub.subject_name
ORDER BY sub.subject_name;

-- 6. Студенты с неудовлетворительными оценками (2)
SELECT DISTINCT s.full_name, gr.grade, sub.subject_name
FROM grades gr
JOIN students s ON gr.student_id = s.student_id
JOIN subjects sub ON gr.subject_id = sub.subject_id
WHERE gr.grade = 2
ORDER BY s.full_name, sub.subject_name;

-- ==========================
-- ОТЧЁТНЫЕ ВЫБОРКИ (под задание)
-- ==========================

-- A. Средний балл студентов по каждой группе указанного факультета
--    Подставь нужный факультет: 'ИПТИП', 'ИВТИ', 'ФКТИ', …
SELECT g.faculty, g.group_name, ROUND(AVG(gr.grade), 2) AS avg_grade
FROM grades gr
JOIN students s ON gr.student_id = s.student_id
JOIN groups g   ON s.group_id    = g.group_id
WHERE g.faculty = 'ИПТИП'
GROUP BY g.faculty, g.group_name
ORDER BY avg_grade DESC, g.group_name;

-- B. Группа-лидер по предмету (по среднему баллу), пример: subject_id = 1
SELECT g.group_name, ROUND(AVG(gr.grade), 2) AS avg_grade
FROM grades gr
JOIN students s ON gr.student_id = s.student_id
JOIN groups g   ON s.group_id    = g.group_id
WHERE gr.subject_id = 1
GROUP BY g.group_name
ORDER BY avg_grade DESC, g.group_name
LIMIT 1;

-- C. Список студентов к отчислению (неудов более двух)
SELECT g.faculty, g.group_name, s.full_name, COUNT(*) AS fails
FROM grades gr
JOIN students s ON gr.student_id = s.student_id
JOIN groups g   ON s.group_id    = g.group_id
WHERE gr.grade = 2
GROUP BY g.faculty, g.group_name, s.full_name
HAVING COUNT(*) > 2
ORDER BY g.faculty, g.group_name, s.full_name;

-- D. Самый «провальный» предмет (больше всего неудов)
SELECT sub.subject_name, COUNT(*) AS fails
FROM grades gr
JOIN subjects sub ON gr.subject_id = sub.subject_id
WHERE gr.grade = 2
GROUP BY sub.subject_name
ORDER BY fails DESC, sub.subject_name
LIMIT 1;
