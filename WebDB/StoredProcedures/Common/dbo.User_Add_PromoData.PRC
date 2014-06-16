if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[User_Add_PromoData]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[User_Add_PromoData]
GO


CREATE Procedure dbo.User_Add_PromoData
(
  @CustomerID int=0,
  @CallerID int=0,
  @Points int,
  @PromoID int,
  @SiteID int
)
AS
/*checked for new schema 8/4/2003 --JD*/
SET NOCOUNT ON
-- 1/6/2005 CK - Only award points to customers that are not Anonymous

Declare @RegPromoId int
Declare @RegPoints int
set @RegPromoId = 1

select @RegPoints = ValueInt
	from valuelookup 
	where	LType = 'WEBSERVER'
		and Lkey = 'RegistrationPoints'

--*******************************
--** If Reg Point disabled do nothing
--*******************************
if (IsNull(@RegPoints, 0) <= 0)
	return


if not exists(Select CustID from Customer where custid = @CustomerID and ConsumerType = 8)
BEGIN
	if @CallerID = 0
	Begin
		Insert Into PromoUse(CustID,PromoID,points,SiteID)
		Values(@CustomerID,@PromoID,@points,@SiteID)
		IF @@ERROR <> 0
			Return(1)
	End
	
	If @CallerID > 0
	Begin
		Insert Into PromoUse(CallerID,PromoID,points,SiteID)
		Values(@CallerID,@PromoID,@points,@SiteID)
		IF @@ERROR <> 0
			Return(1)
	End

END

Return(0)

GO

GRANT EXECUTE ON [User_Add_PromoData] TO ExecuteOnlyRole

GO
