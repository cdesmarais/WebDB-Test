if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[XML_User_GetCreditCardID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[XML_User_GetCreditCardID]
GO

CREATE PROCEDURE dbo.XML_User_GetCreditCardID 
(@userID int
,@retVal int OUTPUT
)
AS

SET NOCOUNT ON
set transaction isolation level read uncommitted

select @retVal = CreditCardID 
from CreditCard 
where CustID = @userID

GO


GRANT EXECUTE ON [XML_User_GetCreditCardID] TO ExecuteOnlyRole

GO
