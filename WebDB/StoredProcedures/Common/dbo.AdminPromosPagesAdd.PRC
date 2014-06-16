if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AdminPromosPagesAdd]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AdminPromosPagesAdd]
GO






CREATE PROCEDURE dbo.AdminPromosPagesAdd
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
  @ExclusionMessage nvarchar(999),
  @DisplaySearchBoxExclusion bit
)
As
SET NOCOUNT ON

Declare @PromoID as int
insert into PromoPages (PromoPageName
				 ,PromoPageDesc
				 ,PromoPageImage
				 ,ImageAltTag
				 ,Active
				 ,PromoSearchTypeID
				 ,IconBoldText
				 ,IconText
				 ,PromoPageCode
				 ,RefCodePage
				 ,RefCodeLink
				 ,SelectionDate
				 ,BeginDate
				 ,EndDate
				 ,SortOrder
				 ,ExternalURL
				 ,SuppressDIP
				 ,QualifyConfMessage
				 ,NonQualifyConfMessage
				 ,EventStartDate
				 ,EventEndDate
				 ,ExclusionMessage
				 ,DisplaySearchBoxExclusion
				 ) 
values                          (@Name
				,@Description
				,@Image
				,@ImageAltTag
				,@Active
				,@PromoSearchTypeID
				,@IconBoldText
				,@IconText
				,@PromoPageCode
				,@RefCodePage
				,@RefCodeLink
				,@SelectionDate
				,@BeginDate
				,@EndDate
  				,@SortOrder
  				,@ExternalURL
				,@SuppressDIP
				,@QualifyConfMessage
				,@NonQualifyConfMessage
				,@EventStartDate
				,@EventEndDate
				,@ExclusionMessage
				,@DisplaySearchBoxExclusion
			)

Set @PromoID = scope_identity()

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

GRANT EXECUTE ON [AdminPromosPagesAdd] TO ExecuteOnlyRole

GO
