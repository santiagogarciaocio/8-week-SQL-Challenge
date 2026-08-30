/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
-- 2. How many days has each customer visited the restaurant?
-- 3. What was the first item from the menu purchased by each customer?
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
-- 5. Which item was the most popular for each customer?
-- 6. Which item was purchased first by the customer after they became a member?
-- 7. Which item was purchased just before the customer became a member?
-- 8. What is the total items and amount spent for each member before they became a member?
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?


-- 1. What is the total amount each customer spent at the restaurant?

SELECT sales.customer_id as Customer,SUM(menu.price) as TotalSpentperCustomer
from  sales 
left join menu
	on sales.product_id = menu.product_id
group by sales.customer_id
ORDER BY TotalSpentperCustomer DESC;



-- 2. How many days has each customer visited the restaurant?
SELECT sales.customer_id as Customer, COUNT(DISTINCT(order_date)) CantidadDiasVisito
FROM sales
GROUP BY customer_id
ORDER BY CantidadDiasVisito DESC;

-- 3. What was the first item from the menu purchased by each customer?
SELECT DISTINCT ON (customer_id)
	customer_id as Customer,
	product_name as FirstItemPurchase
FROM sales
LEFT JOIN menu
	on sales.product_id = menu.product_id
ORDER BY customer_id, order_date ASC;


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT product_name as ProductoMasVendido, count(*) as CantidadDeVentas
FROM sales t1
lEFT JOIN menu t2
	ON t1.product_id = t2.product_id
group by product_name
LIMIT 1;

-- 5. Which item was the most popular for each customer?
WITH producto_conteo AS (
  	SELECT   		
  		customer_id,
  		product_name,
  		count(*) as cantidadVentas
  	FROM sales s
  	left join menu m 
  		ON s.product_id=m.product_id
  	GROUP BY customer_id, product_name
  )
SELECT DISTINCT ON (customer_id)
  	customer_id as customer,
    product_name as producto,
    cantidadVentas
FROM producto_conteo
ORDER BY customer_id, cantidadVentas DESC;


-- 6. Which item was purchased first by the customer after they became a member?
SELECT DISTINCT ON (s.customer_id)
	s.customer_id as Customer,
    s.order_date as DiaPedido,
    me.product_name as Pedido
FROM sales s
left join menu me
	on s.product_id = me.product_id
left join members mb
	on s.customer_id = mb.customer_id
WHERE s.order_date >= mb.join_date :: date
ORDER BY s.customer_id, s.order_date ASC;


-- 7. Which item was purchased just before the customer became a member?
SELECT DISTINCT ON (s.customer_id)
	s.customer_id as Customer,
    s.order_date as DiaPedido,
    me.product_name as Pedido
FROM sales s
left join menu me
	on s.product_id = me.product_id
left join members mb
	on s.customer_id = mb.customer_id
WHERE s.order_date < mb.join_date :: date
ORDER BY s.customer_id, s.order_date DESC;


-- 8. What is the total items and amount spent for each member before they became a member?
SELECT 
	s.customer_id as Customer,
    sum(price) as TotalSpentBeforeMembership
FROM sales s
left join menu me
	on s.product_id = me.product_id
left join members mb
	on s.customer_id = mb.customer_id
WHERE s.order_date < mb.join_date :: date
GROUP BY s.customer_id
ORDER BY TotalSpentBeforeMembership;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
WITH salesWithMultiplier AS (
SELECT   
  *,
  case 
  	WHEN product_id = 1 THEN 2
  	ELSE 1
  END AS point_multiplier
FROM sales
)
SELECT 
	customer_id as customer,
	SUM(point_multiplier * 10 * price) as Points
FROM salesWithMultiplier s
LEFT JOIN menu m
	ON s.product_id = m.product_id
GROUP BY s.customer_id;


-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

select 
	s.customer_id as Cutomer,
    sum(	
      CASE 
      	WHEN order_date BETWEEN join_Date ::date  AND  (join_Date ::date + interval '7 days')
      		THEN m.price*2*10
      	WHEN s.product_id = 1 THEN m.price*2*10
      	ELSE m.price*10
      END
    ) AS PointEndJanuary
FROM sales s
LEFT JOIN menu m
	ON s.product_id=m.product_id
LEFT JOIN members mb
	ON s.customer_id = mb.customer_id
WHERE order_date < '2021-02-01' 
	AND mb.join_date IS NOT NULL
GROUP BY s.customer_id