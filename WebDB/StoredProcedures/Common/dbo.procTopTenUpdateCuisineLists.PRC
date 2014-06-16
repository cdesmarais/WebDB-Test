if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[procTopTenUpdateCuisineLists]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[procTopTenUpdateCuisineLists]
GO


create procedure [dbo].[procTopTenUpdateCuisineLists] 
(
 @cuisineid	int
)
as

	declare @metroname nvarchar(100)
	declare @tmpcuisineid int
	declare @listtypeid int
	declare @cuisinename nvarchar(100)
	declare @dberror int
	
	--Check if cuisineid is valid, if not exit
	select 		@tmpcuisineid = f.FoodTypeID 
	from 		FoodType f
	inner join	dbo.DBUserDistinctLanguageVW db 
	on			db.languageid = f.LanguageID
	where 		f.FoodTypeID = @cuisineid
	
	if(@tmpcuisineid is null)
	begin
		raiserror('Invalid FoodTypeID',17,1)
		return(1)
	end

	--Check that this Cuisine has lists generated 
	--If it does not, raise an error and exit
	declare	@return_value int
	exec @return_value = [dbo].[procAreTopTenListsGenerated] null, null, @cuisineid

	if(@return_value = 0) --if no lists exist in TopTenList for this cuisine
	begin
		raiserror('No lists exist for this food type',17,1)
		return(1)
	end

	--check that there is a record in TopTenListType for this cuisine
	SELECT @listtypeid = toptenlisttypeid FROM TopTenListType WHERE CuisineID = @cuisineid
	
	if(@listtypeid is null) --if no lists exist in TopTenListType for this cuisine
	begin
		raiserror('No list type exists for this food type',17,1)
		return(1)
	end
	
	--get cuisine names
	select 		@cuisinename = f.foodtype 
	from 		FoodType f
	inner join	dbo.DBUserDistinctLanguageVW db 
	on			db.languageid = f.LanguageID
	where 		FoodTypeID = @cuisineid
	

	begin transaction
	
		--update list name in TopTenListType
		update	toptenlisttype
		set 	listname = @cuisinename
		where	toptenlisttypeid = @listtypeid
				
		set @DBError = @@error
		if @DBError <> 0
		goto general_error
		
		--write to audit log table
		INSERT INTO OTTopTenSchemaAudit (cuisineid, OperationTypeID)
		VALUES (@cuisineid, 2)
			
		set @DBError = @@error
		if @DBError <> 0
		goto general_error
	
	commit transaction
	return(0)

general_error:
	rollback transaction	
	return(1)
	
GO

grant execute on [proctoptenupdatecuisinelists] to executeonlyrole

GO

