

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AdminPromoPages_Discounts_GetPromoReferrerOverride]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AdminPromoPages_Discounts_GetPromoReferrerOverride]
go

create procedure dbo.AdminPromoPages_Discounts_GetPromoReferrerOverride
(
  @PromoID int
)
as
set nocount on
set transaction isolation level read uncommitted

-- get promo referer overide configuration.
select 
	restref.PromoReferrerId
	,restref.ReferrerID
	,ref.ReferrerName
	,restref.StartDT
	,restref.EndDT
from 
	ReferrerOverrideToRestRef restref
	
	inner join Referrer ref
	on restref.ReferrerID = ref.ReferrerID
where 
	restref.PromoID = @PromoId
order by
	restref.EndDT desc
	,restref.ReferrerID

go

grant execute on [AdminPromoPages_Discounts_GetPromoReferrerOverride] to ExecuteOnlyRole

go


