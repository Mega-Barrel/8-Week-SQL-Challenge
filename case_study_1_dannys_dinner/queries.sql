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
SELECT
	customer_id,
	product_id
FROM
	(
		SELECT
			m.customer_id,
			s.product_id,
			ROW_NUMBER() OVER (
				PARTITION BY
					m.customer_id
				ORDER BY
					s.order_date ASC
			) AS row_num
		FROM
			dannys_dinner.sales s
		JOIN
			dannys_dinner.members m
		ON
			s.customer_id = m.customer_id
		WHERE
			 s.order_date > m.join_date
		ORDER BY
			s.order_date ASC
	) rn
WHERE
	row_num = 1
;

-- 7. Which item was purchased just before the customer became a member?
SELECT
	customer_id,
	product_id
FROM
	(
		SELECT
			m.customer_id,
			s.product_id,
			ROW_NUMBER() OVER (
				PARTITION BY
					m.customer_id
				ORDER BY
					s.order_date DESC
			) AS row_num
		FROM
			dannys_dinner.sales s
		JOIN
			dannys_dinner.members m
		ON
			s.customer_id = m.customer_id
		WHERE
			 s.order_date < m.join_date
		ORDER BY
			s.order_date ASC
	) rn
WHERE
	row_num = 1
;

-- 8. What is the total items and amount spent for each member before they became a member?
SELECT
	m.customer_id,
	COUNT(s.product_id) AS total_items,
	SUM(me.price) AS amount_spend
FROM
	dannys_dinner.sales s
INNER JOIN
	dannys_dinner.members m
ON
	s.customer_id = m.customer_id
INNER JOIN
	dannys_dinner.menu me
ON
	s.product_id = me.product_id
WHERE
	 s.order_date < m.join_date
GROUP BY
	m.customer_id
ORDER BY
	m.customer_id
;

-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT
	s.customer_id,
	SUM(
		CASE
			WHEN
				me.product_name = 'sushi' THEN me.price * 20
			ELSE
				me.price * 10
		END
	) AS points
FROM
	dannys_dinner.sales s
INNER JOIN
	dannys_dinner.menu me
ON
	s.product_id = me.product_id
GROUP BY
	s.customer_id
ORDER BY
	1
;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, 
-- not just sushi - how many points do customer A and B have at the end of January?
SELECT
	s.customer_id,
	SUM(
		CASE
			WHEN m.product_name = 'sushi' THEN 2 * 10 * m.price		
			WHEN s.order_date BETWEEN mem.join_date AND mem.join_date + 6 THEN 2 * 10 * m.price			
			ELSE 10 * m.price
		END
	) AS points
FROM
	dannys_dinner.sales s
INNER JOIN
	dannys_dinner.members mem
ON
	s.customer_id = mem.customer_id
AND
	mem.join_date <= s.order_date
AND
	s.order_date <= '2021-01-31'
INNER JOIN
	dannys_dinner.menu m
ON
	s.product_id = m.product_id
GROUP BY
	s.customer_id
ORDER BY
	s.customer_id
;