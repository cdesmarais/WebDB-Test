if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Gift_GetDetails]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Gift_GetDetails]
GO

CREATE Procedure dbo.Gift_GetDetails
 (
  @GiftID int,
  @UserID int,
  @IsCaller int = 0
 )
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

if(@IsCaller = 0)
BEGIN
SELECT Customer.FName + ' ' + Customer.LName As CustomerName,
     Customer.Email as CustomerEmail,
     g.GiftName As GiftName,
     g.Notes as GiftNotes
FROM Customer,GiftVW g
WHERE (g.GiftID = @GiftID) AND 
    (Customer.CustID = @UserID)
END

if(@IsCaller <> 0)
BEGIN
SELECT Caller.FName + ' ' + Caller.LName As CustomerName,
     Caller.Email as CustomerEmail,
     g.GiftName As GiftName,
     g.Notes as GiftNotes
FROM Caller,GiftVW g
WHERE (g.GiftID = @GiftID) AND 
    (Caller.CallerID = @UserID)
END

GO

GRANT EXECUTE ON [Gift_GetDetails] TO ExecuteOnlyRole

GO
