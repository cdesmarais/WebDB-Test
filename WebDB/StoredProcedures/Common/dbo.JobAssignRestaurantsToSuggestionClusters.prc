if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobAssignRestaurantsToSuggestionClusters]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobAssignRestaurantsToSuggestionClusters]
go


create  Procedure [dbo].[JobAssignRestaurantsToSuggestionClusters]
as
	
	set nocount on
	set transaction isolation level read uncommitted 

	declare  @rc int
			,@error int
	
	exec @rc = procClusterOutlierRestaurants
		
	select @error = @@error
	if @error != 0 
	begin
		raiserror('Outliers not updated, procClusterOutlierRestaurants raised an error',16,1) 
		return
	end
	
	-- NOTE: these return codes are defined
	if @rc = 0
	begin
		-- success, go ahead and exit
		return
	end
	else if @rc = -1
	begin
		raiserror('Outliers not updated.  Encountered error updating clusters',16,1) 
		return
	end
	else 
	begin
		raiserror('Outliers not updated..  unknown error',16,1) 
		return
	end
	


go

grant execute on [JobAssignRestaurantsToSuggestionClusters] TO ExecuteOnlyRole
go
