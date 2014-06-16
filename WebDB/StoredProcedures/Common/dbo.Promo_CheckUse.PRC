if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Promo_CheckUse]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Promo_CheckUse]
GO






CREATE PROCEDURE dbo.Promo_CheckUse

@PromoID int,
@CustomerID int,
@CallerID int,
@resoDate datetime

AS

Declare @reusable int,@ValidUser int


if @PromoID = 0
BEGIN
	Select '0' as redeem_date
END
else
BEGIN
	
	Select @reusable = Reusable from Promos where Promos.PromoID = @PromoID
	if @reusable <> 1
	BEGIN
		Select RedeemDate as redeem_date from PromoUse
		inner join Promos on PromoUse.PromoID = Promos.PromoID
		where CustID = @CustomerID and PromoUse.PromoID = @PromoID
		and @resoDate >= Promos.Startdate and @resoDate <= Promos.Enddate
	END
	
	else
	BEGIN
		if @CallerID > 0
		BEGIN
			if not exists(Select Promos.PromoID from Promos
			inner join PromoConsumerType on Promos.PromoID = PromoConsumerType.PromoID
			inner join Caller on PromoConsumerType.ConsumerTypeID = Caller.ConsumerType
			where Promos.PromoID = @PromoID and Caller.CallerID = @CallerID
			and @resoDate >= Promos.Startdate and @resoDate <= Promos.Enddate )
			BEGIN
				Select '1/1/1900' as redeem_date
			END
			else
			BEGIN
				Select '0' as redeem_date
			END
		END
		else
		BEGIN
			if not exists(Select Promos.PromoID from Promos
			inner join PromoConsumerType on Promos.PromoID = PromoConsumerType.PromoID
			inner join Customer on PromoConsumerType.ConsumerTypeID = Customer.ConsumerType
			where Promos.PromoID = @PromoID and Customer.CustID = @CustomerID
			and @resoDate >= Promos.Startdate and @resoDate <= Promos.Enddate )
			BEGIN
				Select '1/1/1900' as redeem_date
			END
			else
			BEGIN
				Select '0' as redeem_date
			END
		END
		
	END
END
GO

GRANT EXECUTE ON [Promo_CheckUse] TO ExecuteOnlyRole

GO
