WITH crimebytimequarter AS (
    SELECT
        year,
        CASE month
            WHEN 'JAN'   THEN
                'Q1'
            WHEN 'FEB'   THEN
                'Q1'
            WHEN 'MAR'   THEN
                'Q1'
            WHEN 'APR'   THEN
                'Q2'
            WHEN 'MAY'   THEN
                'Q2'
            WHEN 'JUN'   THEN
                'Q2'
            WHEN 'JUL'   THEN
                'Q3'
            WHEN 'AUG'   THEN
                'Q3'
            WHEN 'SEP'   THEN
                'Q3'
            WHEN 'OCT'   THEN
                'Q4'
            WHEN 'NOV'   THEN
                'Q4'
            WHEN 'DEC'   THEN
                'Q4'
        END AS quarter,
        CASE
            WHEN period = 'AM'
                 AND hour >= 0
                 AND hour < 6 THEN
                1
            WHEN period = 'AM'
                 AND hour >= 6 THEN
                2
            WHEN period = 'PM'
                 AND hour >= 0
                 AND hour < 6 THEN
                3
            WHEN period = 'PM'
                 AND hour >= 6 THEN
                4
            ELSE
                0
        END AS time_sector,
        district
    FROM
        (
            SELECT  
                year,
                substr(to_char(c.timestamp), 4, 3) month,
                mod(to_number(substr(to_char(c.timestamp), 11, 2)), 12) hour,
                TRIM(substr(to_char(c.timestamp), 26, 3)) period,
                c.district
            FROM
                cct_cases c
            WHERE
                c.domestic = 'false'
                AND year = {y}
        )
)
SELECT month_range||' '||time_range, total
FROM
(SELECT
    year,
    CASE quarter
        WHEN 'Q1'   THEN
            'Q1 : January to April'
        WHEN 'Q2'   THEN
            'Q2 : May to July'
        WHEN 'Q3'   THEN
            'Q3 : August to September'
        ELSE
            'Q4: October to December'
    END AS month_range,
    CASE time_sector
        WHEN 1   THEN
            'T1: 00 a.m. to 06 a.m.'
        WHEN 2   THEN
            'T2: 06 a.m. to 12 p.m.'
        WHEN 3   THEN
            'T3: 12 p.m. to 06 p.m.'
        ELSE
            'T4: 06 p.m. to 00 a.m.'
    END AS time_range,
    COUNT(1) total
FROM
    crimebytimequarter
GROUP BY
    year,
    quarter,
    time_sector
ORDER BY
    1 ASC,
    2 ASC,
    3 ASC,
    4 DESC);