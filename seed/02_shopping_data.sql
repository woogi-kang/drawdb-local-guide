-- =========================================================
-- 쇼핑몰 예제 데이터 (PostgreSQL 컨테이너 초기화용)
-- drawDB 에는 불러오지 않습니다. (drawDB 는 스키마만 그립니다)
-- =========================================================

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
