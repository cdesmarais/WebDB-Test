if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_UpdatePartnerOfferStatusByRestID11]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_UpdatePartnerOfferStatusByRestID11]
GO

create procedure [dbo].[Admin_UpdatePartnerOfferStatusByRestID11]
(
	@RestaurantID int,
	@AcceptFlower bit,
	@AcceptGift bit,
	@MarketingEmailOpted bit,
	@RestrictedByRestBlockedList bit,	
	@PrivateDineEmailOptOut bit,	
	@CHARMUserID nvarchar(100),
	@SuppressedLimo BIT,
	@SuppressedAMEX BIT,
	@AdWordsID NVARCHAR(100),
	@AdWordsValue NVARCHAR(100),
	@EnabledParking BIT,
	@ShowPOPAsLastOffer BIT,
	@EnabledFoodSpotting BIT,
	@EnabledVVOffers BIT,
	@EnableFaceBookLikeBox bit,
	@OfferClassID int, 
	@RestaurantOfferID int,
	@ShowThirdPartyMenu bit,
	@TreatfulRID int,
	@TreatfulURL NVARCHAR(200),
	@HidePromotedOffersInRestRef bit = 0
)
as 
/************************************************************
Purpose: Update Partner offer status for a Restaurant and add
		 entry in audit log(PartnerOfferChangeTrackLog) table.
*************************************************************/
BEGIN TRANSACTION 

declare @CurrAcceptFlower bit, @CurrAcceptGift bit
declare @NewAcceptFlower bit, @NewAcceptGift bit, @doInsert bit
declare @CurrMarketingEmailOpted bit
declare @CurrRestrictedByRestBlockedList bit
declare @CurrPrivateDineEmailOptOut bit
declare @CurrSuppressedLimo bit
declare @CurrSuppressedAMEX bit
declare @CurrEnabledParking bit
declare @CurrAdWordsID NVARCHAR(100)
declare @CurrAdWordsValue NVARCHAR(100)
declare @CurrShowPOPAsLastOffer bit
declare @CurrFoodSpotting bit
declare @CurrVVOffers bit
declare @CurrHidePromotedOffersInRestRef bit
declare @CurrTreatfulRID int
declare @CurrTreatfulURL NVARCHAR(200)

declare @HidePromotedOffersInRestRefLookupId int = 86

declare @ProcName as nvarchar(1000)  
declare @Action as nvarchar(3000)  
declare @DBError int  

set @ProcName = 'Admin_UpdatePartnerOfferStatusByRestID10' 

-- select existing/current status of partner offer from Restaurant table.
select 
	@CurrAcceptFlower = AcceptFlower,
	@CurrAcceptGift = AcceptGift,
	@CurrRestrictedByRestBlockedList = LimitedBooking,	
	@CurrAdWordsID = AdWordsID,
	@CurrAdWordsValue = AdWordsValue
from
	Restaurant
where
	RID = @RestaurantID

/* Get Current value of Marketing Email Opted In for Rest Ref flag */
set @CurrMarketingEmailOpted = 0
if exists(
	select 
		ValueId
	from 
		ValueLookupIdList vl
	where 
		vl.LookupId = 3
		and vl.ValueId = @RestaurantID)
begin
	set @CurrMarketingEmailOpted = 1
end

/* Get Current value of Private Dining Email Link Opted Out for Restref flag */
set @CurrPrivateDineEmailOptOut = 0
if exists(
	select 
		ValueId
	from 
		ValueLookupIdList vl
	where 
		vl.LookupId = 40
		and vl.ValueId = @RestaurantID)
begin
	set @CurrPrivateDineEmailOptOut = 1
end

/* Get Current value of Limo Suppression */
SET @CurrSuppressedLimo = 0
if exists(
	select 
		ValueId
	from 
		ValueLookupIdList vl
	where 
		vl.LookupId = 23
		and vl.ValueId = @RestaurantID)
begin
	set @CurrSuppressedLimo = 1
end

/* Get Current value of AMEX Suppression */
set @CurrSuppressedAMEX = 0
if exists(
	select 
		ValueId
	from 
		ValueLookupIdList vl
	where 
		vl.LookupId = 58
		and vl.ValueId = @RestaurantID)
begin
	set @CurrSuppressedAMEX = 1
end

/* Get Current value of enabled parking */
if exists(select 1 from RestaurantCentralParking 
			where RID = @RestaurantID)
	begin
		select @CurrEnabledParking = [Enabled]
		from RestaurantCentralParking r
		where r.RID = @RestaurantID
	end
else
	begin
		set @CurrEnabledParking = 0
	end

