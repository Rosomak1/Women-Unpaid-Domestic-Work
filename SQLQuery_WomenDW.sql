
--Looking at the overview of the data from the 1st table I will use

select *
from WomenUnpaidWork..WomenDomesticWork 

--The data is for years between 1997-2015
--Some years do not have any data so I will focus on the average in the period of those years

select
Entity, 
ROUND(AVG(Daily_time_spent_on_domestic_work_by_women) , 2) as AvgTimeSpentByWomanOnDomesticWorkByCountry
from WomenUnpaidWork..WomenDomesticWork 
where Daily_time_spent_on_domestic_work_by_women != 0
group by Entity

--Top 10 countries in the world with the HIGHEST average time per day that women spent on domestic work (paid and unpaid)

select TOP 10
Entity, 
ROUND(AVG(Daily_time_spent_on_domestic_work_by_women) , 2) as AvgTimeSpentByWomanOnDomesticWorkByCountry
from WomenUnpaidWork..WomenDomesticWork 
where Daily_time_spent_on_domestic_work_by_women != 0
group by Entity
order by AvgTimeSpentByWomanOnDomesticWorkByCountry DESC

--Top 10 countries in the world with the LOWEST average time per day that women spent on domestic work

select TOP 10
Entity, 
ROUND(AVG(Daily_time_spent_on_domestic_work_by_women) , 2) as AvgTimeSpentByWomanOnDomesticWorkByCountry
from WomenUnpaidWork..WomenDomesticWork 
where Daily_time_spent_on_domestic_work_by_women != 0
group by Entity
order by AvgTimeSpentByWomanOnDomesticWorkByCountry ASC

--Overview of data about av time spent on domestic work by female and men
--The data contains historical data but we will focus only on the years between 1997-2015

select * from WomenUnpaidWork..FemalevsMaleDW
where Year BETWEEN 1997 AND 2015 
AND TimeSpentOnDomesticWorkMaleInHours IS NOT NULL AND TimeSpentOnDomesticWorkFemaleInHours IS NOT NULL

--The av time spent by men and women on domestic works by countries

select
ROUND(AVG(cast(TimeSpentOnDomesticWorkMaleInHours as float)), 2) as AvgTimeSpentByMen,
ROUND(AVG(cast(TimeSpentOnDomesticWorkFemaleInHours as float)), 2) as AvgTimeSpentByWomen,
Entity
from WomenUnpaidWork..FemalevsMaleDW
where Year BETWEEN 1997 AND 2015 
AND TimeSpentOnDomesticWorkMaleInHours IS NOT NULL AND TimeSpentOnDomesticWorkFemaleInHours IS NOT NULL
group by Entity

--Cross checking data with data from the table - WomenDomesticWork

select TOP 20 
Entity,
ROUND(AVG(cast(TimeSpentOnDomesticWorkFemaleInHours as float)), 2) as AvgTimeSpentByWomen
from WomenUnpaidWork..FemalevsMaleDW
where Year BETWEEN 1997 AND 2015 
AND TimeSpentOnDomesticWorkMaleInHours IS NOT NULL AND TimeSpentOnDomesticWorkFemaleInHours IS NOT NULL
group by Entity
order by AvgTimeSpentByWomen  DESC

select TOP 20
Entity, 
ROUND(AVG(Daily_time_spent_on_domestic_work_by_women) , 2) as AvgTimeSpentByWomanOnDomesticWorkByCountry
from WomenUnpaidWork..WomenDomesticWork 
where Daily_time_spent_on_domestic_work_by_women != 0
group by Entity
order by AvgTimeSpentByWomanOnDomesticWorkByCountry DESC

--As the data in WomenDomesticWork is for both paid and unapid domestic work by women and it is not seperated, it may be the reason why only some of the values are similar
--Also there is less data per country in FemalevsMaleDW table

--For this reason we will look into data for countries that coincide in both tables to proceed with further analysis

