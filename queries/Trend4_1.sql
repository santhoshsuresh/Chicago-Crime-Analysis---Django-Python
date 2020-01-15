Trend 4: A bar graph analysis on types of crimes reported in different locations
(residential area, streets etc.) in Chicago for the date range provided by the user.

SELECT /*+PARALLEL(10)*/
    l.location_description,
    i.primary_desc,
    COUNT(DISTINCT c.case_no)
FROM
    cct_cases            c,
    cct_crime_loc_desc   l,
    cct_iucr             i
WHERE
    c.location_id = l.loc_id
    AND c.iucr_code = i.code
    AND trunc(c.timestamp) >= '01-JAN-2012'
    AND         -- INPUT 
     trunc(c.timestamp) <= '31-DEC-2019'
    AND         -- INPUT
     i.primary_desc IN (
        SELECT
            regexp_substr((decode(iucrlist, '',(
                SELECT
                    LISTAGG(primary_desc, ',') WITHIN GROUP(
                        ORDER BY
                            primary_desc
                    ) iucr_list
                FROM
                    (
                        SELECT DISTINCT
                            primary_desc
                        FROM
                            cct_iucr
                    )
            ), iucrlist)), '[^,]+', 1, level)
        FROM
            dual
        CONNECT BY
            regexp_substr((decode(iucrlist, '',(
                SELECT
                    LISTAGG(primary_desc, ',') WITHIN GROUP(
                        ORDER BY
                            primary_desc
                    ) iucr_list
                FROM
                    (
                        SELECT DISTINCT
                            primary_desc
                        FROM
                            cct_iucr
                    )
            ), iucrlist)), '[^,]+', 1, level) IS NOT NULL
    )
    AND l.location_description IN (
        SELECT
            regexp_substr((decode(loclist, '',(
                SELECT
                    LISTAGG(location_description, ',') WITHIN GROUP(
                        ORDER BY
                            location_description
                    ) dist_list
                FROM
                    (
                        SELECT DISTINCT
                            location_description
                        FROM
                            cct_crime_loc_desc
                    )
            ), loclist)), '[^,]+', 1, level)
        FROM
            dual
        CONNECT BY
            regexp_substr((decode(loclist, '',(
                SELECT
                    LISTAGG(location_description, ',') WITHIN GROUP(
                        ORDER BY
                            location_description
                    ) dist_list
                FROM
                    (
                        SELECT DISTINCT
                            location_description
                        FROM
                            cct_crime_loc_desc
                    )
            ), loclist)), '[^,]+', 1, level) IS NOT NULL
    )
GROUP BY
    l.location_description,
    i.primary_desc
ORDER BY
    3 DESC;