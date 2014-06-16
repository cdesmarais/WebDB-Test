if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_MetroInfo_Get]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_MetroInfo_Get]
GO

CREATE Procedure dbo.Admin_MetroInfo_Get
 (
  @Metro_Area_ID int = 0
 )
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

if @Metro_Area_ID <> 0
Begin
	SELECT 	metroareaid as Metro_Area_ID,
			MetroAreaName as Name,
			m.Active,
			SearchLevel as Search_Level,
			Message,
			EmailContact as email_contact,
			TopTenList,
			TZID,
			CountryID,
			TitleTag,
			DFFStartDT,
			MinNumRests,
			DisplayDays,
			ShortDisplayName,
			LanguageID,
			-- new column added to retrive meta description and keyowrds.
			m.PrimaryLanguageID,
			MetaDescriptionText,    
			MetaKeywordText,
			m.SupportedDomainID as DomainID,			
			SiteDisplayName,
			MetroAreaSName as SName,
			(SELECT ValueID FROM [ValueLookupIDList] WHERE [LookupID] = 1 AND ValueID = @Metro_Area_ID) AS RRPTS_SUPPRESS_METRO_EXCLUDE,
			(SELECT ValueID FROM [ValueLookupIDList] WHERE [LookupID] = 4 AND ValueID = @Metro_Area_ID) AS AUTOFILL_METRO_WHITELIST,
			(SELECT ValueID FROM [ValueLookupIDList] WHERE [LookupID] = 6 AND ValueID = @Metro_Area_ID) AS REDENVELOPE_METRO_EXCLUDE,
			(SELECT ValueID FROM [ValueLookupIDList] WHERE [LookupID] = 7 AND ValueID = @Metro_Area_ID) AS USER_RECOMMENDED_METRO,
			(SELECT ValueID FROM [ValueLookupIDList] WHERE [LookupID] = 8 AND ValueID = @Metro_Area_ID) AS FEATURED_DIP_METRO,
			(SELECT ValueID FROM [ValueLookupIDList] WHERE [LookupID] = 9 AND ValueID = @Metro_Area_ID) AS DIP_WINGS_METRO,
			(SELECT ValueID FROM [ValueLookupIDList] WHERE [LookupID] = 10 AND ValueID = @Metro_Area_ID) AS MOBILE_INFO_METRO_BLACKLIST,
			(SELECT ValueID FROM [ValueLookupIDList] WHERE [LookupID] = 11 AND ValueID = @Metro_Area_ID) AS DINERSCHOICE_METRO_LONGNAME_BLACKLIST,
			(SELECT ValueID FROM [ValueLookupIDList] WHERE [LookupID] = 13 AND ValueID = @Metro_Area_ID) AS DINERS_CHOICE_METRO_BLACKLIST,
            (SELECT ValueID FROM [ValueLookupIDList] WHERE [LookupID] = 20 AND ValueID = @Metro_Area_ID) AS MAPSEARCH_METRO_BLACKLIST,
            (SELECT ValueID FROM [ValueLookupIDList] WHERE [LookupID] = 19 AND ValueID = @Metro_Area_ID) AS RATINGS_REVIEWS_METRO_BLACKLIST,
            (SELECT ValueID FROM [ValueLookupIDList] WHERE [LookupID] = 34 AND ValueID = @Metro_Area_ID) AS ENHANCED_PRIVATE_DINING_METRO_WHITELIST,
			m.ShowRegionLists,			
			MetroTitleTag,
			m.ShowSpotLight,			
			m.SpotlightLink,
			m.SpotlightLinkText,
			m.SpotlightImage		
	FROM 	MetroAreaAVW m -- Get metro info from all Languages
	inner join [Domain] 
	on	m.SupportedDomainID =  [Domain].DomainID
	where 	MetroAreaID = @Metro_Area_ID
	order	by LanguageID, SName
End
else
Begin

	Declare @Languages AS int
	Select @Languages = count(DISTINCT LanguageID) from MetroAreaLocal

	SELECT 	metroareaid as Metro_Area_ID,
			MetroAreaName as Name,
			Active,
			SearchLevel as Search_Level,
			Message,
			EmailContact as email_contact,
			@Languages as Languages,
			CASE WHEN (LEN(LTRIM(MetroAreaSName)) = 0) THEN MetroAreaName ELSE MetroAreaSName END SName,
			m.SupportedDomainID
	FROM 	MetroAreaVW m
	ORDER 	BY SName
End

Return(0)

GO

GRANT EXECUTE ON [Admin_MetroInfo_Get] TO ExecuteOnlyRole
GO  

