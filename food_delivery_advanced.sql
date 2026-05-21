-- ============================================================
--   ONLINE FOOD DELIVERY SQL PROJECT  [ ADVANCED VERSION ]
--   Phases: Setup → Data → Exploration → Analysis →
--           Advanced Queries → Views → Stored Procedures →
--           CTEs & Window Functions → Triggers → Dashboard
-- ============================================================

-- ============================================================
-- PHASE 1: DATABASE & TABLE SETUP
-- ============================================================

CREATE DATABASE IF NOT EXISTS food_delivery_pro;
USE food_delivery_pro;

-- Customers Table
CREATE TABLE IF NOT EXISTS customers (
    customer_id         INT PRIMARY KEY AUTO_INCREMENT,
    customer_name       VARCHAR(100) NOT NULL,
    email               VARCHAR(150) UNIQUE,
    phone               VARCHAR(20),
    city                VARCHAR(60),
    country             VARCHAR(60),
    loyalty_points      INT DEFAULT 0,
    registration_date   DATE
);

-- Restaurants Table
CREATE TABLE IF NOT EXISTS restaurants (
    restaurant_id       INT PRIMARY KEY AUTO_INCREMENT,
    restaurant_name     VARCHAR(150) NOT NULL,
    cuisine_type        VARCHAR(60),
    city                VARCHAR(60),
    country             VARCHAR(60),
    rating              DECIMAL(2,1),
    total_reviews       INT DEFAULT 0,
    is_active           BOOLEAN DEFAULT TRUE,
    opening_time        TIME,
    closing_time        TIME
);

-- Menu Items Table
CREATE TABLE IF NOT EXISTS menu_items (
    item_id             INT PRIMARY KEY AUTO_INCREMENT,
    restaurant_id       INT,
    item_name           VARCHAR(120) NOT NULL,
    category            VARCHAR(50),
    price               DECIMAL(8,2),
    is_available        BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id)
);

-- Delivery Agents Table
CREATE TABLE IF NOT EXISTS delivery_agents (
    agent_id            INT PRIMARY KEY AUTO_INCREMENT,
    agent_name          VARCHAR(100) NOT NULL,
    phone               VARCHAR(20),
    city                VARCHAR(60),
    country             VARCHAR(60),
    vehicle_type        VARCHAR(30),
    rating              DECIMAL(2,1) DEFAULT 5.0,
    total_deliveries    INT DEFAULT 0,
    is_active           BOOLEAN DEFAULT TRUE
);

-- Coupons Table  (NEW)
CREATE TABLE IF NOT EXISTS coupons (
    coupon_id           INT PRIMARY KEY AUTO_INCREMENT,
    coupon_code         VARCHAR(30) UNIQUE NOT NULL,
    discount_percent    DECIMAL(5,2),
    min_order_amount    DECIMAL(8,2) DEFAULT 0,
    max_discount_cap    DECIMAL(8,2),
    valid_from          DATE,
    valid_until         DATE,
    is_active           BOOLEAN DEFAULT TRUE
);

-- Orders Table
CREATE TABLE IF NOT EXISTS orders (
    order_id            INT PRIMARY KEY AUTO_INCREMENT,
    customer_id         INT,
    restaurant_id       INT,
    agent_id            INT,
    coupon_id           INT NULL,
    order_date          DATE NOT NULL,
    order_time          TIME,
    delivery_time_minutes INT,
    order_amount        DECIMAL(10,2),
    discount            DECIMAL(8,2) DEFAULT 0,
    net_amount          DECIMAL(10,2),
    payment_method      VARCHAR(30),
    order_status        VARCHAR(20) DEFAULT 'Delivered',
    city                VARCHAR(60),
    country             VARCHAR(60),
    FOREIGN KEY (customer_id)   REFERENCES customers(customer_id),
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id),
    FOREIGN KEY (agent_id)      REFERENCES delivery_agents(agent_id),
    FOREIGN KEY (coupon_id)     REFERENCES coupons(coupon_id)
);

-- Order Items Table
CREATE TABLE IF NOT EXISTS order_items (
    order_item_id       INT PRIMARY KEY AUTO_INCREMENT,
    order_id            INT,
    item_id             INT,
    quantity            INT DEFAULT 1,
    unit_price          DECIMAL(8,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (item_id)  REFERENCES menu_items(item_id)
);

-- Customer Reviews Table  (NEW)
CREATE TABLE IF NOT EXISTS reviews (
    review_id           INT PRIMARY KEY AUTO_INCREMENT,
    order_id            INT,
    customer_id         INT,
    restaurant_id       INT,
    agent_id            INT,
    food_rating         INT CHECK (food_rating BETWEEN 1 AND 5),
    delivery_rating     INT CHECK (delivery_rating BETWEEN 1 AND 5),
    review_text         TEXT,
    review_date         DATE,
    FOREIGN KEY (order_id)      REFERENCES orders(order_id),
    FOREIGN KEY (customer_id)   REFERENCES customers(customer_id),
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id),
    FOREIGN KEY (agent_id)      REFERENCES delivery_agents(agent_id)
);

