-- ============================================
-- Домашнє завдання 2: Нормалізація бази даних
-- Студент: Андрій Дзьомбак
-- ============================================

-- Створення бази даних
DROP DATABASE IF EXISTS order_management;
CREATE DATABASE order_management CHARACTER SET utf8;
USE order_management;

-- ============================================
-- ТАБЛИЦЯ 1: Клієнти (Clients)
-- ============================================
-- Зберігає інформацію про клієнтів
-- Виділена з початкової таблиці для уникнення дублювання даних про клієнтів

CREATE TABLE clients (
    client_id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Унікальний ідентифікатор клієнта',
    client_name VARCHAR(100) NOT NULL COMMENT 'Ім''я клієнта (прізвище)',
    client_address VARCHAR(200) NOT NULL COMMENT 'Адреса клієнта',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Дата створення запису',

    INDEX idx_client_name (client_name)
) ENGINE=InnoDB COMMENT='Таблиця клієнтів';

-- ============================================
-- ТАБЛИЦЯ 2: Товари (Products)
-- ============================================
-- Зберігає каталог товарів
-- Виділена для уникнення дублювання назв товарів

CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Унікальний ідентифікатор товару',
    product_name VARCHAR(100) NOT NULL UNIQUE COMMENT 'Назва товару',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Дата додавання товару',

    INDEX idx_product_name (product_name)
) ENGINE=InnoDB COMMENT='Каталог товарів';

-- ============================================
-- ТАБЛИЦЯ 3: Замовлення (Orders)
-- ============================================
-- Зберігає інформацію про замовлення
-- Пов'язана з таблицею клієнтів через client_id

CREATE TABLE orders (
    order_id INT PRIMARY KEY COMMENT 'Номер замовлення',
    client_id INT NOT NULL COMMENT 'Ідентифікатор клієнта',
    order_date DATE NOT NULL COMMENT 'Дата оформлення замовлення',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Дата створення запису',

    CONSTRAINT fk_orders_client
        FOREIGN KEY (client_id)
        REFERENCES clients(client_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    INDEX idx_order_date (order_date),
    INDEX idx_client_id (client_id)
) ENGINE=InnoDB COMMENT='Таблиця замовлень';

-- ============================================
-- ТАБЛИЦЯ 4: Позиції замовлення (Order Items)
-- ============================================
-- Зв'язує замовлення з товарами (багато-до-багатьох)
-- Містить кількість кожного товару в замовленні

CREATE TABLE order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Унікальний ідентифікатор позиції',
    order_id INT NOT NULL COMMENT 'Номер замовлення',
    product_id INT NOT NULL COMMENT 'Ідентифікатор товару',
    quantity INT NOT NULL COMMENT 'Кількість товару',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Дата створення запису',

    CONSTRAINT fk_order_items_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_order_items_product
        FOREIGN KEY (product_id)
        REFERENCES products(product_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT chk_quantity CHECK (quantity > 0),

    -- Унікальність: один товар один раз у замовленні
    UNIQUE KEY uk_order_product (order_id, product_id),

    INDEX idx_order_id (order_id),
    INDEX idx_product_id (product_id)
) ENGINE=InnoDB COMMENT='Позиції замовлення (багато-до-багатьох зв''язок між замовленнями та товарами)';
