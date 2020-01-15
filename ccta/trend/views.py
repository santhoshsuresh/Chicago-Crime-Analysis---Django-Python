from django.shortcuts import render
from django.http import JsonResponse
from django.db import connection
from .forms import Analysis1, Analysis2, Analysis3
from datetime import datetime

from django.views.decorators.csrf import csrf_exempt

from rest_framework.views import APIView
from rest_framework.response import Response

def home(request):
    return render(request, 'trend/homepage.html')

def about(request):
    return render(request, 'trend/About.html')

def percentchange(request):
    my_form = Analysis1(initial={'loc':'Chicago'})
    context = {
        "form": my_form
    }
    return render(request, 'trend/percentchange.html', context)

def loc_analysis(request):
    my_form = Analysis2()
    context = {
        "form": my_form
    }
    return render(request, 'trend/loc_ana.html', context)

def typecrime_analysis(request):
    my_form = Analysis3()
    context = {
        "form": my_form
    }
    return render(request, 'trend/discrime.html', context)

def crime_time(request):
    return render(request, 'trend/stddeviation.html')

def beat_trend(request):
    return render(request, 'trend/beat_trend.html')

def violence_trend(request):
    return render(request, 'trend/violence_trend.html')

def arrestcrime_trend(request):
    return render(request, 'trend/arrestcrime.html')

@csrf_exempt
def get_data(request):
    print("Reached")
    if request.method == "POST":
        trend = request.POST.get('trend')

        d = datetime.today()
        
        start_date = d.strftime('%Y-%m-%d')
        end_date = d.strftime('%Y-%m-%d')
        choice = ""
        district = ""
        loc = ""
        desc = ""
        year = ""

        if trend == "percentage_analysis":
            start_date = request.POST.get('start_date')
            end_date = request.POST.get('end_date')
            start_date = datetime.strptime(start_date, '%d-%B-%Y').strftime('%Y-%m-%d')
            end_date = datetime.strptime(end_date, '%d-%B-%Y').strftime('%Y-%m-%d')

        elif trend == "location_analysis":
            start_date = request.POST.get('start_date')
            end_date = request.POST.get('end_date')
            start_date = datetime.strptime(start_date, '%d-%B-%Y').strftime('%Y-%m-%d')
            end_date = datetime.strptime(end_date, '%d-%B-%Y').strftime('%Y-%m-%d')
            desc = request.POST.get('desc')
            loc = request.POST.get('loc')
        
        elif trend == "dis_analysis":
            start_date = request.POST.get('start_date')
            end_date = request.POST.get('end_date')
            start_date = datetime.strptime(start_date, '%d-%B-%Y').strftime('%Y-%m-%d')
            end_date = datetime.strptime(end_date, '%d-%B-%Y').strftime('%Y-%m-%d')

        elif trend == "risk_analysis":
            year = request.POST.get('year')
        
        elif trend == "violence_analysis":
            year = request.POST.get('year')

        xaxis = []
        yaxis = []
        zaxis = []
        with connection.cursor() as cursor:
            query = getquery(trend, start_date, end_date, district, choice, desc, loc, year)
            print(query)
            cursor.execute(query)
            result = cursor.fetchall()
            print(result)

        if trend == "violence_analysis" or trend == "deviation_trend":
            for row in result:
                xaxis.append(row[0])
                yaxis.append(row[1])
                zaxis.append(row[2])

            # print("zaxis",zaxis)    
            data = {
                "labels": xaxis,
                "chartdata": yaxis,
                "chartdata2": zaxis
            }
        else:
            for row in result:
                xaxis.append(row[0])
                yaxis.append(row[1])
            # print("cnt",loc, cnt)
            data = {
                "labels": xaxis,
                "chartdata": yaxis,
            }
        return JsonResponse(data)
    
def getquery(trend, start_date, end_date, district, choice, desc, loc, year):
    query = ""
    if trend == "percentage_analysis":
        query = qry_percentage_trend1(start_date, end_date)
    elif trend == "dis_analysis":
        query = qry_disanalysis_trend2(start_date, end_date)
    elif trend == "risk_analysis":
        query = qry_riskanalysis( year)
    elif trend == "beat_trend":
        query = qry_beattrend()
    elif trend == "violence_analysis":
        query = qry_violence_trend()
    elif trend == "arrest_crime":
        query = qry_arrestcrime()
    elif trend == "deviation_trend":
        query = qry_stddev_trend()
    return query

