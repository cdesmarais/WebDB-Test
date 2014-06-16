if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Points_Verify]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Points_Verify]
GO



CREATE PROCEDURE dbo.Points_Verify

@ResDateTime datetime,
@RestaurantID int,
@Points int = 0 OUTPUT

AS


declare @temp int

declare @unusedOut int 
exec procIncentiveLookup @RestaurantID, @ResDateTime, @unusedOut OUTPUT, @temp OUTPUT

if @temp is not null
	set @points = ('1000') -- * @PartySize) 
else
	set @points = '100' -- min point value for a reso ... until business rule changes
GO

GRANT EXECUTE ON [Points_Verify] TO ExecuteOnlyRole

GO
