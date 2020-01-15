Trend 1: A line graph to showing the trend on percentage change in number of crimes reported over a course of years for each district of Chicago.

select c.year,
	   case c.month
   		when 1 THEN 'January'
   		when 2 THEN 'February'
   		when 3 THEN 'March'
   		when 4 THEN 'April'
   		when 5 THEN 'May'
   		when 6 THEN 'June'
   		when 7 THEN 'July'
   		when 8 THEN 'August'
   		when 9 THEN 'September'
   		when 10 THEN 'October'
   		when 11 THEN 'November'
   		when 12 THEN 'December'
   		end as month,
   		round((c.cnt / p.cnt ),2) * 100 as "PERCT_CHANGE"	   
from
(select count(*) cnt, year, month, district from
(select /*+parallel(10)*/
    year,
	extract(month from to_date(cast(c.timestamp as date),'YYYY-mm-dd')) month,
    district
from 
    cct_cases c
where 
    c.district is not null and
    trunc(c.timestamp) >= '01-JAN-2012' and	-- user input
    trunc(c.timestamp) <= '31-DEC-2013')	-- user input
group by year, month, district) c,  
(select count(*) cnt, year, month, district from
(select /*+parallel(10)*/
    year,
	extract(month from to_date(cast(c.timestamp as date),'YYYY-mm-dd')) month,
    district
from 
    cct_cases c
where 
    c.district is not null and
    trunc(c.timestamp) >= '01-JAN-2012' and	-- user input
    trunc(c.timestamp) <= '31-DEC-2013')	-- user input
group by year, month, district) p
where 
	c.year = decode(c.month, 1, p.year+1, p.year) and
	c.month = decode(p.month + 1, 13, 1, p.month + 1) and
	c.district = p.district and
	c.district IN (1)											-- user input
order by c.year,c.month, c.district;
