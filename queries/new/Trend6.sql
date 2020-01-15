Trend 6: Identify most active beats/districts by comparing the number of arrests to that
of total crimes reported in that beat/district. Determine the most and least efficient using a
bar graph.


SELECT /*+parallel(10)*/
    year,
    beat_no,
    district,
    COUNT(*)
FROM
    cct_cases c
WHERE
    arrest = 'true'
    AND district IS NOT NULL
    AND ( beat_no,
          district ) IN (
        SELECT DISTINCT
            beat_number,
            district_no
        FROM
            cct_beats
        UNION
        SELECT DISTINCT
            beat_number,
            district_no
        FROM
            cct_beats_dep
    )
    AND trunc(c.timestamp) >= nvl('01-JAN-2012', trunc(c.timestamp))
    AND trunc(c.timestamp) <= nvl('31-DEC-2013', trunc(c.timestamp))
    AND c.district IN (
        SELECT
            regexp_substr((decode(dlist, '',(
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
            ), dlist)), '[^,]+', 1, level)
        FROM
            dual
        CONNECT BY
            regexp_substr((decode(dlist, '',(
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
            ), dlist)), '[^,]+', 1, level) IS NOT NULL
    )
GROUP BY
    year,
    beat_no,
    district
ORDER BY
    1 ASC,
    4 DESC;