/*  Get Current setting for POP as Last Offer */
SET @CurrShowPOPAsLastOffer = 1
if exists(
	select 
		ValueId
	from 
		ValueLookupIdList vl
	where 
		vl.LookupId = 51
		and vl.ValueId = @RestaurantID)
begin
	set @CurrShowPOPAsLastOffer = 0
end

/*  Get Current setting for FoodSpotting */
SET @CurrFoodSpotting = 1 --default is not blacklisted
if exists(
	select 
		ValueId
	from 
		ValueLookupIdList vl
	where 
		vl.LookupId = 63
		and vl.ValueId = @RestaurantID)
begin
	--existence means it's blacklisted
	set @CurrFoodSpotting = 0
end

/*  Get Current setting for VV Offers */
SET @CurrVVOffers = 1 --default is not blacklisted
if exists(
	select 
		ValueId
	from 
		ValueLookupIdList vl
	where 
		vl.LookupId = 74
		and vl.ValueId = @RestaurantID)
begin
	--existence means it's blacklisted
	set @CurrVVOffers = 0
END

/*  Get Current setting for HidePromotedOffersInRestRef */
SET @CurrHidePromotedOffersInRestRef = 0 -- default is not hidden
if exists(
	select 
		ValueId
	from 
		ValueLookupIdList vl
	where 
		vl.LookupId = @HidePromotedOffersInRestRefLookupId
		and vl.ValueId = @RestaurantID)
begin
	--existence means it's being hidden
	set @CurrHidePromotedOffersInRestRef = 1
END

SET @CurrTreatfulRID = null
SET @CurrTreatfulURL = null
select @CurrTreatfulRID = rt.TreatfulRID, @CurrTreatfulURL = rt.TreatfulURL 
from RestaurantTreatful rt 
where rt.RID = @RestaurantID

/*  Log the VV Offers if opt-in status changed */
IF (@CurrVVOffers <> @EnabledVVOffers)
begin
		insert into	OfferOptInLog
		(
			OfferClassID
			,RestaurantOfferID
			,RID
			,OptIn
			,CharmUser		
		)
		values
		(
			@OfferClassID
			,@RestaurantOfferID
			,@RestaurantID
			,@EnabledVVOffers		
			,@CharmUserID		
		)
end	
		

-- update partner offer status in Restaurant table.
set @Action = 'UPDATE Restaurant' 
update
	Restaurant
set
	AcceptFlower = @AcceptFlower
	,AcceptGift = @AcceptGift
	,LimitedBooking = @RestrictedByRestBlockedList
	,AdWordsID = @AdWordsID
	,AdWordsValue = @AdWordsValue
	,ShowFaceBookLikeBox = @EnableFaceBookLikeBox
	,ShowThirdPartyMenu = @ShowThirdPartyMenu
where 
	RID = @RestaurantID

/* Update Marketing Email Opted In for Rest Ref flag with new Value 
   If New Value = 1 then Add entry in Valuelookupidlist table else
   delete entry from Valuelookupidlist table for the restaurant */

if(@MarketingEmailOpted = 1 and @CurrMarketingEmailOpted = 0)
begin
	insert into 
		ValueLookupIdList
		(
			LookupID
			,ValueID
		)
	values
		(	
			3
			,@RestaurantID
		)
end
else if (@MarketingEmailOpted = 0 and @CurrMarketingEmailOpted = 1)
begin
	delete from 
		ValueLookupIdList
	where
		LookupId = 3
		and ValueId = @RestaurantID		
end


/* UpdatePrivate Dining Email Link Opted Out for Restref flag with new Value 
   If New Value = 1 then Add entry in Valuelookupidlist table else
   delete entry from Valuelookupidlist table for the restaurant */

if(@PrivateDineEmailOptOut = 1 and @CurrPrivateDineEmailOptOut = 0)
begin
	insert into 
		ValueLookupIdList
		(
			LookupID
			,ValueID
		)
	values
		(	
			40
			,@RestaurantID
		)
end
else if (@PrivateDineEmailOptOut = 0 and @CurrPrivateDineEmailOptOut = 1)
begin
	delete from 
		ValueLookupIdList
	where
		LookupId = 40
		and ValueId = @RestaurantID		
end


/* Update Limo Suppression By RID with new Value 
   If New Value = 1 then Add entry in Valuelookupidlist table else
   delete entry from Valuelookupidlist table for the restaurant */

if(@SuppressedLimo = 1 and @CurrSuppressedLimo = 0)
begin
	insert into 
		ValueLookupIdList
		(
			LookupID
			,ValueID
		)
	values
		(	
			23
			,@RestaurantID
		)
