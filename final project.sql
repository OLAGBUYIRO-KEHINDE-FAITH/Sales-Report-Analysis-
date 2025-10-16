-- Which products category generate the highest revenue


select 
        p.category,
Round(SUM(od.unitprice * od.quantity),2) as total_revenue
from [order_details cp] od
join [products cp] p
on p.productid = od.productid
join [orders cp] o
on o.order_id = od.orderid
join [Customer cp] c
on c.customer_id = o.customer_id
group by  p.category
order by total_revenue desc;


-- Who are our top 5 customers

select top 5
     c.customer_id,
     c.first_name,
     c. last_name,
ROUND(SUM(o.totalamount),2) as total_spent
 from [Customer cp] c
 join [orders cp] o
 on c.customer_id = o.customer_id
 group by c.customer_id, c.last_name, c.first_name
 order by total_spent desc;


-- How many orders are still in processing or returned

   WITH OrderStatus AS (
    SELECT 
        status,
        COUNT(order_id) AS total_orders
    FROM [orders cp]
    WHERE status IN ('Processing', 'Returned', 'delivered', 'shipped')
    GROUP BY status
)
SELECT *
FROM OrderStatus;

-- Total orders

select 
count(order_id) as total_orders
from [orders cp];

--total items sold

select
count(quantity) total_items_sold
from [order_details cp];
 
 -- Top 10 products that generates highest_revenue
 select top 10
 p.product_name,
 Round(sum(od.unitprice * od.quantity),2) as total_revenue
 from [order_details cp] od
 join [products cp] p 
 on p.productid = od.productid
 group by p.product_name
 order by total_revenue desc;

 --Top 5 products that generates low revenue 
 select top 5
 p.product_name,
 ROUND(sum(od.unitprice * od.quantity),2) as total_revenue
 from [order_details cp] od
 join [products cp] p
 on p.productid = od.productid
 group by p.product_name
 order by total_revenue asc;



 select 
 year(order_date) as sales_year,
 count (order_id) as total_orders
 from [orders cp] o
 group by year(order_date)
 order by total_orders;



 -- “What is the total annual sales?
 select 
 YEAR(o.order_date) as sales_year,
 Round(sum(od.unitprice * od.quantity), 2) as total_revenue
 from [orders cp] o
 join [order_details cp] od
 on od.orderid = o.order_id
 group by YEAR(o.order_date)
 order by total_revenue;



 -- What is the total quarterly sales?
WITH quarterly_sales AS (
    SELECT 
        YEAR(o.order_date) AS sales_year,
        DATEPART(QUARTER, o.order_date) AS sales_quarter,
        SUM(od.unitprice * od.quantity) AS total_sales
    FROM [orders cp] AS o
    JOIN [order_details cp] AS od
        ON od.orderid = o.order_id
    GROUP BY YEAR(o.order_date), DATEPART(QUARTER, o.order_date)
)
SELECT 
    CONCAT('Q', sales_quarter, ' ', sales_year) AS quarter_name,
    FORMAT(total_sales, 'N2') AS total_sales
FROM quarterly_sales
WHERE 
    (sales_year = 2024 AND sales_quarter = 4)
    OR 
    (sales_year = 2025 AND sales_quarter IN (1,2,3))
ORDER BY sales_year, sales_quarter;


-- Total quantity 
SELECT 
    YEAR(o.order_date) AS sales_year,
    DATEPART(QUARTER,o.order_date) as quantity_quarter,
    COUNT(od.quantity) AS total_quantity
FROM [orders cp] AS o
JOIN [order_details cp] AS od
    ON od.orderid = o.order_id
GROUP BY YEAR(o.order_date), DATEPART(QUARTER,o.order_date)
ORDER BY sales_year;



-- YOY GROWTH Q4 2024 TO Q1-Q3 2025
WITH sales_summary AS (
    SELECT 
        YEAR(o.order_date) AS sales_year,
        DATEPART(QUARTER, o.order_date) AS sales_quarter,
        SUM(od.unitprice * od.quantity) AS total_sales,
        SUM(od.quantity) AS total_quantity,
        ROUND(sum(od.unitprice), 2) AS total_unitprice
    FROM [order_details cp] od
    JOIN [orders cp] o ON o.order_id = od.orderid
    GROUP BY YEAR(o.order_date), DATEPART(QUARTER, o.order_date)
)

SELECT 
    -- Total for 2024 Q4
    (SELECT SUM(total_sales) 
     FROM sales_summary 
     WHERE sales_year = 2024 AND sales_quarter = 4) AS sales_2024_Q4,

    -- Total for 2025 Q1–Q3
    (SELECT SUM(total_sales) 
     FROM sales_summary 
     WHERE sales_year = 2025 AND sales_quarter IN (1,2,3)) AS sales_2025_Q1_to_Q3,

    -- Growth in %
    ROUND(
        (
                (SELECT SUM(total_sales) 
                 FROM sales_summary 
                 WHERE sales_year = 2025 AND sales_quarter IN (1,2,3))
                -
                (SELECT SUM(total_sales) 
             FROM sales_summary 
             WHERE sales_year = 2024 AND sales_quarter = 4)
        ) * 100
    , 2) AS yoy_growth_percent;








