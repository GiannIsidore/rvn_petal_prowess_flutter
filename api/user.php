<?php
include 'connection.php';
class User {
    private $conn;
    public function __construct($conn) {
        $this->conn = $conn;
    }

    public function createUser($username, $password) {
        try {
            // Check if username already exists
            $stmt = $this->conn->prepare("SELECT id FROM accounts WHERE username = ?");
            $stmt->execute([$username]);
            if ($stmt->fetch()) {
                return ['status' => 0, 'message' => 'Username already exists'];
            }

            // Hash the password
            $hashedPassword = password_hash($password, PASSWORD_DEFAULT);
            $stmt = $this->conn->prepare("INSERT INTO accounts (username, password) VALUES (?, ?)");
            $stmt->execute([$username, $hashedPassword]);
            return ['status' => 1, 'message' => 'Account created successfully'];
        } catch(PDOException $e) {
            return ['status' => 0, 'message' => 'Error: ' . $e->getMessage()];
        }
    }

    public function getUser($username, $password) {
        try {
            $stmt = $this->conn->prepare("SELECT * FROM accounts WHERE username = ?");
            $stmt->execute([$username]);
            $user = $stmt->fetch(PDO::FETCH_ASSOC);

            if ($user && password_verify($password, $user['password'])) {
                return ['status' => 1, 'message' => 'Login successful', 'user' => ['id' => $user['id'], 'username' => $user['username']]];
            }
            return ['status' => 0, 'message' => 'Invalid username or password'];
        } catch(PDOException $e) {
            return ['status' => 0, 'message' => 'Error: ' . $e->getMessage()];
        }
    }
}
$user = new User($conn);

if (basename(__FILE__) == basename($_SERVER['SCRIPT_FILENAME'])) {
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $data = isset($_POST['json']) ? json_decode($_POST['json'], true) : null;
        $operation = isset($_POST['operation']) ? $_POST['operation'] : null;
    }
    if(isset($operation)) {
        switch($operation) {
            case 'createUser':
                $createResult = $user->createUser($data['username'], $data['password']);
                echo json_encode($createResult);
                break;
            case 'getUser':
                $getUserResult = $user->getUser($data['username'], $data['password']);
                echo json_encode($getUserResult);
                break;
        }
    }
}
