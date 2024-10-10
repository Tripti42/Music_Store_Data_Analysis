use music;

-- 1.How many different genres are available in the database?
SELECT COUNT(DISTINCT name) AS genre_count
FROM genre;

-- 2.Who is the senior most employee based on job title? 

SELECT title, last_name, first_name 
FROM employee
ORDER BY levels DESC
LIMIT 1;

-- 3.Which artists have not sold any tracks?
SELECT a.artist_id, a.name AS artist_name
FROM artist a
LEFT JOIN album al ON a.artist_id = al.artist_id
LEFT JOIN track t ON al.album_id = t.album_id
LEFT JOIN invoice_line il ON t.track_id = il.track_id
WHERE il.invoice_line_id IS NULL;

-- 4. Find the total revenue generated from each genre.
SELECT g.name AS genre, SUM(il.unit_price * il.quantity) AS total_revenue
FROM invoice_line il
JOIN track t ON il.track_id = t.track_id
JOIN genre g ON t.genre_id = g.genre_id
GROUP BY g.name
ORDER BY total_revenue DESC;

-- 5. Which album has the highest number of tracks?
SELECT al.album_id, al.title, COUNT(t.track_id) AS track_count
FROM album al
JOIN track t ON al.album_id = t.album_id
GROUP BY al.album_id, al.title
ORDER BY track_count DESC
LIMIT 1;

-- 6. Find the top 5 customers based on the number of invoices they have.
SELECT c.customer_id, c.first_name, c.last_name, COUNT(i.invoice_id) AS invoice_count
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY invoice_count DESC
LIMIT 5;

-- 7. which tracks have been purchased the most?
SELECT t.name AS track_name, COUNT(il.invoice_line_id) AS purchase_count
FROM track t
JOIN invoice_line il ON t.track_id = il.track_id
GROUP BY t.track_id, t.name
ORDER BY purchase_count DESC;


-- 8. Find the average spending per customer.
SELECT AVG(total_spending) AS average_spending
FROM (
    SELECT c.customer_id, SUM(i.total) AS total_spending
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    GROUP BY c.customer_id
) AS customer_totals;


-- 9.Which countries have the highest average invoice total?
SELECT billing_country, AVG(total) AS average_invoice_total
FROM invoice
GROUP BY billing_country
ORDER BY average_invoice_total DESC;


-- 10.Which countries have the most Invoices? 

SELECT COUNT(*) AS c, billing_country 
FROM invoice
GROUP BY billing_country
ORDER BY c DESC;


/* 11.What are top 3 values of total invoice? */

SELECT total 
FROM invoice
ORDER BY total DESC;


/* 12. Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

SELECT billing_city,SUM(total) AS InvoiceTotal
FROM invoice
GROUP BY billing_city
ORDER BY InvoiceTotal DESC
LIMIT 1;


/*  13.Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

SELECT customer.customer_id, first_name, last_name, SUM(invoice.total) AS total_spending
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id, first_name, last_name
ORDER BY total_spending DESC
LIMIT 1;


/* 14.Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */


SELECT DISTINCT customer.email, customer.first_name, customer.last_name, genre.name AS genre
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
JOIN track ON invoice_line.track_id = track.track_id
JOIN genre ON track.genre_id = genre.genre_id
WHERE genre.name = 'Rock'
ORDER BY customer.email;




/* 15. Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

SELECT artist.artist_id, artist.name, COUNT(track.track_id) AS number_of_songs
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name = 'Rock'
GROUP BY artist.artist_id, artist.name
ORDER BY number_of_songs DESC
LIMIT 10;


/*  16.Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

SELECT name, milliseconds
FROM track
WHERE milliseconds > (SELECT AVG(milliseconds) FROM track)
ORDER BY milliseconds DESC;




/* 17.Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */

/* Steps to Solve: First, find which artist has earned the most according to the InvoiceLines. Now use this artist to find 
which customer spent the most on this artist. For this query, you will need to use the Invoice, InvoiceLine, Track, Customer, 
Album, and Artist tables. Note, this one is tricky because the Total spent in the Invoice table might not be on a single product, 
so you need to use the InvoiceLine table to find out how many of each product was purchased, and then multiply this by the price
for each artist. */

