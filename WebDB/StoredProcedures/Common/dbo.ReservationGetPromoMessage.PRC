
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ReservationGetPromoMessage]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ReservationGetPromoMessage]
GO



CREATE Procedure dbo.ReservationGetPromoMessage
(
@RID int,
@ResDateTime datetime,
@PromoMessage nvarchar(999) OUTPUT
)
AS
SET NOCOUNT ON


Declare @QualifyRID int, @ExclusionDateID int
Declare @Qualify nvarchar(999), @NonQualify nvarchar(999)

declare @theResoDatePart datetime
set @theResoDatePart = CAST(ROUND(CAST(@ResDateTime AS float), 0, 1) AS datetime)


--Set @RID = 3533
--Set @ResDateTime = '5/23/2005 7:00 PM'

Select top 1 @Qualify = coalesce(QualifyConfMessage,''), 
@NonQualify = coalesce(NonQualifyConfMessage,''),
@QualifyRID = coalesce((Select RID from PromoRests where Rid = @RID and PromoID = pptr.promoID and 
(
(Lunch = 1 and convert(nvarchar(12),@ResDateTime,114) < '16:00:00.000') or
(Dinner = 1 and convert(nvarchar(12),@ResDateTime,114) >= '16:00:00.000')
)
),0),
@ExclusionDateID = coalesce((Select PromoPageExclusions.PromoID from PromoPageExclusions 
where pptr.PromoID = PromoPageExclusions.PromoID and datediff(dd,@ResDateTime,ExclusionDate) = 0),'0')
from PromoPagesToRegion pptr
inner join PromoPages on pptr.promoID = PromoPages.promoID
where 
@theResoDatePart >= EventStartDate and @theResoDatePart <= EventEndDate
and (coalesce(QualifyConfMessage,'') != '' or coalesce(NonQualifyConfMessage,'') != '')
and regionID = 
(Select top 1 MacroID from 
restaurant 
inner join Neighborhood on restaurant.neighborhoodID = Neighborhood.neighborhoodID
where rid = @RID) and active = 1


if @QualifyRID != 0 and @Qualify != ''
BEGIN
	Set @PromoMessage = @Qualify
END

if @ExclusionDateID != 0 or (@QualifyRID = 0 and @NonQualify != '')
BEGIN
	Set @PromoMessage = @NonQualify
END

if @PromoMessage is null
BEGIN
	Set @PromoMessage = ''
END



GO

GRANT EXECUTE ON [ReservationGetPromoMessage] TO ExecuteOnlyRole

GO
