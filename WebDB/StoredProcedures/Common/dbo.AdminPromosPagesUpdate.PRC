if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AdminPromosPagesUpdate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AdminPromosPagesUpdate]
GO



CREATE PROCEDURE dbo.AdminPromosPagesUpdate
(
  @Name nvarchar(65),
  @Description text,
  @Image nvarchar(50),
  @ImageAltTag nvarchar(65),
  @PromoSearchTypeID int,
  @IconBoldText nvarchar(50),
  @IconText nvarchar(50),
  @PromoPageCode nvarchar(50),
  @RefCodePage int,
  @RefCodeLink int,
  @SelectionDate nvarchar(50),
  @BeginDate nvarchar(50),
  @EndDate nvarchar(50),
  @SortOrder int,
  @ExternalURL nvarchar(150),

  @SuppressDIP int,
  @QualifyConfMessage nvarchar(999),
  @NonQualifyConfMessage nvarchar(999),
  @EventStartDate nvarchar(50),
  @EventEndDate nvarchar(50),

  @Exclusion1 varchar(8000),
  @Exclusion2 varchar(8000),
  @Exclusion3 varchar(8000),
  @Exclusion4 varchar(8000),
  @Exclusion5 varchar(8000),
  @Exclusion6 varchar(8000),
  @Exclusion7 varchar(8000),
  @Exclusion8 varchar(8000),
  
  @Active int,
  @PromoID int,
  @ExclusionMessage nvarchar(999),
  @DisplaySearchBoxExclusion bit
)
As
SET NOCOUNT ON

-- akash: Execute logic only if DIP supression value has changed
if not exists (select * from promopages where active=1 and promoid=@PromoID and suppressdip=@SuppressDIP)
    BEGIN
	-- if DIP supression is being turned OFF then delete all exclusions
	if @SuppressDIP = 0
		BEGIN
			delete from PromoDIPSupressExclusion where promoid=@promoid
		END
    END

update PromoPages set 
PromoPageName=@Name
,PromoPageDesc=@Description
,PromoPageImage=@Image
,ImageAltTag = @ImageAltTag
,active=@Active 
,PromoSearchTypeID=@PromoSearchTypeID
,IconBoldText=@IconBoldText
,IconText=@IconText
,PromoPageCode=@PromoPageCode
,RefCodePage=@RefCodePage
,RefCodeLink=@RefCodeLink
,SelectionDate=@SelectionDate
,BeginDate=@BeginDate
,EndDate=@EndDate
,ExternalURL=@ExternalURL
,SortOrder=@SortOrder
,DisplaySearchBoxExclusion=@DisplaySearchBoxExclusion
,SuppressDIP=@SuppressDIP
,QualifyConfMessage=@QualifyConfMessage
,NonQualifyConfMessage=@NonQualifyConfMessage
,EventStartDate=@EventStartDate
,EventEndDate=@EventEndDate
,ExclusionMessage = @ExclusionMessage

where PromoID = @PromoID


delete PromoPageExclusions from PromoPageExclusions where PromoID = @promoID

if @Exclusion1 != ''
BEGIN
	insert into PromoPageExclusions (PromoID,ExclusionDate,PromoGrouping)
			select @promoID, StringValues, 1
			from fStringsToTab(@Exclusion1, ',')
END

if @Exclusion2 != ''
BEGIN
	insert into PromoPageExclusions (PromoID,ExclusionDate,PromoGrouping)
			select @promoID, StringValues, 2
			from fStringsToTab(@Exclusion2, ',')
END

if @Exclusion3 != ''
BEGIN
	insert into PromoPageExclusions (PromoID,ExclusionDate,PromoGrouping)
			select @promoID, StringValues, 3
			from fStringsToTab(@Exclusion3, ',')
END

if @Exclusion4 != ''
BEGIN
	insert into PromoPageExclusions (PromoID,ExclusionDate,PromoGrouping)
			select @promoID, StringValues, 4
			from fStringsToTab(@Exclusion4, ',')
END

if @Exclusion5 != ''
BEGIN
	insert into PromoPageExclusions (PromoID,ExclusionDate,PromoGrouping)
			select @promoID, StringValues, 5
			from fStringsToTab(@Exclusion5, ',')
END

if @Exclusion6 != ''
BEGIN
	insert into PromoPageExclusions (PromoID,ExclusionDate,PromoGrouping)
			select @promoID, StringValues, 6
			from fStringsToTab(@Exclusion6, ',')
END

if @Exclusion7 != ''
BEGIN
	insert into PromoPageExclusions (PromoID,ExclusionDate,PromoGrouping)
			select @promoID, StringValues, 7
			from fStringsToTab(@Exclusion7, ',')
END

if @Exclusion8 != ''
BEGIN
	insert into PromoPageExclusions (PromoID,ExclusionDate,PromoGrouping)
			select @promoID, StringValues, 8
			from fStringsToTab(@Exclusion8, ',')
END
GO

GRANT EXECUTE ON [AdminPromosPagesUpdate] TO ExecuteOnlyRole

GO
