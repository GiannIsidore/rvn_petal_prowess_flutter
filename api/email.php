<?php
include_once 'connection.php';
class Email {
    private $smtpHost;
    private $smtpPort;
    private $smtpUser;
    private $smtpPass;
    private $fromEmail;
    private $fromName;

    public function __construct() {
        $c = (require __DIR__ . '/config.php')['smtp'];
        $this->smtpHost = $c['host'];
        $this->smtpPort = $c['port'];
        $this->smtpUser = $c['user'];
        $this->smtpPass = $c['pass'];
        $this->fromEmail = $c['from_email'];
        $this->fromName = $c['from_name'];
    }

    private function smtpSend($toEmail, $toName, $subject, $htmlBody) {
        $fp = @fsockopen($this->smtpHost, $this->smtpPort, $errno, $errstr, 30);
        if (!$fp) return ['status' => 0, 'message' => "SMTP connect failed: $errstr"];

        $this->getResponse($fp);
        $this->sendCmd($fp, "EHLO localhost");

        // STARTTLS upgrade for port 587
        $this->sendCmd($fp, "STARTTLS");
        stream_socket_enable_crypto($fp, true, STREAM_CRYPTO_METHOD_TLS_CLIENT);
        $this->sendCmd($fp, "EHLO localhost");

        $this->sendCmd($fp, "AUTH LOGIN");
        $this->sendCmd($fp, base64_encode($this->smtpUser));
        $resp = $this->sendCmd($fp, base64_encode($this->smtpPass));
        if (strpos($resp, '535') !== false) {
            fclose($fp);
            return ['status' => 0, 'message' => 'SMTP auth failed'];
        }

        $this->sendCmd($fp, "MAIL FROM:<{$this->fromEmail}>");
        $this->sendCmd($fp, "RCPT TO:<{$toEmail}>");
        $this->sendCmd($fp, "DATA");

        $headers  = "From: {$this->fromName} <{$this->fromEmail}>\r\n";
        $headers .= "To: {$toName} <{$toEmail}>\r\n";
        $headers .= "Subject: {$subject}\r\n";
        $headers .= "MIME-Version: 1.0\r\n";
        $headers .= "Content-Type: text/html; charset=UTF-8\r\n";
        $headers .= "\r\n";
        $headers .= $htmlBody . "\r\n";

        $resp = $this->sendCmd($fp, $headers . "\r\n.");
        $this->sendCmd($fp, "QUIT");
        fclose($fp);

        if (strpos($resp, '250') !== false) {
            return ['status' => 1, 'message' => 'Email sent'];
        }
        return ['status' => 0, 'message' => 'Email send failed: ' . $resp];
    }

    private function sendCmd($fp, $cmd) {
        fwrite($fp, $cmd . "\r\n");
        return $this->getResponse($fp);
    }

    private function getResponse($fp) {
        $response = '';
        while ($line = fgets($fp, 512)) {
            $response .= $line;
            if (substr($line, 3, 1) == ' ') break;
        }
        return $response;
    }

    // ===== EMAIL TEMPLATES =====

    private function baseTemplate($title, $content) {
        return '
        <div style="font-family:Segoe UI,Arial,sans-serif;max-width:520px;margin:0 auto;background:#fff;border-radius:12px;overflow:hidden;box-shadow:0 4px 20px rgba(0,0,0,0.1);">
            <div style="background:#2e7d32;padding:20px;text-align:center;color:#fff;">
                <h1 style="margin:0;font-size:22px;">🌸 RVN Petal Prowess</h1>
            </div>
            <div style="padding:25px;">
                <h2 style="color:#2e7d32;margin-top:0;">' . $title . '</h2>
                ' . $content . '
            </div>
            <div style="background:#f1f8f4;padding:15px;text-align:center;font-size:13px;color:#666;">
                Zone 1, Sankanan, Manolo Fortich, Bukidnon<br>
                Thank you for choosing RVN Petal Prowess!
            </div>
        </div>';
    }

    private function orderDetailsHtml($order) {
        $html  = '<table style="width:100%;border-collapse:collapse;font-size:14px;">';
        $html .= '<tr><td style="padding:6px 0;color:#666;">Product:</td><td style="padding:6px 0;font-weight:600;">' . $order['product'] . '</td></tr>';
        $html .= '<tr><td style="padding:6px 0;color:#666;">Size:</td><td style="padding:6px 0;">' . $order['size'] . '</td></tr>';
        $html .= '<tr><td style="padding:6px 0;color:#666;">Quantity:</td><td style="padding:6px 0;">' . $order['quantity'] . '</td></tr>';
        $html .= '<tr><td style="padding:6px 0;color:#666;">Method:</td><td style="padding:6px 0;">' . $order['delivery_method'] . '</td></tr>';
        $html .= '<tr><td style="padding:6px 0;color:#666;">Date:</td><td style="padding:6px 0;">' . $order['date_needed'] . '</td></tr>';
        $html .= '<tr><td style="padding:6px 0;color:#666;">Time:</td><td style="padding:6px 0;">' . ($order['time_needed'] ?? '-') . '</td></tr>';
        if (!empty($order['flower_preferences']) && $order['flower_preferences'] !== '-') {
            $html .= '<tr><td style="padding:6px 0;color:#666;">Flowers:</td><td style="padding:6px 0;">' . $order['flower_preferences'] . '</td></tr>';
        }
        $html .= '</table>';

        // Price breakdown
        $unitPrice = $order['unit_price'] ?? 0;
        $qty = $order['quantity'] ?? 1;
        $deliveryCharge = $order['delivery_charge'] ?? 0;
        $totalPrice = $order['total_price'] ?? 0;

        $html .= '<div style="margin-top:15px;padding:12px;background:#f9f9f9;border-radius:8px;border:1px solid #e0e0e0;">';
        $html .= '<table style="width:100%;border-collapse:collapse;font-size:14px;">';
        $html .= '<tr><td style="padding:4px 0;color:#666;">Unit Price:</td><td style="padding:4px 0;text-align:right;">&#8369;' . number_format($unitPrice, 2) . '</td></tr>';
        $html .= '<tr><td style="padding:4px 0;color:#666;">Quantity:</td><td style="padding:4px 0;text-align:right;">x' . $qty . '</td></tr>';
        $html .= '<tr><td style="padding:4px 0;color:#666;">Subtotal:</td><td style="padding:4px 0;text-align:right;">&#8369;' . number_format($unitPrice * $qty, 2) . '</td></tr>';
        if ($deliveryCharge > 0) {
            $html .= '<tr><td style="padding:4px 0;color:#666;">Delivery Charge:</td><td style="padding:4px 0;text-align:right;">&#8369;' . number_format($deliveryCharge, 2) . '</td></tr>';
        }
        $html .= '<tr style="border-top:1px solid #ccc;"><td style="padding:8px 0 4px;font-weight:700;color:#2e7d32;">Total:</td><td style="padding:8px 0 4px;text-align:right;font-weight:700;color:#2e7d32;font-size:16px;">&#8369;' . number_format($totalPrice, 2) . '</td></tr>';
        $html .= '</table>';
        $html .= '</div>';

        return $html;
    }

