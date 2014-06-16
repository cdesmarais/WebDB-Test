if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Promo_AddDineForCharity]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Promo_AddDineForCharity]
GO




CREATE PROCEDURE dbo.Admin_Promo_AddDineForCharity
(
  @RestID int
)
AS

INSERT INTO PromoDineForCharity (RID) VALUES (@RestID)




GO

GRANT EXECUTE ON [Admin_Promo_AddDineForCharity] TO ExecuteOnlyRole

GO
