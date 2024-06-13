-- [Q1] What is the distribution of customers across states?
select state, count(customer_id) as Total_Customer,count(customer_id)*100/(select count(customer_id) from customer_t) as Porcentage 
from customer_t
group by 1
order by 2 desc;

-- [Q2] What is the average rating in each quarter?
with rating as (select customer_feedback, quarter_number, 
case 
when customer_feedback = "Very Bad" then 1
when customer_feedback = "Bad" then 2
when customer_feedback = "Okay" then 3
when customer_feedback = "Good" then 4
when customer_feedback = "Very Good" then 5
end as N_customer_feedback
from order_t)
select quarter_number, avg(N_customer_feedback) as Av_Customer_Feedback
from rating
group by 1
order by av_customer_feedback desc;

-- [Q3] Are customers getting more dissatisfied over time?
with feedback as (select quarter_number, customer_feedback, range_customer_feedback, N_customer_feedback,
sum(N_customer_feedback) over(partition by quarter_number) as total_customer_feedback
from (Select quarter_number, customer_feedback, count(customer_feedback) as N_customer_feedback,
case 
when customer_feedback = "Very Bad" then 1
when customer_feedback = "Bad" then 2
when customer_feedback = "Okay" then 3
when customer_feedback = "Good" then 4
when customer_feedback = "Very Good" then 5
end as Range_customer_feedback
from order_t
Group by 1,2
order by 3 asc) as base
group by 1,2,3
order by 1 asc)
select quarter_number, customer_feedback, Range_customer_feedback, (N_customer_feedback/total_customer_feedback)*100 as Porcentage
from feedback
group by 1,2,3
order by 1,3 asc;

-- [Q4] Which are the top 5 vehicle makers preferred by the customer.
with top_vehicle as (Select vehicle_maker, count(a.customer_id) as Total_Customers
from order_t as a
inner join product_t as b using (product_id)
group by 1
order by 2 desc
limit 5)
select vehicle_maker, Total_customers,(total_customers/(select count(customer_id) from customer_t))*100 as Porcentage_by_customers
from top_vehicle;

-- *[Q5] What is the most preferred vehicle make in each state?
select * from (select a.state, c.vehicle_maker, count(a.customer_id) as Total_Customer, rank() over(partition by state order by count(a.customer_id)desc) as Ranking
from customer_t as a
inner join order_t as b using (customer_id)
inner join product_t as c using (product_id) 
group by 1,2) as referencia 
where Ranking <=1;

-- [Q6] What is the trend of number of orders by quarters?
select quarter_number, count(order_id) as Total_orders
from order_t
group by 1
order by 1;

-- [Q7] What is the quarter over quarter % change in revenue? 
with result as (select quarter_number, round(sum((quantity*vehicle_price)-(quantity*vehicle_price*(discount/100))),2) as Current_Revenue
from order_t
group by 1
order by 1 asc)
select quarter_number, Current_revenue, 
lag(current_revenue)over(order by quarter_number) as Previous_revenue, 
round((current_revenue-lag(current_revenue) over(order by quarter_number)),2) as Difference,
round(((current_revenue-lag(current_revenue)over(order by quarter_number))/(lag(current_revenue)over(order by quarter_number))*100),2) as Porcentage
from result
order by quarter_number asc;

-- [Q8] What is the trend of revenue and orders by quarters?
select quarter_number, round(sum((quantity*vehicle_price)-(quantity*vehicle_price*(discount/100))),2) as Revenue, count(order_id) as Total_Orders
from order_t
group by 1
order by 1 asc;

-- [Q9] What is the average discount offered for different types of credit cards?
select credit_card_type, avg(discount) as Average_Discount
from customer_t as a
left join order_t as b using(customer_id)
group by 1
order by 2 desc;

-- [Q10] What is the average time taken to ship the placed orders for each quarters?
select quarter_number, avg(shipping) as Averange_Shipping_Days 
from (select quarter_number, datediff(ship_date, order_date) as Shipping
from order_t
order by 1 asc) as base
group by 1
order by 1 asc;

-- other queries
with overall_feedback as (select customer_feedback, quarter_number,
case 
when customer_feedback = "Very Bad" then 1
when customer_feedback = "Bad" then 2
when customer_feedback = "Okay" then 3
when customer_feedback = "Good" then 4
when customer_feedback = "Very Good" then 5
end as N_customer_feedback
from order_t)
select avg(N_customer_feedback) as Total_average
from overall_feedback;

select count(customer_feedback) as total_feedback from order_t
where customer_feedback="good";

with vehicle_quantity as (select vehicle_maker, sum(quantity) as Quantity
from (select a.product_id, a.vehicle_maker, b.quantity
from product_t as a
inner join order_t as b using(product_id)
group by 1,2,3
order by 2 asc) as results
group by 1
order by 2 desc
limit 5)
select vehicle_maker, Quantity,(Quantity/(select count(quantity) from order_t))*100 as Porcentage_by_quantity
from vehicle_quantity;

with test as (select quarter_number, datediff(ship_date, order_date) as Shipping
from order_t
order by 1 asc) 
select avg(shipping) as Total_average from test;


