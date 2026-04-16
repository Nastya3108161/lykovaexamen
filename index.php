<?php
$host = 'localhost';
$dbname = 'project_Lykova';
$username = 'admin';
$password = 'admin';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch(PDOException $e) {
    die("Ошибка подключения: " . $e->getMessage());
}
?>

<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Система управления проектами</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; padding: 20px; }
        h1 { color: #333; margin-bottom: 20px; }
        h2 { color: #555; margin: 20px 0 10px 0; }
        table { width: 100%; background: white; border-collapse: collapse; margin-bottom: 20px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background: #4CAF50; color: white; }
        tr:hover { background: #f5f5f5; }
        .status { padding: 4px 8px; border-radius: 4px; font-size: 12px; font-weight: bold; }
        .status-active { background: #4CAF50; color: white; }
        .status-completed { background: #2196F3; color: white; }
        .status-planning { background: #FF9800; color: white; }
        .status-todo { background: #9E9E9E; color: white; }
        .status-progress { background: #FFC107; color: #333; }
        .status-done { background: #4CAF50; color: white; }
        .nav { background: #333; color: white; padding: 15px; margin-bottom: 20px; border-radius: 5px; }
        .nav a { color: white; text-decoration: none; margin-right: 20px; }
        .nav a:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <div class="container">
        <h1>📊 Система управления проектами</h1>
        
        <div class="nav">
            <a href="?page=projects">📁 Проекты</a>
            <a href="?page=tasks">✅ Задачи</a>
            <a href="?page=performers">👥 Исполнители</a>
            <a href="?page=overdue">⚠️ Просроченные задачи</a>
        </div>

        <?php
        $page = $_GET['page'] ?? 'projects';
        
        switch($page) {
            case 'projects':
                $stmt = $pdo->query("SELECT * FROM project_details");
                $projects = $stmt->fetchAll();
                ?>
                <h2>Проекты</h2>
                <table>
                    <thead>
                        <tr><th>ID</th><th>Название</th><th>Менеджер</th><th>Даты</th><th>Статус</th><th>Бюджет</th><th>Задачи</th></tr>
                    </thead>
                    <tbody>
                        <?php foreach($projects as $project): ?>
                        <tr>
                            <td><?= $project['id'] ?></td>
                            <td><?= htmlspecialchars($project['name']) ?></td>
                            <td><?= htmlspecialchars($project['manager_name'] ?? 'Не назначен') ?></td>
                            <td><?= $project['start_date'] ?> → <?= $project['end_date'] ?></td>
                            <td><span class="status status-<?= $project['status'] ?>"><?= $project['status'] ?></span></td>
                            <td><?= number_format($project['budget'], 2) ?> ₽</td>
                            <td><?= $project['completed_tasks'] ?>/<?= $project['total_tasks'] ?></td>
                        </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
                <?php
                break;
                
            case 'tasks':
                $stmt = $pdo->query("SELECT * FROM task_details ORDER BY due_date");
                $tasks = $stmt->fetchAll();
                ?>
                <h2>Задачи</h2>
                <table>
                    <thead>
                        <tr><th>ID</th><th>Название</th><th>Проект</th><th>Исполнитель</th><th>Статус</th><th>Приоритет</th><th>Срок</th></tr>
                    </thead>
                    <tbody>
                        <?php foreach($tasks as $task): ?>
                        <tr>
                            <td><?= $task['id'] ?></td>
                            <td><?= htmlspecialchars($task['title']) ?></td>
                            <td><?= htmlspecialchars($task['project_name']) ?></td>
                            <td><?= htmlspecialchars($task['assigned_to_name'] ?? 'Не назначен') ?></td>
                            <td><span class="status status-<?= $task['status'] ?>"><?= $task['status'] ?></span></td>
                            <td><span class="status"><?= $task['priority'] ?></span></td>
                            <td <?= ($task['due_date'] < date('Y-m-d') && $task['status'] != 'done') ? 'style="color: red; font-weight: bold;"' : '' ?>>
                                <?= $task['due_date'] ?>
                            </td>
                        </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
                <?php
                break;
                
            case 'performers':
                $stmt = $pdo->query("SELECT * FROM performer_stats");
                $performers = $stmt->fetchAll();
                ?>
                <h2>Исполнители</h2>
                <table>
                    <thead>
                        <tr><th>ID</th><th>ФИО</th><th>Должность</th><th>Email</th><th>Задач назначено</th><th>Выполнено</th><th>Часов затрачено</th></tr>
                    </thead>
                    <tbody>
                        <?php foreach($performers as $performer): ?>
                        <tr>
                            <td><?= $performer['id'] ?></td>
                            <td><?= htmlspecialchars($performer['full_name']) ?></td>
                            <td><?= htmlspecialchars($performer['position']) ?></td>
                            <td><?= htmlspecialchars($performer['email']) ?></td>
                            <td><?= $performer['assigned_tasks'] ?></td>
                            <td><?= $performer['completed_tasks'] ?></td>
                            <td><?= $performer['total_hours_spent'] ?></td>
                        </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
                <?php
                break;
                
            case 'overdue':
                $stmt = $pdo->query("CALL GetOverdueTasks()");
                $overdue = $stmt->fetchAll();
                ?>
                <h2>⚠️ Просроченные задачи</h2>
                <?php if(count($overdue) > 0): ?>
                <table>
                    <thead>
                        <tr><th>ID</th><th>Задача</th><th>Проект</th><th>Исполнитель</th><th>Срок</th><th>Дней просрочки</th></tr>
                    </thead>
                    <tbody>
                        <?php foreach($overdue as $task): ?>
                        <tr style="background: #ffe6e6;">
                            <td><?= $task['id'] ?></td>
                            <td><?= htmlspecialchars($task['title']) ?></td>
                            <td><?= htmlspecialchars($task['project_name']) ?></td>
                            <td><?= htmlspecialchars($task['assigned_to'] ?? 'Не назначен') ?></td>
                            <td><?= $task['due_date'] ?></td>
                            <td style="color: red; font-weight: bold;"><?= $task['days_overdue'] ?></td>
                        </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
                <?php else: ?>
                <p style="color: green;">✅ Нет просроченных задач!</p>
                <?php endif; ?>
                <?php
                break;
        }
        ?>
    </div>
</body>
</html>