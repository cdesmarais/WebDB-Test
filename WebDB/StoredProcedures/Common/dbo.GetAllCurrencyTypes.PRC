if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetAllCurrencyTypes]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GetAllCurrencyTypes]
GO

CREATE PROCEDURE dbo.GetAllCurrencyTypes

AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	select CurrencyType, CurrencyDescription
	from CurrencyType

GO

GRANT EXECUTE ON [GetAllCurrencyTypes] TO ExecuteOnlyRole
GO
