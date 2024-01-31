--This is a chain of SQL queries used in PostGIS to accomplish various objectives as highlighted in each instance.
--The queries are part of a data analysis and management process that involves spatial and demographic data. 
--The primary objectives of these queries revolve around the integration and analysis of census data, school information, 
--and geographic boundaries (sub-counties) within a specified region.

CREATE extension postgis;
--create table with 2019 census data
CREATE TABLE census(ObjectID numeric,
				   county VARCHAR(150),
				   subcounty VARCHAR(150),
				   county_code NUMERIC,
				   male numeric,
				   female numeric,
				   intersex numeric,
				   total numeric);

1--Selection operation
--Use view function to create temporary table  for schools
CREATE VIEW schools AS (SELECT *
FROM "public"."OSM_Points"
WHERE "OSM_Points"."amenity"='school')



2--Intersection and join operation
--Use already created temporary table to view distribution of schools
SELECT c.adm1_en, b.amenity,b.name,b.geom
FROM "public"."Sub_counties" AS c INNER JOIN
schools AS b ON ST_Intersects(c.geom, b.geom)
WHERE c.adm1_en='West Pokot' AND b.amenity='school';

3--Intersection and join operation
--Count number of schools in each sub county)
SELECT COUNT(b.amenity),c.adm2_en
FROM "public"."Sub_counties" AS c INNER JOIN
schools AS b ON ST_Intersects(c.geom, b.geom)
WHERE c.adm1_en='West Pokot' AND b.amenity='school'
GROUP BY c.adm2_en;


4--Intersection,join and selection operations
--Total Count of schools in Westpokot county
SELECT count(b.amenity),c.adm1_en
FROM "public"."Sub_counties" AS c INNER JOIN
schools AS b ON ST_Intersects(c.geom, b.geom)
WHERE c.adm1_en='West Pokot' AND b.amenity='school'
GROUP BY c.adm1_en;



5--Cartesian product operation
--Combine census data and subcounty shapefiles 
--And extract subcounty level population
CREATE VIEW Subcounty_census AS(SELECT b.*,c.adm1_en,c.adm2_en,c.shape_area,c.geom
FROM "public"."Sub_counties" AS c, "public"."census" AS b 
WHERE b.subcounty=c.adm2_en);



6--Selection operation
--Generate sub county population for West Pokot County selection operation
SELECT a.subcounty,a.male,a.female,a.intersex,a.total,a.geom
FROM subcounty_census AS a
WHERE a.county='West Pokot';

7--Selection operation
--Define water points within West Pokot county
CREATE VIEW water_points AS (SELECT c.adm2_en,b.amenity,b.operator,b.geom
FROM "public"."Sub_counties" AS c INNER JOIN
"public"."OSM_Points" AS b ON ST_Intersects(c.geom, b.geom)
WHERE c.adm1_en='West Pokot' AND b.amenity='water_point');

--Identify water operators
SELECT DISTINCT a.operator
FROM water_points AS a


8-- Count number of water points in each subcounty within West Pokot
SELECT a.adm2_en,COUNT(a.amenity)
FROM water_points AS a
GROUP BY a.adm2_en


9--Buffer 3km around water points create a virtual relation for water buffer
CREATE VIEW water_buffer AS (SELECT a.geom,geometry(ST_Buffer((a.geom)::geography,3000))AS buffer_geom
FROM water_points AS a);

10--View for all schools within West Pokot county
CREATE VIEW schools_WP AS (SELECT c.adm1_en,c.adm2_en ,b.*,b.geom AS schools_geom
FROM "public"."Sub_counties" AS c INNER JOIN
schools AS b ON ST_Intersects(c.geom, b.geom)
WHERE c.adm1_en='West Pokot' AND b.amenity='school');


--Projection operation
--Identify the categories of individuals or organizations who manage schools
SELECT DISTINCT a.operatorty
FROM schools_WP AS a

--School operators in different subcounties
SELECT COUNT(a.operatorty),a.adm2_en
FROM schools_WP AS a
GROUP BY a.adm2_en

--Projection operation
--Total number of distinctive school operators
SELECT COUNT ( DISTINCT a.operatorty) AS "Number of operators"
FROM schools_WP AS a;

--Number of distinctive school operators in each sub county
SELECT COUNT(operatorty),adm2_en
FROM (SELECT DISTINCT operatorty,adm2_en FROM schools_WP) T
GROUP BY adm2_en

				 
11--Total number of schools that are within 3km from a water point
SELECT COUNT(a.schools_geom)
FROM schools_WP AS a INNER JOIN water_buffer AS b ON st_contains(b.buffer_geom,a.schools_geom);

12--Number of schools outside 3km water point buffer
SELECT(a.schools_geom)
FROM schools_WP AS a INNER JOIN water_buffer AS b ON st_disjoints(b.buffer_geom,a.schools_geom)
WHERE x=true;

13-- Average distance between schools and water points 3km buffer
SELECT avg(geography_distance_knn(geography(b.buffer_geom),geography(a.schools_geom)))
FROM schools_WP AS a,water_buffer AS b;


14--Number of subcounties in each county
SELECT COUNT(a.adm2_en),a.adm1_en
FROM "public"."Sub_counties" AS a
GROUP BY a.adm1_en;

--Subcounties male population
SELECT a.subcounty,a.male
FROM subcounty_census AS a
ORDER BY a.male;

--Subcounties female populatin order
SELECT a.subcounty,a.female
FROM subcounty_census AS a
ORDER BY a.female;

--Subcounties intersex population order
SELECT a.subcounty,a.intersex
FROM subcounty_census AS a
ORDER BY a.intersex;

--Subcounties total population order
SELECT a.subcounty,a.total
FROM subcounty_census AS a
ORDER BY a.total;

--Subcounties order by size
SELECT a.subcounty,a.shape_area
FROM subcounty_census AS a
ORDER BY a.shape_area;
