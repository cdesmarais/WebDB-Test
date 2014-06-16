if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[User_Add_CheckPromo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[User_Add_CheckPromo]
GO

CREATE Procedure dbo.User_Add_CheckPromo
(
  @PromoCode nvarchar(300)
)
AS

if Not Exists(Select 1 from Promos where code = @PromoCode and active = 1)
  Begin
  Select retval = 1
  Return(1)
  End
if Not Exists(Select 1 From Promos Where code = @PromoCode And (datediff(d,Startdate,getdate()) >= 0 And datediff(d,Enddate,getdate()) < 0) And active = 1)
  Begin
  Select retval = 2
  Return(2)
  End

Select Points,PromoID As PromoID,retval = 0
From Promos
Where code = @PromoCode And (datediff(d,Startdate,getdate()) >= 0 And datediff(d,Enddate,getdate()) < 0) And active = 1 and PromoTypeID = 1
Return(0)
GO

GRANT EXECUTE ON [User_Add_CheckPromo] TO ExecuteOnlyRole

GO
