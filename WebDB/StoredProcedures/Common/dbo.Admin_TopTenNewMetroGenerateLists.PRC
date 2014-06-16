if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_TopTenNewMetroGenerateLists]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_TopTenNewMetroGenerateLists]
GO


CREATE PROCEDURE [dbo].[Admin_TopTenNewMetroGenerateLists] 
(
 @metroareaid	int
)
AS


DECLARE @RegionalListTypeID int

 --Check if MetroAreaID is valid, if not exit
DECLARE @tmpMetroID int
SELECT @tmpMetroID = MetroAreaID FROM MetroAreaVW WHERE MetroAreaID = @metroareaid
if(@tmpMetroID IS NOT NULL)
BEGIN

	declare @lists table (
	TopTenListTypeID int not null,
	FinalDisplayOrder int identity not null,
	ListDisplayOrder int not null,
	ListNameOverride nvarchar(100),
	MetroAreaID int not null,
	MediaStore_FeedListID int null,
	MacroID int null,
	CuisineID int null,
	NeighborhoodID int null
	)

--Check that this MetroArea does not have any lists generated yet
--If it does, raise an error and exit
	if(SELECT COUNT(*) FROM TopTenList WHERE MetroAreaID = @metroareaid) > 0
	BEGIN
		RAISERROR('Lists already exist for this metro area',17,1)
		RETURN
	END

	--Build all non-regional lists
	INSERT INTO @lists (TopTenListTypeID, ListDisplayOrder, MetroAreaID, MediaStore_FeedListID, MacroID, CuisineID, NeighborhoodID)
	SELECT TopTenListTypeID,DefaultDisplayOrder,@MetroAreaID, MediaStore_FeedListID, NULL, CuisineID, NULL 
	FROM TopTenListType
	WHERE TopTenListTypeID != 2
	ORDER BY DefaultDisplayOrder

	--Now build regional lists
	declare @TopRankRegion int, @SortOrd int

	--Get the ListTypeID for Regional lists
	SELECT @RegionalListTypeID =  TopTenListTypeID
	FROM TopTenListType
	WHERE ListName = 'Regional'
	
	select top 1 @TopRankRegion = mn.MacroID
	from metroarea ma
	inner join MacroNeighborhoodVW mn
	on ma.metroareaid = mn.metroareaid
	where ma.metroareaid = @MetroAreaID
	and mn.active = 1
	order by coalesce(sortorder,2)

	if((@TopRankRegion IS NOT NULL)  AND  (@TopRankRegion > 0)) --if this metro has regions
		BEGIN
			--Populate the Rank 1 region
			UPDATE @lists 
			SET ListDisplayOrder = 6,
			ListNameOverride = mn.MacroName,
			MacroID = mn.MacroID
			FROM @lists l
			INNER JOIN TopTenListType ttlt ON l.TopTenListTypeID = ttlt.TopTenListTypeID
			INNER JOIN MacroNeighborhoodVW mn ON l.MetroAreaID = mn.MetroAreaID
			WHERE l.TopTenListTypeID = @RegionalListTypeID
			AND l.MetroAreaID = @MetroAreaID
			AND mn.MacroID = @TopRankRegion

			--Populate the rest of the regions
			INSERT INTO @lists (TopTenListTypeID, ListDisplayOrder, ListNameOverride, MetroAreaID, MediaStore_FeedListID, MacroID, CuisineID, NeighborhoodID)
			select @RegionalListTypeID, 0, MacroName, @MetroAreaID, ttlt.MediaStore_FeedListID, MacroID, NULL, NULL 
			from MacroNeighborhoodVW mn
			INNER JOIN TopTenListType ttlt ON @RegionalListTypeID = ttlt.TopTenListTypeID
			where metroAreaid = @MetroAreaID and Active = 1 and MacroID != @TopRankRegion
		END

	--Add the Most Booked 1,000 Point Tables List last
	INSERT INTO @lists (TopTenListTypeID, ListDisplayOrder, MetroAreaID, MediaStore_FeedListID, MacroID, CuisineID, NeighborhoodID)
	SELECT TopTenListTypeID,DefaultDisplayOrder,@MetroAreaID, MediaStore_FeedListID, NULL, CuisineID, NULL 
	FROM TopTenListType
	WHERE TopTenListTypeID = 2	
	
	--Insert the contents of @lists table variable into the TopTenList table
	INSERT INTO TopTenList ( ListNameOverride, TopTenListTypeID, ListDisplayOrder, MetroAreaID, MediaStore_FeedListID, MacroID, CuisineID, LastModified, LastModifiedBy)
	SELECT  ListNameOverride, TopTenListTypeID, FinalDisplayOrder, MetroAreaID, MediaStore_FeedListID, MacroID, CuisineID, GETDATE(), 'init'
	FROM @lists
	ORDER BY FinalDisplayOrder

END


GO

GRANT EXECUTE ON [Admin_TopTenNewMetroGenerateLists] TO ExecuteOnlyRole

GO