def qry_stddev_trend():
    query = """select case tz
                when 1 then '00 a.m. to 06 a.m.'
                when 2 then '06 a.m. to 12 p.m.'
                when 3 then '12 p.m. to 06 p.m.'
                else '06 p.m. to 00 a.m.' end as times,
                std_dev,
                mean
            from (select distinct tz, round(STDDEV(total) OVER (ORDER BY tz)) std_dev, round(avg(total) OVER (ORDER BY tz)) mean
            from
            (SELECT 
                case 
                    when extract(hour from c.timestamp) >= 0 and  extract(hour from c.timestamp) < 6 then 1
                    when extract(hour from c.timestamp) >= 6 and  extract(hour from c.timestamp) < 12 then 2
                    when extract(hour from c.timestamp) >= 12 and  extract(hour from c.timestamp) < 18 then 3
                    else 4
                end as tz,
                count(*) total
            from cct_cases c
            where 
                c.domestic = 'false' 
                AND c.district IS NOT NULL 
                AND year = 2019
            group by
                extract(hour from c.timestamp)
            )
            );"""
    return query

def qry_arrestcrime():
    query = """select arrest.year, total.number_of_cases, arrest.number_of_arrests
                from
                (select year, count (case_no) as number_of_arrests
                from cct_cases 
                where arrest='true'
                group by year) arrest,(select year, count (case_no) as number_of_cases
                from cct_cases 
                group by year) total
                where arrest.year = total.year
                order by 1;"""
    return query

def qry_violence_trend():
    query = """WITH crimestatistics AS (
                SELECT  
                    c.year,
                    'Domestic' type,
                    COUNT(1) total
                FROM
                    cct_cases c
                WHERE
                    c.domestic = 'true'
                GROUP BY
                    c.year
                UNION ALL
                SELECT  
                    c.year,
                    'Non-Domestic' type,
                    COUNT(1) total
                FROM
                    cct_cases c
                WHERE
                    c.domestic = 'false'
                GROUP BY
                    c.year
            )
            SELECT
            *
            FROM
                crimestatistics PIVOT (
                    SUM ( total )
                    FOR type
                    IN ( 'Domestic' AS domestic, 'Non-Domestic' AS nondomestic )
                );"""
    return query

def qry_beattrend():
    query = """Select beat_no AS "X-axis" , round(avg(count),2) AS "Y axis" from(
                SELECT count(case_no) as count,beat_no, year FROM cct_Cases GROUP BY beat_no,year)
                group by beat_no
                order by "Y axis" desc
                fetch first 7 rows only"""
    return query

def qry_riskanalysis(year):
    query = """WITH crimebytimequarter AS (
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
                4 DESC);""".format(y = year)
    return query

def qry_disanalysis_trend2(start_date, end_date):
    # query = """select year, count(*) from cct_cases 
    #             where timestamp between TO_DATE('{sd}', 'yyyy-mm-dd') and TO_DATE('{ed}', 'yyyy-mm-dd')
    #             group by year order by 1""".format(sd=start_date, ed = end_date)
    query = """WITH totrangecases AS (
                SELECT
                    COUNT(case_no) total_case
                FROM
                    cct_cases
                WHERE
                    district IS NOT NULL
                    AND trunc(timestamp) >= TO_DATE('{sd}', 'yyyy-mm-dd')
                    AND trunc(timestamp) <= TO_DATE('{ed}', 'yyyy-mm-dd')
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
                            AND trunc(timestamp) >= TO_DATE('{sd}', 'yyyy-mm-dd')
                            AND trunc(timestamp) <= TO_DATE('{ed}', 'yyyy-mm-dd')
                        GROUP BY
                            district
                    )
            )
            SELECT
                district,
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
                        AND trunc(timestamp) >= TO_DATE('{sd}', 'yyyy-mm-dd')
                        AND trunc(timestamp) <= TO_DATE('{ed}', 'yyyy-mm-dd')
                    GROUP BY
                        district
                    ORDER BY
                        district
                )
                fetch first 10 rows only;""".format(sd=start_date, ed = end_date)
    return query

def qry_location_trend2(start_date, end_date, desc, loc):
    query = """SELECT /*+PARALLEL(10)*/
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
                3 DESC;"""

def qry_percentage_trend1(start_date, end_date):
    query = """with count_cases as (
                select year, count(case_no) as cnt 
                FROM cct_cases 
                WHERE timestamp BETWEEN to_date('{sd}', 'yyyy-dd-mm') AND to_date('{ed}', 'yyyy-dd-mm')
                GROUP BY year 
                ORDER BY 1)
            SELECT c2.year,(round(((c1.cnt - c2.cnt)/c1.cnt)*100,0))  
            FROM count_cases c1 
            JOIN count_cases c2 ON c1.year = c2.year-1
            order by 1""".format(sd = start_date, ed = end_date)
    return query