-- Creating Dabase Structure --

create database fnp_sales_data;

use fnp_sales_data;

create table customers(
	customer_id varchar(5) primary key,
    customer_name varchar(50) not null,
    city varchar(50) not null,
    contact_number varchar(15) not null,
    email_id varchar(100) not null,
    gender varchar(10) not null,
    address varchar(200) not null
);

create table products(
	product_id int primary key,
    product_name varchar(50) not null,
    category varchar(50) not null,
    price int not null,
    occasion varchar(30) not null
);

create table orders(
	order_id int primary key,
    customer_id varchar(5) not null,
    product_id int not null,
    quantity int not null,
    order_date varchar(15) not null,
    order_time time not null,
    delivery_date varchar(15) not null,
    delivery_time time not null,
    foreign key(customer_id) references customers(customer_id),
    foreign key(product_id) references products(product_id)
);

-- Quering the tables

select * from customers;

select * from products;

select * from orders;

-- Transforming Data

update customers set
contact_number = convert(convert(contact_number, decimal(15)), char);

alter table orders add column order_date2 date after order_date;

update orders set order_date2 = str_to_date(order_date, "%d-%m-%Y");

alter table orders drop column order_date;

alter table orders rename column order_date2 to order_date;

alter table orders add column delivery_date2 date after delivery_date;

update orders set delivery_date2 = str_to_date(delivery_date, "%d-%m-%Y");

alter table orders drop column delivery_date;

alter table orders rename column delivery_date2 to delivery_date;

alter table orders add column Total_amount float;

select
*
from
product join orders on product.product_id = orders.product_id;

update
products join orders on products.product_id = orders.product_id
set orders.Total_amount = products.price * orders.quantity;


-- Answers to find

# Q1. Find the total revenue generated across all the products.

select sum(total_amount) as 'Total Revenue Generated' from orders;

# Q2. Find the average customer spending on products.

    select round(avg(total_amount), 2) as 'Average Customer Spending' from orders;
    
# Q3. Calculate the average time taken in days for orders to deliver.

select round(avg(datediff(delivery_date, order_date)), 2)
as 'Aevrage Delivery time Taken in Days' from orders;

    
# Q4. List total revenue generated month by month.

select
month(delivery_date) as 'Month Number',
monthname(delivery_date) as 'Months Name',
sum(Total_amount) as 'Total Revanue'
from orders
group by monthname(delivery_date), month(delivery_date)
order by month(delivery_date);

select
monthname(delivery_date) as 'Months Name',
sum(Total_amount) as 'Total Revanue'
from orders
group by monthname(delivery_date), month(delivery_date)
order by month(delivery_date);

# Q5. Compare the total revenue by time of day like morning, afternoon and evening.

select
case
when hour(delivery_time) < 12 then 'Morning'
when hour(delivery_time) < 18 then "Afternoon"
else "Evening"
end as Time_of_Day,
sum(Total_amount) as 'Total Revenue'
from orders
group by Time_of_Day;
    
# Q6. Determine which 10 products are giving the most revenue.

select
products.product_name as 'Product Name',
sum(orders.Total_amount) as 'Total Revenue'
from
products join orders on products.product_id = orders.product_id
group by products.product_name
order by sum(orders.Total_amount) desc limit 10;

# Q7. Calculate which product categories gave what revenue.

select category,
sum(price) as Total_Revenue from products
group by category
order by Total_Revenue desc;

select
products.category as 'Product Category',
sum(orders.total_amount) as 'Total Revenue'
from products
join orders on products.product_id = orders.product_id
group by products.category;

# Q8. List which 10 cities are placing the highest number of orders.

select 
customers.city as 'Customers City',
count(orders.order_id) as 'Number Of Order'
from customers join orders on customers.customer_id = orders.customer_id
group by customers.city order by count(orders.order_id) desc limit 10;

# Q9. Compare the total revenue generated from different occasions.

select
products.occasion as 'Product Occasion',
sum(Total_amount) as 'Total Revenue'
from products join orders on products.product_id = orders.product_id
group by products.occasion;

# Q10. Find out which products are most popular during specific occasions.

select
p.occasion as `Product Occasion`,
p.product_name as `Product Name`,
sum(o.Total_amount) as `Total Revenue`
from products as p join orders as o on p.product_id = o.product_id
group by `Product Occasion`, `Product Name`;

select
p.occasion `Product Occasion`,
p.product_name `Product Name`,
sum(o.Total_amount) `Total Revenue`
from products as p join orders as o on p.product_id = o.product_id
group by `Product Occasion`, `Product Name`;

-- --- using sub and nested query -------- -------------- ---------

select
	*
from
(select
	p.occasion as `Product Occasion`,
	p.product_name as `Product Name`,
	sum(o.Total_amount) as `Total Revenue`,
	dense_rank() over(partition by p.occasion order by sum(o.Total_amount) desc ) as Product_Rank
	from 
    products as p
    join orders as o on p.product_id = o.product_id
group by `Product Occasion`, `Product Name`) as Product_Rank_By_Occasion
where Product_Rank <= 5;

--  --- using CTE( cooman table expression) ---------- -------- 

with `Product Rank By Occasion` as(
select
	p.occasion as `Product Occasion`,
	p.product_name as `Product Name`,
	sum(o.Total_amount) as `Total Revenue`,
	dense_rank() over(partition by p.occasion order by sum(o.Total_amount) desc ) as Product_Rank
	from 
    products as p
    join orders as o on p.product_id = o.product_id
group by `Product Occasion`, `Product Name`)
select * from `Product Rank By Occasion` where `Product_Rank` <= 5;