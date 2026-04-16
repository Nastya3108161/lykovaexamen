-- phpMyAdmin SQL Dump
-- version 5.1.3-3.red80
-- https://www.phpmyadmin.net/
--
-- Хост: localhost
-- Время создания: Апр 16 2026 г., 09:18
-- Версия сервера: 10.11.11-MariaDB
-- Версия PHP: 8.1.32

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- База данных: `project_Lykova`
--

DELIMITER $$
--
-- Процедуры
--
CREATE DEFINER=`admin`@`localhost` PROCEDURE `CompleteTask` (IN `task_id` INT, IN `actual_hours` DECIMAL(5,2))   BEGIN
    UPDATE tasks 
    SET status = 'done', 
        completed_at = NOW(),
        actual_hours = actual_hours
    WHERE id = task_id;
    
    SELECT CONCAT('Task ', task_id, ' completed successfully') as message;
END$$

CREATE DEFINER=`admin`@`localhost` PROCEDURE `GetOverdueTasks` ()   BEGIN
    SELECT 
        t.id,
        t.title,
        p.name as project_name,
        pr.full_name as assigned_to,
        t.due_date,
        DATEDIFF(CURDATE(), t.due_date) as days_overdue
    FROM tasks t
    JOIN projects p ON t.project_id = p.id
    LEFT JOIN performers pr ON t.assigned_to = pr.id
    WHERE t.status != 'done' 
    AND t.due_date < CURDATE()
    ORDER BY days_overdue DESC;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Структура таблицы `performers`
--

