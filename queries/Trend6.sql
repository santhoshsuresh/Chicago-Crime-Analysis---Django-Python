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
    AND trunc(c.timestamp) >= nvl('01-JAN-2012', trunc(c.timestamp)) -- user input
    AND trunc(c.timestamp) <= nvl('31-DEC-2013', trunc(c.timestamp)) -- user input
    AND c.district IN (
        ( SELECT DISTINCT
            to_char(district_no)
        FROM
            cct_district
        UNION
        SELECT DISTINCT
            to_char(district_no)
        FROM
            cct_district_dep
        )
        INTERSECT
        SELECT
            regexp_substr('1,24,19,25', '[^,]+', 1, level)    -- input district numbers as comma seperated values 
        FROM
            dual
        CONNECT BY
            regexp_substr('1,24,19,25', '[^,]+', 1, level) IS NOT NULL -- input district numbers as comma seperated values
    )
GROUP BY
    year,
    beat_no,
    district
ORDER BY
    1 ASC,
    4 DESC;