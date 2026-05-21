# 🍔 Online Food Delivery — SQL Project

![SQL](https://img.shields.io/badge/Database-MySQL%209.0-blue)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen)
![Phase](https://img.shields.io/badge/Phases-1--9-orange)

---

## 📌 Project Overview

This is a complete end-to-end **SQL project** built on an **Online Food Delivery** dataset.  
The project covers database design, data insertion, business analysis, performance optimization using indexes, and automation using triggers — across **9 structured phases**.

---

## 🎯 Business Objectives

- Analyze customer ordering behavior and spending patterns
- Identify top-performing restaurants and cuisine types
- Monitor delivery performance across cities and agents
- Detect high-value orders and delivery delays automatically
- Optimize query performance using indexing
- Automate data integrity checks using triggers

---

## 🗂️ Dataset Overview

| Table | Description |
|---|---|
| `customers` | Customer details — name, city, registration date |
| `restaurants` | Restaurant info — cuisine type, city, rating |
| `menu_items` | Menu items with price and availability |
| `delivery_agents` | Agent details — vehicle type, city |
| `orders` | Core transaction table — amount, date, delivery time |
| `order_items` | Line items per order |

---

## 🏗️ Project Phases

### ✅ Phase 1 — Database & Table Setup
- Created normalized database schema
- Defined primary keys, foreign keys, and constraints
- 6 tables: `customers`, `restaurants`, `menu_items`, `delivery_agents`, `orders`, `order_items`

### ✅ Phase 2 — Data Insertion
- Inserted realistic sample data
- 10 customers, 10 restaurants, 5 delivery agents, 15+ orders

### ✅ Phase 3 — Basic Data Exploration
- Total orders, total revenue, average order value
- Orders grouped by payment method

### ✅ Phase 4 — Customer Analysis
- Top 5 customers by spending
- Customer frequency classification (Frequent / Regular / Occasional)
- City-wise customer distribution

### ✅ Phase 5 — Restaurant & Revenue Analysis
- Top 10 restaurants by revenue
- Revenue breakdown by cuisine type
- City-wise orders and revenue

### ✅ Phase 6 — Delivery Performance Analysis
- Average, fastest, and slowest delivery times by city
- Delivery agent performance ranking
- Orders with delivery time > 45 minutes (delayed)

### ✅ Phase 7 — Advanced Queries & Business Insights
- Monthly revenue trend analysis
- High-value orders (above ₹1000)
- Discount impact analysis
- Repeat customer identification
- Best performing day of the week

### ✅ Phase 8 — Performance Optimization (Indexes)
- Created indexes on `order_date`, `customer_name`, `restaurant_name`, `city`, `order_amount`
- Used `EXPLAIN` to verify query optimization
- Primary key columns skipped (auto-indexed)

### ✅ Phase 9 — Triggers (Automation)
- **Trigger 1:** Auto-logs orders with amount > ₹1000 into `high_value_orders_log`
- **Trigger 2:** Prevents negative discount values on insert (sets to 0)
- **Trigger 3:** Auto-logs orders with delivery time > 45 mins into `delivery_delay_log`

---

## 📊 Dashboard Queries

Exported query results used to build charts in Google Sheets:

| Chart | Type |
|---|---|
| Total Revenue | Scorecard |
| City-wise Total Orders | Pie Chart |
| Top 10 Restaurants by Revenue | Bar Chart |
| City-wise Average Delivery Time | 3D Pie Chart |
| Monthly Revenue Trend | Line Chart |
| Payment Method Distribution | Donut Chart |

---

## ⚡ Performance Optimization

```sql
-- Indexes created for faster query execution
CREATE INDEX idx_order_date      ON orders(order_date);
CREATE INDEX idx_customer_name   ON customers(customer_name);
CREATE INDEX idx_restaurant_name ON restaurants(restaurant_name);
CREATE INDEX idx_orders_city     ON orders(city);
CREATE INDEX idx_order_amount    ON orders(order_amount);
```

---

## 🔁 Triggers

```sql
-- Trigger 1: Log high value orders
CREATE TRIGGER trg_high_value_orders
AFTER INSERT ON orders FOR EACH ROW
BEGIN
    IF NEW.order_amount > 1000 THEN
        INSERT INTO high_value_orders_log ...
    END IF;
END;

-- Trigger 2: Prevent negative discounts
CREATE TRIGGER trg_prevent_negative_discount
BEFORE INSERT ON orders FOR EACH ROW
BEGIN
    IF NEW.discount < 0 THEN SET NEW.discount = 0; END IF;
END;

-- Trigger 3: Log delayed deliveries
CREATE TRIGGER trg_delivery_delay_warning
AFTER INSERT ON orders FOR EACH ROW
BEGIN
    IF NEW.delivery_time_minutes > 45 THEN
        INSERT INTO delivery_delay_log ...
    END IF;
END;
```

---

## 🛠️ Tools & Technologies

| Tool | Purpose |
|---|---|
| MySQL 9.0 | Database & query execution |
| MySQL Workbench | SQL IDE |
| VS Code | Code editor |
| Google Sheets | Dashboard & charts |
| GitHub | Version control & project hosting |

---

## 🚀 How to Run

1. Clone this repository
```bash
git clone https://github.com/pritigunjal17-dot/food-delivery-sql-project.git
```

2. Open `food_delivery_sql_project.sql` in **MySQL Workbench** or **VS Code**

3. Run in this order:
   - Phase 1 → Create Database & Tables
   - Phase 2 → Insert Sample Data
   - Phase 3–7 → Run Analysis Queries
   - Phase 8 → Create Indexes
   - Phase 9 → Create Triggers & Test

4. Export dashboard query results to **Google Sheets** for visualization

---

## 📁 Project Structure

```
food-delivery-sql-project/
│
├── food_delivery_sql_project.sql   # Complete SQL file (all phases)
├── README.md                       # Project documentation
└── dashboard/                      # (optional) Screenshots of charts
```

---

## 📈 Key Business Insights

- 🏙️ **Mumbai and Hyderabad** generate the highest revenue
- 🍽️ **South Indian cuisine** has the highest average rating (4.9)
- ⏱️ **Average delivery time** is under 40 minutes across most cities
- 💳 **UPI** is the most preferred payment method
- 🔁 **Repeat customers** contribute to over 60% of total orders
- ⚠️ Orders above ₹1000 are automatically flagged for monitoring

---

## 👤 Author

**Priti Gunjal**  
SQL Course Project — [sql2026]  
📧 pritigunjal7@email.com  
🔗 (https://www.linkedin.com/in/priti-gunjal-44aa1a37a)

---

## 📜 License

This project is created for educational purposes as part of a SQL course submission.
