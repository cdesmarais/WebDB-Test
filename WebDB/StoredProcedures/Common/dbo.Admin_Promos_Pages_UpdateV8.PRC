/*Procedure to update the Promos*/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Promos_Pages_UpdateV8]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[Admin_Promos_Pages_UpdateV8]
go

create procedure dbo.Admin_Promos_Pages_UpdateV8
(
	@PromoID					int
	,@PromoPageName 			nvarchar(65)
	,@PromoPageDesc 			ntext
	,@PromoPageImage			nvarchar(50)
	,@ImageAltTag				nvarchar(65)
	,@MobilePromoPageDesc		nvarchar(MAX)
	,@MobilePromoPageImage		nvarchar(50)
	,@active					bit
	,@PromoSearchTypeID 		int
	,@IconBoldText				nvarchar(50)
	,@IconText					nvarchar(50)
	,@PromoPageCode				nvarchar(50)
	,@RefCodePage 				int
	,@RefCodeLink 				int
	,@SelectionDate 			datetime
	,@BeginDate					datetime
	,@EndDate					datetime
	,@EventStartDate			datetime
	,@EventEndDate				datetime
	,@SortOrder					int
	,@ExternalURL				nvarchar(150)
	,@SuppressDIP				bit
	,@QualifyConfMessage		nvarchar(600)
	,@NonQualifyConfMessage 	nvarchar(600)
	,@ExclusionMessage			nvarchar(600)
	,@DisplaySearchBoxExclusion bit
	,@ExclusionDates			nvarchar(4000)
	,@PromoPageDescTitle		nvarchar(100)
	,@MetaPageTitle				nvarchar(255)
	,@MetaDescription			nvarchar(255)
	,@MetaKeyword				nvarchar(255)
	,@LinkLabel					nvarchar(65)
	,@ChildPromoID				int
	,@PromoPageDescDraft		ntext
	,@PromoPageImageDraft		nvarchar(50)
	,@SelectionDateDraft		datetime
	,@ConvertDraftLive			bit
	,@ExpireMessage				nvarchar(600)
	,@SuppressPrice				bit
	,@LinkText					nvarchar(150)
    ,@ShowOnStartPage			bit
    ,@ThumbnailPromoPageImageID int
    ,@RestaurantWeekPromoStatus bit
    ,@MastheadUrl				nvarchar(255)
)
as
set nocount on

begin transaction

-- akash: Execute logic only if DIP supression value has changed
	if not exists (	select 
						* 
					from 
						dbo.promopages 
					where 
						active = 1 and 
						promoid = @PromoID and 
						suppressdip = @SuppressDIP )
	begin
		-- if DIP supression is being turned OFF then delete all exclusions
		if @SuppressDIP = 0
		begin
			delete from dbo.PromoDIPSupressExclusion where promoid=@PromoID
		end
	end

	update dbo.PromoPages 
	set
		PromoPageName = @PromoPageName
		,PromoPageDesc = @PromoPageDesc
		,PromoPageImage = @PromoPageImage
		,PromoPageDescDraft = @PromoPageDescDraft
		,PromoPageImageDraft = @PromoPageImageDraft
		,MobilePromoPageDesc = @MobilePromoPageDesc
		,MobilePromoPageImage = @MobilePromoPageImage
		,ConvertDraftLive = @ConvertDraftLive
		,ImageAltTag = @ImageAltTag
		,active = @Active 
		,PromoSearchTypeID = @PromoSearchTypeID
		,IconBoldText = @IconBoldText
		,IconText = @IconText
		,PromoPageCode = @PromoPageCode
		,RefCodePage = @RefCodePage
		,RefCodeLink = @RefCodeLink
		,SelectionDate = @SelectionDate
		,SelectionDateDraft = @SelectionDateDraft
		,BeginDate = @BeginDate
		,EndDate = @EndDate
		,EventStartDate = @EventStartDate
		,EventEndDate = @EventEndDate
		,SortOrder = @SortOrder
		,ExternalURL = @ExternalURL
		,SuppressDIP = @SuppressDIP
		,QualifyConfMessage = @QualifyConfMessage
		,NonQualifyConfMessage = @NonQualifyConfMessage
		,ExclusionMessage = @ExclusionMessage
		,DisplaySearchBoxExclusion = @DisplaySearchBoxExclusion
		,DescriptionTitle = @PromoPageDescTitle
		,MetaPageTitle = @MetaPageTitle
		,MetaDescription = @MetaDescription
		,MetaKeyword = @MetaKeyword
		,LinkLabel = @LinkLabel
		,ChildPromoID = @ChildPromoID
		,ExpireMessage = @ExpireMessage
		,SuppressPrice = @SuppressPrice
		,LinkText = @LinkText
		,ShowOnStartPage = @ShowOnStartPage
		,ThumbnailPromoPageImageID = @ThumbnailPromoPageImageID
		,MastheadUrl = @MastheadUrl
	where 
		PromoID = @PromoID

	if @@ERROR <> 0
		goto error

	delete from 
		dbo.PromoPageExclusions 
	where 
		PromoID = @PromoID

	if @@ERROR <> 0
		goto error

	insert into dbo.PromoPageExclusions 
	(
		PromoID
		,ExclusionDate
		,PromoGrouping
	)
	select 
		@PromoID
		,StringValues
		,1
	from 
		fStringsToTab(@ExclusionDates, ',')

	if @@ERROR <> 0
		goto error

	-- dbo.AdminPromosPagesUpdateRegion:
	delete from PromoPagesToRegion where PromoID = @PromoID

	if @@ERROR <> 0
		goto error

	if len(@QualifyConfMessage) > 0 OR 
		len(@NonQualifyConfMessage) > 0 OR 
		len(@ExclusionMessage) > 0
	begin

		insert into 
			PromoPagesToRegion
		( 
			PromoID
			,RegionID
		)
		Select distinct 
			@PromoID as PromoID
			,MacroID as RegionID 
		from 
			PromoRests inner join 
			restaurant 			
			on PromoRests.rid = restaurant.rid inner join 
			neighborhood 			
			on restaurant.neighborhoodid = neighborhood.neighborhoodid
		where promoID = @PromoID
		
	end
	
	if @@ERROR <> 0
		goto error
		
	declare @ExecutionStatus bit /*1 = sucess and  0 = fail*/
	
	/*Add or Update the Restaurant Week promo Status*/
	exec Admin_Promos_Pages_Groups_AddUpdate @PromoID,1,@RestaurantWeekPromoStatus,@ExecutionStatus

	if @ExecutionStatus = 0
		goto error

	commit transaction
	return(0)
	 
	error:
	rollback transaction
	return(0)

go

grant execute on [Admin_Promos_Pages_UpdateV8] to ExecuteOnlyRole

go
