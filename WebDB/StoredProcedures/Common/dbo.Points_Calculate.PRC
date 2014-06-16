if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Points_Calculate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Points_Calculate]
GO





CREATE PROCEDURE dbo.Points_Calculate

@PromoID int,
@ResDateTime datetime,
@RestaurantID int,
@PartySize int,
@resID int = 0,
@Points int = 0 OUTPUT

AS
	Declare @IncentedPromo int, @IncentiveID int, @HotelID int, @isblocked int

	--*****************
	--** Check if points are allowed
	--*****************
	Select @HotelID = coalesce(CompanyID,0) from Reservation where resID = @resID

	Exec ConciergeHotelBlockedRestaurant @HotelID, @RestaurantID, @isblocked OUTPUT
	if @isblocked = 1
	BEGIN
		Set @points = 0
		return
	END


Set  @ResDateTime = cast(@ResDateTime as datetime)
Select @IncentedPromo = coalesce(DiningIncentive,0) from Promos where PromoID = @PromoID


if @IncentedPromo = 1
--Calculate Incented Points
BEGIN


	Select @IncentiveID = IncentiveID from reservation where resID = @resID
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
	else
	BEGIN
		if exists(Select HolidayID 
					from HolidaySchedule 
					where HolidayDate = cast(convert(nvarchar, cast(@ResDateTime as datetime), 110) as datetime) 
					and
					SuppressDIP = 1)
		BEGIN
			Set @Points = 100
		END
	END
END
	

else
BEGIN
       SET @Points = coalesce(
	(Select Points from Promos 
	where PromoID = @PromoID and active = 1
	and startdate <= cast(convert(nvarchar, cast(@ResDateTime as datetime), 110) as datetime)
	and enddate >= cast(convert(nvarchar, cast(@ResDateTime as datetime), 110) as datetime)
	),100)


END

-- akash: conceirge DIP supression change,if its a 1000 points check to see if we should suppress it
if @Points = 1000 
	BEGIN
		declare @SupDip int
		--set @SupDip = dbo.Concierge_SupressDIP(@RestaurantID,@ResDateTime)
		-- AKASH NOTE: Had to call identical stored proc with output param, calling the original 
		-- proc was failing when called from the website, very puzzling, we spent a lot of time to try to figure 
		-- out what it was, but couldnt find any leads. So reluctantly I am creating a copy of 
		-- Concierge_SuppressDIP as Concierge_SuppressDIP_Wrapper, which is identical except that it has an output param
		EXEC Concierge_SuppressDIP_Wrapper @RestaurantID,@ResDateTime,@SupDip OUTPUT

		if @SupDip = 1 
		BEGIN
			set @Points = 100
		END 
	END

go


GRANT EXECUTE ON [Points_Calculate] TO ExecuteOnlyRole

GO
