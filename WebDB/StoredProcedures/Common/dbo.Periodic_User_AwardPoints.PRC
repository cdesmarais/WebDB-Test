GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Periodic_User_AwardPoints]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Periodic_User_AwardPoints]
GO






Create Procedure dbo.Periodic_User_AwardPoints
 (
  @UserID int,
  @Points int
 )
As
SET NOCOUNT ON
UPDATE Customer
SET Points= Points + @Points
WHERE (CustID = @UserID)





GO

GRANT EXECUTE ON [Periodic_User_AwardPoints] TO ExecuteOnlyRole

GO
