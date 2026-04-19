create database insulin;
use insulin;
show tables;
#Creacion de tabla
create table health(
	id int primary key,
    original_id int,
    Country varchar(255),
    Year int,
    Age int,
    Gender varchar(50),
    Age_group varchar(50),
    HbA1c float,
    HDL float,
    LDL float,
    TG float,
    TG_HDL_Ratio float,
    Fasting_Insulin float,
    HOMA_IR float,
    Diabetic int,
    Insulin_Resistant int, 
    Heart_Risk varchar(50)
);

#Importar csv a workbench
TRUNCATE TABLE health;
LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/health_dataset.csv"
INTO TABLE health
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS
(id, Country, Year, Age, Gender, Age_group, HbA1c, HDL, LDL, TG, TG_HDL_Ratio, Fasting_Insulin, HOMA_IR, Diabetic, Insulin_Resistant, Heart_Risk)
SET original_id = id; 

###############ANALISIS DE LA DATABASE#########################
select * from health limit 100;
#cantidad de registros
select 'Registros',count(*) from health;

#valores nulos
select 'Nulos',sum(country is null) as country,sum(year is null) as year, sum(age is null) as age,sum(gender is null) as gender,
sum(age_group is null) as age_group,sum(hba1c is null) as hba1c,sum(hdl is null) as hdl,sum(tg is null) as tg,sum(tg_hdl_ratio is null) as tg_hdl_ratio,
sum(fasting_insulin is null) as fastins_insulin,sum(homa_ir is null) as homa_ir,sum(diabetic is null) as diabetic,sum(insulin_resistant is null) as insulin_resistant,
sum(heart_risk is null) as heart_risk from health;

#valores unicos
select country,count(country) as valores from health group by country order by valores desc;
select year,count(year) as valores from health group by year order by valores desc;
select age,count(age) as valores from health group by age order by valores desc;
select gender,count(gender) as valores from health group by gender order by valores desc;
select age_group,count(age_group) as valores from health group by age_group order by valores desc;
select heart_risk,count(heart_risk) as valores from health group by heart_risk order by valores desc;
select diabetic,count(diabetic) as valores from health group by diabetic order by valores desc;
select insulin_resistant,count(insulin_resistant) as valores from health group by insulin_resistant order by valores desc;

#valores promedio de variables
with promedios as (
	select 'age', round(avg(age),3) as average from health union all select 'hba1c',round(avg(HbA1c),3) from health union all select 'hdl',round(avg(hdl),3) from health union all
    select 'ldl',round(avg(ldl),3) from health union all select 'tg',round(avg(tg),3) from health union all select 'tg_hdl_ratio',round(avg(tg_hdl_ratio),3) from health union all
    select 'fasting_insulin',round(avg(fasting_insulin),3) from health union all select 'homa_ir',round(avg(homa_ir),3) from health order by average desc
)
select * from promedios;

with pais_problemas as (
	select country,sum(diabetic) as diabetic,sum(insulin_resistant) as insulin_resistant,sum(if(heart_risk='High',1,0)) as heart_risk, 
    (sum(diabetic)+sum(insulin_resistant)+sum(if(heart_risk='High',1,0))) as total from health group by country
)

select * from pais_problemas;

with pais_problemas2 as (
	select country,sum(diabetic) as diabetic,sum(insulin_resistant) as insulin_resistant,sum(if(heart_risk='High',1,0)) as heart_risk from health group by country
)
select country,diabetic,insulin_resistant,heart_risk,(diabetic+insulin_resistant+heart_risk) as total from pais_problemas2 order by total desc;

#Distribucion de sexos por pais
with pais_sexo as(
	select country, sum(if(gender='Male',1,0)) as Men, sum(if(gender='Female',1,0)) as Women from health group by country
)
select * from pais_sexo order by women desc;

#Distribicion de edad por pais
with pais_edad as(
	select country,round(avg(age),3) as edad from health group by country
)
select * from pais_edad order by edad desc;

#Grupo de edad mas presente en cada pais
with pais_grupo as(
	select country,sum(if(age_group='Adult',1,0)) as Adult,sum(if(age_group='Elderly',1,0)) as Elderly, sum(if(age_group='Child',1,0)) as Child,
    sum(if(age_group='Teen',1,0)) as Teen,count(age_group) as total from health group by country
)
select * from pais_grupo;

#Pais con mas registros por año
with pais_año as(
	select country,sum(if(year=2005,1,0)) as '2005',sum(if(year=2006,1,0)) as '2006',sum(if(year=2007,1,0)) as '2007',sum(if(year=2008,1,0)) as '2008',
    sum(if(year=2009,1,0)) as '2009',sum(if(year=2010,1,0)) as '2010',sum(if(year=2011,1,0)) as '2011',sum(if(year=2012,1,0)) as '2012',sum(if(year=2013,1,0)) as '2013',
    sum(if(year=2014,1,0)) as '2014',sum(if(year=2015,1,0)) as '2015',sum(if(year=2016,1,0)) as '2016',sum(if(year=2017,1,0)) as '2017',sum(if(year=2018,1,0)) as '2018',
    sum(if(year=2019,1,0)) as '2019',sum(if(year=2020,1,0)) as '2020',sum(if(year=2021,1,0)) as '2021',sum(if(year=2022,1,0)) as '2022',sum(if(year=2023,1,0)) as '2023',
    sum(if(year=2024,1,0)) as '2024' from health group by country
)
select * from pais_año;

