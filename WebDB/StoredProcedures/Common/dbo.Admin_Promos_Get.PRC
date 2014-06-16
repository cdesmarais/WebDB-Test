if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Promos_Get]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Promos_Get]
GO

CREATE Procedure dbo.Admin_Promos_Get
 (
  @Promo_ID int = 0
 )
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

if @Promo_ID = 0
  Begin
 SELECT PromoID as Promo_ID
,code
,points
,PromosDesc as description
,active 
FROM Promos
order by active desc
,code
  End
if @Promo_ID <> 0
  Begin
    SELECT code,points,PromosDesc as description,popuptext as popup_text,Startdate as start_date,Enddate as end_date,active,Reusable,Coalesce(ConsumerTypeID,0)  as UserTypes,EmailMessage as Email_Message,DiningIncentive as Dining_Incentive
	FROM Promos
	left outer join PromoConsumerType on Promos.PromoID = PromoConsumerType.PromoID
	where Promos.PromoID = @Promo_ID
  End

GO

GRANT EXECUTE ON [Admin_Promos_Get] TO ExecuteOnlyRole

GO
