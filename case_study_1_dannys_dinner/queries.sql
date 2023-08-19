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