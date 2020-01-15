Trend 5: Identify safe and risky hours to walk around in different location (Clubs, Street,
Store etc.) for each/multiple months in a year. This data could be used as a
recommendation to increase/decrease the patrols in those locations.

-- inputs :  year and district value
-- outputs: number of crimes in month/time range

SELECT
    year,
    CASE month
        WHEN 1    THEN
            'January'
        WHEN 2    THEN
            'February'
        WHEN 3    THEN
            'March'
        WHEN 4    THEN
            'April'
        WHEN 5    THEN
            'May'
        WHEN 6    THEN
            'June'
        WHEN 7    THEN
            'July'
        WHEN 8    THEN
            'August'
        WHEN 9    THEN
            'September'
        WHEN 10   THEN
            'October'
        WHEN 11   THEN
            'November'
        WHEN 12   THEN
            'December'
    END AS month1,
    round(AVG(perct_change), 2)
FROM
    (
        SELECT
            c.year,
            c.month,
            c.district,
            round((c.cnt / p.cnt), 2) * 100 AS "PERCT_CHANGE"
        FROM
            (
                SELECT
                    COUNT(*) cnt,
                    year,
                    month,
                    district
                FROM
                    (
                        SELECT /*+parallel(10)*/
                            year,
                            CASE substr(to_char(c.timestamp), 4, 3)
                                WHEN 'JAN'   THEN
                                    1
                                WHEN 'FEB'   THEN
                                    2
                                WHEN 'MAR'   THEN
                                    3
                                WHEN 'APR'   THEN
                                    4
                                WHEN 'MAY'   THEN
                                    5
                                WHEN 'JUN'   THEN
                                    6
                                WHEN 'JUL'   THEN
                                    7
                                WHEN 'AUG'   THEN
                                    8
                                WHEN 'SEP'   THEN
                                    9
                                WHEN 'OCT'   THEN
                                    10
                                WHEN 'NOV'   THEN
                                    11
                                WHEN 'DEC'   THEN
                                    12
                            END AS month,
                            district
                        FROM
                            cct_cases c
                        WHERE
                            c.district IS NOT NULL
                            AND trunc(c.timestamp) >= '01-JAN-2012'
                            AND trunc(c.timestamp) <= '31-DEC-2013'
                    )
                GROUP BY
                    year,
                    month,
                    district
            ) c,
            (
                SELECT
                    COUNT(*) cnt,
                    year,
                    month,
                    district
                FROM
                    (
                        SELECT /*+parallel(10)*/
                            year,
                            CASE substr(to_char(c.timestamp), 4, 3)
                                WHEN 'JAN'   THEN
                                    1
                                WHEN 'FEB'   THEN
                                    2
                                WHEN 'MAR'   THEN
                                    3
                                WHEN 'APR'   THEN
                                    4
                                WHEN 'MAY'   THEN
                                    5
                                WHEN 'JUN'   THEN
                                    6
                                WHEN 'JUL'   THEN
                                    7
                                WHEN 'AUG'   THEN
                                    8
                                WHEN 'SEP'   THEN
                                    9
                                WHEN 'OCT'   THEN
                                    10
                                WHEN 'NOV'   THEN
                                    11
                                WHEN 'DEC'   THEN
                                    12
                            END AS month,
                            district
                        FROM
                            cct_cases c
                        WHERE
                            c.district IS NOT NULL
                            AND trunc(c.timestamp) >= '01-JAN-2012'
                            AND trunc(c.timestamp) <= '31-DEC-2013'
                    )
                GROUP BY
                    year,
                    month,
                    district
            ) p
        WHERE
            c.year = decode(c.month, 1, p.year + 1, p.year)
            AND c.month = decode(p.month + 1, 13, 1, p.month + 1)
            AND c.district = p.district
            AND c.district IN (
                SELECT
                    regexp_substr((decode(d_list_ip, '',(
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
                    ), d_list_ip)), '[^,]+', 1, level)
                FROM
                    dual
                CONNECT BY
                    regexp_substr((decode(d_list_ip, '',(
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
                    ), d_list_ip)), '[^,]+', 1, level) IS NOT NULL
            )
        ORDER BY
            c.year,
            c.month,
            c.district
    )
GROUP BY
    year,
    month
ORDER BY
    year,
    month;
 

-- sample output for 2019 and districts 1,2,3,4,5

  
      YEAR MONTH_RANGE         TIME_RANGE           COUNT(1)
---------- ------------------- ------------------ ----------
      2019 August to September 00 a.m. to 06 a.m.       9529
      2019 August to September 06 a.m. to 12 p.m.      11828
      2019 August to September 06 p.m. to 00 a.m.      18793
      2019 August to September 12 p.m. to 06 p.m.      18731
      2019 January to April    00 a.m. to 06 a.m.       6634
      2019 January to April    06 a.m. to 12 p.m.      10523
      2019 January to April    06 p.m. to 00 a.m.      14088
      2019 January to April    12 p.m. to 06 p.m.      16858
      2019 May to July         00 a.m. to 06 a.m.       8424
      2019 May to July         06 a.m. to 12 p.m.      11858
      2019 May to July         06 p.m. to 00 a.m.      16944

      YEAR MONTH_RANGE         TIME_RANGE           COUNT(1)
---------- ------------------- ------------------ ----------
      2019 May to July         12 p.m. to 06 p.m.      18748
      2019 October to December 00 a.m. to 06 a.m.       2965
      2019 October to December 06 a.m. to 12 p.m.       4252
      2019 October to December 06 p.m. to 00 a.m.       6383
      2019 October to December 12 p.m. to 06 p.m.       7204

16 rows selected. 

