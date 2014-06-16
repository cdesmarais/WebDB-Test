



/*Procedure to Add a new restaurant promo*/

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Promos_Pages_AddV6]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[Admin_Promos_Pages_AddV6]
go

  
create procedure dbo.Admin_Promos_Pages_AddV6  
(  
	@PromoPageName				nvarchar(65)  
	,@PromoPageDesc				ntext  
	,@PromoPageImage			nvarchar(50)  
	,@ImageAltTag				nvarchar(65)  
	,@MobilePromoPageImage		nvarchar(50)
	,@active					bit  
	,@PromoSearchTypeID 		int  
	,@IconBoldText				nvarchar(50)  
	,@IconText					nvarchar(50)  
	,@PromoPageCode				nvarchar(50)  
	,@RefCodePage				int  
	,@RefCodeLink				int  
	,@SelectionDate				datetime  
	,@BeginDate					datetime  
	,@EndDate					datetime  
	,@EventStartDate			datetime  
	,@EventEndDate				datetime  
	,@SortOrder					int  
	,@ExternalURL				nvarchar(150)  
	,@SuppressDIP				bit  
	,@QualifyConfMessage		nvarchar(999)  
	,@NonQualifyConfMessage 	nvarchar(999)  
	,@ExclusionMessage			nvarchar(999)  
	,@DisplaySearchBoxExclusion bit  
	,@ExclusionDates   			nvarchar(4000)  
	,@LanguageID				int
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
	,@SuppressPrice				bit  
	,@LinkText					nvarchar(150)  
	,@ShowOnStartPage			bit   
	,@ThumbnailPromoPageImageID	int  
	,@RestaurantWeekPromoStatus	bit  
	,@ExpireMessage				nvarchar(1200)
)  
as  
set nocount on  
  
	begin transaction  

	declare @PromoID as int  

	insert into dbo.PromoPages   
	(  
		PromoPageName  
		,PromoPageImage  
		,PromoPageDesc  
		,MobilePromoPageImage
		,active  
		,PromoSearchTypeID  
		,IconBoldText  
		,IconText  
		,PromoPageCode  
		,RefCodePage  
		,RefCodeLink  
		,BeginDate  
		,EndDate  
		,SelectionDate  
		,SortOrder  
		,ExternalURL  
		,EventStartDate  
		,EventEndDate  
		,SuppressDIP  
		,QualifyConfMessage  
		,NonQualifyConfMessage  
		,ExclusionMessage  
		,DisplaySearchBoxExclusion  
		,LanguageID
		,ImageAltTag  
		,MetaDescription  
		,MetaKeyword  
		,LinkLabel  
		,ChildPromoID  
		,PromoPageDescDraft  
		,PromoPageImageDraft  
		,SelectionDateDraft  
		,ConvertDraftLive  
		,SuppressPrice  
		,LinkText  
		,ShowOnStartPage  
		,ThumbnailPromoPageImageID  
		,ExpireMessage
	)   
	values   
	(   
		@PromoPageName  
		,@PromoPageImage  
		,@PromoPageDesc  
		,@MobilePromoPageImage
		,@active  
		,@PromoSearchTypeID  
		,@IconBoldText  
		,@IconText  
		,@PromoPageCode  
		,@RefCodePage  
		,@RefCodeLink  
		,@BeginDate  
		,@EndDate  
		,@SelectionDate  
		,@SortOrder  
		,@ExternalURL  
		,@EventStartDate  
		,@EventEndDate  
		,@SuppressDIP  
		,@QualifyConfMessage  
		,@NonQualifyConfMessage  
		,@ExclusionMessage  
		,@DisplaySearchBoxExclusion  
		,@LanguageID
		,@ImageAltTag  
		,@MetaDescription  
		,@MetaKeyword  
		,@LinkLabel  
		,@ChildPromoID   
		,@PromoPageDescDraft  
		,@PromoPageImageDraft  
		,@SelectionDateDraft  
		,@ConvertDraftLive  
		,@SuppressPrice  
		,@LinkText  
		,@ShowOnStartPage  
		,@ThumbnailPromoPageImageID  
		,@ExpireMessage
	)   

	set @PromoID = scope_identity()  
  
	if @@ERROR <> 0  
		goto error  
  
	insert into dbo.PromoPageExclusions   
	(  
		PromoID  
		,ExclusionDate  
		,PromoGrouping  
	)  
	select   
		@promoID  
		,StringValues  
		,0  
	from   
		fStringsToTab(@ExclusionDates, ',')  
  
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

grant execute on [Admin_Promos_Pages_AddV6] to ExecuteOnlyRole

go



