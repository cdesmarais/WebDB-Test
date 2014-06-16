if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CreditType_List_ByID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[CreditType_List_ByID]
GO

CREATE Procedure dbo.CreditType_List_ByID
(
	@CCTypeID int
)
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

SELECT	PaymentTypeID AS CreditCardTypeID
		,PaymentType AS CreditCardTypeName
FROM	PaymentTypeVW
where	PaymentTypeID = @CCTypeID

GO



GRANT EXECUTE ON [CreditType_List_ByID] TO ExecuteOnlyRole

GO
