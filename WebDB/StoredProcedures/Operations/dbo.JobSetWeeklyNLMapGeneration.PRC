if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobSetWeeklyNLMapGeneration]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobSetWeeklyNLMapGeneration]
go

-------------------------------------------------------------------------------
---   If map file generation is not scheduled in the future, then sets to next Sunday 12:00 AM 
-------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[JobSetWeeklyNLMapGeneration]
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	declare @genDate  datetime, @currentDate datetime, @nextGenDate datetime
	
	--- get set generation date 
	select @genDate = ValueDT
	from dbo.ValueLookup
	where 	LType='ISAPIWEB' and  LKey='NLMapFileGenerationDate'
	
	set @currentDate = getdate()
	
	-- if genDate is in future then do nothing and return
	if (@gendate is not null AND @gendate > dateadd(hh, -3, @currentDate))
		return
		
	if (7 = datepart(dw, @currentDate-1)) -- if already Sunday, then set to next Sunday
		set @currentDate  = @currentDate + 7
		
	set @nextGenDate  = CONVERT(char(10), (@currentDate+(7-datepart(dw, @currentDate-1))), 110) 
	
	if (@gendate is null)
	begin
		insert into dbo.ValueLookup ( LType, LKey, ValueDT)
		values ('ISAPIWEB', 'NLMapFileGenerationDate', @nextGenDate) 
	end
	else begin
		update dbo.ValueLookup
		set ValueDT = @nextGenDate   
		where 	LType='ISAPIWEB' and  LKey='NLMapFileGenerationDate'
	end
GO

GRANT EXECUTE ON [JobSetWeeklyNLMapGeneration] TO ExecuteOnlyRole
GO


