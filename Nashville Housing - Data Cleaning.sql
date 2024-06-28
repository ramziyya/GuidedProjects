SELECT *
FROM [Portfolio Project]..NashvilleHousing

-- Standartizing Date Type

SELECT SaleDate, CONVERT(DATE, SaleDate)
FROM [Portfolio Project]..NashvilleHousing

UPDATE [Portfolio Project]..NashvilleHousing
SET SaleDate = CONVERT(DATE, SaleDate)

ALTER TABLE [Portfolio Project]..NashvilleHousing
ADD SaleDate2 DATE; 

UPDATE [Portfolio Project]..NashvilleHousing
SET SaleDate2 = CONVERT(DATE, SaleDate)

SELECT *
FROM [Portfolio Project]..NashvilleHousing

-- Populating Property Address Data

SELECT *
FROM [Portfolio Project]..NashvilleHousing
WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT
a.ParcelID AS ParcelID1, ISNULL(a.PropertyAddress, 'Uknown Address') AS PropertyAddress1, 
b.ParcelID AS ParcelID2, ISNULL(b.PropertyAddress, 'Unknown Address') AS PropertyAddress2, 
ISNULL(a.PropertyAddress, b.PropertyAddress) AS FinalPropertyAddress
FROM [Portfolio Project]..NashvilleHousing a
JOIN [Portfolio Project]..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b. [UniqueID ]
WHERE a.PropertyAddress IS NULL


UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Portfolio Project]..NashvilleHousing a
JOIN [Portfolio Project]..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b. [UniqueID ]
Where a.PropertyAddress IS NULL

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM [Portfolio Project]..NashvilleHousing
	
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)  AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM [Portfolio Project]..NashvilleHousing

ALTER TABLE [Portfolio Project]..NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

Update [Portfolio Project]..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX (',', PropertyAddress) -1)

ALTER TABLE [Portfolio Project]..NashvilleHousing
ADD PropertySplitCity nvarchar(255);

UPDATE [Portfolio Project]..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) -1, LEN(PropertyAddress))


SELECT *
FROM [Portfolio Project]..NashvilleHousing


SELECT OwnerAddress
FROM [Portfolio Project]..NashvilleHousing


SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM [Portfolio Project]..NashvilleHousing

ALTER TABLE [Portfolio Project]..NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

UPDATE [Portfolio Project]..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE [Portfolio Project]..NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

UPDATE [Portfolio Project]..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE [Portfolio Project]..NashvilleHousing
ADD OwnerSplitState nvarchar(255);

UPDATE [Portfolio Project]..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


SELECT *
FROM [Portfolio Project]..NashvilleHousing

-- Changing Y and N to Yes and No in 'Sold as Vacant' field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [Portfolio Project]..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE	WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVAcant
		END
FROM [Portfolio Project]..NashvilleHousing


-- Removing Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
				     UniqueID
					 ) row_num
FROM [Portfolio Project]..NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1
--order by PropertyAddress


-- Deleting Unused Columns

SELECT*
FROM [Portfolio Project]..NashvilleHousing


ALTER TABLE [Portfolio Project]..NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict

ALTER TABLE [Portfolio Project]..NashvilleHousing
DROP COLUMN SaleDate	