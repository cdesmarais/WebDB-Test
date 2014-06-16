if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[User_AwardPoints]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[User_AwardPoints]
GO



CREATE Procedure dbo.User_AwardPoints
 (
  @UserID int,
  @Points int
 )
/*revised for new schema 8/5/2003 --JD*/
As
SET NOCOUNT ON
UPDATE Customer
SET Points= Points + @Points
WHERE (CustID = @UserID)
GO

GRANT EXECUTE ON [User_AwardPoints] TO ExecuteOnlyRole

GO
