/*

Cleaning Data in SQL Queries

*/

Select SaleDateConverted
From PortofolioProj.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format
--Select SaleDate,CONVERT(datetime, SaleDate)
--From PortofolioProj.dbo.NashvilleHousing


--Select saleDateConverted, CONVERT(Date,SaleDate)
--From PortofolioProj.dbo.NashvilleHousing


--Update PortofolioProj..NashvilleHousing
--SET SaleDate = CONVERT(datetime,SaleDate)

-- If it doesn't Update properly

ALTER TABLE PortofolioProj..NashvilleHousing
Add SaleDateConverted datetime;

--ALTER TABLE PortofolioProj..NashvilleHousing
--Add SaleDate date;
--Update PortofolioProj..NashvilleHousing
--SET SaleDate = CONVERT(date,SaleDateConverted)

--Select SaleDate
--from PortofolioProj..NashvilleHousing
 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From PortofolioProj.dbo.NashvilleHousing
Where PropertyAddress is null
order by ParcelID


-- NB:  The ParcelID is constant for the same Property Address even though there are different UniqueIDs 
-- When you look through the imported file, you realize some of the Properties repeat, they some of the instances seem to  miss ProperyAddress
-- Join two instances of a table with ParcelID and Property Addreses
-- Replace Property address values with that of the first table where address is null

Select a.ParcelID, 
	   a.PropertyAddress, 
	   b.ParcelID, b.PropertyAddress, 
	   ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortofolioProj.dbo.NashvilleHousing a
JOIN PortofolioProj.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID  -- Note that ParcelID is constant for the same Property Address even though there are different UniqueIDs 
	AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortofolioProj.dbo.NashvilleHousing a
JOIN PortofolioProj.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null



USE PortofolioProj
--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From PortofolioProj.dbo.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

-- Commands for editing string include, Substring(), charindex(), len(),trim etc
-- Substring to cut a part of propertyaddress, charindex for limit of cut

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, TRIM(SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))) as Address
From PortofolioProj.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = TRIM(SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)))




Select *
From PortofolioProj.dbo.NashvilleHousing





Select OwnerAddress
From PortofolioProj.dbo.NashvilleHousing


-- PARSENAME CAN ALSO BE USED
-- Using Select statements to preview results
Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortofolioProj.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

Select NashvilleHousing.ownersplitcity
from NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From PortofolioProj.dbo.NashvilleHousing




--------------------------------------------------------------------------------------------------------------------------


-- Change 0 and 1 to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant)
From NashvilleHousing;


Alter table NashvilleHousing
Add SoldAsVacant1 varchar(50)
--Select SoldAsVacant, Count(SoldAsVacant)
--From PortofolioProj.dbo.NashvilleHousing
--Group by SoldAsVacant
--order by 2





Select SoldAsVacant1,
	CASE When SoldAsVacant = 1 THEN 'Yes'
	   When SoldAsVacant = 0 THEN 'No'
	   END
From PortofolioProj.dbo.NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant1 = CASE When SoldAsVacant = 1 THEN 'Yes'
	   When SoldAsVacant = 0 THEN 'No'
	   END


Select SoldAsVacant1,count(soldasvacant1)
From PortofolioProj.dbo.NashvilleHousing
group by SoldAsVacant1


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE as
(
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

From PortofolioProj.dbo.NashvilleHousing

--order by ParcelID
)
--Select *
--From RowNumCTE
--Where row_num > 1 --Shows rows in partitioned data that have a count of more than one, i.e data repeats in more than row
--Order by PropertyAddress

-- Now we delete
Delete
From RowNumCTE
Where row_num > 1

/*
Select *
From PortofolioProj.dbo.NashvilleHousing
where ParcelID =  '107 14 0 157.00'

*/

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From PortofolioProj.dbo.NashvilleHousing


ALTER TABLE PortofolioProj.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDateConverted









-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
