-- Complaints Table  (NEW)
CREATE TABLE IF NOT EXISTS complaints (
    complaint_id        INT PRIMARY KEY AUTO_INCREMENT,
    order_id            INT,
    customer_id         INT,
    complaint_type      VARCHAR(60),   -- 'Late Delivery', 'Wrong Item', 'Quality Issue', etc.
    complaint_text      TEXT,
    status              VARCHAR(20) DEFAULT 'Open',  -- 'Open', 'Resolved', 'Closed'
    filed_date          DATE,
    resolved_date       DATE NULL,
    FOREIGN KEY (order_id)    REFERENCES orders(order_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- ============================================================
-- PHASE 2: SAMPLE DATA INSERTION
-- ============================================================

-- Customers (international)
INSERT INTO customers (customer_name, email, phone, city, country, loyalty_points, registration_date) VALUES
('James Carter',       'james@email.com',   '+1-555-0101', 'New York',   'USA',     1200, '2023-01-10'),
('Sophie Martin',      'sophie@email.com',  '+33-600-1234','Paris',      'France',   800, '2023-02-14'),
('Liam O\'Brien',      'liam@email.com',    '+44-777-5678','London',     'UK',      1500, '2023-03-20'),
('Yuki Tanaka',        'yuki@email.com',    '+81-90-1111', 'Tokyo',      'Japan',    600, '2023-04-05'),
('Carlos Mendez',      'carlos@email.com',  '+34-600-4321','Madrid',     'Spain',    950, '2023-05-18'),
('Amara Osei',         'amara@email.com',   '+234-801-555','Lagos',      'Nigeria',  400, '2023-06-22'),
('Elena Novak',        'elena@email.com',   '+7-916-3333', 'Moscow',     'Russia',   700, '2023-07-14'),
('Wei Zhang',          'wei@email.com',     '+86-138-0000','Shanghai',   'China',   2000, '2023-08-01'),
('Isabella Rossi',     'isabella@email.com','+39-333-7890','Rome',       'Italy',   1100, '2023-09-09'),
('Lucas Müller',       'lucas@email.com',   '+49-176-2222','Berlin',     'Germany', 1300, '2023-10-15'),
('Fatima Al-Rashid',   'fatima@email.com',  '+971-50-9999','Dubai',      'UAE',     1700, '2023-11-01'),
('Priya Iyer',         'priya@email.com',   '+65-9123-456','Singapore',  'Singapore',900, '2023-12-05');

-- Restaurants
INSERT INTO restaurants (restaurant_name, cuisine_type, city, country, rating, total_reviews, opening_time, closing_time) VALUES
('The Steak House',     'American',    'New York',  'USA',        4.6, 320, '11:00:00', '23:00:00'),
('Le Bistro Parisien',  'French',      'Paris',     'France',     4.8, 510, '12:00:00', '22:30:00'),
('Big Ben Burgers',     'British',     'London',    'UK',         4.2, 280, '10:00:00', '22:00:00'),
('Sakura Ramen',        'Japanese',    'Tokyo',     'Japan',      4.9, 740, '11:30:00', '23:30:00'),
('Casa de Tapas',       'Spanish',     'Madrid',    'Spain',      4.5, 360, '13:00:00', '00:00:00'),
('Jollof Kitchen',      'West African','Lagos',     'Nigeria',    4.7, 210, '09:00:00', '21:00:00'),
('Borscht & Beyond',    'Russian',     'Moscow',    'Russia',     4.1, 190, '12:00:00', '22:00:00'),
('Dynasty Dim Sum',     'Chinese',     'Shanghai',  'China',      4.8, 620, '10:00:00', '22:00:00'),
('Trattoria Roma',      'Italian',     'Rome',      'Italy',      4.7, 430, '12:30:00', '23:00:00'),
('Currywurst Haus',     'German',      'Berlin',    'Germany',    4.3, 250, '11:00:00', '21:30:00'),
('Spice Souk',          'Middle Eastern','Dubai',   'UAE',        4.6, 380, '12:00:00', '01:00:00'),
('Hawker Heaven',       'Singaporean', 'Singapore', 'Singapore',  4.9, 550, '08:00:00', '22:00:00');

-- Menu Items
INSERT INTO menu_items (restaurant_id, item_name, category, price) VALUES
(1,  'Ribeye Steak',        'Main',      45.00),
(1,  'BBQ Ribs',            'Main',      38.00),
(1,  'Caesar Salad',        'Starter',   12.00),
(2,  'Coq au Vin',          'Main',      32.00),
(2,  'Crème Brûlée',        'Dessert',   10.00),
(3,  'Classic Burger',      'Main',      14.00),
(3,  'Fish & Chips',        'Main',      16.00),
(4,  'Tonkotsu Ramen',      'Main',      18.00),
(4,  'Gyoza (6pcs)',        'Starter',    8.00),
(5,  'Patatas Bravas',      'Starter',    9.00),
(5,  'Paella Valenciana',   'Main',      28.00),
(6,  'Jollof Rice & Chicken','Main',     12.00),
(7,  'Beef Borscht',        'Soup',      10.00),
(8,  'Char Siu Bao (4pcs)', 'Dim Sum',   7.00),
(8,  'Har Gow (3pcs)',      'Dim Sum',    7.00),
(9,  'Pasta Carbonara',     'Main',      22.00),
(9,  'Tiramisu',            'Dessert',    9.00),
(10, 'Currywurst Platter',  'Main',      13.00),
(11, 'Lamb Kofta',          'Main',      24.00),
(11, 'Hummus & Pita',       'Starter',    8.00),
(12, 'Hainanese Chicken',   'Main',      14.00),
(12, 'Laksa',               'Main',      12.00);

-- Delivery Agents
INSERT INTO delivery_agents (agent_name, phone, city, country, vehicle_type, rating, total_deliveries) VALUES
('Marco Vitelli',   '+1-555-8001',  'New York',  'USA',        'Bike',    4.8, 320),
('Jean Dupont',     '+33-600-8002', 'Paris',     'France',     'Scooter', 4.6, 275),
('Oliver Smith',    '+44-777-8003', 'London',    'UK',         'Bike',    4.7, 410),
('Kenji Sato',      '+81-90-8004',  'Tokyo',     'Japan',      'Bicycle', 4.9, 500),
('Miguel Torres',   '+34-600-8005', 'Madrid',    'Spain',      'Scooter', 4.4, 230),
('Emeka Eze',       '+234-801-8006','Lagos',     'Nigeria',    'Bike',    4.5, 190),
('Ivan Petrov',     '+7-916-8007',  'Moscow',    'Russia',     'Car',     4.3, 150),
('Chen Wei',        '+86-138-8008', 'Shanghai',  'China',      'Scooter', 4.7, 360),
('Giulia Bianchi',  '+39-333-8009', 'Rome',      'Italy',      'Scooter', 4.6, 290),
('Hans Becker',     '+49-176-8010', 'Berlin',    'Germany',    'Bike',    4.4, 210),
('Rania Hassan',    '+971-50-8011', 'Dubai',     'UAE',        'Car',     4.8, 440),
('Mei Lin',         '+65-9123-8012','Singapore', 'Singapore',  'Bicycle', 4.9, 520);

-- Coupons
INSERT INTO coupons (coupon_code, discount_percent, min_order_amount, max_discount_cap, valid_from, valid_until) VALUES
('WELCOME10',  10.00, 20.00,  15.00, '2024-01-01', '2024-12-31'),
('SAVE20',     20.00, 50.00,  30.00, '2024-01-01', '2024-06-30'),
('FLASH50',    50.00, 100.00, 60.00, '2024-03-01', '2024-03-31'),
('LOYAL15',    15.00, 30.00,  20.00, '2024-01-01', '2024-12-31'),
('SUMMER25',   25.00, 40.00,  25.00, '2024-06-01', '2024-08-31');

-- Orders
INSERT INTO orders (customer_id, restaurant_id, agent_id, coupon_id, order_date, order_time, delivery_time_minutes, order_amount, discount, net_amount, payment_method, order_status, city, country) VALUES
(1,  1,  1,  1,    '2024-01-10', '12:30:00', 32,  95.00,   9.50,  85.50,  'Card',   'Delivered', 'New York',  'USA'),
(2,  2,  2,  NULL, '2024-01-12', '19:00:00', 28,  42.00,   0.00,  42.00,  'Wallet', 'Delivered', 'Paris',     'France'),
(3,  3,  3,  2,    '2024-01-15', '13:15:00', 40,  62.00,  12.40,  49.60,  'Card',   'Delivered', 'London',    'UK'),
(4,  4,  4,  NULL, '2024-01-18', '20:00:00', 22,  54.00,   0.00,  54.00,  'Cash',   'Delivered', 'Tokyo',     'Japan'),
(5,  5,  5,  4,    '2024-01-20', '14:30:00', 35,  74.00,  11.10,  62.90,  'UPI',    'Delivered', 'Madrid',    'Spain'),
(6,  6,  6,  NULL, '2024-01-22', '11:00:00', 50,  36.00,   0.00,  36.00,  'Cash',   'Delivered', 'Lagos',     'Nigeria'),
(7,  7,  7,  NULL, '2024-01-25', '18:45:00', 60,  30.00,   0.00,  30.00,  'Card',   'Delivered', 'Moscow',    'Russia'),
(8,  8,  8,  2,    '2024-01-27', '12:00:00', 25,  42.00,   8.40,  33.60,  'Wallet', 'Delivered', 'Shanghai',  'China'),
(9,  9,  9,  NULL, '2024-01-29', '21:00:00', 38,  62.00,   0.00,  62.00,  'Card',   'Delivered', 'Rome',      'Italy'),
(10,10, 10,  1,    '2024-02-02', '13:00:00', 30,  52.00,   5.20,  46.80,  'Card',   'Delivered', 'Berlin',    'Germany'),
(11,11, 11,  NULL, '2024-02-05', '20:30:00', 20,  80.00,   0.00,  80.00,  'Wallet', 'Delivered', 'Dubai',     'UAE'),
(12,12, 12,  4,    '2024-02-08', '12:45:00', 18,  52.00,   7.80,  44.20,  'Card',   'Delivered', 'Singapore', 'Singapore'),
(1,  4,  1,  NULL, '2024-02-10', '19:15:00', 42,  72.00,   0.00,  72.00,  'Card',   'Delivered', 'New York',  'USA'),
(3,  9,  3,  2,    '2024-02-14', '20:00:00', 35,  84.00,  16.80,  67.20,  'Cash',   'Delivered', 'London',    'UK'),
(8, 12,  8,  NULL, '2024-02-18', '13:30:00', 22,  52.00,   0.00,  52.00,  'Wallet', 'Delivered', 'Shanghai',  'China'),
(4,  8,  4,  3,    '2024-03-01', '11:00:00', 28,  105.00, 60.00,  45.00,  'Cash',   'Delivered', 'Tokyo',     'Japan'),
(11, 1,  11, NULL, '2024-03-05', '21:00:00', 48,  120.00,  0.00, 120.00,  'Card',   'Delivered', 'Dubai',     'UAE'),
(2,  4,  2,  NULL, '2024-03-08', '19:00:00', 26,  54.00,   0.00,  54.00,  'Wallet', 'Delivered', 'Paris',     'France'),
(9, 11,  9,  4,    '2024-03-12', '20:30:00', 55,  96.00,  14.40,  81.60,  'Card',   'Delivered', 'Rome',      'Italy'),
(5,  2,  5,  NULL, '2024-03-15', '18:00:00', 45,  64.00,   0.00,  64.00,  'UPI',    'Delivered', 'Madrid',    'Spain'),
(6, 12,  6,  1,    '2024-03-18', '12:00:00', 30,  42.00,   4.20,  37.80,  'Cash',   'Delivered', 'Lagos',     'Nigeria'),
(10, 4,  10, NULL, '2024-03-20', '13:30:00', 65,  90.00,   0.00,  90.00,  'Card',   'Cancelled', 'Berlin',    'Germany'),
(7,  8,  7,  2,    '2024-03-22', '14:00:00', 35,  56.00,  11.20,  44.80,  'Wallet', 'Delivered', 'Moscow',    'Russia'),
(12, 9,  12, NULL, '2024-03-25', '19:00:00', 40,  53.00,   0.00,  53.00,  'Card',   'Delivered', 'Singapore', 'Singapore'),
(1,  11, 1,  NULL, '2024-04-02', '20:00:00', 25,  76.00,   0.00,  76.00,  'Card',   'Delivered', 'New York',  'USA');

-- Order Items
INSERT INTO order_items (order_id, item_id, quantity, unit_price) VALUES
(1,  1,  2, 45.00), (1,  3,  1, 12.00),
(2,  4,  1, 32.00), (2,  5,  1, 10.00),
(3,  6,  2, 14.00), (3,  7,  1, 16.00),
(4,  8,  2, 18.00), (4,  9,  2,  8.00),
(5, 10,  2,  9.00), (5, 11,  2, 28.00),
(6, 12,  3, 12.00),
(7, 13,  3, 10.00),
(8, 14,  3,  7.00), (8, 15,  3,  7.00),
(9, 16,  2, 22.00), (9, 17,  2,  9.00),
(10,18,  4, 13.00),
(11,19,  2, 24.00), (11,20,  4,  8.00),
(12,21,  2, 14.00), (12,22,  2, 12.00),
(13, 8,  2, 18.00), (13, 9,  4,  8.00),
(14,16,  2, 22.00), (14,17,  4,  9.00),
(15,21,  2, 14.00), (15,22,  2, 12.00),
(16,14,  4,  7.00), (16,15,  4,  7.00), (16, 8, 3, 18.00),
(17, 1,  2, 45.00), (17, 2,  1, 38.00),
(18, 8,  3, 18.00),
(19,19,  2, 24.00), (19,20,  3,  8.00), (19,11,1,28.00),
(20, 4,  2, 32.00),
(21,21,  2, 14.00), (21,22,  1, 12.00),
(22, 8,  3, 18.00), (22, 9,  4,  8.00),
(23,14,  4,  7.00), (23,15,  4,  7.00),
(24,16,  1, 22.00), (24,17,  1,  9.00), (24,22,2,12.00),
(25,19,  2, 24.00), (25,20,  1,  8.00);

-- Reviews
INSERT INTO reviews (order_id, customer_id, restaurant_id, agent_id, food_rating, delivery_rating, review_text, review_date) VALUES
(1,  1,  1,  1, 5, 5, 'Amazing steak, delivered hot!',              '2024-01-10'),
(2,  2,  2,  2, 5, 4, 'Wonderful French food, slightly late.',       '2024-01-12'),
(3,  3,  3,  3, 4, 4, 'Good burger, packaging could be better.',     '2024-01-15'),
(4,  4,  4,  4, 5, 5, 'Best ramen I have had in years.',             '2024-01-18'),
(5,  5,  5,  5, 4, 3, 'Nice tapas but delivery was slow.',           '2024-01-20'),
(6,  6,  6,  6, 5, 4, 'Authentic jollof rice, loved it!',            '2024-01-22'),
(9,  9,  9,  9, 5, 5, 'Pasta perfetto! Will order again.',           '2024-01-29'),
(11,11, 11, 11, 5, 5, 'Lamb kofta was outstanding, fast delivery.',  '2024-02-05'),
(12,12, 12, 12, 5, 5, 'Hawker food at its best!',                    '2024-02-08'),
(17,11,  1, 11, 4, 4, 'Good steak but slightly overcooked.',         '2024-03-05');

-- Complaints
INSERT INTO complaints (order_id, customer_id, complaint_type, complaint_text, status, filed_date, resolved_date) VALUES
(6,  6, 'Late Delivery',   'Order arrived 25 minutes after the estimated time.', 'Resolved', '2024-01-22', '2024-01-24'),
(7,  7, 'Quality Issue',   'Food was cold on arrival.',                           'Resolved', '2024-01-25', '2024-01-26'),
(19, 9, 'Late Delivery',   'Delivery took over 55 minutes.',                     'Open',     '2024-03-12', NULL),
(22,10, 'Wrong Item',      'Received spicy version instead of regular.',          'Open',     '2024-03-20', NULL),
(5,  5, 'Quality Issue',   'Paella was undercooked.',                             'Closed',   '2024-01-20', '2024-01-23');

-- ============================================================
-- PHASE 3: BASIC DATA EXPLORATION
-- ============================================================

-- View all tables overview
SELECT 'customers'    AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL
SELECT 'restaurants',  COUNT(*) FROM restaurants
UNION ALL
SELECT 'orders',       COUNT(*) FROM orders
UNION ALL
SELECT 'order_items',  COUNT(*) FROM order_items
UNION ALL
SELECT 'reviews',      COUNT(*) FROM reviews
UNION ALL
SELECT 'complaints',   COUNT(*) FROM complaints;

-- Total revenue (gross vs net)
SELECT
    SUM(order_amount)           AS gross_revenue,
    SUM(discount)               AS total_discounts_given,
    SUM(net_amount)             AS net_revenue
FROM orders
WHERE order_status = 'Delivered';

-- Orders by status
SELECT order_status, COUNT(*) AS order_count
FROM orders
GROUP BY order_status;

-- Orders by payment method
SELECT payment_method, COUNT(*) AS order_count,
       ROUND(SUM(net_amount), 2) AS total_revenue
FROM orders
GROUP BY payment_method
ORDER BY total_revenue DESC;

-- ============================================================
-- PHASE 4: CUSTOMER ANALYSIS
-- ============================================================

-- Top customers by net spending
SELECT
    c.customer_name,
    c.city,
    c.country,
    c.loyalty_points,
    COUNT(o.order_id)               AS total_orders,
    ROUND(SUM(o.net_amount), 2)     AS total_spent,
    ROUND(AVG(o.net_amount), 2)     AS avg_order_value
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_status = 'Delivered'
GROUP BY c.customer_id, c.customer_name, c.city, c.country, c.loyalty_points
ORDER BY total_spent DESC;

-- Customer segmentation by spend
SELECT
    c.customer_name,
    c.country,
    ROUND(SUM(o.net_amount), 2) AS total_spent,
    CASE
        WHEN SUM(o.net_amount) >= 200 THEN 'Premium'
        WHEN SUM(o.net_amount) >= 100 THEN 'Regular'
        ELSE 'Casual'
    END AS customer_segment
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name, c.country
ORDER BY total_spent DESC;

-- Customers who have never placed an order
SELECT c.customer_name, c.city, c.country, c.registration_date
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- Country-wise customer count
SELECT country, COUNT(*) AS customer_count
FROM customers
GROUP BY country
ORDER BY customer_count DESC;

-- ============================================================
-- PHASE 5: RESTAURANT & REVENUE ANALYSIS
-- ============================================================

-- Top restaurants by net revenue
SELECT
    r.restaurant_name,
    r.cuisine_type,
    r.city,
    r.country,
    r.rating,
    COUNT(o.order_id)               AS total_orders,
    ROUND(SUM(o.net_amount), 2)     AS net_revenue,
    ROUND(AVG(o.net_amount), 2)     AS avg_order_value
FROM restaurants r
JOIN orders o ON r.restaurant_id = o.restaurant_id
WHERE o.order_status = 'Delivered'
GROUP BY r.restaurant_id, r.restaurant_name, r.cuisine_type, r.city, r.country, r.rating
ORDER BY net_revenue DESC;

-- Revenue by cuisine type
SELECT
    r.cuisine_type,
    COUNT(o.order_id)               AS total_orders,
    ROUND(SUM(o.net_amount), 2)     AS net_revenue
FROM restaurants r
JOIN orders o ON r.restaurant_id = o.restaurant_id
GROUP BY r.cuisine_type
ORDER BY net_revenue DESC;

-- Country-wise order summary
SELECT
    o.country,
    COUNT(o.order_id)               AS total_orders,
    ROUND(SUM(o.order_amount), 2)   AS gross_revenue,
    ROUND(SUM(o.net_amount), 2)     AS net_revenue,
    ROUND(AVG(o.delivery_time_minutes), 1) AS avg_delivery_mins
FROM orders o
GROUP BY o.country
ORDER BY net_revenue DESC;

-- ============================================================
-- PHASE 6: DELIVERY PERFORMANCE ANALYSIS
-- ============================================================

-- Agent performance leaderboard
SELECT
    da.agent_name,
    da.city,
    da.country,
    da.vehicle_type,
    da.rating                                   AS agent_rating,
    COUNT(o.order_id)                           AS total_deliveries,
    ROUND(AVG(o.delivery_time_minutes), 1)      AS avg_delivery_mins,
    MIN(o.delivery_time_minutes)                AS fastest_delivery,
    MAX(o.delivery_time_minutes)                AS slowest_delivery
FROM delivery_agents da
JOIN orders o ON da.agent_id = o.agent_id
GROUP BY da.agent_id, da.agent_name, da.city, da.country, da.vehicle_type, da.rating
ORDER BY avg_delivery_mins;

-- Delayed orders (> 45 mins)
SELECT
    o.order_id,
    c.customer_name,
    r.restaurant_name,
    da.agent_name,
    o.delivery_time_minutes,
    o.city,
    o.order_date
FROM orders o
JOIN customers       c  ON o.customer_id    = c.customer_id
JOIN restaurants     r  ON o.restaurant_id  = r.restaurant_id
JOIN delivery_agents da ON o.agent_id       = da.agent_id
WHERE o.delivery_time_minutes > 45
ORDER BY o.delivery_time_minutes DESC;

-- Vehicle type vs average delivery time
SELECT
    da.vehicle_type,
    COUNT(o.order_id)                       AS total_deliveries,
    ROUND(AVG(o.delivery_time_minutes), 1)  AS avg_delivery_mins
FROM delivery_agents da
JOIN orders o ON da.agent_id = o.agent_id
GROUP BY da.vehicle_type
ORDER BY avg_delivery_mins;

-- ============================================================
-- PHASE 7: REVIEWS & COMPLAINTS ANALYSIS
-- ============================================================

-- Average food and delivery ratings per restaurant
SELECT
    r.restaurant_name,
    r.city,
    COUNT(rv.review_id)                     AS total_reviews,
    ROUND(AVG(rv.food_rating), 2)           AS avg_food_rating,
    ROUND(AVG(rv.delivery_rating), 2)       AS avg_delivery_rating,
    r.rating                                AS overall_rating
FROM restaurants r
JOIN reviews rv ON r.restaurant_id = rv.restaurant_id
GROUP BY r.restaurant_id, r.restaurant_name, r.city, r.rating
ORDER BY avg_food_rating DESC;

-- Complaints breakdown by type and status
SELECT
    complaint_type,
    status,
    COUNT(*) AS complaint_count
FROM complaints
GROUP BY complaint_type, status
ORDER BY complaint_type, status;

-- Average complaint resolution time (days)
SELECT
    complaint_type,
    ROUND(AVG(DATEDIFF(resolved_date, filed_date)), 1) AS avg_resolution_days
FROM complaints
WHERE resolved_date IS NOT NULL
GROUP BY complaint_type;

-- Customers with complaints
SELECT
    c.customer_name,
    c.city,
    COUNT(co.complaint_id) AS total_complaints
FROM customers c
JOIN complaints co ON c.customer_id = co.customer_id
GROUP BY c.customer_id, c.customer_name, c.city
ORDER BY total_complaints DESC;

-- ============================================================
-- PHASE 8: COUPON & DISCOUNT ANALYSIS
-- ============================================================

-- Coupon usage frequency
SELECT
    cp.coupon_code,
    cp.discount_percent,
    COUNT(o.order_id)               AS times_used,
    ROUND(SUM(o.discount), 2)       AS total_discount_given,
    ROUND(SUM(o.net_amount), 2)     AS net_revenue_generated
FROM coupons cp
JOIN orders o ON cp.coupon_id = o.coupon_id
GROUP BY cp.coupon_id, cp.coupon_code, cp.discount_percent
ORDER BY times_used DESC;

-- Orders with vs without coupons
SELECT
    CASE WHEN coupon_id IS NOT NULL THEN 'With Coupon' ELSE 'No Coupon' END AS coupon_usage,
    COUNT(*)                            AS order_count,
    ROUND(AVG(order_amount), 2)         AS avg_gross_amount,
    ROUND(AVG(net_amount), 2)           AS avg_net_amount,
    ROUND(SUM(discount), 2)             AS total_discount
FROM orders
GROUP BY coupon_usage;

-- ============================================================
-- PHASE 9: ADVANCED QUERIES & BUSINESS INSIGHTS
-- ============================================================

-- Monthly revenue trend (gross vs net)
SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    COUNT(order_id)                  AS total_orders,
    ROUND(SUM(order_amount), 2)      AS gross_revenue,
    ROUND(SUM(net_amount), 2)        AS net_revenue,
    ROUND(SUM(discount), 2)          AS total_discounts
FROM orders
GROUP BY month
ORDER BY month;

-- Best day of week for orders
SELECT
    DAYNAME(order_date)         AS day_of_week,
    COUNT(order_id)             AS total_orders,
    ROUND(SUM(net_amount), 2)   AS total_revenue
FROM orders
GROUP BY day_of_week
ORDER BY total_revenue DESC;

-- Peak order hours
SELECT
    HOUR(order_time)            AS order_hour,
    COUNT(order_id)             AS total_orders
FROM orders
GROUP BY order_hour
ORDER BY total_orders DESC;

-- High-value orders (net > 100)
SELECT
    o.order_id,
    c.customer_name,
    r.restaurant_name,
    o.net_amount,
    o.order_date,
    o.city,
    o.country
FROM orders o
JOIN customers   c ON o.customer_id   = c.customer_id
JOIN restaurants r ON o.restaurant_id = r.restaurant_id
WHERE o.net_amount > 100
ORDER BY o.net_amount DESC;

-- Restaurants with cancelled orders
SELECT
    r.restaurant_name,
    COUNT(o.order_id) AS cancelled_orders
FROM restaurants r
JOIN orders o ON r.restaurant_id = o.restaurant_id
WHERE o.order_status = 'Cancelled'
GROUP BY r.restaurant_id, r.restaurant_name;

-- ============================================================
-- PHASE 10: VIEWS
-- ============================================================

-- View 1: Customer Order Summary
CREATE OR REPLACE VIEW vw_customer_summary AS
SELECT
    c.customer_id,
    c.customer_name,
    c.city,
    c.country,
    c.loyalty_points,
    COUNT(o.order_id)               AS total_orders,
    ROUND(SUM(o.net_amount), 2)     AS total_spent,
    ROUND(AVG(o.net_amount), 2)     AS avg_order_value,
    MAX(o.order_date)               AS last_order_date
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
    AND o.order_status = 'Delivered'
GROUP BY c.customer_id, c.customer_name, c.city, c.country, c.loyalty_points;

-- View 2: Restaurant Performance Dashboard
CREATE OR REPLACE VIEW vw_restaurant_performance AS
SELECT
    r.restaurant_id,
    r.restaurant_name,
    r.cuisine_type,
    r.city,
    r.country,
    r.rating                                AS listed_rating,
    COUNT(DISTINCT o.order_id)              AS total_orders,
    ROUND(SUM(o.net_amount), 2)             AS net_revenue,
    ROUND(AVG(o.delivery_time_minutes), 1)  AS avg_delivery_mins,
    ROUND(AVG(rv.food_rating), 2)           AS avg_food_rating,
    COUNT(DISTINCT rv.review_id)            AS total_reviews
FROM restaurants r
LEFT JOIN orders  o  ON r.restaurant_id = o.restaurant_id  AND o.order_status = 'Delivered'
LEFT JOIN reviews rv ON r.restaurant_id = rv.restaurant_id
GROUP BY r.restaurant_id, r.restaurant_name, r.cuisine_type, r.city, r.country, r.rating;

-- View 3: Delayed Orders View
CREATE OR REPLACE VIEW vw_delayed_orders AS
SELECT
    o.order_id,
    c.customer_name,
    r.restaurant_name,
    da.agent_name,
    o.delivery_time_minutes,
    o.order_date,
    o.city,
    o.country
FROM orders o
JOIN customers       c  ON o.customer_id   = c.customer_id
JOIN restaurants     r  ON o.restaurant_id = r.restaurant_id
JOIN delivery_agents da ON o.agent_id      = da.agent_id
WHERE o.delivery_time_minutes > 45;

-- Use the views
SELECT * FROM vw_customer_summary    ORDER BY total_spent DESC;
SELECT * FROM vw_restaurant_performance ORDER BY net_revenue DESC;
SELECT * FROM vw_delayed_orders;

-- ============================================================
-- PHASE 11: STORED PROCEDURES
-- ============================================================

-- Procedure 1: Get orders for a given customer
DROP PROCEDURE IF EXISTS sp_customer_orders;

CREATE PROCEDURE sp_customer_orders(IN p_customer_id INT)
BEGIN
    SELECT
        o.order_id,
        r.restaurant_name,
        o.order_date,
        o.order_amount,
        o.discount,
        o.net_amount,
        o.delivery_time_minutes,
        o.order_status
    FROM orders o
    JOIN restaurants r ON o.restaurant_id = r.restaurant_id
    WHERE o.customer_id = p_customer_id
    ORDER BY o.order_date DESC;
END;

-- Test Procedure 1
CALL sp_customer_orders(1);

-- -----------------------------------------------------------

-- Procedure 2: Revenue report by country and month
DROP PROCEDURE IF EXISTS sp_revenue_report;

CREATE PROCEDURE sp_revenue_report(IN p_country VARCHAR(60), IN p_month VARCHAR(7))
BEGIN
    SELECT
        o.country,
        DATE_FORMAT(o.order_date, '%Y-%m')  AS month,
        COUNT(o.order_id)                   AS total_orders,
        ROUND(SUM(o.order_amount), 2)       AS gross_revenue,
        ROUND(SUM(o.discount), 2)           AS total_discount,
        ROUND(SUM(o.net_amount), 2)         AS net_revenue
    FROM orders o
    WHERE o.country = p_country
      AND DATE_FORMAT(o.order_date, '%Y-%m') = p_month
    GROUP BY o.country, month;
END;

-- Test Procedure 2
CALL sp_revenue_report('USA', '2024-01');
CALL sp_revenue_report('Japan', '2024-01');

-- -----------------------------------------------------------

-- Procedure 3: Agent delivery stats
DROP PROCEDURE IF EXISTS sp_agent_stats;

CREATE PROCEDURE sp_agent_stats(IN p_agent_id INT)
BEGIN
    SELECT
        da.agent_name,
        da.vehicle_type,
        da.city,
        COUNT(o.order_id)                       AS total_deliveries,
        ROUND(AVG(o.delivery_time_minutes), 1)  AS avg_delivery_mins,
        SUM(CASE WHEN o.delivery_time_minutes > 45 THEN 1 ELSE 0 END) AS delayed_count
    FROM delivery_agents da
    JOIN orders o ON da.agent_id = o.agent_id
    WHERE da.agent_id = p_agent_id
    GROUP BY da.agent_id, da.agent_name, da.vehicle_type, da.city;
END;

-- Test Procedure 3
CALL sp_agent_stats(4);

-- ============================================================
-- PHASE 12: CTEs & WINDOW FUNCTIONS
-- ============================================================

-- CTE 1: Revenue per restaurant with running total
WITH restaurant_revenue AS (
    SELECT
        r.restaurant_name,
        r.country,
        ROUND(SUM(o.net_amount), 2) AS net_revenue
    FROM restaurants r
    JOIN orders o ON r.restaurant_id = o.restaurant_id
    WHERE o.order_status = 'Delivered'
    GROUP BY r.restaurant_id, r.restaurant_name, r.country
)
SELECT
    restaurant_name,
    country,
    net_revenue,
    SUM(net_revenue) OVER (ORDER BY net_revenue DESC) AS running_total_revenue
FROM restaurant_revenue
ORDER BY net_revenue DESC;

-- ---------------------------------------------------------

-- CTE 2: Customer order ranking within each country
WITH customer_spending AS (
    SELECT
        c.customer_id,
        c.customer_name,
        c.country,
        ROUND(SUM(o.net_amount), 2) AS total_spent
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    WHERE o.order_status = 'Delivered'
    GROUP BY c.customer_id, c.customer_name, c.country
)
SELECT
    customer_name,
    country,
    total_spent,
    RANK() OVER (PARTITION BY country ORDER BY total_spent DESC) AS country_rank
FROM customer_spending;

-- ---------------------------------------------------------

-- Window Function 1: Month-over-month revenue change
WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS month,
        ROUND(SUM(net_amount), 2)        AS net_revenue
    FROM orders
    GROUP BY month
)
SELECT
    month,
    net_revenue,
    LAG(net_revenue) OVER (ORDER BY month)                                   AS prev_month_revenue,
    ROUND(net_revenue - LAG(net_revenue) OVER (ORDER BY month), 2)           AS revenue_change,
    ROUND(
        (net_revenue - LAG(net_revenue) OVER (ORDER BY month))
        / NULLIF(LAG(net_revenue) OVER (ORDER BY month), 0) * 100, 2
    )                                                                        AS pct_change
FROM monthly_revenue
ORDER BY month;

-- ---------------------------------------------------------

-- Window Function 2: Delivery time percentile per country
SELECT
    o.order_id,
    o.country,
    o.delivery_time_minutes,
    ROUND(PERCENT_RANK() OVER (PARTITION BY o.country ORDER BY o.delivery_time_minutes), 2) AS delivery_percentile,
    NTILE(4) OVER (PARTITION BY o.country ORDER BY o.delivery_time_minutes)                 AS delivery_quartile
FROM orders o
ORDER BY o.country, o.delivery_time_minutes;

-- ---------------------------------------------------------

-- Window Function 3: Rolling 3-order average per customer
SELECT
    c.customer_name,
    o.order_date,
    o.net_amount,
    ROUND(
        AVG(o.net_amount) OVER (
            PARTITION BY o.customer_id
            ORDER BY o.order_date
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ), 2
    ) AS rolling_3_avg
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
ORDER BY c.customer_name, o.order_date;

-- ---------------------------------------------------------

-- CTE 3: Top menu item per restaurant by quantity sold
WITH item_sales AS (
    SELECT
        mi.restaurant_id,
        mi.item_name,
        SUM(oi.quantity)    AS total_qty_sold,
        ROUND(SUM(oi.quantity * oi.unit_price), 2) AS item_revenue,
        ROW_NUMBER() OVER (
            PARTITION BY mi.restaurant_id
            ORDER BY SUM(oi.quantity) DESC
        ) AS item_rank
    FROM order_items oi
    JOIN menu_items mi ON oi.item_id = mi.item_id
    GROUP BY mi.restaurant_id, mi.item_id, mi.item_name
)
SELECT
    r.restaurant_name,
    r.country,
    is2.item_name       AS best_selling_item,
    is2.total_qty_sold,
    is2.item_revenue
FROM item_sales is2
JOIN restaurants r ON is2.restaurant_id = r.restaurant_id
WHERE is2.item_rank = 1
ORDER BY is2.total_qty_sold DESC;

-- ============================================================
-- PHASE 13: PERFORMANCE OPTIMIZATION – INDEXES
-- ============================================================

CREATE INDEX idx_orders_date        ON orders(order_date);
CREATE INDEX idx_orders_country     ON orders(country);
CREATE INDEX idx_orders_status      ON orders(order_status);
CREATE INDEX idx_orders_net_amount  ON orders(net_amount);
CREATE INDEX idx_customer_name      ON customers(customer_name);
CREATE INDEX idx_customer_country   ON customers(country);
CREATE INDEX idx_restaurant_name    ON restaurants(restaurant_name);
CREATE INDEX idx_reviews_restaurant ON reviews(restaurant_id);
CREATE INDEX idx_complaints_status  ON complaints(status);

-- View index usage
SHOW INDEX FROM orders;

-- Query performance test
EXPLAIN SELECT * FROM orders WHERE order_date = '2024-01-10';
EXPLAIN SELECT * FROM customers WHERE country = 'Japan';

-- ============================================================
-- PHASE 14: TRIGGERS – AUTOMATION & DATA INTEGRITY
-- ============================================================

-- ---------------------------------------------------------
-- Trigger 1: Auto-calculate net_amount on INSERT
-- ---------------------------------------------------------

CREATE TRIGGER trg_calc_net_amount
BEFORE INSERT ON orders
FOR EACH ROW
BEGIN
    IF NEW.discount < 0 THEN
        SET NEW.discount = 0;
    END IF;
    SET NEW.net_amount = NEW.order_amount - NEW.discount;
END;

-- ---------------------------------------------------------
-- Trigger 2: Log high-value orders (net > 100)
-- ---------------------------------------------------------

CREATE TABLE IF NOT EXISTS high_value_orders_log (
    log_id          INT PRIMARY KEY AUTO_INCREMENT,
    order_id        INT,
    customer_id     INT,
    net_amount      DECIMAL(10,2),
    order_date      DATE,
    country         VARCHAR(60),
    logged_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER trg_high_value_log
AFTER INSERT ON orders
FOR EACH ROW
BEGIN
    IF NEW.net_amount > 100 THEN
        INSERT INTO high_value_orders_log (order_id, customer_id, net_amount, order_date, country)
        VALUES (NEW.order_id, NEW.customer_id, NEW.net_amount, NEW.order_date, NEW.country);
    END IF;
END;

-- ---------------------------------------------------------
-- Trigger 3: Auto-log delayed deliveries
-- ---------------------------------------------------------

CREATE TABLE IF NOT EXISTS delivery_delay_log (
    log_id                  INT PRIMARY KEY AUTO_INCREMENT,
    order_id                INT,
    customer_id             INT,
    agent_id                INT,
    delivery_time_minutes   INT,
    city                    VARCHAR(60),
    order_date              DATE,
    logged_at               TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER trg_delay_log
AFTER INSERT ON orders
FOR EACH ROW
BEGIN
    IF NEW.delivery_time_minutes > 45 THEN
        INSERT INTO delivery_delay_log
            (order_id, customer_id, agent_id, delivery_time_minutes, city, order_date)
        VALUES
            (NEW.order_id, NEW.customer_id, NEW.agent_id,
             NEW.delivery_time_minutes, NEW.city, NEW.order_date);
    END IF;
END;

-- ---------------------------------------------------------
-- Trigger 4: Auto-update restaurant total_reviews on new review
-- ---------------------------------------------------------

CREATE TRIGGER trg_update_review_count
AFTER INSERT ON reviews
FOR EACH ROW
BEGIN
    UPDATE restaurants
    SET total_reviews = total_reviews + 1
    WHERE restaurant_id = NEW.restaurant_id;
END;

-- ============================================================
-- TRIGGER TESTING
-- ============================================================

-- Test 1: High-value order → logged in high_value_orders_log
INSERT INTO orders
    (customer_id, restaurant_id, agent_id, coupon_id, order_date, order_time,
     delivery_time_minutes, order_amount, discount, net_amount,
     payment_method, order_status, city, country)
VALUES
    (1, 1, 1, NULL, '2024-05-01', '20:00:00', 25, 180.00, 0.00, 180.00,
     'Card', 'Delivered', 'New York', 'USA');

-- Test 2: Delayed order → logged in delivery_delay_log
INSERT INTO orders
    (customer_id, restaurant_id, agent_id, coupon_id, order_date, order_time,
     delivery_time_minutes, order_amount, discount, net_amount,
     payment_method, order_status, city, country)
VALUES
    (5, 5, 5, NULL, '2024-05-02', '21:00:00', 70, 80.00, 0.00, 80.00,
     'Cash', 'Delivered', 'Madrid', 'Spain');

-- Test 3: Negative discount → should be saved as 0
INSERT INTO orders
    (customer_id, restaurant_id, agent_id, coupon_id, order_date, order_time,
     delivery_time_minutes, order_amount, discount, net_amount,
     payment_method, order_status, city, country)
VALUES
    (3, 3, 3, NULL, '2024-05-03', '13:00:00', 28, 45.00, -10.00, 0.00,
     'Card', 'Delivered', 'London', 'UK');

-- Test 4: New review → restaurant total_reviews should increment
INSERT INTO reviews
    (order_id, customer_id, restaurant_id, agent_id, food_rating, delivery_rating,
     review_text, review_date)
VALUES (1, 1, 1, 1, 5, 5, 'Absolutely incredible, best meal ever!', '2024-05-01');

-- Verify Trigger Results
SELECT * FROM high_value_orders_log;
SELECT * FROM delivery_delay_log;
SELECT order_id, discount, net_amount FROM orders WHERE order_date = '2024-05-03';  -- discount = 0
SELECT restaurant_id, total_reviews FROM restaurants WHERE restaurant_id = 1;       -- count increased

-- ============================================================
-- DASHBOARD QUERIES
-- ============================================================

-- KPI 1: Total Gross Revenue
SELECT ROUND(SUM(order_amount), 2) AS gross_revenue FROM orders WHERE order_status = 'Delivered';

-- KPI 2: Total Net Revenue
SELECT ROUND(SUM(net_amount), 2) AS net_revenue FROM orders WHERE order_status = 'Delivered';

-- KPI 3: Total Orders
SELECT COUNT(order_id) AS total_orders FROM orders;

-- KPI 4: Average Net Order Value
SELECT ROUND(AVG(net_amount), 2) AS avg_net_order_value FROM orders WHERE order_status = 'Delivered';

-- KPI 5: Average Delivery Time
SELECT ROUND(AVG(delivery_time_minutes), 1) AS avg_delivery_mins FROM orders WHERE order_status = 'Delivered';

-- KPI 6: Overall Complaint Resolution Rate
SELECT
    ROUND(SUM(CASE WHEN status != 'Open' THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS resolution_rate_pct
FROM complaints;

-- Chart 1: Country-wise Net Revenue (Bar Chart)
SELECT country, ROUND(SUM(net_amount), 2) AS net_revenue
FROM orders WHERE order_status = 'Delivered'
GROUP BY country ORDER BY net_revenue DESC;

-- Chart 2: Top Restaurants by Revenue (Horizontal Bar)
SELECT r.restaurant_name, ROUND(SUM(o.net_amount), 2) AS net_revenue
FROM restaurants r JOIN orders o ON r.restaurant_id = o.restaurant_id
WHERE o.order_status = 'Delivered'
GROUP BY r.restaurant_name ORDER BY net_revenue DESC LIMIT 10;

-- Chart 3: Monthly Revenue Trend (Line Chart)
SELECT DATE_FORMAT(order_date, '%Y-%m') AS month,
       ROUND(SUM(net_amount), 2)        AS net_revenue
FROM orders GROUP BY month ORDER BY month;

-- Chart 4: Payment Method Split (Donut Chart)
SELECT payment_method, COUNT(*) AS order_count
FROM orders GROUP BY payment_method ORDER BY order_count DESC;

-- Chart 5: Delivery Time Distribution by Country (Box Chart)
SELECT country,
       MIN(delivery_time_minutes)                       AS min_time,
       ROUND(AVG(delivery_time_minutes), 1)             AS avg_time,
       MAX(delivery_time_minutes)                       AS max_time
FROM orders GROUP BY country ORDER BY avg_time;

-- Chart 6: Cuisine Popularity (Pie Chart)
SELECT r.cuisine_type, COUNT(o.order_id) AS total_orders
FROM restaurants r JOIN orders o ON r.restaurant_id = o.restaurant_id
GROUP BY r.cuisine_type ORDER BY total_orders DESC;

-- Chart 7: Complaint Type Breakdown (Stacked Bar)
SELECT complaint_type, status, COUNT(*) AS count
FROM complaints
GROUP BY complaint_type, status;

-- ============================================================
-- END OF PROJECT
-- ============================================================
