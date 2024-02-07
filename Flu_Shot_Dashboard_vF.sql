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

