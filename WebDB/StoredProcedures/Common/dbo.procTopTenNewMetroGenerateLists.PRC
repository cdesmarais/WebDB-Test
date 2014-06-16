if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[procTopTenNewMetroGenerateLists]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[procTopTenNewMetroGenerateLists]
GO


CREATE PROCEDURE [dbo].[procTopTenNewMetroGenerateLists] 
(
 @metroareaid	int,
 @dffstartdt	datetime
)
AS

--this proc should always be called from Admin_MetroAdd, so there is no need to create a seperate transaction

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

	declare	@return_value int
	exec @return_value = [dbo].[procAreTopTenListsGenerated] @metroareaid, null, null

	if(@return_value = 1) 
	begin
		raiserror('lists already exist for this metro area',17,1)
		return(1)
	end

	
--Check if this metro has a DFF Start Date defined
--If not, only generate 'Most Booked' and 'Most Booked 1000 Point' lists

	if(@dffstartdt = '' or @dffstartdt is null) 

		begin
		
			insert into 	@lists (toptenlisttypeid, listdisplayorder, metroareaid, mediastore_feedlistid, macroid, cuisineid, neighborhoodid)
			select 			toptenlisttypeid,defaultdisplayorder,@metroareaid, mediastore_feedlistid, null, cuisineid, null 
			from 			toptenlisttype
			where 			toptenlisttypeid in (1,2)
			order by 		defaultdisplayorder		
					
		end	
		
	else --If there is a DFF start date defined
		
		begin
		
			--Build all non-regional lists
			insert into @lists (toptenlisttypeid, listdisplayorder, metroareaid, mediastore_feedlistid, macroid, cuisineid, neighborhoodid)
			select toptenlisttypeid,defaultdisplayorder,@metroareaid, mediastore_feedlistid, null, cuisineid, null 
			from toptenlisttype
			where toptenlisttypeid != 22
			order by defaultdisplayorder
						
		end
		
		
		--Insert the contents of @lists table variable into the TopTenList table
		insert into toptenlist ( listnameoverride, toptenlisttypeid, listdisplayorder, metroareaid, mediastore_feedlistid, macroid, cuisineid, lastmodified, lastmodifiedby)
		select  listnameoverride, toptenlisttypeid, finaldisplayorder, metroareaid, mediastore_feedlistid, macroid, cuisineid, getdate(), 'init'
		from @lists
		order by finaldisplayorder
		
		insert into ottoptenschemaaudit (metroareaid, operationtypeid)
		values (@metroareaid, 1) --operationtypeid of '1' is 'create'
		
	return(0)
	
END


GO

GRANT EXECUTE ON [procTopTenNewMetroGenerateLists] TO ExecuteOnlyRole

GO

