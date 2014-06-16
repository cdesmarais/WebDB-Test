if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[procIncentiveLookup]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[procIncentiveLookup]
GO


CREATE PROCEDURE dbo.procIncentiveLookup

@RestaurantID int,
@ResDateTime datetime,
@IncentiveID int = NULL OUTPUT,
@Points int = NULL OUTPUT

AS

	Select @IncentiveID = IncentiveID,
			@Points = amount
	From IncentiveVW
	Where	active = 1
			and LastMinutePopThresholdTime IS NULL
			and IncentiveDay = datepart(dw,@ResDateTime) 
			and dbo.fGetDatePart(@ResDateTime) between Startdate and EndDate
			and StartTime <= dbo.fGetTimePart(@ResDateTime)
			and EndTime > dbo.fGetTimePart(@ResDateTime) --** End Time is not inclusive
			and RID=@RestaurantID

			
GO

GRANT EXECUTE ON [procIncentiveLookup] TO ExecuteOnlyRole

GO
