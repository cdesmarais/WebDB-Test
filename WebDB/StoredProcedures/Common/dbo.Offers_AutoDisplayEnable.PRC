

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Offers_AutoDisplayEnable]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Offers_AutoDisplayEnable]
go

create Procedure dbo.[Offers_AutoDisplayEnable]

as

	/*
		This stored procedure will turn on the OT website display status and 
		the checkbox will appear checked on start of offer.
	*/ 
	declare @GetTodaysUTCDate datetime
	set @GetTodaysUTCDate = getutcdate()
	
	set transaction isolation level read committed
	
	update 
		RestaurantOffer
	set
		DisplayOnOTWebsite = 1
	from 
		RestaurantOffer ro
		inner join RestaurantVW rest
		on ro.RID = rest.RID
	where
		OfferStatusID = 1 /* offer = active*/ 
		and DisplayOnOTWebsite = 0
		and 
		/*	concat start date and time
			fGetOfferTimeFromBitMask function returns time only with date part as 1900-01-01
			datediff gets the no of days from 1900-01-01 (which is 0 also in sql server) and
			startdate. These no of days are then added to time returned by 
			fGetOfferTimeFromBitMask function
		 */
		dateadd(d,datediff(D,0,startdate),dbo.fGetOfferTimeFromBitMask(ro.Times00_745 ,ro.Times08_1545 
		,ro.Times16_2345,1))
		 <= dbo.fConvertFromUTC(@GetTodaysUTCDate,rest.TZID)	
		 /*	above start time concat logic is also applied to end date and time */	 
		 and 		 
		 dateadd(d,datediff(D,0,EndDate),dbo.fGetOfferTimeFromBitMask(ro.Times00_745 ,ro.Times08_1545 
		,ro.Times16_2345,0))
		 > dbo.fConvertFromUTC(@GetTodaysUTCDate,rest.TZID)
		
go

grant execute on [Offers_AutoDisplayEnable] TO ExecuteOnlyRole
go




