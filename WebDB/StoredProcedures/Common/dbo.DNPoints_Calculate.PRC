if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNPoints_Calculate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNPoints_Calculate]
GO



CREATE PROCEDURE dbo.DNPoints_Calculate

@PromoID int,
@ResDateTime datetime,
@RestaurantID int,
@PartySize int,
@reservationID int = 0,
@Points int = 0 OUTPUT

AS
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
Set  @ResDateTime = cast(@ResDateTime as datetime)

Declare @IncentedPromo int,@IncentiveID int,@HotelID int,@isblocked int,@oldPoints int

Select @IncentedPromo = coalesce(DiningIncentive,0) from Promos where 
PromoID = @PromoID 
and Startdate <= cast(convert(nvarchar,cast(@ResDateTime as datetime),110) as datetime)
and Enddate >= cast(convert(nvarchar,cast(@ResDateTime as datetime),110) as datetime)
if @reservationID <> 0 and @IncentedPromo = 0
BEGIN
	select @IncentedPromo = coalesce(IncentiveID,0)  from Reservation where ResID = @reservationID
END
if @IncentedPromo <> 0
--Calculate Incented Points
BEGIN

	Select @IncentiveID = incentiveid from Reservation where ResID = @reservationID

	--******************
	--** Retrieve points: must honor origial reso or any incentive that matches the time criteria
	--******************
	select @Points = amount from Incentive where IncentiveID = @IncentiveID
	
	if (@Points is null)
	BEGIN
		declare @unusedOut int 
		exec procIncentiveLookup @RestaurantID, @ResDateTime, @unusedOut OUTPUT, @Points OUTPUT
	END
	
	if @Points is null
	BEGIN
		Set @Points = 100
	END
END
	

else
BEGIN
       SET @Points = coalesce(
	(Select Points from Promos 
	where PromoID = @PromoID and active = 1
	and Startdate <= cast(convert(nvarchar,cast(@ResDateTime as datetime),110) as datetime)
	and Enddate >= cast(convert(nvarchar,cast(@ResDateTime as datetime),110) as datetime)
	),100)

	Select @HotelID = coalesce(CompanyID,0) from Reservation where ResID = @reservationID

	Exec ConciergeHotelBlockedRestaurant @HotelID,@RestaurantID,@isblocked OUTPUT
	if @isblocked = 1
	BEGIN
		Set @points = 0
	END


END
GO


GRANT EXECUTE ON [DNPoints_Calculate] TO ExecuteOnlyRole

GO
