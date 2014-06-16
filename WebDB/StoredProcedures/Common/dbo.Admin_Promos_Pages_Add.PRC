if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Promos_Pages_Add]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Promos_Pages_Add]
GO

CREATE PROCEDURE dbo.Admin_Promos_Pages_Add
(
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
	@QualifyConfMessage NVarChar(999),
	@NonQualifyConfMessage NVarChar(999),
	@ExclusionMessage NVarChar(999),
	@DisplaySearchBoxExclusion Bit,
	@ExclusionDates NVarChar(4000),
	@SupportedDomainID Int,
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

DECLARE @PromoID as int

INSERT INTO dbo.PromoPages (
	PromoPageName,
	PromoPageImage,
	PromoPageDesc,
	active,
	PromoSearchTypeID,
	IconBoldText,
	IconText,
	PromoPageCode,
	RefCodePage,
	RefCodeLink,
	BeginDate,
	EndDate,
	SelectionDate,
	SortOrder,
	ExternalURL,
	EventStartDate,
	EventEndDate,
	SuppressDIP,
	QualifyConfMessage,
	NonQualifyConfMessage,
	ExclusionMessage,
	DisplaySearchBoxExclusion,
	SupportedDomainID,
	ImageAltTag,
	MetaDescription,
	MetaKeyword,
	LinkLabel,
	ChildPromoID
) VALUES ( 
	/* PromoPageName - [nvarchar](65) */ @PromoPageName,
	/* PromoPageImage - [nvarchar](50) */ @PromoPageImage,
	/* PromoPageDesc - [ntext] */ @PromoPageDesc,
	/* active - [bit] */ @active,
	/* PromoSearchTypeID - [int] */ @PromoSearchTypeID,
	/* IconBoldText - [nvarchar](50) */ @IconBoldText,
	/* IconText - [nvarchar](50) */ @IconText,
	/* PromoPageCode - [nvarchar](50) */ @PromoPageCode,
	/* RefCodePage - [int] */ @RefCodePage,
	/* RefCodeLink - [int] */ @RefCodeLink,
	/* BeginDate - [datetime] */ @BeginDate,
	/* EndDate - [datetime] */ @EndDate,
	/* SelectionDate - [datetime] */ @SelectionDate,
	/* SortOrder - [int] */ @SortOrder,
	/* ExternalURL - [nvarchar](150) */ @ExternalURL,
	/* EventStartDate - [datetime] */ @EventStartDate,
	/* EventEndDate - [datetime] */ @EventEndDate,
	/* SuppressDIP - [bit] */ @SuppressDIP,
	/* QualifyConfMessage - [nvarchar](999) */ @QualifyConfMessage,
	/* NonQualifyConfMessage - [nvarchar](999) */ @NonQualifyConfMessage,
	/* ExclusionMessage - [nvarchar](999) */ @ExclusionMessage,
	/* DisplaySearchBoxExclusion - [bit] */ @DisplaySearchBoxExclusion,
	/* SupportedDomainID - [int] */ @SupportedDomainID,
	/* ImageAltTag - [nvarchar](65) */ @ImageAltTag,
	/* MetaDescription - [nvarchar](255) */ @MetaDescription,
	/* MetaKeyword - [nvarchar](255) */ @MetaKeyword,
	/* LinkLabel - [nvarchar](255) */ @LinkLabel,
	/* ChildPromoID - [int] */ @ChildPromoID ) 

SET @PromoID = scope_identity()

if @@ERROR <> 0
	goto error

INSERT INTO dbo.PromoPageExclusions (PromoID,ExclusionDate,PromoGrouping)
	SELECT @promoID, StringValues, 0
	FROM fStringsToTab(@ExclusionDates, ',')

if @@ERROR <> 0
	goto error
		
COMMIT TRANSACTION
Return(0)
 
error:
ROLLBACK TRANSACTION
Return(0)
GO

GRANT EXECUTE ON [Admin_Promos_Pages_Add] TO ExecuteOnlyRole

GO
