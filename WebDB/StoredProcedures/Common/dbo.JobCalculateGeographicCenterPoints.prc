if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobCalculateGeographicCenterPoints]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobCalculateGeographicCenterPoints]
go


create  Procedure [dbo].[JobCalculateGeographicCenterPoints]
as

	-- procCalculateGeographicCenterPoints does the real work.  This stored proc is a wrapper 
	-- for the sql server job.  Raiserror is used whenever an error code is returned
	-- by the proc so that a nagios warning will be triggered.
	
	set nocount on
	set transaction isolation level read uncommitted 

	declare  @rc int
			,@error int
	
	exec @rc = procCalculateGeographicCenterPoints @SendEmailReport = 1
		
	select @error = @@error
	if @error != 0 
	begin
		raiserror('Center points not updated.  procCalculateGeographicCenterPoints raised an error',16,1) 
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
		raiserror('Center points not updated.  Encountered error updating metro center points',16,1) 
		return
	end
	else if @rc = -2
	begin
		raiserror('Center points not updated.  Encountered error updating macro center points',16,1) 
		return
	end
	else if @rc = -3
	begin
		raiserror('Center points not updated.  Encountered error updating neighborhood center points',16,1) 
		return
	end
	else if @rc = -4
	begin
		raiserror('Center points not updated.  Could not update null neighborhood center points',16,1) 
		return
	end
	else if @rc = -5
	begin
		raiserror('Center points not updated.  Could not update null macro center points',16,1) 
		return
	end
	else if @rc = -6
	begin
		raiserror('Center points not updated.  Could not update null metro lat/lon spans',16,1) 
		return
	end
	else if @rc = -7
	begin
		raiserror('Center points not updated.  Could not update null macro lat/lon spans',16,1) 
		return
	end
	else if @rc = -8
	begin
		raiserror('Center points not updated.  Could not update null neighborhood lat/lon spans',16,1) 
		return
	end
	else 
	begin
		raiserror('Center points not updated.  unknown error',16,1) 
		return
	end
	


go

grant execute on [JobCalculateGeographicCenterPoints] TO ExecuteOnlyRole
go
