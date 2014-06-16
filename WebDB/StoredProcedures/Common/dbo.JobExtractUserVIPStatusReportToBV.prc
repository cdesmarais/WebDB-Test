if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobExtractUserVIPStatusReportToBV]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobExtractUserVIPStatusReportToBV]
go


create  Procedure [dbo].[JobExtractUserVIPStatusReportToBV]
as

	-- procExtractUserVIPStatusReportToBV does the real work.  This stored proc is a wrapper 
	-- for the sql server job.  Raiserror is used whenever an error code is returned
	-- by the proc so that a nagios warning will be triggered.
	
	set nocount on
	set transaction isolation level read uncommitted 

	declare  @rc int
			,@error int
	
	exec @rc = procExtractUserVIPStatusReportToBV
		
	select @error = @@error

	if @error != 0 
	begin
		raiserror('Error generating User VIP Status Report.  procExtractUserVIPStatusReportToBV raised an error',16,1) 
		return
	end
	
	if @rc = 0
		begin
			-- success, go ahead and exit
			return
		end
	else 
		begin
			raiserror('Error generating User VIP Status Report.  unknown error',16,1) 
			return
		end
	


go

grant execute on [JobExtractUserVIPStatusReportToBV] TO ExecuteOnlyRole
go
