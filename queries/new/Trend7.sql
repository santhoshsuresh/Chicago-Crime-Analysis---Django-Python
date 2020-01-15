Trend 7: Observe the trend in the frequency of Domestic/ Non-domestic violence
reported over the date range provided by user, using a line graph.

-- input - year value

WITH crimestatistics AS (
    SELECT /*+parallel(10)*/
        c.year year,
        CASE substr(to_char(c.timestamp), 4, 3)
            WHEN 'JAN'   THEN
                'January'
            WHEN 'FEB'   THEN
                'February'
            WHEN 'MAR'   THEN
                'March'
            WHEN 'APR'   THEN
                'April'
            WHEN 'MAY'   THEN
                'May'
            WHEN 'JUN'   THEN
                'June'
            WHEN 'JUL'   THEN
                'July'
            WHEN 'AUG'   THEN
                'August'
            WHEN 'SEP'   THEN
                'September'
            WHEN 'OCT'   THEN
                'October'
            WHEN 'NOV'   THEN
                'November'
            WHEN 'DEC'   THEN
                'December'
        END AS month,
        'Domestic' type,
        COUNT(1) total
    FROM
        cct_cases c
    WHERE
        c.domestic = 'true'
        AND c.year = 2018
    GROUP BY
        c.year,
        substr(to_char(c.timestamp), 4, 3)
    UNION ALL
    SELECT /*+parallel(10)*/
        c.year year,
        CASE substr(to_char(c.timestamp), 4, 3)
            WHEN 'JAN'   THEN
                'January'
            WHEN 'FEB'   THEN
                'February'
            WHEN 'MAR'   THEN
                'March'
            WHEN 'APR'   THEN
                'April'
            WHEN 'MAY'   THEN
                'May'
            WHEN 'JUN'   THEN
                'June'
            WHEN 'JUL'   THEN
                'July'
            WHEN 'AUG'   THEN
                'August'
            WHEN 'SEP'   THEN
                'September'
            WHEN 'OCT'   THEN
                'October'
            WHEN 'NOV'   THEN
                'November'
            WHEN 'DEC'   THEN
                'December'
        END AS month,
        'Non-Domestic' type,
        COUNT(1) total
    FROM
        cct_cases c
    WHERE
        c.domestic = 'false'
        AND c.year = 2018
    GROUP BY
        c.year,
        substr(to_char(c.timestamp), 4, 3)
)
SELECT
    *
FROM
    crimestatistics PIVOT (
        SUM ( total )
        FOR type
        IN ( 'Domestic' AS domestic, 'Non-Domestic' AS nondomestic )
    )
ORDER BY
    decode(month, 'January', 1, 'February', 2,'March', 3, 'April', 4, 'May',5, 'June', 6, 'July', 7,'August', 8, 'September', 9, 'October',10, 'November', 11, 'December', 12);
    
    
      YEAR MONTH       DOMESTIC NONDOMESTIC
---------- --------- ---------- -----------
      2019 January         3319       16141
      2019 February        3015       15225
      2019 March           3497       16737
      2019 April           3535       17246
      2019 May             4069       19374
      2019 June            3923       19354
      2019 July            4088       20454
      2019 August          3903       20050
      2019 September       3590       18377
      2019 October         3246       17660
      2019 November         685        3144

11 rows selected. 


      YEAR MONTH       DOMESTIC NONDOMESTIC
---------- --------- ---------- -----------
      2018 January         3261       17131
      2018 February        2882       14418
      2018 March           3543       17645
      2018 April           3498       17593
      2018 May             4277       20392
      2018 June            4113       20055
      2018 July            4128       21050
      2018 August          3985       21361
      2018 September       3642       19367
      2018 October         3622       19151
      2018 November        3364       17240
      2018 December        3511       18385

12 rows selected. 

