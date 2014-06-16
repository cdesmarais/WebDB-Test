if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[XML_Restaurant_CheckAvailability]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[XML_Restaurant_CheckAvailability]
GO

CREATE PROCEDURE dbo.XML_Restaurant_CheckAvailability
(
@RestaurantID int
)

 AS

SET NOCOUNT ON
set transaction isolation level read uncommitted

declare @isreachable int
select @isreachable = IsReachable from Restaurant where RID = @RestaurantID

if @isreachable <> 1
	RaisError ('99',16,1)



GO

GRANT EXECUTE ON [XML_Restaurant_CheckAvailability] TO ExecuteOnlyRole

GO
