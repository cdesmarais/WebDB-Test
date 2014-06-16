if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CreditCard_DenyList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[CreditCard_DenyList]
GO



CREATE PROCEDURE dbo.CreditCard_DenyList
 (
  @CreditCards nvarchar(4000)
 )
As

--*****************
--** TODO: EV: Drop this proc. Uses Dead Table CreditCard
--*****************
SET NOCOUNT ON
UPDATE CreditCard
SET StatusID= 2 -- denied
WHERE CHARINDEX(',' + CAST(CreditCardID AS nvarchar(16)) + ',',@CreditCards) > 0
GO

GRANT EXECUTE ON [CreditCard_DenyList] TO ExecuteOnlyRole

GO
