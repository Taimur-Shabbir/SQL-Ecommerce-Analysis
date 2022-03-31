## Data Cleaning

# remove '$' in 'product_cost' and 'product_price' columns then change type to double

update products 
set product_cost = replace(product_cost, '$','')

update products 
set product_price = replace(product_price, '$','')

alter table products
modify product_cost double

alter table products
modify product_price double

# -------------------------------------------------------------------------------

## Queries

# Q1) Which 5 products have generated the most profit?

select a.product_name, round(sum((a.product_price-a.product_cost)*b.units), 2) as total_profit
from products a inner join sales_toys b using(Product_ID)
group by a.product_name
order by total_profit desc
limit 5


# -------------------------------------------------------------------------------

# Q2) What product category is the most profitable overall?

select a.product_category, round(sum((a.product_price-a.product_cost)*b.units), 2) as total_profit
from products a inner join sales_toys b using(Product_ID)
group by a.product_category
order by total_profit desc


# -------------------------------------------------------------------------------

# Q3) What products are high margin and which ones are low margin?
# let's define 'high margin' as cases where the price minus the cost is greater than 5, and 'low margin'
# otherwise

select product_name, round(product_price-product_cost, 2) as margin,
	   case when (product_price-product_cost) > 5 then 'High Margin' else 'Low Margin' end as Status
from products
order by margin desc

# -------------------------------------------------------------------------------


# Q4) Are high margin products more profitable? Or are low margin products more profitable?

with cte1 as( # find the total profit and margin for each product
select a.product_name, round(sum((a.product_price-a.product_cost)*b.units), 2) as total_profit,
	   max(round(a.product_price-a.product_cost, 2)) as margin
from products a inner join sales_toys b using(Product_ID)
group by a.product_name
order by total_profit desc)
select cte1.product_name, cte1.total_profit, cte1.margin, # get the results from above CTE and label each product as 'high' or 'low' margin
       case when cte1.margin > 5 then 'High Margin' else 'Low Margin' end as Status
from cte1
order by total_profit DESC, margin desc

# -------------------------------------------------------------------------------

# Q5) Is there a seasonality aspect to sales?

# The date range of the data is 2017-01-01 to 2018-09-30. This means that all months apart from
# October, November and December have two months worth of data (once for 2017 and once for 2018).
# To find the average revenue by month, we need to divide every month until September (inclusive) by 2
# and we do *not* divide the last 3 months by 2

# using the results of the derived table, find the average monthly revenue
select tab1.Month, tab1.number_of_unique_sales, tab1.total_monthly_revenue,
	   case when
	   tab1.Month in(10, 11, 12) then tab1.total_monthly_revenue/1 else tab1.total_monthly_revenue/2 end as average_monthly_revenue
from
# define the derived table which gets the number of unique sales and *total* monthly revenue
(select month(a.date) as Month, count(distinct a.Sale_ID) as number_of_unique_sales, 
	   round(sum(a.units*b.product_price), 2) as total_monthly_revenue
from sales_toys a inner join products b using(Product_ID)
group by month(a.date)
order by Month) tab1

# -------------------------------------------------------------------------------

# Q6) Is there a difference in product category popularity between Summer and Winter months?

# get revenue of winter months

with w as(
select a.product_category, round(sum(a.product_price*b.units), 2) as total_revenue
from products a inner join sales_toys b using(Product_ID)
where month(b.date) in(1, 2, 12)
group by a.product_category),

# get revenue of summer months

s as(
select a.product_category, round(sum(a.product_price*b.units), 2) as total_revenue
from products a inner join sales_toys b using(Product_ID)
where month(b.date) in(6, 7, 8)
group by a.product_category)

# collect the results of the above two CTEs, joining on product category

select w.product_category, w.total_revenue as winter_revenue, s.total_revenue as summer_revenue
from w inner join s using(product_category)

# -------------------------------------------------------------------------------

# Q7) What cities generate the most revenue?

select s.Store_city, round(sum(p.product_price*t.units), 2) as City_Revenue
from stores s
	 inner join sales_toys t on s.Store_ID = t.Store_ID
     inner join products p on p.Product_ID = t.Product_ID
group by s.Store_City
order by City_Revenue desc

# -------------------------------------------------------------------------------

# Q8) Are older (legacy) stores able to incorporate ecommerce technology well? Are they providing the same
#     level of success as newer stores? Earliest store opening is in 1992, latest in 2016. Let's consider
#	  2004 which is halfway between the two dates as the cutoff point

with cte2 as(
select s.Store_ID, s.Store_Name, round(sum(p.product_price*t.units), 2) as Store_Revenue
from stores s
	 inner join sales_toys t on s.Store_ID = t.Store_ID
     inner join products p on p.Product_ID = t.Product_ID
group by s.Store_ID, s.Store_Name)
select cte2.Store_name, cte2.Store_Revenue,
	   case when year(s.store_open_date) <= 2004 then 'Legacy Store' else 'New Store' end as Age_Status
from cte2 inner join stores s using(Store_ID)
order by Store_Revenue DESC

# -------------------------------------------------------------------------------

# Q9) How much money is tied up in each store in the form of stock? Top 5 vs Bottom 5

# top 5

select i.store_id, s.store_name, round(sum(i.Stock_On_Hand*p.product_price), 2) as total_inventory_value
from inventory i
	 inner join stores s on i.store_id = s.store_id
     inner join products p on i.product_id = p.product_id
group by i.store_id, s.store_name
order by total_inventory_value desc
limit 5

# bottom 5

select i.store_id, s.store_name, round(sum(i.Stock_On_Hand*p.product_price), 2) as total_inventory_value
from inventory i
	 inner join stores s on i.store_id = s.store_id
     inner join products p on i.product_id = p.product_id
group by i.store_id, s.store_name
order by total_inventory_value asc
limit 5

# ------------------------------------------------------------------------------------

# Q10) Is there any relationship between value of stock tied up and revenue by store?

with inventory_value as( # get inventory value per store
select i.store_id, s.store_name, round(sum(i.Stock_On_Hand*p.product_price), 2) as total_inventory_value
from inventory i
	 inner join stores s on i.store_id = s.store_id
     inner join products p on i.product_id = p.product_id
group by i.store_id, s.store_name
order by total_inventory_value),
store_revenue as( # get total revenue per store
select s.store_name, sum(p.product_price*t.units) as revenue
from products p
	 inner join sales_toys t on p.product_id = t.product_id
     inner join stores s on t.store_id = s.store_id
group by s.store_name)

# collect and return relevant results of above CTEs, joining on store_name

select inventory_value.store_name, inventory_value.total_inventory_value, store_revenue.revenue
from inventory_value inner join store_revenue using(store_name)
order by store_revenue.revenue desc