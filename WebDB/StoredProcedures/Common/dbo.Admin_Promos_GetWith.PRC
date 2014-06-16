if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Promos_GetWith]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Promos_GetWith]
GO




CREATE PROCEDURE dbo.Admin_Promos_GetWith
 (
  @Promo_ID int
 )
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT code,points,PromosDesc as description,popuptext as popup_text,Startdate as start_date,Enddate as end_date,active
FROM Promos
where PromoID = @Promo_ID
GO

GRANT EXECUTE ON [Admin_Promos_GetWith] TO ExecuteOnlyRole

GO
