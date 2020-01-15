Trend 5: Identify safe and risky hours to walk around in different location (Clubs, Street,
Store etc.) for each/multiple months in a year. This data could be used as a
recommendation to increase/decrease the patrols in those locations.

-- inputs :  year and district value
-- outputs: number of crimes in month/time range

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
            SELECT /*+parallel(10)*/
                year,
                substr(to_char(c.timestamp), 4, 3) month,
                mod(to_number(substr(to_char(c.timestamp), 11, 2)), 12) hour,
                TRIM(substr(to_char(c.timestamp), 26, 3)) period,
                c.district
            FROM
                cct_cases c
            WHERE
                c.domestic = 'false'
                AND year = 2019
        )
)
SELECT
    year,
    --     district,
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
    COUNT(1)
FROM
    crimebytimequarter
WHERE
    district IN (
        SELECT
            regexp_substr((decode(NULL, '',(
                SELECT
                    LISTAGG(district_no, ',') WITHIN GROUP(
                        ORDER BY
                            district_no
                    ) dist_list
                FROM
                    (
                        SELECT
                            district_no
                        FROM
                            cct_district
                        UNION
                        SELECT
                            district_no
                        FROM
                            cct_district_dep
                    )
            ), NULL)), '[^,]+', 1, level)
        FROM
            dual
        CONNECT BY
            regexp_substr((decode(NULL, '',(
                SELECT
                    LISTAGG(district_no, ',') WITHIN GROUP(
                        ORDER BY
                            district_no
                    ) dist_list
                FROM
                    (
                        SELECT
                            district_no
                        FROM
                            cct_district
                        UNION
                        SELECT
                            district_no
                        FROM
                            cct_district_dep
                    )
            ), NULL)), '[^,]+', 1, level) IS NOT NULL
    )
GROUP BY
    year,
--     district
    quarter,
    time_sector
ORDER BY
    1 ASC,
    2 ASC,
    3 ASC,
    4 DESC;

-- sample output for 2019 and districts 1,2,3,4,5

      YEAR MONTH_RANGE              TIME_RANGE               COUNT(1)
---------- ------------------------ ---------------------- ----------
      2019 Q1 : January to April    T1: 00 a.m. to 06 a.m.       6634
      2019 Q1 : January to April    T2: 06 a.m. to 12 p.m.      10523
      2019 Q1 : January to April    T3: 12 p.m. to 06 p.m.      16858
      2019 Q1 : January to April    T4: 06 p.m. to 00 a.m.      14088

      2019 Q2 : May to July         T1: 00 a.m. to 06 a.m.       8424
      2019 Q2 : May to July         T2: 06 a.m. to 12 p.m.      11858
      2019 Q2 : May to July         T3: 12 p.m. to 06 p.m.      18748
      2019 Q2 : May to July         T4: 06 p.m. to 00 a.m.      16944

      2019 Q3 : August to September T1: 00 a.m. to 06 a.m.       9529
      2019 Q3 : August to September T2: 06 a.m. to 12 p.m.      11828
      2019 Q3 : August to September T3: 12 p.m. to 06 p.m.      18731
      2019 Q3 : August to September T4: 06 p.m. to 00 a.m.      18793

      2019 Q4: October to December  T1: 00 a.m. to 06 a.m.       2965
      2019 Q4: October to December  T2: 06 a.m. to 12 p.m.       4252
      2019 Q4: October to December  T3: 12 p.m. to 06 p.m.       7204
      2019 Q4: October to December  T4: 06 p.m. to 00 a.m.       6383

16 rows selected. 