end
else if (@SuppressedLimo = 0 and @CurrSuppressedLimo = 1)
begin
	delete from 
		ValueLookupIdList
	where
		LookupId = 23
		and ValueId = @RestaurantID		
end

/* Update AMEX Suppression By RID with new Value 
   If New Value = 1 then Add entry in Valuelookupidlist table else
   delete entry from Valuelookupidlist table for the restaurant */

if(@SuppressedAMEX = 1 and @CurrSuppressedAMEX = 0)
begin
	insert into 
		ValueLookupIdList
		(
			LookupID
			,ValueID
		)
	values
		(	
			58
			,@RestaurantID
		)
end
else if (@SuppressedAMEX = 0 and @CurrSuppressedAMEX = 1)
begin
	delete from 
		ValueLookupIdList
	where
		LookupId = 58
		and ValueId = @RestaurantID		
end

/* Update Show POP as Last Offer By RID with new Value 
   If New Value = 0 then Add entry in Valuelookupidlist table else
   delete entry from Valuelookupidlist table for the restaurant */

if(@ShowPOPAsLastOffer = 0 and @CurrShowPOPAsLastOffer = 1)
begin
	insert into 
		ValueLookupIdList
		(
			LookupID
			,ValueID
		)
	values
		(	
			51
			,@RestaurantID
		)
end
else if (@ShowPOPAsLastOffer = 1 and @CurrShowPOPAsLastOffer = 0)
begin
	delete from 
		ValueLookupIdList
	where
		LookupId = 51
		and ValueId = @RestaurantID		
end


if((@EnabledParking = 1 and @CurrEnabledParking = 0) or 
		(@EnabledParking = 0 and @CurrEnabledParking = 1))
begin
	if exists(select 1 from RestaurantCentralParking 
				where RID = @RestaurantID)
		begin
			update RestaurantCentralParking
			set [Enabled] = @EnabledParking
			where RID = @RestaurantID		
		end
	else
		begin
			insert into RestaurantCentralParking (RID, [Enabled])
			values (@RestaurantID, @EnabledParking)
		end
end

if(@EnabledFoodSpotting = 0 and @CurrFoodSpotting = 1)
--opting out so add to blacklist
begin
	insert into 
		ValueLookupIdList
		(
			LookupID
			,ValueID
		)
	values
		(	
			63
			,@RestaurantID
		)
end
else if (@EnabledFoodSpotting =1 and @CurrFoodSpotting = 0)
--opting in so delete from blacklist
begin
	delete from 
		ValueLookupIdList
	where
		LookupId = 63
		and ValueId = @RestaurantID		
end

--VVOffers
if(@EnabledVVOffers = 0 and @CurrVVOffers = 1)
--opting out so add to blacklist
begin
	insert into 
		ValueLookupIdList
		(
			LookupID
			,ValueID
		)
	values
		(	
			74
			,@RestaurantID
		)
end
else if (@EnabledVVOffers =1 and @CurrVVOffers = 0)
--opting in so delete from blacklist
begin
	delete from 
		ValueLookupIdList
	where
		LookupId = 74
		and ValueId = @RestaurantID		
end
	
-- add or remove HidePromotedOffersInRestRef setting as necessary
if(@HidePromotedOffersInRestRef <> @CurrHidePromotedOffersInRestRef)
begin
	if(@HidePromotedOffersInRestRef = 1)
		insert into ValueLookupIdList(LookupId, ValueID)
		values (@HidePromotedOffersInRestRefLookupId, @RestaurantId)
	else
		delete from ValueLookupIdList
		where LookupId = @HidePromotedOffersInRestRefLookupId and ValueId = @RestaurantId			
end

if ((COALESCE(@TreatfulRID, 0) <> COALESCE(@CurrTreatfulRID,0)) OR (COALESCE(@TreatfulURL,'') <> COALESCE(@CurrTreatfulURL,'')))
begin
	if ((@CurrTreatfulRID IS NULL) and (@CurrTreatfulURL IS NULL))
		insert into RestaurantTreatful (RID, TreatfulRID, TreatfulURL) values (@RestaurantID, @TreatfulRID, @TreatfulURL)
	else if ((@TreatfulRID IS NULL) and (@TreatfulURL IS NULL))
		delete from RestaurantTreatful where RID = @RestaurantID
	else
		update RestaurantTreatful set TreatfulRID = @TreatfulRID, TreatfulURL = @TreatfulURL where RID = @RestaurantID
end

set @DBError = @@error  
if @DBError <> 0  
 goto general_error 
 
 
