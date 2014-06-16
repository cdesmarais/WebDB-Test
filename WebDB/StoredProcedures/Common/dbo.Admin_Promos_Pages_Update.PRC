
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Promos_Pages_Update]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Promos_Pages_Update]
GO


CREATE PROCEDURE dbo.Admin_Promos_Pages_Update
(
	@PromoID int,
	@PromoPageName NVarChar(65),
	@PromoPageDesc NText,
	@PromoPageImage NVarChar(50),
	@ImageAltTag NVarChar(65),
	@active Bit,
	@PromoSearchTypeID Int,
	@IconBoldText NVarChar(50),
	@IconText NVarChar(50),
	@PromoPageCode NVarChar(50),
	@RefCodePage Int,
	@RefCodeLink Int,
	@SelectionDate DateTime,
	@BeginDate DateTime,
	@EndDate DateTime,
	@EventStartDate DateTime,
	@EventEndDate DateTime,
	@SortOrder Int,
	@ExternalURL NVarChar(150),
	@SuppressDIP Bit,
	@QualifyConfMessage NVarChar(600),
	@NonQualifyConfMessage NVarChar(600),
	@ExclusionMessage NVarChar(600),
	@DisplaySearchBoxExclusion Bit,
	@ExclusionDates NVarChar(4000),
	@PromoPageDescTitle NVARCHAR(100),
	@MetaPageTitle NVARCHAR(255),
	@MetaDescription NVarChar(255),
	@MetaKeyword NVarChar(255),
	@LinkLabel NVarChar(65),
	@ChildPromoID Int
)
As
SET NOCOUNT ON

BEGIN TRANSACTION

-- akash: Execute logic only if DIP supression value has changed
IF NOT EXISTS (SELECT * FROM dbo.promopages WHERE active=1 AND promoid=@PromoID AND suppressdip=@SuppressDIP)
    BEGIN
	-- if DIP supression is being turned OFF then delete all exclusions
	IF @SuppressDIP = 0
		BEGIN
			DELETE FROM dbo.PromoDIPSupressExclusion WHERE promoid=@PromoID
		END
    END

UPDATE dbo.PromoPages SET
	PromoPageName = @PromoPageName
	,PromoPageDesc = @PromoPageDesc
	,PromoPageImage = @PromoPageImage
	,ImageAltTag = @ImageAltTag
	,active = @Active 
	,PromoSearchTypeID = @PromoSearchTypeID
	,IconBoldText = @IconBoldText
	,IconText = @IconText
	,PromoPageCode = @PromoPageCode
	,RefCodePage = @RefCodePage
	,RefCodeLink = @RefCodeLink
	,SelectionDate = @SelectionDate
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
WHERE PromoID = @PromoID

if @@ERROR <> 0
	goto error

DELETE FROM dbo.PromoPageExclusions WHERE PromoID = @PromoID

if @@ERROR <> 0
	goto error

INSERT INTO dbo.PromoPageExclusions (PromoID,ExclusionDate,PromoGrouping)
	SELECT @PromoID, StringValues, 1
	FROM fStringsToTab(@ExclusionDates, ',')

if @@ERROR <> 0
	goto error

-- dbo.AdminPromosPagesUpdateRegion:
Delete from PromoPagesToRegion where PromoID =  @PromoID

if @@ERROR <> 0
	goto error

IF LEN(@QualifyConfMessage) > 0 OR 
	LEN(@NonQualifyConfMessage) > 0 OR 
	LEN(@ExclusionMessage) > 0
BEGIN

	Insert into PromoPagesToRegion
	( PromoID, RegionID )
	Select distinct @PromoID as PromoID, MacroID as RegionID from PromoRests 
	inner join restaurant on PromoRests.rid = restaurant.rid
	inner join neighborhood on restaurant.neighborhoodid = neighborhood.neighborhoodid
	where promoID = @PromoID
	
END

if @@ERROR <> 0
		goto error

COMMIT TRANSACTION
Return(0)
 
error:
ROLLBACK TRANSACTION
Return(0)

GO

GRANT EXECUTE ON [Admin_Promos_Pages_Update] TO ExecuteOnlyRole

GO
