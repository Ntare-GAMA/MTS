-- Create Database
CREATE DATABASE IF NOT EXISTS mts_bakery;
USE mts_bakery;

-- Customers Table
CREATE TABLE IF NOT EXISTS customers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NOT NULL UNIQUE,
    address TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_phone (phone)
);

-- Products Table
CREATE TABLE IF NOT EXISTS products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    category VARCHAR(100) NOT NULL,
    image_url TEXT,
    rating DECIMAL(2, 1) DEFAULT 5.0,
    in_stock BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_category (category)
);

-- Orders Table
CREATE TABLE IF NOT EXISTS orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_number VARCHAR(50) UNIQUE NOT NULL,
    customer_id INT NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    payment_phone VARCHAR(20) NOT NULL,
    payment_status ENUM('pending', 'processing', 'successful', 'failed') DEFAULT 'pending',
    order_status ENUM('pending', 'confirmed', 'preparing', 'ready', 'delivered', 'cancelled') DEFAULT 'pending',
    transaction_id VARCHAR(255),
    momo_reference VARCHAR(255),
    delivery_address TEXT NOT NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    INDEX idx_order_number (order_number),
    INDEX idx_payment_status (payment_status),
    INDEX idx_order_status (order_status)
);

-- Order Items Table
CREATE TABLE IF NOT EXISTS order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    subtotal DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id),
    INDEX idx_order_id (order_id)
);

-- Payment Transactions Table
CREATE TABLE IF NOT EXISTS payment_transactions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    transaction_id VARCHAR(255) UNIQUE NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'RWF',
    payment_method VARCHAR(50) NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    status ENUM('pending', 'processing', 'successful', 'failed') DEFAULT 'pending',
    momo_transaction_id VARCHAR(255),
    momo_financial_transaction_id VARCHAR(255),
    error_message TEXT,
    callback_data JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id),
    INDEX idx_transaction_id (transaction_id),
    INDEX idx_status (status)
);

