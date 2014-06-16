if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetCyberSourceCreditCardTypes]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GetCyberSourceCreditCardTypes]
GO


CREATE PROCEDURE dbo.GetCyberSourceCreditCardTypes
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT	PaymentTypeID, PaymentType, CyberSourceID, LanguageID
FROM	dbo.PaymentTypeVw 
WHERE	PaymentTypeID IN (2, 3, 4, 6) 
ORDER BY PaymentType
GO

GRANT EXECUTE ON [GetCyberSourceCreditCardTypes] TO ExecuteOnlyRole
GO
