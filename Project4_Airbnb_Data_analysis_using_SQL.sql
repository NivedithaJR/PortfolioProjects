--Most common room type available
SELECT room_type, COUNT(DISTINCT id) as number_available
FROM listings
GROUP BY room_type
ORDER BY number_available desc
-- Most common room type available is Entire home/apt

--Top and bottom 10 property type based on average price?
UPDATE listings
SET price = REPLACE(price, ',','')


SELECT DISTINCT TOP 10  a.property_type, ROUND(AVG(a.price_in_dollars) OVER (PARTITION BY a.property_type ),2) AS avg_price_top_10
FROM(
SELECT property_type, CAST(SUBSTRING(price, 2, LEN(price)) AS float) as price_in_dollars
FROM listings) AS a
ORDER BY avg_price_top_10 DESC


SELECT DISTINCT TOP 10 b.property_type, ROUND(AVG(b.price_in_dollars) OVER (PARTITION BY b.property_type),2) AS avg_price_bottom_10
FROM(
SELECT property_type, CAST(SUBSTRING(price, 2, LEN(price)) AS float) as price_in_dollars
FROM listings) AS b

--What is the top and bottom 10 property type based on review score?

SELECT DISTINCT TOP 10  property_type, ROUND(AVG(review_scores_rating) OVER (PARTITION BY property_type),2) AS avg_review_top_10
FROM listings
ORDER BY avg_review_top_10 DESC


SELECT DISTINCT TOP 10 property_type, ROUND(AVG(review_scores_rating) OVER (PARTITION BY property_type),2) AS avg_review_bottom_10
FROM listings
WHERE review_scores_rating IS NOT NULL
ORDER BY avg_review_bottom_10 ASC

--What is the most common amenities provided?

UPDATE listings
SET amenities = REPLACE(amenities, '[','')

UPDATE listings
SET amenities = REPLACE(amenities, ']','')

WITH cte as
(SELECT id, amenities, SUBSTRING(trim(value),2,LEN(trim(value))-2) as All_amenities
FROM listings
cross apply 
STRING_SPLIT(amenities, ','))

SELECT TOP 25 all_amenities, COUNT(All_amenities) as count_amenities
FROM cte
GROUP BY all_amenities
ORDER BY count_amenities DESC

--Is there any correlation between room price and the review score?
SELECT (Avg(review_scores_rating * avg_price_in_dollars)- (Avg(review_scores_rating) * Avg(avg_price_in_dollars))) / (StDevP(review_scores_rating) * StDevP(avg_price_in_dollars)) as correlation
FROM
	(SELECT DISTINCT review_scores_rating, CAST(SUBSTRING(price, 2, LEN(price)) AS float) as avg_price_in_dollars
		FROM listings) as a
WHERE review_scores_rating IS NOT NULL
--There is no correlation etween room price and the review score

--Top 10 host based on revenue
SELECT DISTINCT TOP 10 host_id, host_name, SUM((30-availability_30)*CAST(REPLACE(price, '$',' ') AS float)) as revenue_in_dollars
FROM listings
WHERE host_id IS NOT NULL or host_name IS NOT NULL
GROUP BY host_id, host_name
ORDER BY revenue_in_dollars DESC

--Most commonly verified host information?

WITH verification_table as 
(SELECT host_id, host_verifications, value, SUBSTRING(REPLACE(value,'[',''), 2,LEN(REPLACE(value,'[',''))-2) as verifications
FROM listings
CROSS APPLY
STRING_SPLIT(host_verifications, ','))

SELECT DISTINCT verifications, COUNT(verifications) OVER (PARTITION BY verifications) as most_commonly_verified
FROM verification_table 
ORDER BY most_commonly_verified DESC
-- email, phone are the mostly used verification 

-- Is there any difference in review score between superhost and normal host?

SELECT  DISTINCT UPPER(host_is_superhost) AS is_superhost, review_scores_rating, COUNT(host_id) OVER(PARTITION BY UPPER(host_is_superhost)) as count_review
FROM listings 
WHERE review_scores_rating IN (5,4,3,2,1,0) AND UPPER(host_is_superhost) IS NOT NULL
ORDER BY review_scores_rating DESC
-- Normal host has better rating than superhost

--How is the number of host joined to Airbnb over time?
SELECT DISTINCT a.host_since, COUNT(a.host_id) OVER(PARTITION BY a.host_since)
FROM(
SELECT DISTINCT host_id, host_name, LEFT(CONVERT(date, host_since),7) as host_since
FROM listings 
WHERE host_since IS NOT NULL) as a
ORDER BY host_since ASC
--The number of hosts increased from 2008 to 2013 and then started to decrease gradually till 2022.
SELECT DISTINCT a.host_since, COUNT(a.host_id) OVER(PARTITION BY a.host_since)
FROM(
SELECT DISTINCT host_id, host_name, LEFT(CONVERT(date, host_since),4) as host_since
FROM listings 
WHERE host_since IS NOT NULL) as a
ORDER BY host_since ASC