USE crypto;

-- 1.  Total no. of sales occurred during this time period.

SELECT COUNT(*) FROM
pricedata;

-- 2. Return the top 5 most expensive transactions (by USD price) for this data set. 
-- Return the name, ETH price, and USD price, as well as the date.

SELECT name, event_date,  eth_price, usd_price from pricedata
ORDER BY usd_price DESC
LIMIT 5;

-- 3. Return a table with a row for each transaction with an event column,
-- a USD price column, and a moving average of USD price that averages the last 50 transactions.

SELECT transaction_hash, usd_price, AVG(usd_price)
OVER(ORDER BY event_date ROWS BETWEEN 49 PRECEDING AND CURRENT ROW) AS moving_avg_usd_price
FROM pricedata;

-- 4. Return all the NFT names and their average sale price in USD. Sort descending. Name the average column as average_price

SELECT name, AVG(usd_price)
FROM pricedata
GROUP BY name
ORDER BY AVG(usd_price) DESC;

-- 5. Return each day of the week and the number of sales that occurred on that day of the week, 
-- as well as the average price in ETH. Order by the count of transactions in ascending order.

SELECT DAYNAME(event_date) AS day_of_week,
count(*),
AVG(eth_price)
FROM pricedata
GROUP BY day_of_week
ORDER BY count(*) ASC;

-- 6. Construct a column that describes each sale and is called summary. 

SELECT 
CONCAT(name, ' was sold for $', ROUND(usd_price, 3), ' to ', buyer_address, ' from ', seller_address, ' on ', event_date, '.')
AS summary
FROM pricedata;

-- 7. Create a view called “1919_purchases” and contains any sales where “0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685” was the buyer

CREATE VIEW 1919_purchases 
AS 
SELECT * FROM pricedata
WHERE buyer_address = '0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685';

SELECT * FROM 1919_purchases;

-- 8. Create a histogram of ETH price ranges. Round to the nearest hundred value.

SELECT ROUND(eth_price, -2) AS price_ranges,
COUNT(*)
FROM pricedata
GROUP BY price_ranges
ORDER BY price_ranges;

-- 9. To return a unioned query containing the highest and lowest prices for each NFT

SELECT name, MAX(usd_price) AS price,
'highest' AS status
FROM pricedata
GROUP BY name
 
UNION

SELECT name, MIN(usd_price) AS price,
'lowest' AS status
FROM pricedata
GROUP BY name
ORDER BY name, status ASC;

 -- 10. What NFT sold the most each month/year combination? Also, what was the name and the price in USD? Order in chronological format.

SELECT date_format(event_date, '%m-%y') AS month_year, name, MAX(usd_price) AS highest_price
FROM pricedata
GROUP BY month_year, name
ORDER BY month_year DESC;
 
-- 11. Return the total volume (sum of all sales), rounded to the nearest hundred on a monthly basis (month/year).
  
SELECT ROUND(SUM(usd_price), -2) AS total_volume,
date_format(event_date, '%m-%y') AS month_year
FROM pricedata
GROUP BY month_year;

-- 12. Count how many transactions the wallet "0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685" had over this time period.

SELECT COUNT(*) AS transaction_count
FROM pricedata
WHERE buyer_address = '0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685';

-- Q 13 
 -- a). First create a query that will be used as a subquery. Select the event date, the USD price, 
  -- and the average USD price for each day using a window function. Save it as a temporary table.
  
  CREATE TEMPORARY TABLE subquery AS 
  SELECT event_date, usd_price, AVG(usd_price) 
  OVER(PARTITION BY event_date) AS daily_average
  FROM pricedata;
  
  SELECT * FROM subquery;
  
-- b) Use the table you created in Part A to filter out rows where the USD prices is below 10% of the daily average 
 -- and return a new estimated value which is just the daily average of the filtered data.
 
SELECT event_date, AVG(usd_price) AS estimated_avg_value
FROM subquery
WHERE usd_price >= 0.1 * daily_average
GROUP BY event_date;
           
		
