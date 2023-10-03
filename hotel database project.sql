
-- Is hotel revenue increasing year on year?
-- What market segment are major contributors of the revenue per year? In there a change year on year?
-- When is the hotel at maximum occupancy? Is the period consistent across the years?
-- When are people cancelling the most?
-- Are families with kids more likely to cancel the hotel booking?

use theap44a_hotel;

-- EPLORING THE TABLES --
select  * from hotel2018;
select* from hotel2019;
select * from hotel2020;
select * from meal_cost;
select * from market_segment;

-- EXPLORING THE DATA --
select distinct hotel from hotel2018;
-- Hotel types are two 
-- Resort hotel -- 
-- City hotel --

-- number of booking --
select sum(cnt) as city_hotel from (
select hotel,count(*) as cnt from hotel2018  where hotel = "city hotel"group by 1  union all 
select hotel, count(*)  as cnt from hotel2019 where hotel = "city hotel" group by 1 union all
select hotel,count(*) as cnt  from hotel2020 where hotel = "city hotel" group by 1) as m ;

select sum(cnt) as resort_hotel from (
select hotel,count(*) as cnt from hotel2018  where hotel = "resort hotel"group by 1  union all 
select hotel, count(*)  as cnt from hotel2019 where hotel = "resort hotel" group by 1 union all
select hotel,count(*) as cnt  from hotel2020 where hotel = "resort hotel" group by 1) as m ;

-- city hotel : 93103
-- resort hotel: 48844

-- is_cancelled flag --
-- Two Types of Is cancelled --
-- 0:89108
-- 1: 52839
select sum(cnt) as is_cancelled_0 from (
select count(is_canceled) as cnt  from  hotel2018 where is_canceled = 0 union all
select count(is_canceled) as cnt  from  hotel2019  where is_canceled = 0 union all
select count(is_canceled) as cnt  from  hotel2020  where is_canceled = 0) as y;

select sum(cnt)  as is_cancelled_1 from (
select count(is_canceled) as cnt  from  hotel2018 where is_canceled = 1 union all
select count(is_canceled) as cnt  from  hotel2019  where is_canceled = 1 union all
select count(is_canceled) as cnt  from  hotel2020  where is_canceled = 1) as y;

-- Two type of cancelations: Canceled, No-Show
SELECT is_canceled, reservation_status, count(*) from hotel2018 group by 1,2;

--   *******************************
-- Revenue Calculation of all years 
--   *******************************

-- 1. Room Rent
-- 2. Meal Cost
-- 3. Discount



--    1st QUESTION --

-- ROOM RENT
select arrival_date_year,(sum((stays_in_week_nights+stays_in_weekend_nights)*adr)) as perroomrent 
from hotel2018 where is_canceled=0 group by 1;

-- MEAL COST 
 select h.arrival_date_year,SUM(((h.stays_in_week_nights+h.stays_in_weekend_nights)*(h.adults+ h.children))* m.cost)
 as mealrevenue from hotel2018  as h inner join meal_cost as m on h.meal=m.meal where h.is_canceled=0  group by 1 ;
 
 -- ROOM RENT + MEAL COST
 select  h.arrival_date_year ,( (sum((h.stays_in_week_nights+h.stays_in_weekend_nights)*h.adr)) + 
 SUM(((h.stays_in_week_nights+h.stays_in_weekend_nights)*(h.adults+ h.children))* m.cost)
)as rentandmealrevenue_2018 from hotel2018  as h inner join meal_cost  as m on h.meal=m.meal where h.is_canceled=0 group by 1 ;

 -- DISCOUNT
 select h.arrival_date_year,sum((((h.stays_in_week_nights+h.stays_in_weekend_nights)*h.adr)+
 (((h.stays_in_week_nights+h.stays_in_weekend_nights)*(h.adults+h.children))*m.cost))*
 (ms.discount)) as totaldiscount 
 from hotel2018 as h
 inner join market_segment as ms on h.market_segment=ms.market_segment  
 inner join meal_cost  as m on  m.meal=h.meal 
 where h.is_canceled=0 group by 1;
 
 
-- ************* --
-- SLIDE 2
-- ************* --