CREATE TABLE `performers` (
  `id` int(11) NOT NULL,
  `full_name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `position` varchar(50) DEFAULT NULL,
  `department` varchar(50) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `status` enum('active','inactive') DEFAULT 'active'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Дамп данных таблицы `performers`
--

INSERT INTO `performers` (`id`, `full_name`, `email`, `position`, `department`, `phone`, `created_at`, `status`) VALUES
(1, 'Иванов Иван Иванович', 'ivanov@company.com', 'Senior Developer', 'Разработка', '+7-999-123-4567', '2026-04-16 09:17:13', 'active'),
(2, 'Петрова Анна Сергеевна', 'petrova@company.com', 'Project Manager', 'Управление', '+7-999-234-5678', '2026-04-16 09:17:13', 'active'),
(3, 'Сидоров Алексей Владимирович', 'sidorov@company.com', 'Developer', 'Разработка', '+7-999-345-6789', '2026-04-16 09:17:13', 'active'),
(4, 'Козлова Елена Дмитриевна', 'kozlova@company.com', 'Tester', 'Тестирование', '+7-999-456-7890', '2026-04-16 09:17:13', 'active'),
(5, 'Михайлов Дмитрий Петрович', 'mikhailov@company.com', 'Designer', 'Дизайн', '+7-999-567-8901', '2026-04-16 09:17:13', 'active');

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `performer_stats`
-- (См. Ниже фактическое представление)
--
CREATE TABLE `performer_stats` (
`id` int(11)
,`full_name` varchar(100)
,`email` varchar(100)
,`position` varchar(50)
,`assigned_tasks` bigint(21)
,`completed_tasks` bigint(21)
,`total_hours_spent` decimal(27,2)
);

-- --------------------------------------------------------

--
-- Структура таблицы `projects`
--

CREATE TABLE `projects` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `status` enum('planning','active','completed','on_hold') DEFAULT 'planning',
  `manager_id` int(11) DEFAULT NULL,
  `budget` decimal(15,2) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ;

--
-- Дамп данных таблицы `projects`
--

INSERT INTO `projects` (`id`, `name`, `description`, `start_date`, `end_date`, `status`, `manager_id`, `budget`, `created_at`) VALUES
(1, 'Разработка мобильного приложения', 'Создание кроссплатформенного мобильного приложения для онлайн-заказа', '2024-01-15', '2024-06-30', 'active', 2, '1500000.00', '2026-04-16 09:17:13'),
(2, 'Миграция на облачную платформу', 'Перенос инфраструктуры в облако AWS', '2024-02-01', '2024-05-30', 'planning', 2, '800000.00', '2026-04-16 09:17:13'),
(3, 'Сайт компании', 'Разработка корпоративного сайта с личным кабинетом', '2024-01-10', '2024-04-15', 'completed', 1, '500000.00', '2026-04-16 09:17:13');

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `project_details`
-- (См. Ниже фактическое представление)
--
CREATE TABLE `project_details` (
`id` int(11)
,`name` varchar(100)
,`description` text
,`start_date` date
,`end_date` date
,`status` enum('planning','active','completed','on_hold')
,`manager_id` int(11)
,`budget` decimal(15,2)
,`created_at` timestamp
,`manager_name` varchar(100)
,`manager_email` varchar(100)
,`total_tasks` bigint(21)
,`completed_tasks` bigint(21)
);

-- --------------------------------------------------------

--
-- Структура таблицы `tasks`
--

CREATE TABLE `tasks` (
  `id` int(11) NOT NULL,
  `project_id` int(11) NOT NULL,
  `title` varchar(200) NOT NULL,
  `description` text DEFAULT NULL,
  `status` enum('todo','in_progress','review','done') DEFAULT 'todo',
  `priority` enum('low','medium','high','urgent') DEFAULT 'medium',
  `created_by` int(11) DEFAULT NULL,
  `assigned_to` int(11) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `due_date` date NOT NULL,
  `completed_at` datetime DEFAULT NULL,
  `estimated_hours` decimal(5,2) DEFAULT NULL,
  `actual_hours` decimal(5,2) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ;

--
-- Дамп данных таблицы `tasks`
--

INSERT INTO `tasks` (`id`, `project_id`, `title`, `description`, `status`, `priority`, `created_by`, `assigned_to`, `start_date`, `due_date`, `completed_at`, `estimated_hours`, `actual_hours`, `created_at`, `updated_at`) VALUES
(1, 1, 'Проектирование архитектуры', 'Разработка архитектуры приложения', 'done', 'high', 2, 1, '2024-01-15', '2024-01-30', NULL, '40.00', NULL, '2026-04-16 09:17:13', '2026-04-16 09:17:13'),
(2, 1, 'Разработка API', 'Создание REST API для бэкенда', 'in_progress', 'high', 1, 3, '2024-02-01', '2024-02-28', NULL, '80.00', NULL, '2026-04-16 09:17:13', '2026-04-16 09:17:13'),
(3, 1, 'Создание интерфейса', 'Разработка пользовательского интерфейса', 'in_progress', 'medium', 2, 5, '2024-02-01', '2024-03-15', NULL, '120.00', NULL, '2026-04-16 09:17:13', '2026-04-16 09:17:13'),
(4, 2, 'Анализ текущей инфраструктуры', 'Оценка текущих систем и планирование миграции', 'todo', 'medium', 2, 2, '2024-02-05', '2024-02-20', NULL, '40.00', NULL, '2026-04-16 09:17:13', '2026-04-16 09:17:13'),
(5, 3, 'Вёрстка главной страницы', 'Адаптивная вёрстка главной страницы', 'done', 'medium', 1, 5, '2024-01-10', '2024-01-25', NULL, '60.00', NULL, '2026-04-16 09:17:13', '2026-04-16 09:17:13'),
(6, 3, 'Разработка личного кабинета', 'Функционал личного кабинета пользователя', 'done', 'high', 1, 3, '2024-01-20', '2024-03-10', NULL, '100.00', NULL, '2026-04-16 09:17:13', '2026-04-16 09:17:13');

--
-- Триггеры `tasks`
--
DELIMITER $$
CREATE TRIGGER `update_project_status` AFTER UPDATE ON `tasks` FOR EACH ROW BEGIN
    DECLARE total_tasks INT;
    DECLARE completed_tasks INT;
    
    SELECT COUNT(*), SUM(CASE WHEN status = 'done' THEN 1 ELSE 0 END)
    INTO total_tasks, completed_tasks
    FROM tasks
    WHERE project_id = NEW.project_id;
    
    IF total_tasks = completed_tasks AND total_tasks > 0 THEN
        UPDATE projects 
        SET status = 'completed' 
        WHERE id = NEW.project_id;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Структура таблицы `task_assignments`
--

CREATE TABLE `task_assignments` (
  `task_id` int(11) NOT NULL,
  `performer_id` int(11) NOT NULL,
  `assigned_at` timestamp NULL DEFAULT current_timestamp(),
  `hours_spent` decimal(5,2) DEFAULT 0.00
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Дамп данных таблицы `task_assignments`
--

INSERT INTO `task_assignments` (`task_id`, `performer_id`, `assigned_at`, `hours_spent`) VALUES
(1, 1, '2026-04-16 09:17:13', '42.50'),
(2, 3, '2026-04-16 09:17:13', '35.00'),
(3, 5, '2026-04-16 09:17:13', '28.00'),
(4, 2, '2026-04-16 09:17:13', '10.00'),
(5, 5, '2026-04-16 09:17:13', '58.00'),
(6, 3, '2026-04-16 09:17:13', '95.50');

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `task_details`
-- (См. Ниже фактическое представление)
--
CREATE TABLE `task_details` (
`id` int(11)
,`project_id` int(11)
,`title` varchar(200)
,`description` text
,`status` enum('todo','in_progress','review','done')
,`priority` enum('low','medium','high','urgent')
,`created_by` int(11)
,`assigned_to` int(11)
,`start_date` date
,`due_date` date
,`completed_at` datetime
,`estimated_hours` decimal(5,2)
,`actual_hours` decimal(5,2)
,`created_at` timestamp
,`updated_at` timestamp
,`assigned_to_name` varchar(100)
,`created_by_name` varchar(100)
,`project_name` varchar(100)
,`all_performers` mediumtext
);

-- --------------------------------------------------------

--
-- Структура для представления `performer_stats`
--
DROP TABLE IF EXISTS `performer_stats`;

CREATE ALGORITHM=UNDEFINED DEFINER=`admin`@`localhost` SQL SECURITY DEFINER VIEW `performer_stats`  AS SELECT `pr`.`id` AS `id`, `pr`.`full_name` AS `full_name`, `pr`.`email` AS `email`, `pr`.`position` AS `position`, count(distinct `t`.`id`) AS `assigned_tasks`, count(distinct case when `t`.`status` = 'done' then `t`.`id` end) AS `completed_tasks`, coalesce(sum(`ta`.`hours_spent`),0) AS `total_hours_spent` FROM ((`performers` `pr` left join `task_assignments` `ta` on(`pr`.`id` = `ta`.`performer_id`)) left join `tasks` `t` on(`ta`.`task_id` = `t`.`id`)) GROUP BY `pr`.`id``id`  ;

-- --------------------------------------------------------

--
-- Структура для представления `project_details`
--
DROP TABLE IF EXISTS `project_details`;

CREATE ALGORITHM=UNDEFINED DEFINER=`admin`@`localhost` SQL SECURITY DEFINER VIEW `project_details`  AS SELECT `p`.`id` AS `id`, `p`.`name` AS `name`, `p`.`description` AS `description`, `p`.`start_date` AS `start_date`, `p`.`end_date` AS `end_date`, `p`.`status` AS `status`, `p`.`manager_id` AS `manager_id`, `p`.`budget` AS `budget`, `p`.`created_at` AS `created_at`, `pr`.`full_name` AS `manager_name`, `pr`.`email` AS `manager_email`, count(distinct `t`.`id`) AS `total_tasks`, count(distinct case when `t`.`status` = 'done' then `t`.`id` end) AS `completed_tasks` FROM ((`projects` `p` left join `performers` `pr` on(`p`.`manager_id` = `pr`.`id`)) left join `tasks` `t` on(`p`.`id` = `t`.`project_id`)) GROUP BY `p`.`id``id`  ;

-- --------------------------------------------------------

--
-- Структура для представления `task_details`
--
DROP TABLE IF EXISTS `task_details`;

CREATE ALGORITHM=UNDEFINED DEFINER=`admin`@`localhost` SQL SECURITY DEFINER VIEW `task_details`  AS SELECT `t`.`id` AS `id`, `t`.`project_id` AS `project_id`, `t`.`title` AS `title`, `t`.`description` AS `description`, `t`.`status` AS `status`, `t`.`priority` AS `priority`, `t`.`created_by` AS `created_by`, `t`.`assigned_to` AS `assigned_to`, `t`.`start_date` AS `start_date`, `t`.`due_date` AS `due_date`, `t`.`completed_at` AS `completed_at`, `t`.`estimated_hours` AS `estimated_hours`, `t`.`actual_hours` AS `actual_hours`, `t`.`created_at` AS `created_at`, `t`.`updated_at` AS `updated_at`, `pr`.`full_name` AS `assigned_to_name`, `pr2`.`full_name` AS `created_by_name`, `p`.`name` AS `project_name`, group_concat(distinct `per`.`full_name` separator ', ') AS `all_performers` FROM (((((`tasks` `t` left join `performers` `pr` on(`t`.`assigned_to` = `pr`.`id`)) left join `performers` `pr2` on(`t`.`created_by` = `pr2`.`id`)) left join `projects` `p` on(`t`.`project_id` = `p`.`id`)) left join `task_assignments` `ta` on(`t`.`id` = `ta`.`task_id`)) left join `performers` `per` on(`ta`.`performer_id` = `per`.`id`)) GROUP BY `t`.`id``id`  ;

--
-- Индексы сохранённых таблиц
--

--
-- Индексы таблицы `performers`
--
ALTER TABLE `performers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Индексы таблицы `projects`
--
ALTER TABLE `projects`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_projects_manager` (`manager_id`),
  ADD KEY `idx_projects_status` (`status`);

--
-- Индексы таблицы `tasks`
--
ALTER TABLE `tasks`
  ADD PRIMARY KEY (`id`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `idx_tasks_project` (`project_id`),
  ADD KEY `idx_tasks_assigned` (`assigned_to`),
  ADD KEY `idx_tasks_status` (`status`);

--
-- Индексы таблицы `task_assignments`
--
ALTER TABLE `task_assignments`
  ADD PRIMARY KEY (`task_id`,`performer_id`),
  ADD KEY `performer_id` (`performer_id`);

--
-- AUTO_INCREMENT для сохранённых таблиц
--

--
-- AUTO_INCREMENT для таблицы `performers`
--
ALTER TABLE `performers`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT для таблицы `projects`
--
ALTER TABLE `projects`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `tasks`
--
ALTER TABLE `tasks`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Ограничения внешнего ключа сохраненных таблиц
--

--
-- Ограничения внешнего ключа таблицы `projects`
--
ALTER TABLE `projects`
  ADD CONSTRAINT `projects_ibfk_1` FOREIGN KEY (`manager_id`) REFERENCES `performers` (`id`) ON DELETE SET NULL;

--
-- Ограничения внешнего ключа таблицы `tasks`
--
ALTER TABLE `tasks`
  ADD CONSTRAINT `tasks_ibfk_1` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `tasks_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `performers` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `tasks_ibfk_3` FOREIGN KEY (`assigned_to`) REFERENCES `performers` (`id`) ON DELETE SET NULL;

--
-- Ограничения внешнего ключа таблицы `task_assignments`
--
ALTER TABLE `task_assignments`
  ADD CONSTRAINT `task_assignments_ibfk_1` FOREIGN KEY (`task_id`) REFERENCES `tasks` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `task_assignments_ibfk_2` FOREIGN KEY (`performer_id`) REFERENCES `performers` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