select 
Wdw.Entity, 
ROUND(AVG(Wdw.Daily_time_spent_on_domestic_work_by_women) , 2) as AvgTimeSpentByWomanOnDomesticWorkByCountry
from WomenUnpaidWork..WomenDomesticWork as Wdw
INNER JOIN 
WomenUnpaidWork..FemalevsMaleDW as Fvm
ON 
Wdw.Entity = Fvm.Entity
where Wdw.Daily_time_spent_on_domestic_work_by_women != 0
group by Wdw.Entity

--Let's look now at the top 10 countries with the highest av time spent by women on domestic work

select top 10
Wdw.Entity, 
ROUND(AVG(Wdw.Daily_time_spent_on_domestic_work_by_women) , 2) as AvgTimeSpentByWomanOnDomesticWorkPaidAndUnpaid,
ROUND(AVG(cast(Fvm.TimeSpentOnDomesticWorkFemaleInHours as float)), 2) as AvgTimeSpentByWomenUnpaid
from WomenUnpaidWork..WomenDomesticWork as Wdw
INNER JOIN 
WomenUnpaidWork..FemalevsMaleDW as Fvm
ON 
Wdw.Entity = Fvm.Entity
where Wdw.Daily_time_spent_on_domestic_work_by_women != 0 AND Fvm.Year BETWEEN 1997 AND 2015 
AND Fvm.TimeSpentOnDomesticWorkMaleInHours IS NOT NULL AND Fvm.TimeSpentOnDomesticWorkFemaleInHours IS NOT NULL
group by Wdw.Entity, Fvm.Entity
order by AvgTimeSpentByWomenUnpaid DESC

--Considering the above data we can estimate what % of the women domestic work is unpaid

--1st way of doing it:

select
Wdw.Entity, 
ROUND(AVG(Wdw.Daily_time_spent_on_domestic_work_by_women) , 2) as AvgTimeSpentByWomanOnDomesticWorkPaidAndUnpaidPerDay,
ROUND(AVG(cast(Fvm.TimeSpentOnDomesticWorkFemaleInHours as float)), 2) as AvgTimeSpentByWomenUnpaid,
(ROUND(AVG(cast(Fvm.TimeSpentOnDomesticWorkFemaleInHours as float)), 2))/(ROUND(AVG(Wdw.Daily_time_spent_on_domestic_work_by_women) , 2))*100 as RatioPaidAndUnpaidDomWork
from WomenUnpaidWork..WomenDomesticWork as Wdw
INNER JOIN 
WomenUnpaidWork..FemalevsMaleDW as Fvm
ON 
Wdw.Entity = Fvm.Entity
where Wdw.Daily_time_spent_on_domestic_work_by_women != 0 AND Fvm.Year BETWEEN 1997 AND 2015 
AND Fvm.TimeSpentOnDomesticWorkMaleInHours IS NOT NULL AND Fvm.TimeSpentOnDomesticWorkFemaleInHours IS NOT NULL
group by Wdw.Entity, Fvm.Entity
order by RatioPaidAndUnpaidDomWork DESC


--2nd way of doing it - using temp for better readibility

select 
tmp.Entity, 
tmp.AvgTimeSpentByWomanOnDomesticWorkPaidAndUnpaid,
tmp.AvgTimeSpentByWomenUnpaid,
ROUND(tmp.AvgTimeSpentByWomenUnpaid/tmp.AvgTimeSpentByWomanOnDomesticWorkPaidAndUnpaid*100, 2) AS RatioPaidAndUnpaidDomWork

from
(
select
Wdw.Entity, 
ROUND(AVG(Wdw.Daily_time_spent_on_domestic_work_by_women) , 2) as AvgTimeSpentByWomanOnDomesticWorkPaidAndUnpaid,
ROUND(AVG(cast(Fvm.TimeSpentOnDomesticWorkFemaleInHours as float)), 2) as AvgTimeSpentByWomenUnpaid
from WomenUnpaidWork..WomenDomesticWork as Wdw
INNER JOIN 
WomenUnpaidWork..FemalevsMaleDW as Fvm
ON 
Wdw.Entity = Fvm.Entity
where Wdw.Daily_time_spent_on_domestic_work_by_women != 0 AND Fvm.Year BETWEEN 1997 AND 2015 
AND Fvm.TimeSpentOnDomesticWorkMaleInHours IS NOT NULL AND Fvm.TimeSpentOnDomesticWorkFemaleInHours IS NOT NULL
group by Wdw.Entity, Fvm.Entity
) as tmp

