Trend 8: A heat map displaying the density of crimes reported over the entire Chicago
city for a range of time. Time range could be changed using a slider.


-- input : start/end dates  and district 
SELECT
    c.district,
    COUNT(*)
FROM
    cct_cases c
WHERE 
	c.district IS NOT NULL AND 
	trunc(c.timestamp) >= '01-JAN-2012' AND 
    trunc(c.timestamp) <= '31-DEC-2013' AND
    c.district IN (
        SELECT
            regexp_substr((decode('1,2,3,4,5', '',(
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
            ), '1,2,3,4,5')), '[^,]+', 1, level)
        FROM
            dual
        CONNECT BY
            regexp_substr((decode('1,2,3,4,5', '',(
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
            ), '1,2,3,4,5')), '[^,]+', 1, level) IS NOT NULL)
GROUP BY
	    c.district
ORDER BY 
1 desc;

  DISTRICT   COUNT(*)
---------- ----------
         5      29415
         4      37934
         3      33892
         2      26456
         1      24459


