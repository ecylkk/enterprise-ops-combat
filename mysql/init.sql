-- 03-MySQL 核心实战：建表、索引、关联

USE ops_combat_db;

-- 1. 用户表
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_email (email) -- 唯一索引，防止重复注册
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. 订单表 (模拟高并发核心业务表)
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    status TINYINT NOT NULL COMMENT '0:未支付 1:已支付 2:已取消',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- 核心面试点：为什么加这个索引？
    -- 面试回答：因为客服系统经常通过用户ID查订单，如果不加，100万个订单就会扫全表卡死！
    INDEX idx_user_id (user_id) 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 插入一些演示数据
INSERT INTO users (username, email) VALUES ('dysensei', 'dy@google.com');
INSERT INTO orders (user_id, total_amount, status) VALUES (1, 99.50, 1);

-- 面试题演示：LEFT JOIN 
-- 查出所有用户及其订单金额（哪怕没下单的用户也会显示NULL）
-- SELECT u.username, o.total_amount FROM users u LEFT JOIN orders o ON u.id = o.user_id;
