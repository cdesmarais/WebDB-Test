if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[procTopTenNewCuisineGenerateLists]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[procTopTenNewCuisineGenerateLists]
GO



CREATE PROCEDURE [dbo].[procTopTenNewCuisineGenerateLists] 
(
 @cuisineid	int
)
as

	set nocount on

	declare @cuisinename nvarchar(100)
	declare @toptenlisttypeid int
	declare @listdisplayorder int
	declare @mediastorefeedlistid int
	declare @metroareaid int
	declare @DBError int
	
	--if this is a macro cuisine, add toptenlisttype and toptenlist records
	if @cuisineid in (
		select 		distinct f.FoodTypeID
		from 		FoodType f
		inner join	dbo.DBUserDistinctLanguageVW db
		on			db.languageid = f.LanguageID
		where 		f.FoodTypeID = @cuisineid
		and			f.sftid = @cuisineid
	)
	begin

		--Check that this Cuisine does not have any lists generated yet, or a TopTenListType record
		--If it does, raise an error and exit
		
		declare	@return_value int
		exec @return_value = [dbo].[procAreTopTenListsGenerated] null, null, @cuisineid

		if(@return_value = 1) --if lists exist in TopTenList for this cuisine	
		begin
			raiserror('Lists already exist for this cuisine type',17,1)
			return(1)
		end
		
		--check toptenlisttype table
		if(select count(*) from toptenlisttype where cuisineid = @cuisineid) > 0
		begin
			raiserror('ListType already exists for this cuisine',17,1)
			return(1)
		end		

		--get cuisine name
		select @cuisinename = f.FoodType 
		from 		[dbo].[FoodType] f
		inner join	dbo.DBUserDistinctLanguageVW db
		on			db.languageid = f.LanguageID
		where 		f.FoodTypeID = @cuisineid

		select @ListDisplayOrder = (MAX(DefaultDisplayOrder) + 1) from TopTenListType 

		--insert the new cuisine row into TopTenListType
		insert into TopTenListType (ListName, ListDisplayOrderNationalOverride, TopTenListTypeClassID, CuisineID,DefaultDisplayOrder, MediaStore_FeedListID)
		values (@cuisinename,0,2,@cuisineid,@ListDisplayOrder,20)

		select @toptenlisttypeid = scope_identity()
		
		select @mediastorefeedlistid = mediastore_feedlistid FROM toptenlisttype
		where toptenlisttypeid = @toptenlisttypeid

		SELECT @metroareaid = MIN(metroareaid) from toptenlist
		
		while(@metroareaid <= (SELECT MAX(metroareaid) from toptenlist))
		begin		
		
		if exists(select metroareaid from toptenlist where metroareaid = @metroareaid)
			begin			
			
			select @listdisplayorder = MAX(listdisplayorder)+1 from TopTenList where metroareaid = @metroareaid 
			
				--Add rows to TopTenList table for every participating MetroArea 
				insert [dbo].[TopTenList] (
						 [TopTenListTypeID] 
						,[ListDisplayOrder] 
						,[MetroAreaID] 
						,[MediaStore_FeedListID]
						,[CuisineID]
					) 
				select 		distinct @toptenlisttypeid, @listdisplayorder, mav.metroareaid,@mediastorefeedlistid,@cuisineid
				from 		metroareavw mav
				where 		dffstartdt is not null 
				and			mav.metroareaid = @metroareaid
				order by 	metroareaid
								
			end
			
		set @metroareaid = @metroareaid +1
		
		end
		
		
		--write to audit log table
		INSERT INTO OTTopTenSchemaAudit (CuisineID, OperationTypeID)
		VALUES (@cuisineid, 1) --operationtypeid of '1' is 'create'


	end

	else
		raiserror('Invalid cuisine ID',17,1)
		return(1)

go

grant execute on [proctoptennewcuisinegeneratelists] to executeonlyrole

go
