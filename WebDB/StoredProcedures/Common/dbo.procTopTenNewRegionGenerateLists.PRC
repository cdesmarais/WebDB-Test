if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[procTopTenNewRegionGenerateLists]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[procTopTenNewRegionGenerateLists]
GO


create procedure [dbo].[procTopTenNewRegionGenerateLists] 
(
 @macroid	int
)
as

	declare @regionname nvarchar(100)
	declare @maxlistdisplayorder int
	declare @metroareaid int
	declare @regionallisttypeid int
	declare @dberror int

	--Get the ListTypeID for Regional lists
	set @RegionalListTypeID =  22		

	--get metroareaid for region		
	select	@metroareaid = MetroAreaID
	from	MacroNeighborhoodVW
	where	MacroID = @macroid
	
	--if DFF start date not set on metro, exit
	if(
		select	DFFStartDT from metroareavw
		where	metroareaid = @metroareaid
	) is null
	begin
		return(0)
	end
		
	
	--check for valid macro neighborhood id
	if @macroid not in (
		select 	distinct mn.MacroID
		from 	MacroNeighborhoodVW mn
		where 	mn.MacroID = @macroid
	)
		begin
		
			raiserror('Invalid MacroNeighborhood ID',17,1)
			return(1)
			
		end
			
		--Check that this region does not have any lists generated yet
		--If it does, raise an error and exit
		
		declare	@return_value int
		exec @return_value = [dbo].[procAreTopTenListsGenerated] null, @macroid, null

		if(@return_value = 1) --if lists exist in TopTenList for this macroneighborhood	
		begin
			RAISERROR('Lists already exist for this macroneighborhood type',17,1)
			return(1)
		end
					
		--get region name
		select 	@regionname = MacroName 
		from 	MacroNeighborhoodVW
		where 	MacroID = @macroid
		
		--get next available list display order for metro
		select 	@maxlistdisplayorder = max(ListDisplayOrder) + 1
		from 	TopTenList
		where 	MetroAreaID = @metroareaid
		
		begin transaction
	
				insert TopTenList (
				 [TopTenListTypeID] 
				,[ListDisplayOrder]
				,[ListNameOverride]
				,[MetroAreaID] 
				,[MediaStore_FeedListID]
				,[macroid]
				,[LastModified]
				,[LastModifiedBy]
			) 					
			SELECT distinct 
				ttlt.TopTenListTypeID
				,@maxlistdisplayorder
				,@regionname
				,@metroareaid
				,ttlt.MediaStore_FeedListID
				,@macroid
				,getdate()
				,'init'	
			from TopTenListType ttlt
			inner join MacroNeighborhoodVW mn on @metroareaid = mn.MetroAreaID
			where ttlt.TopTenListTypeID = @RegionalListTypeID
			and mn.metroareaid = @metroareaid
			and ttlt.TopTenListTypeID = @regionallisttypeid
				
			--write to audit log table
			INSERT INTO OTTopTenSchemaAudit (macroid, OperationTypeID)
			VALUES (@macroid, 1) --operationtypeid of '1' is 'add'
		
			set @DBError = @@error
			if @DBError <> 0
			goto general_error
		
		commit transaction
		return(0)

	general_error:
		rollback transaction	
		return(1)
			

GO

grant execute on [procTopTenNewRegionGenerateLists] TO ExecuteOnlyRole

GO
