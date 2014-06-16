if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RestaurantImporter_GetAllRestaurantPaymentTypes]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[RestaurantImporter_GetAllRestaurantPaymentTypes]
GO

CREATE Procedure dbo.RestaurantImporter_GetAllRestaurantPaymentTypes

As

SET NOCOUNT ON

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT	
	pts.rid
	,pts.PaymentTypeID as 'Payment_Type_ID'
	,pt.PaymentType as 'Value'
	,pt.LanguageID
FROM		PaymentTypes pts 
INNER JOIN	PaymentTypeAVW pt 
ON		pts.PaymentTypeID = pt.PaymentTypeID
AND		pts.PaymentTypeID <> 1
AND		pts.PaymentTypeID <> 8
inner join	RestaurantAVW r
on			pts.RID = r.RID
and			pt.LanguageID = r.LanguageID
	
GO

GRANT EXECUTE ON [dbo].[RestaurantImporter_GetAllRestaurantPaymentTypes] TO ExecuteOnlyRole

GO