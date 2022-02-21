
/* 

Cleaning Data in SQL

*/

--Select
--	*
--From [Portfolio Project].dbo.NashvilleHousing

----------------------------------------------------------

--Standardize Sales Format

SELECT
	SaleDate,
	CONVERT(Date,SaleDate)
FROM [Portfolio Project].dbo.NashvilleHousing

UPDATE [Portfolio Project].sbo.NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)
--above Update references impacted records, but those changes aren't shown in actual table. Workaround below


ALTER TABLE [Portfolio Project].dbo.NashvilleHousing
ADD new_sale_date date;

UPDATE [Portfolio Project].dbo.NashvilleHousing
SET new_sale_date = CONVERT(Date,SaleDate);

-------------------------------------------------------------
--populating property address

SELECT
	a.ParcelID,
	b.ParcelID,
	a.PropertyAddress,
	b.PropertyAddress,
	ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Portfolio Project].dbo.NashvilleHousing a
JOIN [Portfolio Project].dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress is NULL;

UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Portfolio Project].dbo.NashvilleHousing a
JOIN [Portfolio Project].dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress is NULL;
--------------------------------------------------------------
--Breaking Our Address into Individual Columns
SELECT
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
	SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as State
FROM [Portfolio Project].dbo.NashvilleHousing

ALTER TABLE [Portfolio Project].dbo.NashvilleHousing
ADD prop_splt_address Nvarchar(255);

UPDATE [Portfolio Project].dbo.NashvilleHousing
SET prop_splt_address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE [Portfolio Project].dbo.NashvilleHousing
ADD prop_splt_state Nvarchar(255)

UPDATE [Portfolio Project].dbo.NashvilleHousing
SET prop_splt_state = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))
--------------------------------------------------------------
--unify SoldAsVacant column with Yes or No

SELECT 
	DISTINCT(SoldAsVacant),
	COUNT(SoldAsVacant)
FROM [Portfolio Project].dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT
	SoldAsVacant,
	CASE
	WHEN SoldAsVacant = 'Y' THEN 'YeS'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM [Portfolio Project].dbo.NashvilleHousing;

UPDATE [Portfolio Project].dbo.NashvilleHousing
SET SoldAsVacant =
	CASE
	WHEN SoldAsVacant = 'Y' THEN 'YeS'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM [Portfolio Project].dbo.NashvilleHousing;
-------------------------------------------------------------
--split owner address out using parsename

SELECT
	roa.OwnerAddress,
	PARSENAME(roa.owner_address_p, 3) AS owner_split_st,
	PARSENAME(roa.owner_address_p, 2) AS owner_split_city,
	PARSENAME(roa.owner_address_p, 1) AS owner_split_address
FROM
(
SELECT
	OwnerAddress,
	REPLACE(OwnerAddress,',','.') AS owner_address_p
FROM [Portfolio Project].dbo.NashvilleHousing) AS roa --"replaced owner address" with period
-------------------
ALTER TABLE [Portfolio Project].dbo.NashvilleHousing
ADD owner_split_st Nvarchar(255);

UPDATE [Portfolio Project].dbo.NashvilleHousing
SET owner_split_st = PARSENAME(roa.owner_address_p, 3)
FROM
(
SELECT
	OwnerAddress,
	REPLACE(OwnerAddress,',','.') AS owner_address_p
FROM [Portfolio Project].dbo.NashvilleHousing) AS roa

ALTER TABLE [Portfolio Project].dbo.NashvilleHousing
ADD owner_split_city Nvarchar(255)

UPDATE [Portfolio Project].dbo.NashvilleHousing
SET owner_split_city = PARSENAME(roa.owner_address_p, 2)
FROM
(
SELECT
	OwnerAddress,
	REPLACE(OwnerAddress,',','.') AS owner_address_p
FROM [Portfolio Project].dbo.NashvilleHousing) AS roa

ALTER TABLE [Portfolio Project].dbo.NashvilleHousing
ADD owner_split_address Nvarchar(255)

UPDATE [Portfolio Project].dbo.NashvilleHousing
SET owner_split_address = PARSENAME(roa.owner_address_p, 1)
FROM
(
SELECT
	OwnerAddress,
	REPLACE(OwnerAddress,',','.') AS owner_address_p
FROM [Portfolio Project].dbo.NashvilleHousing) AS roa

-------------------------------------------------------------
--Remove Duplicates

WITH num_dupe_ct AS(
SELECT 
	*,
	ROW_NUMBER() OVER(
	PARTITION BY 
		ParcelID,
		PropertyAddress,
		SaleDate,
		LegalReference
		ORDER BY ParcelID) row_rum
FROM [Portfolio Project].dbo.NashvilleHousing
--ORDER BY ParcelID
)
SELECT
	*
FROM num_dupe_ct
WHERE row_rum > 1
ORDER BY PropertyAddress


--------------------------------------------------------------
--Dropping unnecessary columns

SELECT
	*
FROM [Portfolio Project].dbo.NashvilleHousing

ALTER TABLE [Portfolio Project].dbo.NashvilleHousing
Drop Column OwnerAddress, PropertyAddress

ALTER TABLE [Portfolio Project].dbo.NashvilleHousing
Drop Column SaleDate