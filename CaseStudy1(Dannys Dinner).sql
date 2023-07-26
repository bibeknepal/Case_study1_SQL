create table sales(
	customer_id varchar(1),
    order_date date,
    product_id int
);

insert into sales 
values
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
  
  
  CREATE TABLE menu (
  product_id int,
  product_name varchar(10),
  price int
);

insert into menu 
values
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');

create table members(
	customer_id varchar(1),
    join_date date
);

insert into members 
values
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
  
-- total amount of each customers spent at the restaurant

select s.customer_id, sum(m.price)
from sales as s join menu as m
on s.product_id = m.product_id
group by customer_id;


-- how many days has each customers visited the restaurant

select customer_id, count(distinct(order_date))
from sales 
group by customer_id;


-- first item from the menu purchased by each customer
select * from members;
select * from sales;
select * from menu;

with cte as (
select customer_id,
min(order_date) as first_purchased_date
from sales
group by customer_id)

select s.customer_id,s.order_date,s.product_id
from sales as s join cte
on s.customer_id = cte.customer_id
and s.order_date  = cte.first_purchased_date;



SELECT customer_id, order_date AS first_purchase_date, product_id AS first_purchased_item
FROM (
  SELECT 
    customer_id,
    order_date,
    product_id,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) AS rn
  FROM sales
) AS ranked_purchases
WHERE rn = 1;



-- most purchased item on the menu
select * from sales;


with cte as(
select product_id , count(product_id)
from sales 
group by product_id
order by count(product_id) desc
limit 1)

select sales.customer_id,count(sales.product_id) 
from sales,cte 
where sales.product_id = cte.product_id
group by customer_id;

-- what item was most popular for each customer

select * from sales;

select pc.customer_id,pc.product_id, pc.product_count
from(
select customer_id,product_id, count(product_id) as product_count
from sales 
group by customer_id,product_id) as pc
join(
select customer_id,max(purchase_count) as max_purchase_count
from(
	select customer_id,product_id,count(product_id) as purchase_count
    from sales 
    group by customer_id,product_id
    ) as subquery
    group by customer_id
    ) as max_count
on pc.customer_id = max_count.customer_id 
and pc.product_count = max_count.max_purchase_count;


-- which item was  purchased first by customer after they 
-- became a member
select * from sales;
select * from members;

SELECT customer_id, product_id, order_date AS first_purchase_date
FROM (
    SELECT m.customer_id ,s.product_id, s.order_date,
           ROW_NUMBER() OVER (PARTITION BY m.customer_id ORDER BY s.order_date) AS rn
    FROM members m
    JOIN sales s ON m.customer_id = s.customer_id
    WHERE s.order_date > m.join_date
) AS subquery
WHERE rn = 1;

-- 

-- which item was purchased just before the customer became the member
select * from sales;
select * from members;

select customer_id, product_id, order_before_join_date from(
select m.customer_id,s.product_id,s.order_date as order_before_join_date,
	dense_rank() over (partition by customer_id order by order_date desc) as rn
from members as m join sales as s
on m.join_date > s.order_date
and m.customer_id = s.customer_id ) as subquery
where rn = 1;

-- What is the total items and amount spent for each member before they became a member?

select * from sales;
select * from members;
select * from menu;

select s.customer_id,count(s.product_id)  as total_items ,sum(m.price) as total_amount_apent
from 
members mb join sales s  join menu m
on mb.customer_id = s.customer_id
and s.product_id = m.product_id
and mb.join_date > s.order_date
group by customer_id ;


-- If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
select * from menu;
select * from sales;

select customer_id, sum(points_earned) from(
select s.customer_id, m.product_name,
case
	when m.product_name = "sushi" then m.price*10*2
    else m.price*10
end as points_earned
from sales s join menu m
on s.product_id = m.product_id) as points
group by customer_id;

-- In the first week after a customer joins the program (including their join date) 
-- they earn 2x points on all items, not just sushi 
-- how many points do customer A and B have at the end of January?

select * from members;
select * from sales;
select * from menu;


SELECT
    customer_id,
    SUM(points_earned) AS total_points
FROM (
    SELECT
        s.customer_id,
        m.product_name,
        CASE
            WHEN m.product_name = 'sushi' THEN m.price * 10 * 2 
            WHEN s.order_date BETWEEN mb.join_date AND DATE_ADD(mb.join_date, INTERVAL 7 DAY) THEN m.price * 10 * 2
            ELSE m.price * 10
        END AS points_earned
    FROM sales s
    JOIN menu m ON s.product_id = m.product_id
    JOIN members mb ON mb.customer_id = s.customer_id
    WHERE MONTH(s.order_date) = 1 -- Filter customers who joined in January
) AS points
GROUP BY customer_id;

-- ---------------------------------------------------------

select * from members;
select * from sales;
select * from menu;

select s.customer_id,s.order_date,m.product_name,m.price,
case
	when s.customer_id = "A" and s.order_date < mb.join_date then "N"
    when s.customer_id = "B" and s.order_date < mb.join_date then "N" 
    when s.customer_id not in (select customer_id from members) then "N" 
    else "Y"
end as member,
case 
	when s.customer_id = "A" and s.order_date < mb.join_date then null
    when s.customer_id = "B" and s.order_date < mb.join_date then null 
    when s.customer_id not in (select customer_id from members) then null
	else dense_rank() over (partition by s.customer_id order by s.order_date) 
end as ranking
from 
members mb right join sales s
on mb.customer_id = s.customer_id
join menu m
on s.product_id = m.product_id
order by customer_id,order_date,product_name;