-- Insert Sample Products
INSERT INTO products (name, price, category, image_url, rating) VALUES
-- Breads
('Sourdough Bread', 3500, 'Bread', 'https://images.unsplash.com/photo-1549931319-a545dcf3bc73?w=400&h=400&fit=crop&q=80', 5.0),
('Baguette', 2000, 'Bread', 'https://images.unsplash.com/photo-1608198093002-ad4e005484ec?w=400&h=400&fit=crop&q=80', 5.0),
('Whole Wheat Bread', 2500, 'Bread', 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400&h=400&fit=crop&q=80', 5.0),
('Ciabatta', 3000, 'Bread', 'https://images.unsplash.com/photo-1586444248902-2f64eddc13df?w=400&h=400&fit=crop&q=80', 5.0),
('Rye Bread', 3200, 'Bread', 'https://images.unsplash.com/photo-1598373182133-52452f7691ef?w=400&h=400&fit=crop&q=80', 5.0),
('Focaccia', 3500, 'Bread', 'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=400&h=400&fit=crop&q=80', 5.0),
('Multigrain Bread', 3000, 'Bread', 'https://images.unsplash.com/photo-1585478259715-876acc5be8eb?w=400&h=400&fit=crop&q=80', 5.0),
('Brioche', 3800, 'Bread', 'https://images.unsplash.com/photo-1608198093002-ad4e005484ec?w=400&h=400&fit=crop&q=80', 5.0),
('Challah Bread', 4000, 'Bread', 'https://images.unsplash.com/photo-1558961363-fa8fdf82db35?w=400&h=400&fit=crop&q=80', 5.0),
('Pita Bread', 1500, 'Bread', 'https://images.unsplash.com/photo-1595853035070-59a39fe84de9?w=400&h=400&fit=crop&q=80', 5.0),
('Pumpernickel Bread', 3500, 'Bread', 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400&h=400&fit=crop&q=80', 5.0),
('French Bread', 2500, 'Bread', 'https://images.unsplash.com/photo-1586444248902-2f64eddc13df?w=400&h=400&fit=crop&q=80', 5.0),
-- Pastries
('Croissant', 2500, 'Pastries', 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=400&h=400&fit=crop&q=80', 5.0),
('Blueberry Muffin', 2000, 'Pastries', 'https://images.unsplash.com/photo-1607958996333-41aef7caefaa?w=400&h=400&fit=crop&q=80', 5.0),
('Cinnamon Roll', 2500, 'Pastries', 'https://images.unsplash.com/photo-1626094309830-abbb0c99da4a?w=400&h=400&fit=crop&q=80', 5.0),
('Fruit Tart', 3500, 'Pastries', 'https://images.unsplash.com/photo-1519915212116-7cfef71f1d3e?w=400&h=400&fit=crop&q=80', 5.0),
('Danish Pastry', 2800, 'Pastries', 'https://images.unsplash.com/photo-1509365465985-25d11c17e812?w=400&h=400&fit=crop&q=80', 5.0),
('Eclair', 3000, 'Pastries', 'https://images.unsplash.com/photo-1612182062631-19fbed77dc16?w=400&h=400&fit=crop&q=80', 5.0),
-- Cakes
('Chocolate Cake', 15000, 'Cakes', 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=400&h=400&fit=crop&q=80', 5.0),
('Wedding Cake', 50000, 'Cakes', 'https://images.unsplash.com/photo-1535254973040-607b474cb50d?w=400&h=400&fit=crop&q=80', 5.0),
('Red Velvet Cake', 18000, 'Cakes', 'https://images.unsplash.com/photo-1586985289688-ca3cf47d3e6e?w=400&h=400&fit=crop&q=80', 5.0),
('Cheesecake', 12000, 'Cakes', 'https://images.unsplash.com/photo-1533134242443-d4e2e2257e0c?w=400&h=400&fit=crop&q=80', 5.0),
-- Pizzas
('Margherita Pizza', 8000, 'Pizza', 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=400&h=400&fit=crop&q=80', 5.0),
('Pepperoni Pizza', 9000, 'Pizza', 'https://images.unsplash.com/photo-1628840042765-356cda07504e?w=400&h=400&fit=crop&q=80', 5.0),
('Vegetarian Pizza', 8500, 'Pizza', 'https://images.unsplash.com/photo-1511689660979-10d2b1aada49?w=400&h=400&fit=crop&q=80', 5.0),
('BBQ Chicken Pizza', 10000, 'Pizza', 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400&h=400&fit=crop&q=80', 5.0),
('Hawaiian Pizza', 9500, 'Pizza', 'https://images.unsplash.com/photo-1595854341625-f33ee10dbf94?w=400&h=400&fit=crop&q=80', 5.0),
('Meat Lovers Pizza', 11000, 'Pizza', 'https://images.unsplash.com/photo-1534308983496-4fabb1a015ee?w=400&h=400&fit=crop&q=80', 5.0),
-- Burgers
('Classic Beef Burger', 5000, 'Burgers', 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400&h=400&fit=crop&q=80', 5.0),
('Cheese Burger', 5500, 'Burgers', 'https://images.unsplash.com/photo-1550547660-d9450f859349?w=400&h=400&fit=crop&q=80', 5.0),
('Chicken Burger', 4500, 'Burgers', 'https://images.unsplash.com/photo-1606755962773-d324e0a13086?w=400&h=400&fit=crop&q=80', 5.0),
('Veggie Burger', 4000, 'Burgers', 'https://images.unsplash.com/photo-1520072959219-c595dc870360?w=400&h=400&fit=crop&q=80', 5.0),
('Double Burger', 7000, 'Burgers', 'https://images.unsplash.com/photo-1553979459-d2229ba7433b?w=400&h=400&fit=crop&q=80', 5.0),
-- Sides
('Sweet Potato Fries', 2500, 'Sides', 'https://images.unsplash.com/photo-1623653387945-2fd25214f8fc?w=400&h=400&fit=crop&q=80', 5.0),
('Regular Fries', 2000, 'Sides', 'https://images.unsplash.com/photo-1576107232684-1279f390859f?w=400&h=400&fit=crop&q=80', 5.0),
('Brochettes (Beef)', 3500, 'Sides', 'https://images.unsplash.com/photo-1529193591184-b1d58069ecdd?w=400&h=400&fit=crop&q=80', 5.0),
('Brochettes (Chicken)', 3000, 'Sides', 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=400&h=400&fit=crop&q=80', 5.0),
('Brochettes (Goat)', 4000, 'Sides', 'https://images.unsplash.com/photo-1603360946369-dc9bb6258143?w=400&h=400&fit=crop&q=80', 5.0),
-- Drinks
('Fresh Orange Juice', 1500, 'Drinks', 'https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=400&h=400&fit=crop&q=80', 5.0),
('Passion Fruit Juice', 1500, 'Drinks', 'https://images.unsplash.com/photo-1546173159-315724a31696?w=400&h=400&fit=crop&q=80', 5.0),
('Mango Juice', 1500, 'Drinks', 'https://images.unsplash.com/photo-1623065422902-30a2d299bbe4?w=400&h=400&fit=crop&q=80', 5.0),
('Coffee (Hot)', 1000, 'Drinks', 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=400&h=400&fit=crop&q=80', 5.0),
('Iced Coffee', 1200, 'Drinks', 'https://images.unsplash.com/photo-1517487881594-2787fef5ebf7?w=400&h=400&fit=crop&q=80', 5.0),
('Tea', 800, 'Drinks', 'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=400&h=400&fit=crop&q=80', 5.0),
('Smoothie', 2500, 'Drinks', 'https://images.unsplash.com/photo-1505252585461-04db1eb84625?w=400&h=400&fit=crop&q=80', 5.0),
('Coca Cola', 1000, 'Drinks', 'https://images.unsplash.com/photo-1554866585-cd94860890b7?w=400&h=400&fit=crop&q=80', 5.0),
('Fanta', 1000, 'Drinks', 'https://images.unsplash.com/photo-1625772299848-391b6a87d7b3?w=400&h=400&fit=crop&q=80', 5.0),
('Sprite', 1000, 'Drinks', 'https://images.unsplash.com/photo-1581006852262-e4307cf6283a?w=400&h=400&fit=crop&q=80', 5.0),
('Mineral Water', 500, 'Drinks', 'https://images.unsplash.com/photo-1548839140-29a749e1cf4d?w=400&h=400&fit=crop&q=80', 5.0),
('Milkshake', 2000, 'Drinks', 'https://images.unsplash.com/photo-1572490122747-3968b75cc699?w=400&h=400&fit=crop&q=80', 5.0);
