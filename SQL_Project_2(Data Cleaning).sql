
 
																		---- DATA CLEANING WITH SQL QUERIES---

select * from dbo.Nashville_housing_dataset

----  1: Standardize Date format 

update Nashville_housing_dataset
set SaleDate=convert( date,SaleDate ) 

---Issue-> it may not change the datatype so you can have another option
alter table  Nashville_housing_dataset
alter column SaleDate date
select SaleDate from Nashville_housing_dataset

---- Populating property address data into several visual columns

select PropertyAddress
from Nashville_housing_dataset
where  PropertyAddress is null 

--count of null values
select  count(*) as null_values
from Nashville_housing_dataset
where PropertyAddress IS NULL;

---Looking at the duplicates Parcel ID's
select ParcelID,count(*) as Num_of_Duplicate_Id
from Nashville_housing_dataset
group by ParcelID
having COUNT(*) > 1;
---self join
select a1.ParcelID,a1.PropertyAddress,a2.ParcelID,a2.PropertyAddress,ISNULL(a1.PropertyAddress,a2.PropertyAddress)
from Nashville_housing_dataset a1
join  Nashville_housing_dataset a2
on a1.ParcelID=a2.ParcelID
and a1.UniqueID <> a2.UniqueID
where a1.PropertyAddress is null
  
--Update
update a1
set PropertyAddress=ISNULL(a1.PropertyAddress,a2.PropertyAddress)
from Nashville_housing_dataset a1
join  Nashville_housing_dataset a2
on a1.ParcelID=a2.ParcelID
and a1.[UniqueID ]<> a2.[UniqueID ]
where a1.PropertyAddress is null

-----------
Select PropertyAddress
from Nashville_housing_dataset
---Property address has two things seprated by a comma 1- address,2-City
select SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress )-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress )+1, len( PropertyAddress))  as city
from Nashville_housing_dataset

--Updating and adding these two columns in data

--Adding a column for split address only
alter table  Nashville_housing_dataset
add Property_Address varchar(255)
update Nashville_housing_dataset
set Property_Address=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress )-1) 
--Adding a column for city only
alter table  Nashville_housing_dataset
add Property_City varchar(255)
update Nashville_housing_dataset
set Property_City=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress )+1, len( PropertyAddress))
select * from Nashville_housing_dataset

select OwnerAddress
from Nashville_housing_dataset
-- we can also use parse name instead of substring,
select   PARSENAME(replace(OwnerAddress,',','.'),3  )as owner_split_address,
	PARSENAME(replace(OwnerAddress,',','.'),2 )as owner_split_city,
	PARSENAME(replace(OwnerAddress,',','.'),1) as owner_split_state
from Nashville_housing_dataset

---adding up these columns in a table

--Adding a column for address only
alter table  Nashville_housing_dataset
add Owner_Property_Address varchar(255)
update Nashville_housing_dataset
set Owner_Property_Address=PARSENAME(replace(OwnerAddress,',','.'),3  )

--Adding a column for city only
alter table  Nashville_housing_dataset
add Owner_Property_City varchar(255)
update Nashville_housing_dataset
set Owner_Property_City=PARSENAME(replace(OwnerAddress,',','.'),2 )

--Adding a column for state only
alter table  Nashville_housing_dataset
add Owner_Property_State varchar(255)
update Nashville_housing_dataset
set Owner_Property_State=PARSENAME(replace(OwnerAddress,',','.'),1 )


-----Removing Duplicates---
select SoldAsVacant
from Nashville_housing_dataset

SELECT distinct  SoldAsVacant , COUNT(*) AS Row_Count
FROM Nashville_housing_dataset
GROUP BY SoldAsVacant;

--using case statment to replace N to No and Yes to Y
SELECT   SoldAsVacant ,
case when SoldAsVacant='Y' then 'Yes'
when SoldAsVacant='N' then 'No'
else SoldAsVacant
end 
FROM Nashville_housing_dataset

---Updating the column in table to have only Yes and No---
update Nashville_housing_dataset
set SoldAsVacant =case when SoldAsVacant='Y' then 'Yes'
when SoldAsVacant='N' then 'No'
else SoldAsVacant
end 

---partioning of unique data in rows---
with cte_nashville as
(
select * ,ROW_NUMBER() over (partition by ParcelID,
									Property_Address,
									SalePrice,
									SaleDate,
									LegalReference
									Order by UniqueID) row_num
from Nashville_housing_dataset
)
select * from  cte_nashville
where row_num='2'

----Deleting unused columns

select * from  Nashville_housing_dataset
ALTER TABLE Nashville_housing_dataset
DROP COLUMN OwnerAddress,PropertyAddress
ALTER TABLE Nashville_housing_dataset
DROP COLUMN SaleDate


