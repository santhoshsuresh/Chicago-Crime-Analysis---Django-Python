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