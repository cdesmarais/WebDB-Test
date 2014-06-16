GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Promo_Wine_EmailCheck]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Promo_Wine_EmailCheck]
GO





CREATE PROCEDURE dbo.Promo_Wine_EmailCheck

(
@CustomerID int
)

AS
SET NOCOUNT ON
Select Count(IncrID)  as eligable from PromoEmailSent where CustID = @CustomerID


GO


GRANT EXECUTE ON [Promo_Wine_EmailCheck] TO ExecuteOnlyRole

GO