WITH best_selling_artist AS (
    SELECT artist.artist_id AS artist_id, artist.name AS artist_name, 
           SUM(invoice_line.unit_price * invoice_line.quantity) AS total_sales
    FROM invoice_line
    JOIN track ON track.track_id = invoice_line.track_id
    JOIN album ON album.album_id = track.album_id
    JOIN artist ON artist.artist_id = album.artist_id
    GROUP BY artist.artist_id, artist.name
    ORDER BY total_sales DESC
    LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, 
       SUM(il.unit_price * il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY c.customer_id, c.first_name, c.last_name, bsa.artist_name
ORDER BY amount_spent DESC;


/* 18. We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

/* Steps to Solve:  There are two parts in question- first most popular music genre and second need data at country level. */



WITH popular_genre AS (
    SELECT 
        COUNT(invoice_line.quantity) AS purchases, 
        customer.country, 
        genre.name, 
        genre.genre_id, 
        RANK() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RankNo 
    FROM invoice_line 
    JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
    JOIN customer ON customer.customer_id = invoice.customer_id
    JOIN track ON track.track_id = invoice_line.track_id
    JOIN genre ON genre.genre_id = track.genre_id
    GROUP BY customer.country, genre.name, genre.genre_id
)

SELECT country, name AS top_genre, purchases 
FROM popular_genre 
WHERE RankNo = 1
ORDER BY country;

/* 19. Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

/* Steps to Solve:  Similar to the above question. There are two parts in question- 
first find the most spent on music for each country and second filter the data for respective customers. */


WITH Customer_with_country AS (
    SELECT 
        customer.customer_id,
        first_name,
        last_name,
        billing_country,
        SUM(invoice.total) AS total_spending,
        RANK() OVER(PARTITION BY billing_country ORDER BY SUM(invoice.total) DESC) AS RankNo 
    FROM invoice
    JOIN customer ON customer.customer_id = invoice.customer_id
    GROUP BY customer.customer_id, first_name, last_name, billing_country
)

SELECT billing_country AS country, 
       first_name, 
       last_name, 
       total_spending 
FROM Customer_with_country 
WHERE RankNo = 1
ORDER BY billing_country;

-- 20.Find the average track length by genre?
 SELECT g.name AS genre, AVG(t.milliseconds) AS average_length
FROM track t
JOIN genre g ON t.genre_id = g.genre_id
GROUP BY g.name
ORDER BY average_length DESC;

-- 21.What is the total number of tracks for each artist?
SELECT a.artist_id, a.name AS artist_name, COUNT(t.track_id) AS total_tracks
FROM artist a
JOIN album al ON a.artist_id = al.artist_id
JOIN track t ON al.album_id = t.album_id
GROUP BY a.artist_id, a.name
ORDER BY total_tracks DESC;

-- 22.Find the top 3 most frequently purchased tracks?
SELECT t.name AS track_name, COUNT(il.invoice_line_id) AS purchase_count
FROM track t
JOIN invoice_line il ON t.track_id = il.track_id
GROUP BY t.track_id, t.name
ORDER BY purchase_count DESC
LIMIT 3;

-- 23.Which album has generated the highest revenue?
SELECT al.album_id, al.title, SUM(il.unit_price * il.quantity) AS total_revenue
FROM album al
JOIN track t ON al.album_id = t.album_id
JOIN invoice_line il ON t.track_id = il.track_id
GROUP BY al.album_id, al.title
ORDER BY total_revenue DESC
LIMIT 1;

-- 24.List all genres along with the number of tracks in each genre?
SELECT g.name AS genre, COUNT(t.track_id) AS track_count
FROM genre g
LEFT JOIN track t ON g.genre_id = t.genre_id
GROUP BY g.genre_id, g.name
ORDER BY track_count DESC;





