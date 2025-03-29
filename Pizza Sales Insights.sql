create database pizza_sales ;

use pizza_sales;

select *
from pizza_sales.pizzas;

select *
from pizza_sales.pizza_types;

select *
from pizza_sales.order_details;

select *
from pizza_sales.orders;

-- Q1. Retrieve the total number of orders placed.
select count(order_id)
from pizza_sales.orders;

-- Q2 Calculate the total revenue generated from pizza sales.
select sum(p1.price*od1.quantity) as total_Revenue
from pizza_sales.order_details as od1
inner join pizza_sales.pizzas as p1
on od1.pizza_id=p1.pizza_id;

-- Q3 Identify the highest-priced pizza.
select pt1.pizza_type_id, pt1.name, p1.price 
from pizza_sales.pizzas as p1 
inner join pizza_sales.pizza_types as pt1
on p1.pizza_type_id=pt1.pizza_type_id
order by price desc
limit 1; 

-- Q4  Identify the most common pizza size ordered.

select p1.size, count(od1.quantity) as total_quantity
from pizza_sales.order_details as od1
inner join pizza_sales.pizzas as p1
on od1.pizza_id=p1.pizza_id
group by p1.size
order by total_quantity desc
limit 1;

-- Q5. List the top 5 most ordered pizza types along with their quantities.
select p1.pizza_type_id, count(od1.quantity) as total_quantity
from pizza_sales.order_details as od1
inner join pizza_sales.pizzas as p1
on od1.pizza_id=p1.pizza_id
group by p1.pizza_type_id
order by total_quantity desc
limit 5; 

-- Q6 Determine the distribution of orders by hour of the day.
with h1 as (
SELECT *, hour(o1.time) as hours
FROM pizza_sales.orders as o1 
)

select h1.hours, count(h1.order_id) as hourly_order_count
from h1
group by h1.hours;

-- Q7 calculate the average number of pizzas ordered per day.
SELECT o1.date, avg(o1.order_id) as Average_orders_per_day
FROM pizza_sales.orders as o1
group by o1.date;

-- Q8 Determine the top 3 most ordered pizza types based on revenue.
select p1.pizza_type_id, pt1.name, sum(p1.price*od1.quantity) as revenue_from_each_type
from pizza_sales.order_details as od1
left join pizza_sales.pizzas as p1
on od1.pizza_id=p1.pizza_id
left join pizza_sales.pizza_types as pt1
on p1.pizza_type_id=pt1.pizza_type_id
group by p1.pizza_type_id, pt1.name 
order by revenue_from_each_type desc
limit 3; 


-- Q9. Calculate the percentage contribution of each pizza type to total revenue.
with TR as (
	select sum(p1.price*od1.quantity) as total_Revenue
	from pizza_sales.order_details as od1
	inner join pizza_sales.pizzas as p1
	on od1.pizza_id=p1.pizza_id
    ), 
 ER as (
	select p1.pizza_type_id, 
		pt1.name, 
		sum(p1.price*od1.quantity) as revenue_from_each_type
	from pizza_sales.order_details as od1
	left join pizza_sales.pizzas as p1
		on od1.pizza_id=p1.pizza_id
	left join pizza_sales.pizza_types as pt1
		on p1.pizza_type_id=pt1.pizza_type_id
	group by p1.pizza_type_id, pt1.name 
	order by revenue_from_each_type desc
    ) 

select 
	ER.pizza_type_id as pizza_id,
    ER.name as pizza_name,
	ER.revenue_from_each_type , 
	concat(round((ER.revenue_from_each_type*100)/ TR.total_Revenue,1),('%')) as percentage_contribution
from ER, TR
order by ER.revenue_from_each_type desc;

-- Q10. Analyze the cumulative revenue generated over time.

with daily_revenue as (
select 
	o1.date, 
	round(sum(quantity*price),1) as daily_total_revenue
from pizza_sales.order_details as od1
	inner join pizza_sales.orders as o1
	  on od1.order_id=o1.order_id
	inner join pizza_sales.pizzas as p1
	  on od1.pizza_id=p1.pizza_id
      group by o1.date
),
lead_revenue as (
select daily_revenue.*,
lead(daily_total_revenue) over (order by daily_revenue.date asc) as next_daily_revenue
from daily_revenue
)

select lead_revenue.date, lead_revenue.daily_total_revenue,
sum(daily_total_revenue) over (order by date asc) as culumative_revenue
from lead_revenue;

-- Q11. Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select p1.pizza_type_id, p1.pizza_id, pt1.name, sum(p1.price*od1.quantity) as revenue_from_each_type
from pizza_sales.order_details as od1
left join pizza_sales.pizzas as p1
on od1.pizza_id=p1.pizza_id
left join pizza_sales.pizza_types as pt1
on p1.pizza_type_id=pt1.pizza_type_id
group by p1.pizza_type_id, p1.pizza_id, pt1.name 
order by revenue_from_each_type desc
limit 3; 