    // ===== PUBLIC METHODS =====

    public function sendOrderConfirmation($order) {
        $content  = '<p>Hi <strong>' . $order['customer_name'] . '</strong>,</p>';
        $content .= '<p>Your order has been received and is now <strong style="color:#856404;">Pending</strong> for review.</p>';
        $content .= $this->orderDetailsHtml($order);
        $content .= '<p style="margin-top:15px;">We will notify you once your order has been approved or rejected. Stay tuned!</p>';

        $html = $this->baseTemplate('Order Received!', $content);
        return $this->smtpSend($order['email'], $order['customer_name'], 'Order Received - RVN Petal Prowess', $html);
    }

    public function sendOrderApproved($order) {
        $content  = '<p>Hi <strong>' . $order['customer_name'] . '</strong>,</p>';
        $content .= '<p>Great news! Your order has been <strong style="color:#2e7d32;">Approved</strong> and is now being processed.</p>';
        $content .= $this->orderDetailsHtml($order);
        $content .= '<p style="margin-top:15px;">We will notify you again once your order is ready for ' . strtolower($order['delivery_method']) . '.</p>';

        $html = $this->baseTemplate('Order Approved!', $content);
        return $this->smtpSend($order['email'], $order['customer_name'], 'Order Approved - RVN Petal Prowess', $html);
    }

    public function sendOrderRejected($order) {
        $content  = '<p>Hi <strong>' . $order['customer_name'] . '</strong>,</p>';
        $content .= '<p>We are sorry to inform you that your order has been <strong style="color:#c62828;">Rejected</strong>.</p>';
        $content .= $this->orderDetailsHtml($order);
        $content .= '<div style="margin-top:15px;padding:12px;background:#fef3f3;border-left:4px solid #c62828;border-radius:4px;">';
        $content .= '<strong>Reason:</strong> ' . ($order['rejection_reason'] ?? 'No reason provided.');
        $content .= '</div>';
        $content .= '<p style="margin-top:15px;">Feel free to place a new order or contact us for questions.</p>';

        $html = $this->baseTemplate('Order Rejected', $content);
        return $this->smtpSend($order['email'], $order['customer_name'], 'Order Update - RVN Petal Prowess', $html);
    }

    public function sendOrderReady($order) {
        $method = $order['delivery_method'] === 'Delivery' ? 'delivered to you' : 'picked up';
        $content  = '<p>Hi <strong>' . $order['customer_name'] . '</strong>,</p>';
        $content .= '<p>Your order is now <strong style="color:#1976d2;">Ready</strong> to be ' . $method . '!</p>';
        $content .= $this->orderDetailsHtml($order);

        if ($order['delivery_method'] === 'Pickup') {
            $content .= '<div style="margin-top:15px;padding:12px;background:#f1f8f4;border-left:4px solid #2e7d32;border-radius:4px;">';
            $content .= '<strong>Pickup Address:</strong><br>Zone 1, Sankanan, Manolo Fortich, Bukidnon<br>Store Hours: 8AM - 6PM (Mon - Sat)';
            $content .= '</div>';
        }

        $html = $this->baseTemplate('Order Ready!', $content);
        return $this->smtpSend($order['email'], $order['customer_name'], 'Order Ready - RVN Petal Prowess', $html);
    }
}
$email = new Email();

if (basename(__FILE__) == basename($_SERVER['SCRIPT_FILENAME'])) {
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $data = isset($_POST['json']) ? json_decode($_POST['json'], true) : null;
        $operation = isset($_POST['operation']) ? $_POST['operation'] : null;
    }
    if(isset($operation)) {
        switch($operation) {
            case 'sendOrderConfirmation':
                $result = $email->sendOrderConfirmation($data);
                echo json_encode($result);
                break;
            case 'sendOrderApproved':
                $result = $email->sendOrderApproved($data);
                echo json_encode($result);
                break;
            case 'sendOrderRejected':
                $result = $email->sendOrderRejected($data);
                echo json_encode($result);
                break;
            case 'sendOrderReady':
                $result = $email->sendOrderReady($data);
                echo json_encode($result);
                break;
        }
    }
}
