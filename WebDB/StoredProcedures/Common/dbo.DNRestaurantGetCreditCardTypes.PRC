if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNRestaurantGetCreditCardTypes]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNRestaurantGetCreditCardTypes]
GO


CREATE PROCEDURE dbo.DNRestaurantGetCreditCardTypes
(@RID int
)
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

if exists (Select pts.PaymentTypeID from PaymentTypes pts 
		inner join PaymentTypeVW pt 
		on pts.PaymentTypeID = pt.PaymentTypeID
		where rid = @RID 
		and pts.PaymentTypeID <> 1
		and pts.PaymentTypeID <> 8) 
BEGIN
	select pts.PaymentTypeID as id
	,pt.PaymentType as name 
	from PaymentTypes pts 
	inner join PaymentTypeVW pt 
	on pts.PaymentTypeID = pt.PaymentTypeID
	where rid = @RID 
	and pts.PaymentTypeID <> 1
	and pts.PaymentTypeID <> 8
	order by pt.PaymentType
END
else
BEGIN
	select pt.PaymentTypeID as id
	,pt.PaymentType as name 
	from PaymentTypeVW pt 
	where PaymentTypeID in (2,3,4,6)
	order by pt.PaymentType
END

GO
GRANT EXECUTE ON [DNRestaurantGetCreditCardTypes] TO ExecuteOnlyRole

GO
