<?php
$config = require __DIR__ . '/config.php';
$c = $config['db'];

try {
    $conn = new PDO("mysql:host={$c['host']};dbname={$c['dbname']}", $c['username'], $c['password']);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    die("Could not connect. " . $e->getMessage());
}
?>
