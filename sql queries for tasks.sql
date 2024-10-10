SELECT * FROM music.album;
use music;

/* Purpose: To understand which genres generate the most revenue.
SQL Query:*/

SELECT g.name AS genre, round(SUM(il.unit_price * il.quantity),2) AS total_revenue
FROM invoice_line il
JOIN track t ON il.track_id = t.track_id
JOIN genre g ON t.genre_id = g.genre_id
GROUP BY g.name
ORDER BY total_revenue DESC;

-- Top Artists by Revenue
-- Purpose: To identify which artists generate the most income for the store.

 SELECT a.name AS artist_name, round (SUM(il.unit_price * il.quantity),3) AS total_revenue
FROM invoice_line il
JOIN track t ON il.track_id = t.track_id
JOIN album al ON t.album_id = al.album_id
JOIN artist a ON al.artist_id = a.artist_id
GROUP BY a.artist_id, a.name
ORDER BY total_revenue DESC
LIMIT 10;

-- Sales Trends Over Time
-- Purpose: To visualize how sales have changed over time.

SELECT DATE_FORMAT(i.invoice_date, '%Y-%m') AS month, round( SUM(i.total),2) AS monthly_sales
FROM invoice i
GROUP BY month
ORDER BY month;


--  Most Popular Tracks
-- Purpose: To find out which tracks are purchased the most.
  SELECT t.name AS track_name, COUNT(il.invoice_line_id) AS purchase_count
FROM invoice_line il
JOIN track t ON il.track_id = t.track_id
GROUP BY t.track_id, t.name
ORDER BY purchase_count DESC
LIMIT 10;

-- Invoices by Country
-- Purpose: To determine where the most invoices are generated.

   SELECT c.country, COUNT(i.invoice_id) AS invoice_count
FROM invoice i
JOIN customer c ON i.customer_id = c.customer_id
GROUP BY c.country
ORDER BY invoice_count DESC;




