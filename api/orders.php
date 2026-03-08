<?php
include_once 'connection.php';
include_once 'email.php';
class Order {
    private $conn;
    private $email;
    public function __construct($conn, $email) {
        $this->conn = $conn;
        $this->email = $email;
    }

    public function createOrder($data) {
        try {
            $stmt = $this->conn->prepare("
                INSERT INTO orders (
                    product, size, quantity, customer_name, email, phone,
                    delivery_method, address, latitude, longitude,
                    delivery_distance_km, delivery_charge, unit_price, total_price,
                    date_needed, time_needed, flower_preferences, notes
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ");
            $stmt->execute([
                $data['product'],
                $data['size'] ?? 'Small',
                $data['quantity'] ?? 1,
                $data['customer_name'],
                $data['email'] ?? '',
                $data['phone'] ?? '',
                $data['delivery_method'] ?? 'Pickup',
                $data['address'] ?? '',
                $data['latitude'] ?? null,
                $data['longitude'] ?? null,
                $data['delivery_distance_km'] ?? null,
                $data['delivery_charge'] ?? 0,
                $data['unit_price'] ?? 0,
                $data['total_price'] ?? 0,
                $data['date_needed'],
                $data['time_needed'] ?? null,
                $data['flower_preferences'] ?? '-',
                $data['notes'] ?? '-'
            ]);
            $orderId = $this->conn->lastInsertId();

            // Send confirmation email (non-blocking, won't fail the order)
            try {
                if (!empty($data['email'])) {
                    $this->email->sendOrderConfirmation($data);
                }
            } catch(Exception $e) {
                // Email failure should not break order creation
            }

            return ['status' => 1, 'message' => 'Order created successfully', 'id' => $orderId];
        } catch(PDOException $e) {
            return ['status' => 0, 'message' => 'Error: ' . $e->getMessage()];
        }
    }

    public function getOrders() {
        try {
            $stmt = $this->conn->query("SELECT * FROM orders ORDER BY created_at DESC");
            $orders = $stmt->fetchAll(PDO::FETCH_ASSOC);
            return ['status' => 1, 'data' => $orders];
        } catch(PDOException $e) {
            return ['status' => 0, 'message' => 'Error: ' . $e->getMessage()];
        }
    }

    public function getOrdersByStatus($status) {
        try {
            $stmt = $this->conn->prepare("SELECT * FROM orders WHERE status = ? ORDER BY created_at DESC");
            $stmt->execute([$status]);
            $orders = $stmt->fetchAll(PDO::FETCH_ASSOC);
            return ['status' => 1, 'data' => $orders];
        } catch(PDOException $e) {
            return ['status' => 0, 'message' => 'Error: ' . $e->getMessage()];
        }
    }

    public function updateOrderStatus($id, $status, $reason = null) {
        try {
            $now = date('Y-m-d H:i:s');

            if ($status === 'Processing') {
                $stmt = $this->conn->prepare("UPDATE orders SET status = ?, approved_at = ?, rejected_at = NULL, ready_at = NULL WHERE id = ?");
                $stmt->execute([$status, $now, $id]);
            } elseif ($status === 'Rejected') {
                $stmt = $this->conn->prepare("UPDATE orders SET status = ?, rejected_at = ?, rejection_reason = ?, approved_at = NULL, ready_at = NULL WHERE id = ?");
                $stmt->execute([$status, $now, $reason, $id]);
            } elseif ($status === 'Ready') {
                $stmt = $this->conn->prepare("UPDATE orders SET status = ?, ready_at = ? WHERE id = ?");
                $stmt->execute([$status, $now, $id]);
            } elseif ($status === 'Completed') {
                $stmt = $this->conn->prepare("UPDATE orders SET status = ?, completed_at = ? WHERE id = ?");
                $stmt->execute([$status, $now, $id]);
            } else {
                $stmt = $this->conn->prepare("UPDATE orders SET status = ? WHERE id = ?");
                $stmt->execute([$status, $id]);
            }

            // Send email notification based on new status
            try {
                $order = $this->getOrderById($id);
                if ($order && !empty($order['email'])) {
                    if ($status === 'Processing') {
                        $this->email->sendOrderApproved($order);
                    } elseif ($status === 'Rejected') {
                        $order['rejection_reason'] = $reason;
                        $this->email->sendOrderRejected($order);
                    } elseif ($status === 'Ready') {
                        $this->email->sendOrderReady($order);
                    }
                }
            } catch(Exception $e) {
                // Email failure should not break status update
            }

            return ['status' => 1, 'message' => 'Order updated'];
        } catch(PDOException $e) {
            return ['status' => 0, 'message' => 'Error: ' . $e->getMessage()];
        }
    }

    private function getOrderById($id) {
        try {
            $stmt = $this->conn->prepare("SELECT * FROM orders WHERE id = ?");
            $stmt->execute([$id]);
            return $stmt->fetch(PDO::FETCH_ASSOC);
        } catch(PDOException $e) {
            return null;
        }
    }

    public function deleteOrder($id) {
        try {
            $stmt = $this->conn->prepare("DELETE FROM orders WHERE id = ?");
            $stmt->execute([$id]);
            if ($stmt->rowCount() === 0) {
                return ['status' => 0, 'message' => 'Order not found'];
            }
            return ['status' => 1, 'message' => 'Order deleted'];
        } catch(PDOException $e) {
            return ['status' => 0, 'message' => 'Error: ' . $e->getMessage()];
        }
    }
}
$order = new Order($conn, $email);

if (basename(__FILE__) == basename($_SERVER['SCRIPT_FILENAME'])) {
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $data = isset($_POST['json']) ? json_decode($_POST['json'], true) : null;
        $operation = isset($_POST['operation']) ? $_POST['operation'] : null;
    }
    if(isset($operation)) {
        switch($operation) {
            case 'createOrder':
                $result = $order->createOrder($data);
                echo json_encode($result);
                break;
            case 'getOrders':
                $result = $order->getOrders();
                echo json_encode($result);
                break;
            case 'getOrdersByStatus':
                $result = $order->getOrdersByStatus($data['status']);
                echo json_encode($result);
                break;
            case 'updateOrderStatus':
                $result = $order->updateOrderStatus($data['id'], $data['status'], $data['rejection_reason'] ?? null);
                echo json_encode($result);
                break;
            case 'deleteOrder':
                $result = $order->deleteOrder($data['id']);
                echo json_encode($result);
                break;
        }
    }
}