order by tmp.AvgTimeSpentByWomenUnpaid DESC

--Now we will use the data from the other tables to see how the high amount of domestic work by women 
--impacts the percentage of women participation in the pairliments and holding top manager seats in the companies

select 
Entity, 
ROUND(AVG(Proporion_of_seats_held_by_women_in_national_parliaments_in_perc) ,2) as Proportion_of_seats
from WomenUnpaidWork..WomenSeatsInParliment
where Year between 1997 and 2015
group by Entity
order by Proportion_of_seats ASC

--Due to data limitation we will also focus on the countries for which the data coincide in all of the above tables

select 
Wsp.Entity, 
--ROUND(AVG(Wdw.Daily_time_spent_on_domestic_work_by_women) , 2) as AvgTimeSpentByWomanOnDomesticWorkPaidAndUnpaid,
ROUND(AVG(cast(Fvm.TimeSpentOnDomesticWorkFemaleInHours as float)), 2) as AvgTimeSpentByWomenUnpaid,
ROUND(AVG(Wsp.Proporion_of_seats_held_by_women_in_national_parliaments_in_perc) ,2) as Proportion_of_seats
FROM
WomenUnpaidWork..WomenSeatsInParliment as Wsp
INNER JOIN  
WomenUnpaidWork..FemalevsMaleDW as Fvm
ON 
Wsp.Entity = Fvm.Entity
INNER JOIN
WomenUnpaidWork..WomenDomesticWork as Wdw
ON Wdw.Entity = Wsp.Entity
where Wsp.Year between 1997 and 2015 
AND Wdw.Daily_time_spent_on_domestic_work_by_women != 0 AND Fvm.Year BETWEEN 1997 AND 2015 
AND Fvm.TimeSpentOnDomesticWorkMaleInHours IS NOT NULL AND Fvm.TimeSpentOnDomesticWorkFemaleInHours IS NOT NULL 
group by Wsp.Entity
order by Proportion_of_seats ASC

select 
Wsp.Entity, 
--ROUND(AVG(Wdw.Daily_time_spent_on_domestic_work_by_women) , 2) as AvgTimeSpentByWomanOnDomesticWorkPaidAndUnpaid,
ROUND(AVG(cast(Fvm.TimeSpentOnDomesticWorkFemaleInHours as float)), 2) as AvgTimeSpentByWomenUnpaid,
ROUND(AVG(Wsp.Proporion_of_seats_held_by_women_in_national_parliaments_in_perc) ,2) as Proporion_of_seats
FROM
WomenUnpaidWork..WomenSeatsInParliment as Wsp
INNER JOIN  
WomenUnpaidWork..FemalevsMaleDW as Fvm
ON 
Wsp.Entity = Fvm.Entity
INNER JOIN
WomenUnpaidWork..WomenDomesticWork as Wdw
ON Wdw.Entity = Wsp.Entity
where Wsp.Year between 1997 and 2015 
AND Wdw.Daily_time_spent_on_domestic_work_by_women != 0 AND Fvm.Year BETWEEN 1997 AND 2015 
AND Fvm.TimeSpentOnDomesticWorkMaleInHours IS NOT NULL AND Fvm.TimeSpentOnDomesticWorkFemaleInHours IS NOT NULL 
group by Wsp.Entity
order by AvgTimeSpentByWomenUnpaid DESC

--With the results of the above queries we can see that there is a correlation between the countries with the highest amount of unpaid work
--done by women and countries with the lowest % of the seats in the parliments that are held by women
--(high amount of unpaid domestic work = low nr of women seats?) 

