if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CreditType_List]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[CreditType_List]
GO



/****** Object:  Stored Procedure dbo.CreditType_List    Script Date: 2/7/2000 3:55:28 PM ******/
CREATE PROCEDURE dbo.CreditType_List
As
SET NOCOUNT ON
SELECT CreditTypeID AS CreditCardTypeID,
    CreditTypeName AS CreditCardTypeName
FROM CreditType
ORDER BY CreditTypeName
GO

GRANT EXECUTE ON [CreditType_List] TO ExecuteOnlyRole

GO
