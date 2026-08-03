create database E_commerce;
use E_commerce;

-- Data Cleaning
# Check Invalid Ratings
SELECT *
FROM orders
WHERE customer_rating<1
OR customer_rating>5;

# Check Customer IDs Without Orders
SELECT c.customer_id
FROM customers c
LEFT JOIN orders o
ON c.customer_id=o.customer_id
WHERE o.customer_id IS NULL;

-- Transforming Data 

UPDATE orders
SET customer_rating = NULL
WHERE customer_rating < 1
OR customer_rating > 5;

delete from customers
where customer_id IN(
select customer_id
from
(
select c.customer_id
from customers c
 left join orders o
on c.customer_id=o.customer_id
where o.customer_id is null
) x);

-- Bussiness Insides
 
 # Q1. Which countries generate the highest revenue and total orders?
 select c.country,
count(o.order_id) as total_orders,
round(sum(o.total_amount_usd),2) as total_revenue
from customers c
join orders o
on c.customer_id = o.customer_id
group by c.country
order by total_revenue desc;

 # Q2. Which membership tier contributes the highest 
 -- Customer Lifetime Value (CLV)?
 select membership_tier,
count(customer_id) as total_customers,
sum(total_spend_usd) as customer_lifetime_value,
round(avg(total_spend_usd),2) as avg_clv
from customers
group by membership_tier
order by customer_lifetime_value desc;

  #Q3. Which product categories generate the highest 
  -- revenue and profit opportunities?
  select category,
sum(total_revenue_usd) as revenue,
sum(total_orders) as total_orders,
round(avg(avg_rating),2) as avg_rating
from product_summary
group by category
order by revenue desc;

 # Q4. How do discounts influence order value, revenue, and return rate?
 select
case
when discount_pct=0 then 'No Discount'
when discount_pct<=10 then 'Low Discount'
when discount_pct<=20 then 'Medium Discount'
else 'High Discount'
end as Discount_Level,

count(order_id) as Orders,
round(avg(total_amount_usd),2) as Avg_Order_Value,
round(sum(total_amount_usd),2) as Revenue,
round(avg(returned)*100,2) as Return_Rate

from orders
group by  Discount_Level
order by Revenue desc;

 # Q5. Which customers are at the highest risk 
-- of churn based on purchase history and engagement?
select customer_id,country,membership_tier,total_orders,total_spend_usd,
days_since_last_purchase,reviews_given,avg_review_score,churned
from customers
where churned=1
order by total_spend_usd desc,
days_since_last_purchase desc;

 # Q6. Which payment methods and devices are most preferred by customers?
 select payment_method,device_used,
count(order_id) as Total_Orders,
round(sum(total_amount_usd),2) as Revenue
from orders
group by payment_method,device_used
order by Total_Orders desc;

 # Q7. Which products receive the highest customer ratings while 
 -- maintaining the lowest return rates?
 select product_name,category,avg_rating,return_rate,total_orders,total_revenue_usd
from product_summary
order by avg_rating desc,
return_rate asc;

 # Q8. How do delivery times affect customer ratings and product returns?
 select
case
when delivery_days<=2 then 'Fast Delivery'
when delivery_days<=5 then 'Standard Delivery'
else 'Late Delivery'
end as Delivery_Type,
count(order_id) as Orders,
round(avg(customer_rating),2) as Avg_Rating,
round(avg(returned)*100,2) as Return_Rate
from orders
group by Delivery_Type;

 # Q9. What are the monthly and quarterly sales trends, and which periods
 -- generate the highest revenue?
select year, month,
count(order_id) as Orders,
round(sum(total_amount_usd),2) as Revenue
from orders
group by year,month
order by year,month; 

select year, quarter,
count(order_id) as Orders,
round(sum(total_amount_usd),2) as Revenue
from orders
group by year,quarter
order by year,quarter;

 # Q10. What strategic recommendations can increase revenue,
 -- ---improve customer retention, and reduce product returns?
 
 -- --- Top 10 Revenue Customers ---- -- 
 select customer_id,
sum(total_amount_usd) as Revenue
from orders
group by customer_id
order by Revenue desc
limit 10;

-- --- ------- High Return Products ----- ----- --- 
select product_name, category,
count(*) as Total_Returns
from orders
where returned=1
group by product_name,category
order by Total_Returns desc;

-- ---------- High Return Products-- --------- - 
select
count(customer_id) as Repeat_Customers
from customers
where total_orders>1;

-- Customer Retention Rate -------- -------- --- 
select
round((count(
CASE 
when churned=0 then 1 
end)*100.0)/count(*),2) as Retention_Rate
from customers;

-- Best Performing Products ---------- ------- 
select product_name, category, total_revenue_usd, avg_rating, return_rate
from product_summary
order by total_revenue_usd desc
limit 10;

# Q1. Which membership tier generates the highest revenue in each 
-- -- product category?
select c.membership_tier, p.category,
count(o.order_id) as total_orders,
round(sum(o.total_amount_usd),2) as total_revenue
from customers c
join orders o on c.customer_id = o.customer_id
JOIN product_summary p on o.product_name = p.product_name
group by c.membership_tier, p.category
order by total_revenue desc;

 # Q2. Which countries generate the highest revenue, and what are their 
 -- --- top-selling product categories?
 select c.country, p.category,
count(o.order_id) as total_orders,
round(sum(o.total_amount_usd),2) as revenue
from customers c
join orders o on c.customer_id = o.customer_id
join product_summary p on o.product_name = p.product_name
group by c.country, p.category
order by revenue desc;

 # Q3. Which months generate the highest revenue and how many new customers 
 -- --- joined during those months?
 select m.year,m.month,m.orders,m.revenue_usd,m.new_customers
from monthly_revenue m
order by m.revenue_usd desc;

 # Q4. Which products have high ratings, low return rates, 
 -- -- and generate high revenue?
 select
p.product_name,
p.category,
p.avg_rating,
p.return_rate,
p.total_revenue_usd,
count(o.order_id) as total_orders
from product_summary p
join orders o on p.product_name = o.product_name
group by
p.product_name,
p.category,
p.avg_rating,
p.return_rate,
p.total_revenue_usd
order by
p.avg_rating desc,
p.return_rate asc,
p.total_revenue_usd desc;

 # Q5. Which product categories generate more revenue than the average 
 -- --- category revenue?
 select category, total_revenue_usd
from product_summary
where total_revenue_usd >(
select 
avg(total_revenue_usd)
from product_summary
)
order by total_revenue_usd desc;

 # Q6. Find the top-selling product in each category based on total revenue.
 with Product_Rank as(
select category,product_name,total_revenue_usd,RANK() 
over(partition by category order by total_revenue_usd desc) as Rank_No
from product_summary
)
select category,product_name,total_revenue_usd
from Product_Rank
where Rank_No = 1;