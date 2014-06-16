
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OTR_CacheUpdateProfileMasterData]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[OTR_CacheUpdateProfileMasterData]
GO

create Procedure dbo.OTR_CacheUpdateProfileMasterData
as
set nocount on
set transaction isolation level read uncommitted


	/* 
	This SP is used to get Update Profile common data for all language 
	Content owned by India team, please notify asaxena@opentable.com if changing.
	*/

	/* 
	MasterID and MasterValue alias helps becuase we have used same alias for all update profile master data 
	same method has been used to filter master data.
	*/

	/* 
	This query is used to get Dining style for all language 
	*/
	select   
		DiningStyleID as MasterID
		,DiningStyle  as  MasterValue
		,DiningStyle  as  MasterValueSortable
		,LanguageID
	from     
		DiningStyleAVW


	/*
	This query is used to get dress code for all language  
	*/
	select	
		DressCodeID as MasterID
		,DressCode  as  MasterValue
		,DressCode  as  MasterValueSortable
		,LanguageID
	from	
		DressCodeAVW
	

	/*
	This query is used to get Food Type for all language  
	*/
	select 
		foodtypeID as MasterID
		,FoodType  as  MasterValue
		,coalesce(NULLIF(FoodTypeSName, ''), FoodType) as  MasterValueSortable
		,LanguageID
	from
		FoodType
	
	
	/*
	This query is used to get Offer for all language  
	*/
	select		
		offerID as MasterID
		,Offer as MasterValue
		,Offer  as  MasterValueSortable
		,LanguageID
	from		
		OfferAVW
	
		
	/*
	This query is used to get parking details for all language  
	*/
	select    
		ParkingID as MasterID  
		,Parking as  MasterValue
		,Parking  as  MasterValueSortable
		,LanguageID  
	from    
		ParkingAVW   

	
	/*
	This query is used to get Payment details for all language  
	*/
	select
		PaymentTypeID as MasterID
		,PaymentType as  MasterValue
		,PaymentType  as  MasterValueSortable
		,LanguageID
	from		
		PaymentTypeAVW

	/*
	This query is used to get Walkin option for all language  
	*/
	select	
		WOID as MasterID
		,WalkinOption as  MasterValue
		,WOID  as  MasterValueSortable
		,LanguageID
	from	
		WalkinOptionAVW

	/*
	This query is used to get Price option for all language
	*/
	select
		PriceQuartileID as MasterID
		,PriceQuartile as  MasterValue
		,PriceQuartileID  as  MasterValueSortable
		,p.CountryID
		,p.CurrencyType
		,LanguageID
	from
		PriceQuartileAVW p
GO

GRANT EXECUTE ON [OTR_CacheUpdateProfileMasterData] TO ExecuteOnlyRole

GO