-- Is hotel revenue increasing year on year?
-- (ROOM RENT + MEAL COST)-DISCOUNT
 
 select h.arrival_date_year as years,round((( (sum((h.stays_in_week_nights+h.stays_in_weekend_nights)*h.adr)) + 
SUM(((h.stays_in_week_nights+h.stays_in_weekend_nights)*(h.adults+ h.children))* m.cost))-
(sum((((h.stays_in_week_nights+h.stays_in_weekend_nights)*h.adr)+
(((h.stays_in_week_nights+h.stays_in_weekend_nights)*(h.adults+h.children))*m.cost))*
(ms.discount)))),2) as totalrevenue
 from hotel2018 as h
 inner join market_segment as ms on h.market_segment=ms.market_segment  
 inner join meal_cost  as m on  m.meal=h.meal where h.is_canceled=0 group by 1 
 union all
 select h.arrival_date_year as years,round((( (sum((h.stays_in_week_nights+h.stays_in_weekend_nights)*h.adr)) + 
 SUM(((h.stays_in_week_nights+h.stays_in_weekend_nights)*(h.adults+ h.children))* m.cost)
)-(sum((((h.stays_in_week_nights+h.stays_in_weekend_nights)*h.adr)+
 (((h.stays_in_week_nights+h.stays_in_weekend_nights)*(h.adults+h.children))*m.cost))*(
 ms.discount)))),2) as totalrevenue  from hotel2019 as h 
 inner join market_segment  as ms on h.market_segment=ms.market_segment  
 inner join meal_cost  as m on  m.meal=h.meal where is_canceled=0 group by 1 
 union all
 select h.arrival_date_year as years, round((( (sum((h.stays_in_week_nights+h.stays_in_weekend_nights)*h.daily_room_rate)) + 
 SUM(((h.stays_in_week_nights+h.stays_in_weekend_nights)*(h.adults+ h.children))* m.cost)
)-(sum((((h.stays_in_week_nights+h.stays_in_weekend_nights)*h.daily_room_rate)+
 (((h.stays_in_week_nights+h.stays_in_weekend_nights)*(h.adults+h.children))*m.cost))*(
 ms.discount)))),2) as totalrevenue from hotel2020
 as h inner join market_segment as ms on h.market_segment=ms.market_segment  
 inner join meal_cost as m on  m.meal=h.meal where h.is_canceled=0 group by 1;

-- ************* --
-- SLIDE 3
-- ************* --

-- 2nd Question
-- What market segment are major contributors of the revenue per year? In there a change year on year?

select market_segment, max(year2018) as year2018,max(year2019) as year2019,max(year2020) as year2020 from ( select market_segment, years,
case when years=2018 then revenue else 0 end as year2018,
case when years=2019 then revenue else 0 end as year2019,
case when years=2020 then revenue else 0 end as year2020 from (
select  h.market_segment,h.arrival_date_year as years, round(sum(((((h.stays_in_week_nights+h.stays_in_weekend_nights)*h.adr)+
 ((h.stays_in_week_nights+h.stays_in_weekend_nights)*(h.adults+h.children)*m.cost))- 
 ((((h.stays_in_week_nights+h.stays_in_weekend_nights)*h.adr)+
 ((h.stays_in_week_nights+h.stays_in_weekend_nights)*(h.adults+h.children)*m.cost))*
 (ms.discount))) ),2)as revenue
 from hotel2018 as h
inner join meal_cost  as m on h.meal=m.meal inner join market_segment as ms on h.market_segment=ms.market_segment
where h.is_canceled=0 group by 1,2 
union all
select  h.market_segment,h.arrival_date_year as years, round(sum(((((h.stays_in_week_nights+h.stays_in_weekend_nights)*h.adr)+
 ((h.stays_in_week_nights+h.stays_in_weekend_nights)*(h.adults+h.children)*m.cost))- 
 ((((h.stays_in_week_nights+h.stays_in_weekend_nights)*h.adr)+
 ((h.stays_in_week_nights+h.stays_in_weekend_nights)*(h.adults+h.children)*m.cost))*
 (ms.discount))) ),2)as revenue
 from hotel2019 as h
inner join meal_cost  as m on h.meal=m.meal inner join market_segment as ms on h.market_segment=ms.market_segment
where h.is_canceled=0 group by 1,2
 union all
select  h.market_segment,h.arrival_date_year as years, round(sum(((((h.stays_in_week_nights+h.stays_in_weekend_nights)*h.daily_room_rate)+
 ((h.stays_in_week_nights+h.stays_in_weekend_nights)*(h.adults+h.children)*m.cost))- 
 ((((h.stays_in_week_nights+h.stays_in_weekend_nights)*h.daily_room_rate)+
 ((h.stays_in_week_nights+h.stays_in_weekend_nights)*(h.adults+h.children)*m.cost))*
 (ms.discount))) ),2)as revenue2020
 from hotel2020 as h
inner join meal_cost  as m on h.meal=m.meal inner join market_segment as ms on h.market_segment=ms.market_segment
where h.is_canceled=0 group by 1 ,2 )  as m group by 1,2 ) as y group by 1 ; 
 
