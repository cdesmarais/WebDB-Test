if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNClearRestsForPromo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNClearRestsForPromo]
GO




CREATE PROCEDURE dbo.DNClearRestsForPromo
(
	@PromoID int	
)
  
As

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


DELETE PromoRests
WHERE PromoID = @PromoID



GO

GRANT EXECUTE ON [DNClearRestsForPromo] TO ExecuteOnlyRole

GO
