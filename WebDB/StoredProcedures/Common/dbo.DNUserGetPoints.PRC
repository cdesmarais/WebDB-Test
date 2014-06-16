if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNUserGetPoints]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNUserGetPoints]
GO


CREATE PROCEDURE dbo.DNUserGetPoints
(
    @UserID int,
    @IsCaller bit = 0
)
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

/*created 10/23/2003*/

if @IsCaller = 0
	select Points from Customer where CustID = @UserID
if @IsCaller = 1
	select Points from Caller where CallerID = @UserID
GO

GRANT EXECUTE ON [DNUserGetPoints] TO ExecuteOnlyRole

GO
