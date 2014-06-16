if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_PaymentType_List]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_PaymentType_List]
GO

CREATE Procedure dbo.Admin_PaymentType_List
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT		PaymentTypeID AS PaymentTypeID
			,PaymentType as Value
FROM		PaymentTypeVW
ORDER BY	PaymentTypeID asc

GO

GRANT EXECUTE ON [Admin_PaymentType_List] TO ExecuteOnlyRole

GO
