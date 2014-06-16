if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Promo_RemoveDineForCharity]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Promo_RemoveDineForCharity]
GO




CREATE PROCEDURE dbo.Admin_Promo_RemoveDineForCharity
(
  @RestID int
)
AS

Delete from PromoDineForCharity where RID = @RestID




GO

GRANT EXECUTE ON [Admin_Promo_RemoveDineForCharity] TO ExecuteOnlyRole

GO
