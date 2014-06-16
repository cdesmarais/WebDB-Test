if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[XML_ValidateUserCC]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[XML_ValidateUserCC]
GO

CREATE PROCEDURE dbo.XML_ValidateUserCC
(
  @UserID int
)
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

declare @count int
/*
select @count = count(CustID) From CreditCard Where CustID = @UserID
if @count <> 1
	    Begin
	    RAISERROR ('100',16,1)
	    Return(0)
	    End

select @count = count(CustID) From CreditCard Where CustID = @UserID And StatusID In(0,1,3)
if @count <> 1
	    Begin
	    RAISERROR ('101',16,1)
	    Return(1)
	    End

select @count = count(CustID) From CreditCard Where CustID = @UserID And datediff(m,getdate(),ExpDate) >= 0
if @count <> 1
	    Begin
	    RAISERROR ('102',16,1)
	    Return(2)
	    End

*/

GO


GRANT EXECUTE ON [XML_ValidateUserCC] TO ExecuteOnlyRole

GO
