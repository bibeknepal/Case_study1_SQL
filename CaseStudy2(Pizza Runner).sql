create database CaseStudy2_pizza_runner;

create table runners(
	runner_id int,
    registration_date date
);
INSERT INTO runners
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');
  
create table customer_orders(
	order_id int,
    customer_id int,
    pizza_id int,
    exclusions varchar(4),
    extras varchar(4),
    order_time timestamp
);

INSERT INTO customer_orders
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');

create table runner_orders
(
	order_id int,
    runner_id int,
    pickup_time varchar(19),
    distance varchar(7),
    duration varchar(10),
    cancellation varchar(23)
);
INSERT INTO runner_orders
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


CREATE TABLE pizza_names (
  pizza_id INTEGER,
  pizza_name TEXT
);

INSERT INTO pizza_names
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');

CREATE TABLE pizza_recipes (
  pizza_id INTEGER,
  toppings TEXT
);

INSERT INTO pizza_recipes
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


CREATE TABLE pizza_toppings (
  topping_id INTEGER,
  topping_name TEXT
);

INSERT INTO pizza_toppings
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
  
  -- How many pizzas were ordered?
  select count(pizza_id) from customer_orders;
  
  -- How many unique customer orders were made?
  
  SELECT COUNT(DISTINCT customer_id) AS unique_orders_count
FROM customer_orders;

  -- How many successful orders were delivered by each runner?
select count(order_id)
from runner_orders
where cancellation is null;

-- How many of each type of pizza was delivered?
select pizza_id,count(pizza_id) from  runner_orders as r join customer_orders as c
on c.order_id = r.order_id
where r.cancellation is null
group by pizza_id;

-- How many Vegetarian and Meatlovers were ordered by each customer?

select pizza_names.pizza_name,count(pizza_names.pizza_id)
from customer_orders 
join pizza_names
on customer_orders.pizza_id = pizza_names.pizza_id
group by pizza_name;

-- What was the maximum number of pizzas delivered in a single order?
WITH pizza_count_cte AS
(
 SELECT c.order_id, COUNT(c.pizza_id) AS pizza_per_order
 FROM customer_orders AS c
 JOIN runner_orders AS r
ON c.order_id = r.order_id
 WHERE r.distance != 0
 GROUP BY c.order_id
)
SELECT MAX(pizza_per_order) AS pizza_count
FROM pizza_count_cte;

-- For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

update runner_orders
set cancellation = null
where cancellation = "" or cancellation = "null";

select count(without_changes),count(with_changes) from(
SELECT
    c.customer_id,
    COUNT(CASE WHEN (c.exclusions IS NULL and c.extras is null) THEN c.pizza_id END) AS without_changes,
    COUNT(CASE WHEN (c.exclusions IS not NULL and c.extras is  not null) OR (c.exclusions = null and c.extras != null) OR (c.exclusions != null and c.extras = null) THEN c.pizza_id END) AS with_changes
FROM
    customer_orders c
JOIN
    runner_orders r ON c.order_id = r.order_id
WHERE
    r.cancellation IS NULL
GROUP BY
    c.customer_id) as subquery;

-- How many pizzas were delivered that had both exclusions and extras?

select count(with_exclusions_and_extra) from(
SELECT
    c.customer_id,
    COUNT(CASE WHEN (c.exclusions IS not NULL and c.extras is  not null)then c.pizza_id end)  AS with_exclusions_and_extra
FROM
    customer_orders c
JOIN
    runner_orders r ON c.order_id = r.order_id
WHERE
    r.cancellation IS NULL
GROUP BY
    c.customer_id) as subquery;
    
    
-- What was the total volume of pizzas ordered for each hour of the day?
select * from customer_orders;

select hour(order_time),count(pizza_id) 
from customer_orders 
group by hour(order_time)
order by hour(order_time);

-- What was the volume of orders for each day of the week?
select * from customer_orders;

SELECT 
    DAYOFWEEK(order_time) AS day_of_week,
    COUNT(*) AS order_volume
FROM 
    customer_orders
GROUP BY 
    day_of_week;

-- --------------------------------------------------------------------------------------------------------------------------------
-- How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
select week(registration_date) as weeks ,count(runner_id)  
from runners
group by week(registration_date);


-- What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

select avg(time_to_reach_HQ) from(
select c.order_id,c.order_time,r.pickup_time,timestampdiff(minute,c.order_time,r.pickup_time )as time_to_reach_HQ
from customer_orders c join runner_orders r
on c.order_id = r.order_id
group by order_id,order_time,pickup_time) as subquery;

-- Is there any relationship between the number of pizzas and how long the order takes to prepare?

select * from customer_orders;
select * from runner_orders;

select avg(time_to_prepare),pizza_order from(
select c.order_id, count(c.order_id) as pizza_order,c.order_time,r.pickup_time,timestampdiff(minute,c.order_time,r.pickup_time )as time_to_prepare
from customer_orders c join runner_orders r
on c.order_id = r.order_id
group by c.order_id,c.order_time,r.pickup_time) as subquery
group by pizza_order;


-- What was the average distance travelled for each customer?


select c.customer_id,avg(r.distance)
from 
customer_orders c join runner_orders r
on c.order_id = r.order_id
WHERE r.cancellation is null
group by customer_id;

-- What was the difference between the longest and shortest delivery times for all orders?
select max(cast(duration as decimal))-min(cast(duration as decimal))
from 
runner_orders
where cancellation is null;

-- What was the average speed for each runner for each delivery and do you notice any trend for these values?



select c.order_id,c.customer_id,r.runner_id,r.distance,r.duration,
round(distance/(duration*1/60),2) as average_speed
from 
customer_orders c join runner_orders r
on c.order_id = r.order_id
where r.cancellation is null
group by order_id,customer_id,runner_id,distance,duration;

-- What is the successful delivery percentage for each runner?
select * from runner_orders;
select * from customer_orders;

select runner_id,
round(100*sum(
case 
	when distance= 0 then 0
    else 1
end)/count(runner_id)) as successful_delivery_percentage
from runner_orders
group by runner_id;

-- --------------------------------------------------------------------------------------------------------------------------------------

-- What are the standard ingredients for each pizza?
create table pizza_recipes1(
	pizza_id int,
    toppings int
);
insert into pizza_recipes1 values
(1,1),
(1,2),
(1,3),
(1,4),
(1,5),
(1,6),
(1,8),
(1,10),
(2,4),
(2,6),
(2,7),
(2,9),
(2,11),
(2,12);

select * from pizza_recipes1;

select pizza_name,group_concat(topping_name) as standard_ingriedents
from
pizza_names pn join pizza_recipes1 pr
on pn.pizza_id = pr.pizza_id
join pizza_toppings pt
on pr.toppings = pt.topping_id
group by pizza_name;


