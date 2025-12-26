-- Скрипт для создания базы данных PostgreSQL и таблицы лидеров
-- Запустить из командной строки:
-- psql -U postgres -f database_setup_postgresql.sql
-- Или подключиться через psql и выполнить: \i database_setup_postgresql.sql

-- Создание базы данных (выполнять от имени postgres)
-- Если база уже существует, эта команда выдаст ошибку - это нормально
CREATE DATABASE tetris_db 
    WITH ENCODING 'UTF8' 
    LC_COLLATE = 'Russian_Russia.1251' 
    LC_CTYPE = 'Russian_Russia.1251' 
    TEMPLATE = template0;

-- Подключение к базе данных
\c tetris_db

-- Создание таблицы лидеров
CREATE TABLE IF NOT EXISTS leaderboard (
  id SERIAL PRIMARY KEY,
  player_name VARCHAR(100) NOT NULL,
  score INTEGER NOT NULL DEFAULT 0,
  level INTEGER NOT NULL DEFAULT 1,
  lines INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Создание индексов для быстрого поиска
CREATE INDEX IF NOT EXISTS idx_score ON leaderboard (score DESC);
CREATE INDEX IF NOT EXISTS idx_created ON leaderboard (created_at DESC);

-- Добавление тестовых данных (опционально)
INSERT INTO leaderboard (player_name, score, level, lines) VALUES
('Тестовый игрок', 5000, 5, 50),
('Владимир', 3000, 3, 30),
('Анна', 2000, 2, 20);

-- Готово!
\echo 'База данных tetris_db успешно создана!'

