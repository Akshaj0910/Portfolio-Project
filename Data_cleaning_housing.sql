-- Cleaning data using sql queries
-- standardize date
select SaleDate
from nashvillehousing;

Alter Table nashvillehousing 
modify column saledate date; 
-- populating property address data
select *
from nashvillehousing
order by parcelid;

select a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, IFNULL(a.propertyaddress , b.propertyaddress)
from nashvillehousing a
join nashvillehousing b
	on a.parcelid=b.parcelid
    and a.uniqueid <> b.uniqueid
where a.propertyaddress is null;

Update nashvillehousing a
join nashvillehousing b
	on a.parcelid=b.parcelid
    and a.uniqueid <> b.uniqueid
set a.propertyaddress = IFNULL(a.propertyaddress , b.propertyaddress)
where a.propertyaddress is null;

-- Breaking out address into individual columns (address,city,state)

select PropertyAddress
from nashvillehousing;

select 
substring(propertyaddress, 1, locate(',', propertyaddress)-1) as address,
substring(propertyaddress, locate(',', propertyaddress)+1, length(propertyaddress)) as city
from nashvillehousing;

Alter table nashvillehousing
add PropertySplitAddress varchar(50);

Update nashvillehousing
set PropertySplitAddress =substring(propertyaddress, 1, locate(',', propertyaddress)-1);

Alter table nashvillehousing
add PropertySplitCity varchar(50);

Update nashvillehousing
set PropertySplitCity = substring(propertyaddress, locate(',', propertyaddress)+1, length(propertyaddress));

select PropertyAddress,PropertySplitAddress,PropertySplitCity
from nashvillehousing;

-- Splitting Owner address
select owneraddress
from nashvillehousing;

SELECT OwnerAddress, substring_index(owneraddress, ',', 1) AS fname,
SUBSTRING_INDEX(SUBSTRING_INDEX(owneraddress,',', 2), ' ',-1) AS mname,
SUBSTRING_INDEX(owneraddress, ',', -1) as lname 
FROM nashvillehousing;

Alter table nashvillehousing
add OwnerSplitAddress varchar(50);

Update nashvillehousing
set OwnerSplitAddress =substring_index(owneraddress, ',', 1);

Alter table nashvillehousing
add OwnerSplitCity varchar(50);

Update nashvillehousing
set OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(owneraddress,',', 2), ' ',-1);

Alter table nashvillehousing
add OwnerSplitState varchar(50);

Update nashvillehousing
set OwnerSplitState = SUBSTRING_INDEX(owneraddress, ',', -1);

select*  
from nashvillehousing;

-- Change Y and N to yes and NO in "sold as vacant" field

select Distinct soldasvacant, count(soldasvacant)
from nashvillehousing
group by SoldAsVacant
order by 2 ;

select soldasvacant,
(case when soldasvacant = 'Y' Then 'Yes'
	when soldasvacant = 'N' Then 'No'
    else soldasvacant
end)
from nashvillehousing;

update nashvillehousing 
set soldasvacant = (case when soldasvacant = 'Y' Then 'Yes'
	when soldasvacant = 'N' Then 'No'
    else soldasvacant
end);

-- removing duplicates
with RowNumCTE as(
select *,
	row_number() over(
    Partition by parcelid,
				 propertyaddress,
                 saleprice,
                 saledate,
                 legalreference
                 ORDER BY
					uniqueid
				) AS row_num
from nashvillehousing
)

Delete nh
from nashvillehousing nh
inner join rownumcte r 
on nh.uniqueID = r.UniqueID 
where row_num >1;


select*from nashvillehousing
order by parcelid;

-- delete unused columns
select* 
from nashvillehousing;

Alter table nashvillehousing 
drop column OwnerAddress,
drop column Taxdistrict, 
drop column propertyaddress;
