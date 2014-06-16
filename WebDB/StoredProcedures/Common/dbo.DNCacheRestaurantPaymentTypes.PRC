if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheRestaurantPaymentTypes]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheRestaurantPaymentTypes]
GO


/*
This proc is used by OT_MgrCache/StoredProcTab.cs in ConsumerSite to fetch data for WebCache
*/
CREATE Procedure dbo.DNCacheRestaurantPaymentTypes

As

SET NOCOUNT ON

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


	SELECT	pts.rid
			,pts.PaymentTypeID as 'Payment_Type_ID'
			,pt.PaymentType as 'Value' 
	FROM		PaymentTypes pts 
	INNER JOIN	PaymentTypeVW pt 
	ON		pts.PaymentTypeID = pt.PaymentTypeID
	AND		pts.PaymentTypeID <> 1
	AND		pts.PaymentTypeID <> 8
	inner join	Restaurant r
	on			pts.RID = r.RID
	and			r.RestStateID != 4	--** Do not include inactive restaurnts
GO






GRANT EXECUTE ON [dbo].[DNCacheRestaurantPaymentTypes] TO ExecuteOnlyRole

GO
