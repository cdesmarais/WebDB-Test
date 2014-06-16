
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNUserGiveRegPoints]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNUserGiveRegPoints]
GO


CREATE PROCEDURE dbo.DNUserGiveRegPoints
(
    @UserID int,
    @IsCaller bit = 0
)
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

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


--*******************************
--** TODO: May consieder adding Metro Configuration of points
--** CODE belongs here
--*******************************


--*******************************
--** If we have regpoints then Add them
--*******************************
if @IsCaller = 0
BEGIN

	Insert into PromoUse (CustID,PromoID,Points,redeemDate,SiteID)
	VALUES (@UserID,@RegPromoID,@RegPoints,current_timestamp,1)
	
	update 	customer 
	set 	Points = Points + @RegPoints, 
		LastPointsGainDate = getdate()  
	where 	custid = @UserID
	

END
if @IsCaller = 1
BEGIN
	Insert into PromoUse (CallerID,PromoID,Points,redeemDate,SiteID)
	VALUES (@UserID,@RegPromoID,@RegPoints,current_timestamp,1)
	
	update 	Caller 
	set 	Points = Points + @RegPoints, 
		LastPointsGainDate = getdate() 
	where 	CallerID = @UserID
END

GO

GRANT EXECUTE ON [DNUserGiveRegPoints] TO ExecuteOnlyRole

GO
