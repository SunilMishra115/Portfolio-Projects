
-- DATA Cleaning in SQL 

select * from Project..NashvilleHousing

-- Standardize date formate

SELECT Saledate,CONVERT(date,Saledate)
 FROM Project..NashvilleHousing

 UPDATE NashvilleHousing
 SET Saledate =CONVERT(date,Saledate)

 ALTER TABLE NashvilleHousing 
 ADD converted_sale_date date 

 UPDATE NashvilleHousing
 SET converted_sale_date =CONVERT(date,Saledate)

 SELECT converted_sale_date
 FROM Project..NashvilleHousing

 SELECT * FROM NashvilleHousing

 --Populate  property Address Data
 /*
as we checked there are some entries where property address is missing but in other rows Propertyaddress is available with same parcel id.
So, we are extracting the data by joining 
*/

 SELECT *
 From Project..NashvilleHousing
 WHERE PropertyAddress is null
 ORDER BY ParcelID

 SELECT *, a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress
 From Project..NashvilleHousing a 
 JOIN Project..NashvilleHousing b
 ON a.ParcelID = b.ParcelID
 AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null

--After this query, there is 35 rows with same ParcelID but PropertyAddress is not updated in a.PropertyAddress
-- Updating address 
 
 SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,isnull(a.PropertyAddress,b.PropertyAddress)
 From Project..NashvilleHousing a 
 JOIN Project..NashvilleHousing b
 ON a.ParcelID = b.ParcelID
 AND a.UniqueID <> b.UniqueID
 WHERE a.PropertyAddress is null

UPDATE a
 SET PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
 From Project..NashvilleHousing a 
 JOIN Project..NashvilleHousing b
 ON a.ParcelID = b.ParcelID
 AND a.UniqueID <> b.UniqueID
 WHERE a.PropertyAddress is null

 SELECT *
 FROM Project..NashvilleHousing
 

 --Breaking out address into individual column Address,City,State

 
Select PropertyAddress
From Project..NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

SELECT PropertyAddress,
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
From Project..NashvilleHousing

SELECT PropertyAddress,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address1
From Project..NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

Select *
From Project..NashvilleHousing

select OwnerAddress
from Project..NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From Project..NashvilleHousing



ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


Select *
From Project..NashvilleHousing


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Project..NashvilleHousing
Group by SoldAsVacant
order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From Project..NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

--Deleting duplicates using CTE method witout deleting from raw data

Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From Project..NashvilleHousing
order by ParcelID


with Row_Num_CTE as (
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From Project..NashvilleHousing
--order by parcelID
)
select *  From Row_Num_CTE
where row_num>1
order by PropertyAddress


with Row_Num_CTE as (
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From Project..NashvilleHousing
--order by parcelID
)
Delete
From Row_Num_CTE
where row_num>1


Select *
From Project..NashvilleHousing


-- removing unused columns

select*
from Project..Nashvillehousing

alter table NashvilleHousing
drop column PropertyAddress,OwnerAddress

select*
from Project..Nashvillehousing