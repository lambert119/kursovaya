// server/index.js
import express from 'express';
import dotenv from 'dotenv';
import cors from 'cors';
import db from './models/index.js';

// маршруты
import studentsRouter from './src/routes/students.js';
import groupsRouter from './src/routes/groups.js';
import teachersRouter from './src/routes/teachers.js';
import subjectsRouter from './src/routes/subjects.js';
import gradesRouter from './src/routes/grades.js';
import reportsRouter from './src/routes/reports.js';

// swagger
import swaggerUi from 'swagger-ui-express';
import { swaggerSpec } from './src/swagger.js';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 8080;

// базовые middlewares
app.use(cors());
app.use(express.json());

// корневой пинг
app.get('/', (_req, res) => res.send('Сервер работает! 🚀'));

// документация
app.use('/docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));

// CRUD роуты
app.use('/api/students', studentsRouter);
app.use('/api/groups', groupsRouter);
app.use('/api/teachers', teachersRouter);
app.use('/api/subjects', subjectsRouter);
app.use('/api/grades', gradesRouter);

// отчёты
app.use('/api/reports', reportsRouter);

// 404 для неизвестных маршрутов
app.use((req, res) => {
  res.status(404).json({ error: 'Маршрут не найден' });
});

// глобальный обработчик ошибок
app.use((err, _req, res, _next) => {
  console.error('UNHANDLED ERROR:', err);
  res.status(500).json({ error: 'Внутренняя ошибка сервера' });
});

async function start() {
  try {
    await db.sequelize.authenticate();
    console.log('✅ DB connected successfully');
    app.listen(PORT, () => {
      console.log(`🚀 Server started on http://localhost:${PORT}`);
      console.log(`📚 Swagger: http://localhost:${PORT}/docs`);
    });
  } catch (err) {
    console.error('❌ DB connection error:', err);
    process.exit(1);
  }
}

start();
