if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_CacheAllPaymentTypes]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_CacheAllPaymentTypes]
GO

CREATE procedure [dbo].[Admin_CacheAllPaymentTypes] 
AS
SET NOCOUNT ON

SELECT	PaymentTypeID,
	PaymentType, 
	LanguageID
FROM	PaymentTypeAVW
Order by PaymentTypeID


GO

GRANT EXECUTE ON [Admin_CacheAllPaymentTypes] TO ExecuteOnlyRole
GO