-- ************* --
-- SLIDE 4  
-- ************* --
 
 -- THIRD QUESTION
 -- WHEN IS THE HOTEL AT MAXIMUM OCCUPANCY ?
 
 
 select arrival_date_month, max(week_num) as week_num,max(occupancy2018) as occupancy2018,
 max(occupancy2019) as occupancy2019,max(occupancy2020) as occupancy2020 from (
 select arrival_date_month,week_num,
 case 
 when arrival_date_year = 2018 then cnt 
 else 0 
 end as occupancy2018,
 case 
 when arrival_date_year = 2019 then cnt 
 else 0
 end as occupancy2019,
 case 
 when  arrival_date_year = 2020 then cnt
 else 0 
 end as occupancy2020 
 from (
select arrival_date_year,arrival_date_month,max(arrival_date_week_number) as week_num,count(*) as cnt  
from hotel2018 group by 1,2
   union 
select arrival_date_year,arrival_date_month,max(arrival_date_week_number) as week_num,count(*) as cnt 
from hotel2019  group by 1,2
union 
select arrival_date_year,arrival_date_month,max(arrival_date_week_number) as week_num,count(*) as cnt
 from hotel2020  group by 1,2
 ) as temp ) as temp2 group by 1 order by 2;

-- ************* --
-- SLIDE 5 
-- ************* --

-- 4th QUESTION
-- WHEN ARE PEOPLE CANCELLING THE MOST?

 select arrival_date_month, max(week_num) as week_num,max(canceled2018) as canceled2018,
 max(canceled2019) as canceled2019,max(canceled2020) as canceled2020 from (
 select arrival_date_month,week_num,
 case 
 when arrival_date_year = 2018 then cnt 
 else 0 
 end as canceled2018,
 case 
 when arrival_date_year = 2019 then cnt 
 else 0
 end as canceled2019,
 case 
 when  arrival_date_year = 2020 then cnt
 else 0 
 end as canceled2020 
 from (
select arrival_date_year,arrival_date_month,max(arrival_date_week_number) as week_num,count(*) as cnt ,is_canceled 
from hotel2018 where is_canceled=1 group by 1,2
   union 
select arrival_date_year,arrival_date_month,max(arrival_date_week_number) as week_num,count(*) as cnt, is_canceled 
from hotel2019 where is_canceled=1 group by 1,2
union 
select arrival_date_year,arrival_date_month,max(arrival_date_week_number) as week_num,count(*) as cnt, is_canceled
 from hotel2020 where is_canceled=1 group by 1,2
 ) as temp ) as temp2 group by 1 order by 2;


-- 5th QUESTION
-- Are families with kids more likely to cancel the hotel booking?

--  created the family flag
select *, case
 when (children+ babies)>0 then "family"
 else "non-family"
end  as family_flag from ( 
select * from  hotel2018 
union all
select * from  hotel2019 
union all
select * from  hotel2020 
) as  f;

-- total number of bookings by family flag
select family_flag , count(*) as total_bookings from ( select *, case
 when (children+ babies)>0 then "family"
 else "non-family"
end  as family_flag from ( 
select * from  hotel2018 
union all
select * from  hotel2019 
union all
select * from  hotel2020 
) as  f ) as m group by 1;

-- total number of cancellation by family flag
select family_flag , count(*) as canceled_bookings from ( select *, case
 when (children+ babies)>0 then "family"
 else "non-family"
end  as family_flag from ( 
select * from  hotel2018 
union all
select * from  hotel2019 
union all
select * from  hotel2020 
) as  f where is_canceled=1 ) as m  group by 1;


-- ************* --
-- SLIDE 6
-- ************* --

-- finding the % of cancellation by family flag

select totalb.family_flag,((canceled_bookings/total_bookings)*100) as percentage_of_canceled from (
select family_flag , count(*) as total_bookings from ( select *, case
 when (children+ babies)>0 then "family"
 else "non-family"
end  as family_flag
 from ( 
select * from  hotel2018 
union all
select * from  hotel2019 
union all
select * from  hotel2020 
) as  f ) as m group by 1) as totalb
inner join 
(select family_flag , count(*) as canceled_bookings 
from ( select *, case
 when (children+ babies)>0 then "family"
 else "non-family"
end  as family_flag 
from ( 
select * from  hotel2018 
union all
select * from  hotel2019 
union all
select * from  hotel2020 
) as  f where is_canceled=1 ) as m  group by 1) as cancelb on totalb.family_flag = cancelb.family_flag group by 1;
 
 
 -- ************* --
-- END
-- ************* --
  
  