if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Promos_Pages_Activate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Promos_Pages_Activate]
GO




CREATE PROCEDURE dbo.Admin_Promos_Pages_Activate
(
  @PromoID int,
  @Active int
)
As
SET NOCOUNT ON

Update PromoPages set Active = @Active where PromoID = @PromoID




GO

GRANT EXECUTE ON [Admin_Promos_Pages_Activate] TO ExecuteOnlyRole

GO
