SELECT SaleDate
FROM [SQL Project Portfolio].dbo.NashvilleHousing

--  Standardize Date Format
ALTER TABLE [SQL Project Portfolio].dbo.NashvilleHousing
ALTER COLUMN SaleDate date

SELECT SaleDate
FROM [SQL Project Portfolio].dbo.NashvilleHousing

--Handle missing Property Address info
SELECT a.UniqueID, b.UniqueID, a.ParcelID, b.ParcelID, a.PropertyAddress, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [SQL Project Portfolio].dbo.NashvilleHousing a
JOIN [SQL Project Portfolio].dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID AND
	a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [SQL Project Portfolio].dbo.NashvilleHousing a
JOIN [SQL Project Portfolio].dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID AND
	a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

SELECT PropertyAddress
FROM [SQL Project Portfolio].dbo.NashvilleHousing 
WHERE PropertyAddress IS NULL

--Break Address into individual columns : Address, city, State

ALTER TABLE NashvilleHousing
DROP COLUMN if exists PropertySplitAddress;
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)


ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress))


select PropertySplitAddress,PropertySplitCity
from NashvilleHousing
ORDER BY ParcelID


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255), 
 OwnerSplitCity nvarchar(255),
 OwnerSplitState nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.'),3),  
	OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.'),2), 
	OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',', '.'),1);

SELECT *
FROM NashvilleHousing

--Change Y to yes and N to No in "SoldAsVancant" field

SELECT SoldAsVacant, CASE WHEN SoldAsVacant = 'N' THEN 'No'
						  WHEN SoldAsVacant = 'Y' THEN 'Yes'
						  ELSE SoldAsVacant END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'N' THEN 'No'
						  WHEN SoldAsVacant = 'Y' THEN 'Yes'
						  ELSE SoldAsVacant END


SELECT SoldAsVacant, COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant

WITH RowNum AS
(
SELECT *, ROW_NUMBER() OVER (
			PARTITION BY 
			ParcelID, 
			PropertyAddress, 
			SalePrice, 
			SaleDate, 
			LegalReference 
			ORDER BY UniqueID) rownum
FROM NashvilleHousing
)

DELETE 
FROM RowNum
WHERE row_num>1

SELECT *     -- To check if the duplicates are deleted
FROM RowNum
WHERE rownum>1

--Drop unused columns
SELECT * 
FROM [SQL Project Portfolio].dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict

SELECT * 
FROM [SQL Project Portfolio].dbo.NashvilleHousing