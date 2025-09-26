-- Учителя
TRUNCATE teachers RESTART IDENTITY CASCADE;
INSERT INTO teachers (full_name, position) VALUES
('Александров Александр Викторович', 'профессор'),
('Иванова Ольга Николаевна', 'доцент'),
('Сергеев Дмитрий Петрович', 'старший преподаватель');

-- Предметы (привяжем по ФИО, не по id — так надёжнее)
TRUNCATE subjects RESTART IDENTITY CASCADE;
INSERT INTO subjects (subject_name, teacher_id) VALUES
('Базы данных', (
  SELECT teacher_id FROM teachers WHERE full_name='Александров Александр Викторович'
)),
('Программирование', (
  SELECT teacher_id FROM teachers WHERE full_name='Иванова Ольга Николаевна'
)),
('Математический анализ', (
  SELECT teacher_id FROM teachers WHERE full_name='Сергеев Дмитрий Петрович'
));
