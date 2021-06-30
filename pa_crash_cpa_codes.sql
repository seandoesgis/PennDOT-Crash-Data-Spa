/*Adds CPA codes to Philadelphia crash locations, non-intersecting crashes are automatically mated with CPAs that are within 1600m*/
--find philly crashes that intersect with the CPA boundary and assign CPA code
with cpa_intersect as (
	select 
		cp.crn, 
		cp.county, 
		cast(right(cpa.geoid_10,2) as numeric) as cpa_code, 
		cpa.dvrpc_code
	from 
		transportation.crash_pennsylvania cp  
	left join 
		boundaries.dvrpc_mcd_phicpa as cpa on st_intersects(st_transform(cp.shape,26918), cpa.shape)  
	where cp.county = '67' and cpa.co_name = 'Philadelphia'
),
--finds the Philly crashes that didn't intersect with CPA boundaries
nojoin as (
	select 
		cr.crn, 
		cr.county, 
		cpa_intersect.cpa_code, 
		st_transform(cr.shape, 26918) as shape
	from 
		transportation.crash_pennsylvania cr
	left join 
		cpa_intersect on cr.crn = cpa_intersect.crn
	where cpa_intersect.cpa_code is null and cr.county ='67'
),
--of the crashes that didn't intersect this finds the nearest CPA less than 1600m to crash location and assigns CPA code
cpa_nonintersect as (
	select 
		nojoin.crn, 
		cast(right(cpa.geoid_10,2) as numeric) as cpa_code 
	from 
		nojoin, 
		boundaries.dvrpc_mcd_phicpa cpa 
	where 
		cpa.co_name ='Philadelphia' and st_distance(nojoin.shape, cpa.shape) < 1600 
	order by 
		st_distance(nojoin.shape, cpa.shape)
)
--joins the intersect query and non-intersect query
select 
	crash.crn, 
	coalesce(cpa_intersect.cpa_code+cpa_nonintersect.cpa_code, cpa_intersect.cpa_code, cpa_nonintersect.cpa_code) as cpa_code
from 
	transportation.crash_pennsylvania crash
full join 
	cpa_intersect on cpa_intersect.crn = crash.crn
full join 
	cpa_nonintersect on cpa_nonintersect.crn = crash.crn
