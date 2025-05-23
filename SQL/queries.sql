
-- SQL Analysis of Customer Purchases and Revenue in a Digital Music Store (Chinook Database)

-- Find the customer who spent the most money in total
SELECT customer.firstname, SUM(invoice.total) AS total_spent
FROM invoice
JOIN customer ON customer.customerid=invoice.customerid
GROUP BY customer.customerid
ORDER BY total_spent DESC
LIMIT 1;

-- Calculate total revenue generated per country, sorted from highest to lowest
SELECT invoice.billingcountry, SUM(invoice.total) AS total_revenue
FROM invoice
GROUP BY invoice.billingcountry
ORDER BY total_revenue DESC;

-- Identify the top 3 music genres by total revenue
SELECT genre.name, SUM(invoiceline.unitprice * invoiceline.quantity) AS total_revenue
FROM genre
JOIN track ON track.genreid = genre.genreid
JOIN invoiceline ON invoiceline.trackid = track.trackid
GROUP BY genre.name
ORDER BY total_revenue DESC
LIMIT 3;

-- Find the top 5 artists who generated the highest total revenue
SELECT artist.name, SUM(invoiceline.unitprice * invoiceline.quantity) AS total_revenue
FROM artist
JOIN album ON album.artistid = artist.artistid
JOIN track ON track.albumid = album.albumid
JOIN invoiceline ON invoiceline.trackid = track.trackid
GROUP BY artist.name
ORDER BY total_revenue DESC
LIMIT 5;

-- List customers who spent more than the average total spending across all customers
SELECT 
  customer.customerid, 
  customer.firstname, 
  customer.lastname, 
  SUM(invoice.total) AS total_spent
FROM invoice
JOIN customer ON invoice.customerid = customer.customerid
GROUP BY customer.customerid
HAVING total_spent > (
    SELECT AVG(customer_totals)
    FROM (
        SELECT SUM(invoice.total) AS customer_totals
        FROM invoice
        GROUP BY customerid
    ) AS customer_totals
);

-- Find customers who have purchased tracks from more than 3 different genres
SELECT 
  customer.customerid,
  customer.firstname,
  customer.lastname,
  COUNT(DISTINCT genre.genreid) AS distinct_genres
FROM customer
JOIN invoice ON customer.customerid = invoice.customerid
JOIN invoiceline ON invoice.invoiceid = invoiceline.invoiceid
JOIN track ON invoiceline.trackid = track.trackid
JOIN genre ON genre.genreid = track.genreid
GROUP BY customer.customerid, customer.firstname, customer.lastname
HAVING distinct_genres > 3
ORDER BY distinct_genres DESC LIMIT 10;

-- Identify customers who have purchased every track in the "Rock" genre
SELECT
  customer.customerid,
  customer.firstname,
  customer.lastname,
  COUNT(DISTINCT track.trackid) AS rock_tracks_bought
FROM customer
JOIN invoice ON customer.customerid = invoice.customerid
JOIN invoiceline ON invoice.invoiceid = invoiceline.invoiceid
JOIN track ON invoiceline.trackid = track.trackid
JOIN genre ON track.genreid = genre.genreid
WHERE genre.name = 'Rock'
GROUP BY customer.customerid, customer.firstname, customer.lastname
HAVING rock_tracks_bought = (
    SELECT COUNT(DISTINCT track.trackid)
    FROM track
    JOIN genre ON track.genreid = genre.genreid
    WHERE genre.name = 'Rock'
);