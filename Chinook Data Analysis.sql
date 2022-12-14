-- Data Analysis of the Chinook dataset to help how the store can optimize their business opportunities.
-- Looking at the countries with the most number of invoices 
SELECT billingcountry,COUNT(billingcountry) AS Invoice_Number
FROM invoice
GROUP BY billingcountry
ORDER BY Invoice_Number DESC;


-- top 10 Cities with the most customers
SELECT billingcity,SUM(total) AS InvoiceTotal
FROM invoice
GROUP BY billingcity
ORDER BY InvoiceTotal DESC
LIMIT 10;

-- Top 10 spending customers
SELECT customer.customerid, firstname, lastname, SUM(total) AS total_spending
FROM customer
JOIN invoice ON customer.customerid = invoice.customerid
GROUP BY (customer.customerid)
ORDER BY total_spending DESC
LIMIT 10;

-- Selecting the Email, First Name, Last name of all the rock music listeners
SELECT DISTINCT email,firstname, lastname
FROM customer
JOIN invoice ON customer.customerid = invoice.customerid
JOIN invoiceline ON invoice.invoiceid = invoiceline.invoiceid
WHERE trackid IN(
	SELECT trackid FROM track
	JOIN genre ON track.genreid = genre.genreid
	WHERE genre.name LIKE 'Rock'
)
ORDER BY email;

-- Top 10 Rock bands of all time

SELECT artist.artistid, artist.name,COUNT(artist.artistid) AS number_of_songs
FROM track
JOIN album ON album.albumid = track.albumid
JOIN artist ON artist.artistid = album.artistid
JOIN genre ON genre.genreid = track.genreid
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artistid
ORDER BY number_of_songs DESC
LIMIT 10;


-- I created a CTE to find which artist earns the most according to the table InvoiceLines.
-- And then found which customers have spend the most on the top artist  

WITH best_selling_artist AS(
	SELECT artist.artistid AS artistid,artist.name AS artistname,SUM(invoiceline.unitprice*invoiceline.quantity) AS total_sales
	FROM invoiceline
	JOIN track ON track.trackid = invoiceline.trackid
	JOIN album ON album.albumid = track.albumid
	JOIN artist ON artist.artistid = album.artistid
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)

SELECT bsa.artistname,SUM(il.unitprice*il.quantity) AS amountspent,c.customerid,c.firstname,c.lastname
FROM invoice i
JOIN customer c ON c.customerid = i.customerid
JOIN invoiceline il ON il.invoiceid = i.invoiceid
JOIN track t ON t.trackid = il.trackid
JOIN album alb ON alb.albumid = t.albumid
JOIN best_selling_artist bsa ON bsa.artistid = alb.artistid
GROUP BY 1,3,4,5
ORDER BY 2 DESC;




-- Most popular genre in each country and the genre with the most purchases
SELECT COUNT(*) AS purchases_per_genre, customer.country, genre.name, genre.genreid
FROM invoiceline
JOIN invoice ON invoice.invoiceid = invoiceline.invoiceid
JOIN customer ON customer.customerid = invoice.customerid
JOIN track ON track.trackid = invoiceline.trackid
JOIN genre ON genre.genreid = track.genreid
GROUP BY 2,3,4
ORDER BY 2;

WITH RECURSIVE
	tbl_sales_per_country AS(
		SELECT COUNT(*) AS purchases_per_genre, customer.country, genre.name, genre.genreid
		FROM invoiceline
		JOIN invoice ON invoice.invoiceid = invoiceline.invoiceid
		JOIN customer ON customer.customerid = invoice.customerid
		JOIN track ON track.trackid = invoiceline.trackid
		JOIN genre ON genre.genreid = track.genreid
		GROUP BY 2,3,4
		ORDER BY 2
	)
	,tbl_max_genre_per_country AS(SELECT MAX(purchases_per_genre) AS max_genre_number, country
		FROM tbl_sales_per_country
		GROUP BY 2
		ORDER BY 2)
        
SELECT tbl_sales_per_country.* 
FROM tbl_sales_per_country
JOIN tbl_max_genre_per_country ON tbl_sales_per_country.country = tbl_max_genre_per_country.country
WHERE tbl_sales_per_country.purchases_per_genre = tbl_max_genre_per_country.max_genre_number;


-- Songs with length greated than average

SELECT name,milliseconds/60000 As Minutes
FROM track
WHERE milliseconds > (
	SELECT AVG(milliseconds) AS avg_track_length
	FROM track)
ORDER BY milliseconds DESC;


-- Customer that has spend the most amount of money on music for each country.
WITH RECURSIVE 
	tbl_customter_with_country AS (
		SELECT customer.customerid,firstname,lastname,billingcountry,SUM(total) AS total_spending
		FROM invoice
		JOIN customer ON customer.customerid = invoice.customerid
		GROUP BY 1,2,3,4
		ORDER BY 2,3 DESC),

	tbl_country_max_spending AS(
		SELECT billingcountry,MAX(total_spending) AS max_spending
		FROM tbl_customter_with_country
		GROUP BY billingcountry)

SELECT tbl_cc.billingcountry, tbl_cc.total_spending,tbl_cc.firstname,tbl_cc.lastname,tbl_cc.customerid
FROM tbl_customter_with_country tbl_cc
JOIN tbl_country_max_spending tbl_ms
ON tbl_cc.billingcountry = tbl_ms.billingcountry
WHERE tbl_cc.total_spending = tbl_ms.max_spending
ORDER BY 1;