/* If None of the values are modified then do not track that operation in log table.*/
set @doInsert = 1
if(@CurrAcceptFlower = @AcceptFlower 
	and @CurrAcceptGift = @AcceptGift 
	and @MarketingEmailOpted = @CurrMarketingEmailOpted
	and @PrivateDineEmailOptOut = @CurrPrivateDineEmailOptOut
	and @RestrictedByRestBlockedList = @CurrRestrictedByRestBlockedList
    and @SuppressedLimo = @CurrSuppressedLimo
    and @SuppressedAMEX = @CurrSuppressedAMEX
    and @AdWordsID = @CurrAdWordsID
    and @AdWordsValue = @CurrAdWordsValue
    and @EnabledParking = @CurrEnabledParking
    and @EnabledFoodSpotting = @CurrFoodSpotting
    and @EnabledVVOffers = @CurrVVOffers
	and @HidePromotedOffersInRestRef = @CurrHidePromotedOffersInRestRef
	and Coalesce(@TreatfulRID, 0) = Coalesce(@CurrTreatfulRID, 0)
	and Coalesce(@TreatfulURL, '') = Coalesce(@CurrTreatfulURL, ''))
begin
	set @doInsert = 0
end


-- add record in PartnerOfferChangeTrackLog table.
set @Action = 'Insert Log in PartnerOfferChangeTrackLog' 
if (@doInsert = 1)
begin
	insert into	PartnerOfferChangeTrackLog
	(
		RID,
		StatusChangeDT,
		CHARMUserID,
		NewAcceptFlowerStatus,
		NewAcceptGiftStatus,
		NewMarketingEmailOpted,
		NewPrivateDineEmailOptOut,
		NewRestrictedByRestBlockedList,
		NewLimoSuppressedByRID,
		NewAMEXSuppressedByRID,
		NewAdwordsID,
		NewAdwordsValue,
		NewEnabledParking,
		NewFoodSpottingStatus,
		NewVVOffersStatus,
		NewTreatfulRID,
		NewTreatfulURL
	)
	values
	(
		@RestaurantID
		,getutcdate()
		,@CHARMUserID	
		,case 
			when @CurrAcceptFlower <> @AcceptFlower then @AcceptFlower
			else NULL
		end
		,case 
			when @CurrAcceptGift <> @AcceptGift then @AcceptGift
			else NULL
		end
		,case 
			when @CurrMarketingEmailOpted <> @MarketingEmailOpted then @MarketingEmailOpted
			else NULL
		end
		,case 
			when @CurrPrivateDineEmailOptOut <> @PrivateDineEmailOptOut then @PrivateDineEmailOptOut
			else NULL
		end
		,case 
			when @CurrRestrictedByRestBlockedList <> @RestrictedByRestBlockedList then @RestrictedByRestBlockedList
			else NULL
		end
		,case 
			when @CurrSuppressedLimo <> @SuppressedLimo then @SuppressedLimo
			else NULL
		END
		,case 
			when @CurrSuppressedAMEX <> @SuppressedAMEX then @SuppressedAMEX
			else NULL
		END
		,case 
			when @CurrAdWordsID <> @AdWordsID then @AdWordsID
			else NULL
		END
		,case 
			when @CurrAdWordsValue <> @AdWordsValue then @AdWordsValue
			else NULL
		end
		,case 
			when @CurrEnabledParking <> @EnabledParking then @EnabledParking
			else NULL
		end
		,case 
			when @CurrFoodSpotting <> @EnabledFoodSpotting then @EnabledFoodSpotting
			else NULL
		end
		,case 
			when @CurrVVOffers <> @EnabledVVOffers then @EnabledVVOffers
			else NULL
		end
		,case 
			when Coalesce(@CurrTreatfulRID, 0) <> Coalesce(@TreatfulRID, 0) then Coalesce(@TreatfulRID, 0)
			else NULL
		end
		,case 
			when Coalesce(@CurrTreatfulURL, '') <> Coalesce(@TreatfulURL, '') then Coalesce(@TreatfulURL, '')
			else NULL
		end		)
end

set @DBError = @@error  
if @DBError <> 0  
 goto general_error  
  
COMMIT TRANSACTION  
Return(0)  
  

general_error:  
 ROLLBACK TRANSACTION  
 exec procLogProcedureError 1, @ProcName, @Action, @DBError  
 Return(0) 

go

GRANT EXECUTE ON dbo.Admin_UpdatePartnerOfferStatusByRestID11 TO ExecuteOnlyRole
go

GRANT EXECUTE ON dbo.Admin_UpdatePartnerOfferStatusByRestID11 TO WebUserUS
go