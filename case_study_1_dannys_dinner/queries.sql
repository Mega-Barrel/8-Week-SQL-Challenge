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

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT
	m.product_name,
	COUNT(m.product_name) AS total_purchases
FROM
	dannys_dinner.sales s
INNER JOIN
	dannys_dinner.menu m
ON
	s.product_id = m.product_id
GROUP BY
	m.product_name
ORDER BY
	total_purchases DESC
LIMIT 1
;

-- 5. Which item was the most popular for each customer?
WITH popular_items AS (
	SELECT
		s.customer_id,
		m.product_name,
		COUNT(m.product_id) AS most_purchased,
		DENSE_RANK() OVER(
			PARTITION BY
				s.customer_id
			ORDER BY
				COUNT(s.customer_id) DESC
		) AS most_purchased_rank
	FROM
		dannys_dinner.sales s
	INNER JOIN
		dannys_dinner.menu m
	ON
		s.product_id = m.product_id
	GROUP BY
		1, 2
	ORDER BY
		1 ASC, 3 DESC
)

SELECT
	customer_id,
	product_name
FROM
	popular_items
WHERE
	most_purchased_rank = 1
;

-- 6. Which item was purchased first by the customer after they became a member?