#Distribucion de sexos por año
with año_sexo as(
	select year,sum((case when gender='Male' then 1 else 0 end)) as male,sum((case when gender='Female' then 1 else 0 end)) as female,
    count(gender) as total from health group by year 
)
select * from año_sexo;

#Distribucion de edad por año
with año_edad as(
	select year,round(avg(age),3) as promedio_edad, sum(case when age_group='Adult' then 1 else 0 end) as Adult, sum(case when age_group='Elderly' then 1 else 0 end) as Elderly,
    sum(case when age_group='Teen' then 1 else 0 end) as Teen,sum(case when age_group='Child' then 1 else 0 end) as Child from health group by year
)
select * from año_edad;

#Problemas medicos por años
with año_enfermedad as (
	select year, sum(Diabetic) as Diabetic,sum(insulin_resistant) as insulin_resistant,sum(case when heart_risk='Low' then 1 else 0 end) as heart_risk_Low,
    sum(case when heart_risk='Medium' then 1 else 0 end) as heart_risk_Medium,sum(case when heart_risk='High' then 1 else 0 end) as heart_risk_High from health group by year
)
select * from año_enfermedad;

#Cuantos años en promedio tienen los sexos
with sexo_edad as(
	select gender,round(avg(age),3) as promedio_edad,max(age) as edad_maxima,min(age) as edad_minima,sum(case when age_group='Adult' then 1 else 0 end) as Adult,
    sum(case when age_group='Elderly' then 1 else 0 end) as Elderly,sum(case when age_group='Teen' then 1 else 0 end) as Teen,sum(case when age_group='Child' then 1 else 0 end) as Child from health group by gender
)
select * from sexo_edad;

#Edad con mas problemas 
with edad_enfermedades as(
	select 'Diabetic',round(avg(age),3) as promedio_edad,sum(case when age_group='Adult' then 1 else 0 end) as Adult,
    sum(case when age_group='Elderly' then 1 else 0 end) as Elderly, sum(case when age_group='Teen' then 1 else 0 end) as Teen,
    sum(case when age_group='Child' then 1 else 0 end) as Child from health where diabetic = 1 group by diabetic union all
    select 'insulin_resistant', round(avg(age),3),sum(case when age_group='Adult' then 1 else 0 end),
    sum(case when age_group='Elderly' then 1 else 0 end), sum(case when age_group='Teen' then 1 else 0 end),
    sum(case when age_group='Child' then 1 else 0 end) from health where insulin_resistant = 1 group by insulin_resistant union all
    select 'heart_risk_low',round(avg(age),3),sum(case when age_group='Adult' then 1 else 0 end),
    sum(case when age_group='Elderly' then 1 else 0 end), sum(case when age_group='Teen' then 1 else 0 end),
    sum(case when age_group='Child' then 1 else 0 end) from health where heart_risk='Low' union all 
    select 'heart_risk_medium',round(avg(age),3),sum(case when age_group='Adult' then 1 else 0 end),
    sum(case when age_group='Elderly' then 1 else 0 end), sum(case when age_group='Teen' then 1 else 0 end),
    sum(case when age_group='Child' then 1 else 0 end) from health where heart_risk='Medium' union all 
    select 'heart_risk_high',round(avg(age),3),sum(case when age_group='Adult' then 1 else 0 end),
    sum(case when age_group='Elderly' then 1 else 0 end), sum(case when age_group='Teen' then 1 else 0 end),
    sum(case when age_group='Child' then 1 else 0 end) from health where heart_risk='High' union all 
    select 'Total',round(avg(age),2),sum(case when age_group='Adult' and (diabetic=1 or insulin_resistant=1) then 1 else 0 end) as Adult,
	sum(case when age_group='Elderly' and (diabetic=1 or insulin_resistant=1) then 1 else 0 end) as Elderly, sum(case when age_group='Teen' and (diabetic=1 and insulin_resistant=1) then 1 else 0 end) as 'Teen',
	sum(case when age_group='Child' and (diabetic=1 or insulin_resistant=1) then 1 else 0 end) as Child from health
)
select * from edad_enfermedades;

#Distribucion de enfermedades por sexo
with sexo_enfermedad as(
	select gender,sum(diabetic) as diabetes,sum(insulin_resistant) as insulin_resistant,sum(if(heart_risk='Low',1,0)) as heart_risk_low,
    sum(if(heart_risk='Medium',1,0)) as heart_risk_medium, sum(if(heart_risk='High',1,0)) as heart_risk_high from health group by gender
)
select * from sexo_enfermedad;

#

