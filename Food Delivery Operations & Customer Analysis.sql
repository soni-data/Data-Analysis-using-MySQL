create database food_delivery;
use food_delivery;
select count(order_id) from orders;

-- Data Cleaning ----- ----------- ------------ ------ 
select * from orders;

SELECT * FROM orders
WHERE order_value IS NULL
OR customer_rating IS NULL;

-- Transforming Data

alter table orders modify column order_id varchar(80) not null;
alter table orders add primary key (order_id);

-- Answer to find ---------------------------------------------------
# Q1. How many total orders were placed?
select count(*) as "Total Order"
from orders;

# Q2. What is the total revenue generated?
select round(sum(final_amount_paid),2) as "Total Revenue"
from orders;

# Q3. What is the average order value, avg delivery time, customer rating?
select round(avg(order_value),2) as "Average Order Value",
round(avg(delivery_time_minutes),2) as "Average Delivery Time",
round(avg(customer_rating),2) as "Average Customer Rating"
from orders;

# Q4. Which city tier generates the highest revenue?
select city_tier, count(*) as Total_orders,
round(sum(final_amount_paid),2) as Total_Revenue from orders
group by city_tier
order by Total_Revenue desc;

# Q5. Which month has the highest number of orders and revenue?
select order_month as "Month",
count(*) as Total_Orders,
round(sum(final_amount_paid),2) as Total_Revenue
from orders
group by order_month
order by Total_Revenue desc limit 5;

# Q6.What are the total number of orders and total revenue generated 
-- by premium and non-premium customers?
select premium_customer_flag,
count(*) AS Orders,
round(sum(final_amount_paid),2) as Revenue
from orders
group by premium_customer_flag;

# Q7.How does the traffic level affect the average delivery time?
select
round(traffic_level_score) as Traffic,
round(avg(delivery_time_minutes),2) Avg_Time
from orders
group by ROUND(traffic_level_score)
order by Traffic;

# Q8. How does weather severity impact delayed deliveries?
select 
weather_severity_score as Weather_Level,
count(*) as Total_Order,
sum(case
when delayed_delivery_flag='True' then 1
else 0
end) as Delayed_order,
round(
sum(case
when delayed_delivery_flag='True' then 1
else 0
end)*100.0/count(*),2
) as Delay_Percentage
from orders
group by weather_severity_score
order by weather_severity_score;

# Q9. Which delivery partners have the highest efficiency?
select
delivery_partner_experience_years,
round(avg(delivery_efficiency_score),2) as average_efficiency,
round(avg(delivery_partner_rating),2) as average_partner_rating
from orders
group by delivery_partner_experience_years
order by average_efficiency desc;

# Q10. What are the characteristics of cancelled or refunded orders?
select
cancellation_flag, refund_flag,
count(*) as total_orders,
round(avg(delivery_time_minutes),2) as average_delivery_time,
round(avg(delivery_distance_km),2) as average_distance,
round(avg(weather_severity_score),2) as average_weather,
round(avg(traffic_level_score),2) as average_traffic
from orders
group by cancellation_flag, refund_flag
order by total_orders desc;

# Q11. Which factors contribute most to delayed deliveries?
select delayed_delivery_flag,
round(avg(delivery_distance_km),2) as avg_distance,
round(avg(traffic_level_score),2) as avg_traffic,
round(avg(weather_severity_score),2) as avg_weather,
round(avg(preparation_time_minutes),2) as avg_preparation_time,
round(avg(delivery_partner_experience_years),2) as avg_experience,
round(avg(delivery_time_minutes),2) as avg_delivery_time
from orders
group by delayed_delivery_flag;

# Q12. Find the Top 3 Highest Revenue Orders in Each City Tier?
with Ranked_Orders as
(
select order_id, city_tier, final_amount_paid, customer_rating,row_number() 
over(partition by city_tier order by final_amount_paid desc) as order_rank
from orders
)
select *
from Ranked_Orders
where order_rank <= 3
order by city_tier, order_rank;

# Q13. Compare Delivery Performance Against the Overall Average?
with Delivery_Analysis as
(
select order_id, city_tier, delivery_time_minutes, traffic_level_score,
weather_severity_score, delivery_distance_km,
avg(delivery_time_minutes) over() as overall_avg_time
from orders
)
select order_id, city_tier, delivery_time_minutes,
round(overall_avg_time,2) as overall_average,
round(delivery_time_minutes - overall_avg_time,2) as extra_minutes,
case
when delivery_time_minutes > overall_avg_time then 'Above Average'
else 'Below Average'
end as delivery_status
from Delivery_Analysis
order by extra_minutes desc;

# Q14. How many orders fall into Low, Medium, 
-- and High Value categories based on the final amount paid?
select
case
when final_amount_paid < 200 then 'Low Value'
when final_amount_paid between 200 and 500 then 'Medium Value'
else 'High Value'
end as Order_Category,
count(*) as Total_Orders,
round(sum(final_amount_paid),2) as Total_Revenue
from orders
group by
case
when final_amount_paid < 200 then 'Low Value'
when final_amount_paid between 200 and 500 then 'Medium Value'
else 'High Value'
end;

# Q!5. How many orders were delivered Early, On Time, 
-- or Delayed compared to the estimated delivery time?
select
case
when delivery_time_minutes < estimated_delivery_time then 'Early Delivery'
when delivery_time_minutes = estimated_delivery_time then 'On Time'
else 'Delayed Delivery'
end as Delivery_Status,
count(*) as Total_Orders,
round(avg(delivery_time_minutes),2) as Avg_Delivery_Time
from orders
group by
case
when delivery_time_minutes < estimated_delivery_time then 'Early Delivery'
when delivery_time_minutes = estimated_delivery_time then 'On Time'
else 'Delayed Delivery'
end;