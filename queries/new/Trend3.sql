Trend 2: A pie chart depicting the distribution on type of crime committed (e.g. Assault,
theft etc.) between the date range provided by the user.

-- input: start/end dates

WITH totrangecases AS (
    SELECT
        COUNT(case_no) total_case
    FROM
        cct_cases
    WHERE
        district IS NOT NULL
        AND trunc(timestamp) >= '01-JAN-2012'
        AND trunc(timestamp) <= '31-DEC-2013'
    GROUP BY
        district
    HAVING
        COUNT(case_no) >= ALL (
            SELECT
                COUNT(case_no)
            FROM
                cct_cases
            WHERE
                district IS NOT NULL
                AND trunc(timestamp) >= '01-JAN-2012'
                AND trunc(timestamp) <= '31-DEC-2013'
            GROUP BY
                district
        )
)
SELECT
    district,
    total_cases,
    relative_grade,
    RANK() OVER(
        ORDER BY
            relative_grade DESC
    ) rank
FROM
    (
        SELECT
            district,
            COUNT(case_no) total_cases,
            ceil(COUNT(case_no) /(
                SELECT
                    total_case
                FROM
                    totrangecases
            ) * 100) AS relative_grade
        FROM
            cct_cases
        WHERE
            district IS NOT NULL
            AND trunc(timestamp) >= '01-JAN-2012'
            AND trunc(timestamp) <= '31-DEC-2013'
        GROUP BY
            district
        ORDER BY
            district
    );