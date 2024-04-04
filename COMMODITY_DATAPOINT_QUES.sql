/**************************************************************************************************
Determine the common commodities between the Top 10 costliest commodities of 2019 and 2020?

What is the maximum difference between the prices of a commodity
at one place vs the other for the month of June 2020? Which commodity was it for?

Arrange the commodities in an order based on the number of variants in which they are available,
with the highest one shown at the top, which is the third commodity in the list.?

In a state with the least number of data points available,
which commodity has the highest number of data points available?

What is the price variation of commodities for each city from January 2019 to December 2020?
 Which commodity has seen the highest price variation and in which city?
**************************************************************************************************/


-- Q1. Determine the common commodities between the Top 10 costliest commodities of 2019 and 2020?

USE COMMODITY_DB;

SELECT * FROM commodities_info;
SELECT * FROM PRICE_DETAILS;

WITH COSTILEST_2019 AS
(
SELECT MAX(RETAIL_PRICE) AS MAX_PRICE, commodity_ID
FROM PRICE_DETAILS
WHERE YEAR(DATE) = "2019"
GROUP BY commodity_ID
ORDER BY MAX_PRICE DESC
LIMIT 10
),
COSTILEST_2020 AS
(
SELECT MAX(RETAIL_PRICE) AS MAX_PRICE, commodity_ID
FROM PRICE_DETAILS
WHERE YEAR(DATE) = "2020"
GROUP BY commodity_ID
ORDER BY MAX_PRICE DESC
LIMIT 10)
SELECT COMMODITY
FROM commodities_info
WHERE ID IN
(SELECT C1.COMMODITY_ID
FROM COSTILEST_2019 C1
INNER JOIN COSTILEST_2020 C2
ON C1.COMMODITY_ID = C2.COMMODITY_ID
INNER JOIN commodities_info CI
ON C2.COMMODITY_ID = CI.ID
);

-- What is the maximum difference between the prices of a commodity
-- at one place vs the other for the month of June 2020? Which commodity was it for?

USE COMMODITY_DB;

SELECT * FROM commodities_info;

WITH SUMMARY AS
(
SELECT commoditY_iD,
 MAX(RETAIL_PRICE) AS MAX_PRICE,
 MIN(RETAIL_PRICE) AS MIN_PRICE,
 MAX(RETAIL_PRICE)-MIN(RETAIL_PRICE) AS PRICE_DIFF
FROM PRICE_DETAILS
WHERE year(DATE) = "2020" AND month(DATE) = "06"
GROUP BY commoditY_iD
ORDER BY PRICE_DIFF DESC
LIMIT 1
)
SELECT PRICE_DIFF FROM SUMMARY;

WITH SUMMARY AS
(
SELECT commoditY_iD,
 MAX(RETAIL_PRICE) AS MAX_PRICE,
 MIN(RETAIL_PRICE) AS MIN_PRICE,
 MAX(RETAIL_PRICE)-MIN(RETAIL_PRICE) AS PRICE_DIFF
FROM PRICE_DETAILS
WHERE year(DATE) = "2020" AND month(DATE) = "06"
GROUP BY commoditY_iD
ORDER BY PRICE_DIFF DESC
LIMIT 1
)
SELECT COMMODITY FROM commodities_info
WHERE ID = (SELECT commoditY_iD FROM SUMMARY);


-- COMBINED QUERRY
 
USE commodity_db;

WITH june_prices AS
(
SELECT commodity_id, 
MIN(retail_price) AS Min_price,
MAX(retail_price) AS Max_price
FROM price_details
WHERE date BETWEEN '2020-06-01' AND '2020-06-30'
GROUP BY commodity_id
)
SELECT ci.commodity,
Max_price-Min_price AS price_difference
FROM
june_prices as jp
JOIN
commodities_info as ci
ON jp.commodity_id=ci.id
ORDER BY price_difference DESC
LIMIT 1;



-- Arrange the commodities in an order based on the number of variants in which they are available,
-- with the highest one shown at the top, which is the third commodity in the list.?

USE COMMODITY_DB;

SELECT Commodity , COUNT(DISTINCT Variety) AS COMM_Variety
FROM commodities_info
GROUP BY Commodity
ORDER BY COMM_Variety DESC
LIMIT 5
;

-- In a state with the least number of data points available,
-- which commodity has the highest number of data points available?

USE COMMODITY_DB;

SELECT * FROM region_info;
SELECT * FROM price_details;
SELECT * FROM commodities_info;
WITH RAW_DATA AS
(
SELECT P.ID, P.Commodity_Id, R.STATE
FROM price_details P
LEFT JOIN region_info R
ON P.Region_Id = R.ID
),
STATE_RECORD_COUNT AS
(
SELECT STATE , COUNT(ID) AS STATE_DATA_POINT
FROM RAW_DATA
GROUP BY STATE
ORDER BY STATE_DATA_POINT
LIMIT 1
),
COMMODITY_LIST AS
(
SELECT commoditY_iD,
COUNT(ID) AS RECORD_COUNT
FROM RAW_DATA
WHERE STATE IN (SELECT DISTINCT STATE FROM STATE_RECORD_COUNT)
GROUP BY commoditY_iD
ORDER BY RECORD_COUNT DESC
)
SELECT * FROM COMMODITY_LIST C1
LEFT JOIN 
commodities_info CI
ON C1.Commodity_Id = CI.ID;

-- What is the price variation of commodities for each city from January 2019 to December 2020?
-- Which commodity has seen the highest price variation and in which city?

use commodity_db;

WITH JAN_2019_DATA AS
(
SELECT * from price_details
WHERE DATE BETWEEN "2019-01-01" AND "2019-01-31"
),
DEC_2020_DATA AS
(
SELECT * from price_details
WHERE DATE BETWEEN "2020-12-01" AND "2020-12-31"
),
PRICE_VAR_SUMMARY AS
(
SELECT
JD.REGION_ID AS REGION_ID,
JD.COMMODITY_ID AS COMMODITY_ID,
JD.RETAIL_PRICE AS START_PRICE,
DD.RETAIL_PRICE AS END_PRICE
FROM JAN_2019_DATA JD
INNER JOIN DEC_2020_DATA DD
ON JD.REGION_ID = DD.REGION_ID AND JD.COMMODITY_ID = DD.COMMODITY_ID),
PRICE_VARIATION_SUMMARY AS
(
SELECT
*, START_PRICE-END_PRICE AS ABS_PRICE_DELTA,
((END_PRICE-START_PRICE)/START_PRICE)*100 AS PERCENTAGE_DELTA
FROM PRICE_VAR_SUMMARY
ORDER BY PERCENTAGE_DELTA DESC
LIMIT 1
)
SELECT CENTRE, STATE,COMMODITY,ABS_PRICE_DELTA, PERCENTAGE_DELTA 
FROM PRICE_VARIATION_SUMMARY PV
INNER JOIN REGION_INFO RI
ON PV.REGION_ID  = RI.ID
INNER JOIN COMMODITIES_INFO CI
ON PV.COMMODITY_ID = CI.ID;





