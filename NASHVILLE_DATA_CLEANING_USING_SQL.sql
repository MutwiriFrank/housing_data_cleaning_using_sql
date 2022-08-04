
select * from housing limit 1000;

--  Conver saledate from date time to just date

select saledate, DATE(saledate)
from housing limit 1000;

alter table housing
add sale_date_converted DATE;

update housing 
set sale_date_converted  = DATE(saledate)

select * from housing limit 1000;


-- Populate primary address data 
-- some Properties have same parcel id and one may lack property addres
-- fIRST DO A SELF JOIN  to know to map those sharing parcel id while lacking address 
-- update table

select *
from housing 
where propertyaddress isnull 

with clean_add (cleaned_property_address )
as (
select COALESCE(h.propertyaddress, h2.propertyaddress) as cleaned_property_address
from housing h 
join housing h2 
	on h.parcelid = h2.parcelid 
	and h.uniqueid_ <> h2.uniqueid_ 
where h.propertyaddress isnull 
)

select cleaned_property_address from clean_add ;

alter table housing
add cleaned_property_address varchar(50);


 with clean_add (uniqueid2, cleaned_property_add )
as (
select h.uniqueid_  as uniqueid2 ,  COALESCE(h.propertyaddress, h2.propertyaddress) as cleaned_property_add
from housing h 
join housing h2 
	on h.parcelid = h2.parcelid 
where h.propertyaddress isnull 
)
--select *
--from clean_add


update  housing as h3
set cleaned_property_address = cleaned_property_add
from clean_add cd
where  h3.uniqueid_ = uniqueid2  

;


select *
from housing



-- Extracting city and address from propertyaddress

select split_part( propertyaddress, ',' , 1 ) as address,
	split_part( propertyaddress, ',' , 2 ) as address2
from housing

alter table housing 
add split_address varchar(50);

update housing 
set split_address = split_part( propertyaddress, ',' , 1 );

alter table housing
add city varchar(50);

update housing
set city = split_part( propertyaddress, ',' , 2 );


ALTER TABLE housing
  rename column city to property_city;
  
 ALTER TABLE housing
 	RENAME COLUMN split_address TO property_address;

 
 select property_address, 
 	split_part( property_address , ' ', 4) as state
 from housing
 	
alter table housing
 	add property_state varchar(50) 
 	
 
update housing 
set	property_state = split_part( property_address , ' ', 4)

 
select *
from housing

--change Y and N to yes and no in soldasvacant

select distinct(soldasvacant)
from housing

select soldasvacant,
	case when soldasvacant = 'Y' then 'YES'
		 when soldasvacant = 'Yes' then 'YES'
		 when soldasvacant = 'N' then 'NO'
		 when soldasvacant = 'No' then 'NO'
		 else soldasvacant
		 end
from housing h ;

update housing 
set soldasvacant = case when soldasvacant = 'Y' then 'YES'
		 when soldasvacant = 'Yes' then 'YES'
		 when soldasvacant = 'N' then 'NO'
		 when soldasvacant = 'No' then 'NO'
		 else soldasvacant
		 end ;

select distinct(soldasvacant), COUNT(soldasvacant)
from housing
group by (soldasvacant)



--Remove duplicate rows 

--- list duplicate rows

with row_numbers as (

select  *,

ROW_NUMBER() over (partition by parcelid, saledate, propertyaddress, ownername  order by parcelid) as row_number2

from housing h 

)
select *
from row_numbers
where row_number2 > 1 ;


-- Delete duplicate rows 
delete from housing h
where uniqueid_  in (

	select  h.uniqueid_  
	from (
		select  *,
	
		ROW_NUMBER() over (partition by parcelid, saledate, propertyaddress, ownername  order by parcelid) as row_number2
		
		from housing as h
	)as h where row_number2 > 1

)

--delete unused columns

alter table housing 
drop column owneraddress 














