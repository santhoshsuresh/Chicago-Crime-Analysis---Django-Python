Trend 1: A line graph to showing the trend on percentage change in number of crimes reported over a course of years for each district of Chicago.

SELECT
    c.year,
    CASE c.month
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
    END AS month,
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
                    EXTRACT(MONTH FROM to_date(CAST(c.timestamp AS DATE), 'YYYY-mm-dd')) month,
                    district
                FROM
                    cct_cases c
                WHERE
                    c.district IS NOT NULL
                    AND trunc(c.timestamp) >= '01-JAN-2012'
                    AND	-- user input
                     trunc(c.timestamp) <= '31-DEC-2013'
            )	-- user input
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
                    EXTRACT(MONTH FROM to_date(CAST(c.timestamp AS DATE), 'YYYY-mm-dd')) month,
                    district
                FROM
                    cct_cases c
                WHERE
                    c.district IS NOT NULL
                    AND trunc(c.timestamp) >= '01-JAN-2012'
                    AND	-- user input
                     trunc(c.timestamp) <= '31-DEC-2013'
            )	-- user input
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
            regexp_substr((decode(<dlist>, '',(
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
            ), <dlist>)), '[^,]+', 1, level)
        FROM
            dual
        CONNECT BY
            regexp_substr((decode(<dlist>, '',(
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
            ), <dlist>)), '[^,]+', 1, level) IS NOT NULL
    )											-- user input
ORDER BY
    c.year,
    c.month,
    c.district;