--Now we will also look if there is a correlation between nr of top female managers and the hours spent by women on the unpaid domestic work

select 
Entity,
AVG(PercentageOfFirmsWithFemaleTopManager) as AvgPercenatgeOfTopWomenManagers
from WomenUnpaidWork..TopFemaleManagers
where Year between 1997 and 2015 
group by Entity
order by AvgPercenatgeOfTopWomenManagers DESC

--Joining the other tables to have the same data sample to compare

select 
Wsp.Entity, 
--ROUND(AVG(Wdw.Daily_time_spent_on_domestic_work_by_women) , 2) as AvgTimeSpentByWomanOnDomesticWorkPaidAndUnpaid,
ROUND(AVG(cast(Fvm.TimeSpentOnDomesticWorkFemaleInHours as float)), 2) as AvgTimeSpentByWomenUnpaid,
ROUND(AVG(Wsp.Proporion_of_seats_held_by_women_in_national_parliaments_in_perc) ,2) as Proporion_of_seats,
ROUND(AVG(Tfm.PercentageOfFirmsWithFemaleTopManager) ,2) as AvgPercenatgeOfTopWomenManagers
FROM
WomenUnpaidWork..WomenSeatsInParliment as Wsp
INNER JOIN  
WomenUnpaidWork..FemalevsMaleDW as Fvm
ON 
Wsp.Entity = Fvm.Entity
INNER JOIN
WomenUnpaidWork..WomenDomesticWork as Wdw
ON Wdw.Entity = Wsp.Entity
JOIN WomenUnpaidWork..TopFemaleManagers AS Tfm
ON tfm.Entity = Wsp.Entity
where Wsp.Year between 1997 and 2015 
AND Wdw.Daily_time_spent_on_domestic_work_by_women != 0 AND Fvm.Year BETWEEN 1997 AND 2015 
AND Fvm.TimeSpentOnDomesticWorkMaleInHours IS NOT NULL AND Fvm.TimeSpentOnDomesticWorkFemaleInHours IS NOT NULL 
AND Tfm.Year between 1997 and 2015
group by Wsp.Entity
order by AvgTimeSpentByWomenUnpaid DESC

CREATE VIEW Comparison_of_AvgTimeSpentOnDW_vs_Seats_vs_TopManagers as

select 
Wsp.Entity, 
--ROUND(AVG(Wdw.Daily_time_spent_on_domestic_work_by_women) , 2) as AvgTimeSpentByWomanOnDomesticWorkPaidAndUnpaid,
ROUND(AVG(cast(Fvm.TimeSpentOnDomesticWorkFemaleInHours as float)), 2) as AvgTimeSpentByWomenUnpaid,
ROUND(AVG(Wsp.Proporion_of_seats_held_by_women_in_national_parliaments_in_perc) ,2) as Proporion_of_seats,
ROUND(AVG(Tfm.PercentageOfFirmsWithFemaleTopManager) ,2) as AvgPercenatgeOfTopWomenManagers
FROM
WomenUnpaidWork..WomenSeatsInParliment as Wsp
INNER JOIN  
WomenUnpaidWork..FemalevsMaleDW as Fvm
ON 
Wsp.Entity = Fvm.Entity
INNER JOIN
WomenUnpaidWork..WomenDomesticWork as Wdw
ON Wdw.Entity = Wsp.Entity
JOIN WomenUnpaidWork..TopFemaleManagers AS Tfm
ON tfm.Entity = Wsp.Entity
where Wsp.Year between 1997 and 2015 
AND Wdw.Daily_time_spent_on_domestic_work_by_women != 0 AND Fvm.Year BETWEEN 1997 AND 2015 
AND Fvm.TimeSpentOnDomesticWorkMaleInHours IS NOT NULL AND Fvm.TimeSpentOnDomesticWorkFemaleInHours IS NOT NULL 
AND Tfm.Year between 1997 and 2015
group by Wsp.Entity