/*
Objective:
Retrieve data on patients who received the flu shot in 2022.
*/

/*
The first CTE filters active patients based on encounters and patient data. 
It selects distinct patients who were active at the hospital between January 1, 2020, and December 31, 2022. 
Active patients are those with no death recorded and whose age is 6 months or older as of December 31, 2022. 
*/
with active_patients as
(
	select 
		distinct patient
	from encounters as e
	join patients as pat
		on e.patient = pat.id
	where 
		start between '2020-01-01 00:00' and '2022-12-31 23:59'
		and pat.deathdate is null
		and EXTRACT(EPOCH FROM age('2022-12-31',pat.birthdate)) / 2592000 >= 6
),

/*
The second CTE filters immunizations to identify flu shots administered in 2022. 
It selects the earliest flu shot date for each patient who received the flu shot with the specified code during 2022.
*/
flu_shot_2022 as 
(
	select 
		 patient
		,min(date) as earliest_flu_shot_2022
	from immunizations
	where code = '5302'
		and date between '2022-01-01 00:00' and '2022-12-31 23:59'
	group by patient
)

/*
The main query joins patient data with the flu_shot_2022 CTE to generate the desired dataset. 
It selects patient attributes such as birthdate, race, county, state, ID, first name, and last name. 
It also includes whether the patient received a flu shot in 2022 (1 for yes, 0 for no), 
the age of the patient as of December 31, 2022, and the earliest flu shot date for those who received it.
*/
select 
	 pat.birthdate
	,pat.race
	,pat.county
	,pat.state
	,pat.id
	,pat.first
	,pat.last
	,flu.earliest_flu_shot_2022
	,flu.patient
	,case
		when flu.patient is not null then 1
		else 0
	end
	as flu_shot_2022
	,extract(YEAR FROM age('2022-12-31', pat.birthdate)) as age
from patients as pat
left join flu_shot_2022 as flu
	on pat.id = flu.patient
where 1=1
	and pat.id in (select patient from active_patients)

