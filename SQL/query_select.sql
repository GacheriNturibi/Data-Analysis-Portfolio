create extension postgis;
--create table with 2019 census data
create table census(ObjectID numeric,
				   county VARCHAR(150),
				   subcounty VARCHAR(150),
				   county_code NUMERIC,
				   male numeric,
				   female numeric,
				   intersex numeric,
				   total numeric);

1--selection operation
--use veiw function to create temporary table  for schools
create view schools as (SELECT *
FROM "public"."OSM_Points"
WHERE "OSM_Points"."amenity"='school')



2--Intersection and join operation
--use already created temporary table to view distribution of schools
SELECT c.adm1_en, b.amenity,b.name,b.geom
FROM "public"."Sub_counties" AS c INNER JOIN
schools As b ON ST_Intersects(c.geom, b.geom)
WHERE c.adm1_en='West Pokot' AND b.amenity='school';

3--Intersection and join operation
--count number of schools in each sub county)
SELECT count(b.amenity),c.adm2_en
FROM "public"."Sub_counties" AS c INNER JOIN
schools As b ON ST_Intersects(c.geom, b.geom)
WHERE c.adm1_en='West Pokot' AND b.amenity='school'
Group by c.adm2_en;


4--Intersection,join and selection operations
--Total Count of schools in Westpokot county
SELECT count(b.amenity),c.adm1_en
FROM "public"."Sub_counties" AS c INNER JOIN
schools As b ON ST_Intersects(c.geom, b.geom)
WHERE c.adm1_en='West Pokot' AND b.amenity='school'
Group by c.adm1_en;



5--cartesian product operation
--combine census data and subcounty shapefiles 
--and extract subcounty level population
create view Subcounty_census as(SELECT b.*,c.adm1_en,c.adm2_en,c.shape_area,c.geom
FROM "public"."Sub_counties" AS c, "public"."census" As b 
where b.subcounty=c.adm2_en);



6--Selection operation
--Generate sub county population for west pokot county selection operation
select a.subcounty,a.male,a.female,a.intersex,a.total,a.geom
from subcounty_census as a
where a.county='West Pokot';

7--selection operation
--define water points within westpokot county
create view water_points as (SELECT c.adm2_en,b.amenity,b.operator,b.geom
FROM "public"."Sub_counties" AS c INNER JOIN
"public"."OSM_Points" As b ON ST_Intersects(c.geom, b.geom)
WHERE c.adm1_en='West Pokot' AND b.amenity='water_point');

--identify water operators
select DISTINCT a.operator
from water_points as a



8-- count number of water points in each subcounty within west pokot
SELECT a.adm2_en,count(a.amenity)
FROM water_points as a
group by a.adm2_en


9--buffer 3km around water points create a virtual relation for water buffer
create view water_buffer as (SELECT a.geom,geometry(ST_Buffer((a.geom)::geography,3000))as buffer_geom
FROM water_points as a);

10--veiw for all schools within west pokot county
create view schools_WP as (SELECT c.adm1_en,c.adm2_en ,b.*,b.geom as schools_geom
FROM "public"."Sub_counties" AS c INNER JOIN
schools As b ON ST_Intersects(c.geom, b.geom)
WHERE c.adm1_en='West Pokot' AND b.amenity='school');


--projection operation
--entify the categories of individuals or organizations who manage schools
select DISTINCT a.operatorty
from schools_WP as a

--school operators in different subcounties
select count(a.operatorty),a.adm2_en
from schools_WP as a
group by a.adm2_en

--projection operation
--tal number of distinctive school operators
SELECT COUNT ( DISTINCT a.operatorty) AS "Number of operators"
FROM schools_WP as a;

--number of distinctive school operators in each sub county
SELECT count(operatorty),adm2_en
FROM (SELECT DISTINCT operatorty,adm2_en FROM schools_WP) T
group by adm2_en

				 
11--total number of schools that are within 3km from a water point
select count(a.schools_geom)
from schools_WP as a inner join water_buffer as b on st_contains(b.buffer_geom,a.schools_geom);

--number of schools outside 3km water point buffer
--lect count(a.schools_geom)
--om schools_WP as a inner join water_buffer as b on st_disjoints(b.buffer_geom,a.schools_geom)
--ere x=true;

13-- average distance between schools and water points 3km buffer
select avg(geography_distance_knn(geography(b.buffer_geom),geography(a.schools_geom)))
from schools_WP as a,water_buffer as b;


14--number of subcounties in each county
select count(a.adm2_en),a.adm1_en
FROM "public"."Sub_counties" as a
Group by a.adm1_en;

--subcounties male population
select a.subcounty,a.male
from subcounty_census as a
order by a.male;

--subcounties female populatin order
select a.subcounty,a.female
from subcounty_census as a
order by a.female;

--subcounties intersex population order
select a.subcounty,a.intersex
from subcounty_census as a
order by a.intersex;

--subcounties total population order
select a.subcounty,a.total
from subcounty_census as a
order by a.total;

--subcounties order by size
select a.subcounty,a.shape_area
from subcounty_census as a
order by a.shape_area;










