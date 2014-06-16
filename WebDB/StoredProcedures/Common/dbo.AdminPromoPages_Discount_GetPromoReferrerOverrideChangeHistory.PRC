

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AdminPromoPages_Discount_GetPromoReferrerOverrideChangeHistory]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AdminPromoPages_Discount_GetPromoReferrerOverrideChangeHistory]
go

create procedure dbo.AdminPromoPages_Discount_GetPromoReferrerOverrideChangeHistory
(
  @PromoReferrerId int
)
as
set nocount on
set transaction isolation level read uncommitted

select 
	ModifyDTUTC
	,SubmittedBy
	,StartDTUTC
	,ExpDTUTC
from 
	PromoReferrerChangeLog 
where 
	PromoReferrerId = @PromoReferrerId
order by
	ModifyDTUTC desc

go

grant execute on [AdminPromoPages_Discount_GetPromoReferrerOverrideChangeHistory] to ExecuteOnlyRole

go



