if exists (select * from dbo.sysobjects where ID = object_id(N'[dbo].[SvcEmailGetDiningFeedback2]') and OBJECTPROPERTY(ID, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[SvcEmailGetDiningFeedback2]
GO

-- Get list of cusotmers that fit the dining feedback form Email
CREATE PROCEDURE [dbo].[SvcEmailGetDiningFeedback2]
(
	 @nStartHour	int
	 ,@nEndHour		int
)
AS

		set nocount on
		set transaction isolation level read uncommitted 
	
		declare @dToday datetime -- only contains the date - not time!
				,@error int

		set @dToday = dbo.fGetDatePart(getdate())
	
		--***********************
		-- Init Start / End Date condition
		--***********************
		declare	 @StartDT		datetime
				,@EndDT			datetime
				,@EmailGapHours	int
	
		set @StartDT		= @dToday - 7
		set @EndDT		= @dToday + 1
		-- Set: elapsed gap has closed; reso must have been seated 24 hours ago; EmailSendGap
		set @EmailGapHours	= 24

		--- This procedure is devided into two procedures, so we can pass @StartDT, @EndDT as parameters to do partition elimimation and improve the performance.

		EXEC procEmailGetDiningFeedback2 @StartDT, @EndDT, @EmailGapHours, @nStartHour, @nEndHour 

GO


GRANT EXECUTE ON [SvcEmailGetDiningFeedback2] TO ExecuteOnlyRole
GO