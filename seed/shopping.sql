-- 쇼핑몰 시드 (PostgreSQL)
-- psql 로 실행하면 테이블+데이터 생성, drawDB 로 가져오면 ERD 생성

CREATE TABLE customers (
    id          SERIAL PRIMARY KEY,
    email       VARCHAR(255) NOT NULL UNIQUE,
    name        VARCHAR(100) NOT NULL,
    phone       VARCHAR(20),
    created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE categories (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE products (
    id           SERIAL PRIMARY KEY,
    category_id  INTEGER NOT NULL,
    name         VARCHAR(200) NOT NULL,
    price        INTEGER NOT NULL,
    stock        INTEGER NOT NULL DEFAULT 0,
    created_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories (id)
);

CREATE TABLE orders (
    id           SERIAL PRIMARY KEY,
    customer_id  INTEGER NOT NULL,
    status       VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    total_price  INTEGER NOT NULL DEFAULT 0,
    ordered_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers (id)
);

CREATE TABLE order_items (
    id          SERIAL PRIMARY KEY,
    order_id    INTEGER NOT NULL,
    product_id  INTEGER NOT NULL,
    quantity    INTEGER NOT NULL,
    unit_price  INTEGER NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders (id),
    FOREIGN KEY (product_id) REFERENCES products (id)
);

CREATE TABLE reviews (
    id           SERIAL PRIMARY KEY,
    product_id   INTEGER NOT NULL,
    customer_id  INTEGER NOT NULL,
    rating       INTEGER NOT NULL,
    content      TEXT,
    created_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products (id),
    FOREIGN KEY (customer_id) REFERENCES customers (id)
);

INSERT INTO customers (email, name, phone) VALUES
('kim@example.com',  '김민수', '010-1111-2222'),
('lee@example.com',  '이서연', '010-3333-4444'),
('park@example.com', '박지훈', NULL);

INSERT INTO categories (name) VALUES
('의류'), ('전자기기'), ('식품');

INSERT INTO products (category_id, name, price, stock) VALUES
(1, '기본 반팔 티셔츠', 19000, 120),
(1, '데님 청바지',      49000,  40),
(2, '무선 이어폰',      89000,  25),
(2, '보조배터리 10000mAh', 29000, 60),
(3, '유기농 원두 1kg',  32000,  30);

INSERT INTO orders (customer_id, status, total_price) VALUES
(1, 'PAID',     68000),
(2, 'SHIPPED',  89000),
(1, 'PENDING',  32000);

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 19000),
(1, 2, 1, 49000),
(2, 3, 1, 89000),
(3, 5, 1, 32000);

INSERT INTO reviews (product_id, customer_id, rating, content) VALUES
(1, 1, 5, '핏이 좋아요'),
(3, 2, 4, '음질 괜찮고 배터리 오래가요');
