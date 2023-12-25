
--Cleaning Data in SQL Queries

SELECT * 
from PortfolioProject.dbo.NashvileHousing

/*Change Data format */

v
Select SaleDate , CONVERT(Date,SaleDate,23) as FormattedSaleDate
from PortfolioProject.dbo.NashvileHousing

-- Update statement to change the format
Update PortfolioProject.dbo.NashvileHousing
Set SaleDate = convert (Date,SaleDate,23)


/*Populate Property address data */
 --Select statement to verify the result before updating  
Select a.ParcelID , a.PropertyAddress , b.ParcelID , b.PropertyAddress , ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvileHousing as a
join  PortfolioProject.dbo.NashvileHousing as b
 on  a.ParcelID = b.ParcelID
 And a.[UniqueID ] <> b.[UniqueID ]
  where a.PropertyAddress is null
--Update statement to populate address data
 Update a
 SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
 from PortfolioProject.dbo.NashvileHousing as a
join  PortfolioProject.dbo.NashvileHousing as b
 on  a.ParcelID = b.ParcelID
 And a.[UniqueID ] <> b.[UniqueID ]
 where a.PropertyAddress is null

 --Select statement to verify the result after updating  
Select a.ParcelID , a.PropertyAddress , b.ParcelID , b.PropertyAddress , ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvileHousing as a
join  PortfolioProject.dbo.NashvileHousing as b
 on  a.ParcelID = b.ParcelID
 And a.[UniqueID ] <> b.[UniqueID ]

 /*Divide Property address data into individual columns (Address,City) */

 Select  PropertyAddress	
 from PortfolioProject.dbo.NashvileHousing

 -- Select individual components (Address, City) using SUBSTRING and CHARINDEX
 Select 
 SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address ,
 SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress )+1 , LEN(PropertyAddress)) as City
  from PortfolioProject.dbo.NashvileHousing

 -- Add a new column PropertySplitAddress to the table
  ALTER Table PortfolioProject.dbo.NashvileHousing
  Add PropertySplitAddress nvarchar(255)

 -- Update PropertySplitAddress with the extracted Address
  Update PortfolioProject.dbo.NashvileHousing
  SET  PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)
  
 -- Add a new column PropertySplitCity to the table
  ALTER Table PortfolioProject.dbo.NashvileHousing
  Add PropertySplitCity nvarchar(255)

 -- Update PropertySplitCity with the extracted City
  Update PortfolioProject.dbo.NashvileHousing
  SET PropertySplitCity= SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN (PropertyAddress))

  Select OwnerAddress
    from PortfolioProject.dbo.NashvileHousing

/*Divide Owner address data into individual columns (Address,City,State) */
	 SELECT OwnerAddress
	     from PortfolioProject.dbo.NashvileHousing
-- Select individual components (State, City, Address) using PARSENAME and REPLACE
	  SELECT 
		PARSENAME(REPLACE(OwnerAddress,',','.'),3)
		,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
		,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
	     from PortfolioProject.dbo.NashvileHousing

 -- Add a new column OwnerSplitAddress to the table
   ALTER Table PortfolioProject.dbo.NashvileHousing
   Add OwnerSplitAddress nvarchar(255)

 -- Update OwnerSplitAddress with the extracted Address
   Update PortfolioProject.dbo.NashvileHousing
   SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

-- Add a new column OwnerSplitCity to the table
    ALTER Table PortfolioProject.dbo.NashvileHousing
   Add OwnerSplitCity nvarchar(255)

-- Update OwnerSplitCity with the extracted City
   Update PortfolioProject.dbo.NashvileHousing
   SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

-- Add a new column OwnerSplitState to the table
    ALTER Table PortfolioProject.dbo.NashvileHousing
   Add OwnerSplitState nvarchar(255)

-- Update OwnerSplitState with the extracted State
   Update PortfolioProject.dbo.NashvileHousing
   SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)



/*Change Y AND N in "Sold as Vacant" to Yes and No */

-- Display distinct values of SoldAsVacant and their counts
Select distinct SoldAsVacant , Count(SoldAsVacant)
	     from PortfolioProject.dbo.NashvileHousing
		 group by SoldAsVacant
		 order by 2


-- Select SoldAsVacant with replacement of 'Y' and 'N' to 'YES' and 'NO'
Select SoldAsVacant,
 CASE  when SoldAsVacant ='Y' Then 'YES'
      when SoldAsVacant ='N' Then 'No'
       Else SoldAsVacant 
END
	     from PortfolioProject.dbo.NashvileHousing 
		 
-- Update the SoldAsVacant column with 'YES' and 'NO' replacements
	 Update PortfolioProject.dbo.NashvileHousing 
SET SoldAsVacant =
      CASE  when SoldAsVacant ='Y' Then 'YES'
      when SoldAsVacant ='N' Then 'No'
      Else SoldAsVacant 
      END

/*Remove Duplicates*/

WITH RowNumCTE as(
Select *, ROW_NUMBER() over (
PARTITION BY ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 Order by UniqueId
             )row_num
	     from PortfolioProject.dbo.NashvileHousing 
		 )
-- Delete duplicates by selecting only rows where the row number is greater than 1
		Delete
		 from RowNumCTE
		 where row_num >1 
		 

		 /*Delete unused Columns*/
		 Alter Table PortfolioProject.dbo.NashvileHousing 
		 Drop column OwnerAddress,TaxDistrict

		