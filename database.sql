-- ============================================
-- RVN Petal Prowess - Database
-- Import this file in phpMyAdmin
-- Create database "rvn" first, then import
-- Compatible with MySQL 5.7+ / MariaDB 10.2+
-- ============================================

CREATE DATABASE IF NOT EXISTS rvn
  CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE rvn;

-- ACCOUNTS TABLE
CREATE TABLE IF NOT EXISTS accounts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Default owner account (username: owner, password: 12345)
INSERT INTO accounts (username, password) VALUES
('owner', '$2y$12$2QbrMI1/4vFOq4iMSmPypOWC5bZpZvUo1.KGatckmQDd6MQgsHdIa');

-- PRODUCTS TABLE
CREATE TABLE IF NOT EXISTS products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    price_small DECIMAL(10,2) NOT NULL DEFAULT 0,
    price_medium DECIMAL(10,2) NOT NULL DEFAULT 0,
    price_large DECIMAL(10,2) NOT NULL DEFAULT 0,
    image_path VARCHAR(255),
    is_active TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Insert the 3 products
INSERT INTO products (name, description, price_small, price_medium, price_large, image_path) VALUES
('Assorted Flowers', 'A mix of fresh seasonal flowers.', 150.00, 250.00, 350.00, '3.jpg/ea84b9ab-446b-4b1e-abe3-27e4186a3e2d.jpg'),
('Custom Bouquet', 'Create your own bouquet design.', 500.00, 1000.00, 1500.00, 'product1/bg.jpg/0cc187c2-6772-4547-91b1-aa609094f5d3.jpg'),
('Custom Pot', 'Personalized potted plants.', 150.00, 250.00, 350.00, '2.jpg/3aace3da-ad32-4722-b170-79fdcac9ac75.jpg');

-- ORDERS TABLE
CREATE TABLE IF NOT EXISTS orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product VARCHAR(100) NOT NULL,
    size ENUM('Small','Medium','Large') NOT NULL DEFAULT 'Small',
    quantity INT NOT NULL DEFAULT 1,
    customer_name VARCHAR(150) NOT NULL,
    email VARCHAR(150),
    phone VARCHAR(50),
    delivery_method ENUM('Pickup','Delivery') NOT NULL DEFAULT 'Pickup',
    address TEXT,
    latitude DECIMAL(10,8) DEFAULT NULL,
    longitude DECIMAL(11,8) DEFAULT NULL,
    delivery_distance_km DECIMAL(8,2) DEFAULT NULL,
    delivery_charge DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    unit_price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    total_price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    date_needed DATE NOT NULL,
    time_needed TIME DEFAULT NULL,
    flower_preferences VARCHAR(500) DEFAULT '-',
    notes TEXT,
    status ENUM('Pending','Processing','Ready','Rejected','Completed') NOT NULL DEFAULT 'Pending',
    rejection_reason TEXT DEFAULT NULL,
    approved_at DATETIME DEFAULT NULL,
    rejected_at DATETIME DEFAULT NULL,
    ready_at DATETIME DEFAULT NULL,
    completed_at DATETIME DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
