-- Queries to the case study

-- 1. What is the total amount each customer spent at the restaurant?
SELECT
	s.customer_id,
	CONCAT('$', SUM(m.price)) AS total_spend
FROM
	dannys_dinner.sales s
INNER JOIN
	dannys_dinner.menu m
ON
	s.product_id = m.product_id
GROUP BY
	s.customer_id
ORDER BY
	s.customer_id ASC
;

-- 2. How many days has each customer visited the restaurant?
SELECT
	s.customer_id,
	COUNT(DISTINCT s.order_date) AS total_visits
FROM
	dannys_dinner.sales s
GROUP BY
	s.customer_id
ORDER BY
	s.customer_id ASC
;

-- 3. What was the first item from the menu purchased by each customer?
SELECT
	DISTINCT customer_id,
	product_name
FROM
	(
		SELECT
			s.customer_id,
			m.product_name,
			DENSE_RANK() OVER (
				PARTITION BY
					s.customer_id
				ORDER BY
					s.order_date
			) AS first_order
		FROM
			dannys_dinner.sales s
		INNER JOIN
			dannys_dinner.menu m
		ON
			s.product_id = m.product_id
		ORDER BY
			customer_id ASC
	) rn
WHERE
	first_order = 1
;