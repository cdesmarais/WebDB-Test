if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CreditCard_ApproveList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[CreditCard_ApproveList]
GO



CREATE PROCEDURE dbo.CreditCard_ApproveList
 (
  @CreditCards nvarchar(4000)
 )
As

--*****************
--** TODO: EV: Drop this proc. Uses Dead Table CreditCard
--*****************
SET NOCOUNT ON
UPDATE CreditCard
SET StatusID= 3 -- approved
WHERE CHARINDEX(',' + CAST(CreditCardID AS nvarchar(16)) + ',',@CreditCards) > 0
GO

GRANT EXECUTE ON [CreditCard_ApproveList] TO ExecuteOnlyRole

GO
