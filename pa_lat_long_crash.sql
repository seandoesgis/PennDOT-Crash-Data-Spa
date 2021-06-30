/*Creates PADOT Crash GIS geometry from CRASH Table.  Must import CRASH table into database from Access first, then adjust/run this to generate geometries*/
create table CRASH_Pennsylvania as
with crashparse as (
	--parse the lat/long deg/min/seconds into seperate fields 
	select 
		c.crn as crn, 
		cast(left(c.latitude,2) as numeric) as lat_deg, 
		cast(right(split_part(c.latitude, ':', 1),2) as numeric) as lat_min, 
		cast(right(c.latitude,6) as numeric) as lat_sec, 
		cast(left(c.longitude,2) as numeric) as long_deg, 
		cast(right(split_part(c.longitude, ':', 1),2) as numeric) as long_min, 
		cast(right(c.longitude,6) as numeric) as long_sec
	from 
		crash c
	where
		coalesce(TRIM(latitude), '') = '' is false
),
--convert seperate deg/min/seconds fields into decimal degrees and create a geometry from them
jointable as (
	select
		crn,
		ST_SetSRID(ST_Point(((long_deg+(long_min/60)+(long_sec/3600))*-1), (lat_deg+(lat_min/60)+(lat_sec/3600))),4326) as shape
	from crashparse
)
--join to original crash table
select 
	c2.*, 
	jointable.shape
from 
	crash c2 
full join jointable on c2.crn = jointable.crn