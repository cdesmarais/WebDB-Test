if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DBCheckI18nWebCache]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DBCheckI18nWebCache]
GO

CREATE Procedure dbo.DBCheckI18nWebCache

As


SET NOCOUNT ON

-- Create Temp table for all Stored Procs
CREATE TABLE #StoredProcs
(
	ProcName NVARCHAR(200),
	ColName NVARCHAR(200),
	Note NVARCHAR(500)
)

-- Create Temp table for all users
CREATE TABLE #Users
(
	userName NVARCHAR(200),
	LanguageID int
)

-- Create Temp table for final
CREATE TABLE #Report
(
	userName NVARCHAR(200),
	LanguageID INT,
	ProcName NVARCHAR(200),
	PrimaryKeyCount INT,
	Rows INT,
	RegionUserRowCount int,
	PrimaryLanguageUserRowCount int,
	ColumnNames NVARCHAR(400),
	Status NVARCHAR(400)
)

-- Procs that populate the web cache with extra columns other than first column that determine uniqueness

insert into #StoredProcs values ('dbo.Admin_Get_404Redirect_Listing ','','')
insert into #StoredProcs values ('dbo.DNCacheAllDomains','','')
--insert into #StoredProcs values ('dbo.DNCacheAllRestaurantCuisines ',', FoodTypeID','') -- This one is different based on the number of cuisines per restaurant vs language issues
insert into #StoredProcs values ('dbo.DNCacheAvailabilityTonight ','','')
insert into #StoredProcs values ('dbo.DNCacheBrainTreeRestaurantInfo ','','')
insert into #StoredProcs values ('dbo.DNCacheCompany','','')
insert into #StoredProcs values ('dbo.DNCacheCompanyNonRestaurants',',RID','')
insert into #StoredProcs values ('dbo.DNCacheCountryList ','','')
insert into #StoredProcs values ('dbo.DNCacheCountrySearchRadius ','','')
--insert into #StoredProcs values ('dbo.DNCacheCuisineMacroToMicroMapping ','','') -- This one is different based on the number of cuisines per restaurant vs language issues
insert into #StoredProcs values ('dbo.DNCacheDffCategories ','','')
insert into #StoredProcs values ('dbo.DNCacheDffDailySummaryRidStats ','','')
insert into #StoredProcs values ('dbo.DNCacheDiningStyle ','','')
insert into #StoredProcs values ('dbo.DNCacheDIPDaySuppress',',SuppressedDate','')
insert into #StoredProcs values ('dbo.DNCacheDomain','','')
insert into #StoredProcs values ('dbo.DNCacheErrorListAll','','')
insert into #StoredProcs values ('dbo.DNCacheERBInfo','','')
insert into #StoredProcs values ('dbo.DNCacheGenericPages ','','')
insert into #StoredProcs values ('dbo.DNCacheGeoList','','')
--insert into #StoredProcs values ('dbo.DNCacheGiftList',',CountryID','') - TODO: Fix and Add back to list
--insert into #StoredProcs values ('dbo.DNCacheHPFeaturedMetrosList',',MetroAreaID','')  -- Only used on .COM
--insert into #StoredProcs values ('dbo.DNCacheHPInternationalList','','') -- Only used on .COM
--insert into #StoredProcs values ('dbo.DNCacheHPStateList',',MacroID,MetroAreaID','') -- Only used on .COM
insert into #StoredProcs values ('dbo.DNCacheLanguage','','')
--insert into #StoredProcs values ('dbo.DNCacheLegalContent ',',DomainID','') -- Can't compare text
insert into #StoredProcs values ('dbo.DNCacheMapToNLURL ','','')
insert into #StoredProcs values ('dbo.DNCacheMobileWebValues ','','')
insert into #StoredProcs values ('dbo.DNCacheNewsletter','','')
--insert into #StoredProcs values ('dbo.DNCacheNewsletterWhitelist ','','') -- Only used on .COM
insert into #StoredProcs values ('dbo.DNCacheNLRules','','')
insert into #StoredProcs values ('dbo.DNCacheNLWhiteBlackListPages ','','')
insert into #StoredProcs values ('dbo.DNCachePhoneFormat',',PhoneFormatID','')
insert into #StoredProcs values ('dbo.DNCachePrices',',CountryID','OK. Underlying View (PriceQuartileVW) intentionally does not return values for sa')
--insert into #StoredProcs values ('dbo.DNCachePromoList',',MetroID','') -- 0 Metro ID causes non-uniqueness
insert into #StoredProcs values ('dbo.DNCachePrivateEventFeatureRests ','','')
insert into #StoredProcs values ('dbo.DNCachePrivateEvents ','','')
insert into #StoredProcs values ('dbo.DNCachePrivateEventType ','','')
--insert into #StoredProcs values ('dbo.DNCachePromoOffers','','') -- Only used on .COM
insert into #StoredProcs values ('dbo.DNCachePromoPagesList',',MetroID','')
insert into #StoredProcs values ('dbo.DNCachePromos','','')
insert into #StoredProcs values ('dbo.DNCacheReferrerMessage ','','')
insert into #StoredProcs values ('dbo.DNCacheReferrers','','')
insert into #StoredProcs values ('dbo.DNCacheReservationOffers ',',MetroAreaID,OfferID','')
insert into #StoredProcs values ('dbo.DNCacheRestaurantCuisines',',FoodTypeID','')
insert into #StoredProcs values ('dbo.DNCacheRestaurantDetails ','','')
insert into #StoredProcs values ('dbo.DNCacheRestaurantDomain','','')
insert into #StoredProcs values ('dbo.DNCacheRestaurantFoodTypes',',FTRank','')
insert into #StoredProcs values ('dbo.DNCacheRestaurantGetCentralParkingList ','','')
--insert into #StoredProcs values ('dbo.DNCacheRestaurantGroups',',RestaurantInGroup','') -- uniqueness issues?
--insert into #StoredProcs values ('dbo.DNCacheRestaurantMessages','','OK. Underlying View (RestaurantMessageVW) intentionally does not return values for sa') 
insert into #StoredProcs values ('dbo.DNCacheRestaurantOffers',',offerID','OK. Underlying View (OfferVW) intentionally does not return values for sa')
insert into #StoredProcs values ('dbo.DNCacheRestaurantPaymentTypes',',Payment_Type_ID','')
insert into #StoredProcs values ('dbo.DNCacheRestaurantProfileDetails ','','')
insert into #StoredProcs values ('dbo.DNCacheRestaurantRooms ','','')
--insert into #StoredProcs values ('dbo.DNCacheRestaurantSearchList','','')
insert into #StoredProcs values ('dbo.DNCacheRestaurantSearchList_v2 ','','')
insert into #StoredProcs values ('dbo.DNCacheSeoFooterUrls','','')
insert into #StoredProcs values ('dbo.DNCacheSeoRegion','','')
insert into #StoredProcs values ('dbo.DNCacheSiteMapXML ','','')
insert into #StoredProcs values ('dbo.DNCacheSocialFanPages ','','')
insert into #StoredProcs values ('dbo.DNCacheSocialTypes ','','')
--insert into #StoredProcs values ('dbo.DNCacheStartGeoMacroData ','','') -- Only used on .COM
--insert into #StoredProcs values ('dbo.DNCacheStartGeoPageTabData ','','') -- Only used on .COM
insert into #StoredProcs values ('dbo.DNCacheStartPageBlogEntries ','','')
insert into #StoredProcs values ('dbo.DNCacheStartPageReviews ','','')
--insert into #StoredProcs values ('dbo.DNCacheStartPageTabData ',',MetroTopTenListID,RID','') --Note that this table does not need a key since it will not be used for lookups
insert into #StoredProcs values ('dbo.DNCacheStateList','','')
insert into #StoredProcs values ('dbo.DNCacheStateMetroList',',metroareaID','')
--insert into #StoredProcs values ('dbo.DNCacheTopTenLists',',TopTenListTypeID','') -- brings back inactive, so no real uniqueness
insert into #StoredProcs values ('dbo.DNCacheTopTenRegionalLists ',',TopTenListID','')
insert into #StoredProcs values ('dbo.DNCacheTopTenRegions ',',MacroID','')
insert into #StoredProcs values ('dbo.DNCacheTopTenRestaurants',',TopTenListInstanceID,RID','')
insert into #StoredProcs values ('dbo.DNCacheUserWhiteListDemolandPoints ',',CallerID','')
insert into #StoredProcs values ('dbo.DNCacheWebUsers','','')
insert into #StoredProcs values ('dbo.DNCacheWebValues','','')
insert into #StoredProcs values ('dbo.DNCacheWelcomeMailMetroConfig ','','')
insert into #StoredProcs values ('dbo.DNCacheXMLPartnerList',',partnerid','')
insert into #StoredProcs values ('dbo.DNGetAllEmailTemplates',',LanguageID','') -- Special Case, one of very few that pulls all languages
insert into #StoredProcs values ('dbo.DNGetAllEmailTemplateTagData',',EmailTemplateID','')
insert into #StoredProcs values ('dbo.DNGetPromoDIPExclusionList',',PromoID,RID','')
insert into #StoredProcs values ('dbo.DNGetRefreshOnChangeTimestamps ','','')
insert into #StoredProcs values ('dbo.DNGetRestaurantCustomMessages',',MessageTypeID','OK. Underlying View (RestaurantCustomMessageVW) intentionally does not return values for sa')
insert into #StoredProcs values ('dbo.DNJustAddedGetAll',',Restaurant_ID','')
insert into #StoredProcs values ('dbo.DNListAllActiveRestaurantIncentives',',incentive_ID','')
insert into #StoredProcs values ('dbo.DNListNonIncentivesRestaurant ','','')
insert into #StoredProcs values ('dbo.DNNewYorkMetroRedirect ','','')
insert into #StoredProcs values ('dbo.DNPromoPagesGetAll',',promo','')
--insert into #StoredProcs values ('dbo.DNPromoPagesGetRules','','') -- May fail due to Date uniqueness
insert into #StoredProcs values ('dbo.DNRestaurantCutOff',',searchdt,sname','')
insert into #StoredProcs values ('dbo.DNRestaurantGetBlockedMsg',',BlockedDate','OK. Will not return data from SA')
insert into #StoredProcs values ('dbo.DNRestaurantGetCCDayMsg',',BlockedDate','OK. Will not return data from SA')
insert into #StoredProcs values ('dbo.DNRestaurantGetCustomMsg',',CustomedDate','')
insert into #StoredProcs values ('dbo.DNRestaurantGetDefaultMsg',',LanguageID','') -- Special Case, one of very few that pulls all languages
insert into #StoredProcs values ('dbo.DNRestaurantGetLimitedBooking',',RID','')
insert into #StoredProcs values ('dbo.DNRestaurantIncentive',',incentiveID','')
insert into #StoredProcs values ('dbo.DNRestaurantListBanquetDetails','','OK. Underlying View (RestaurantMessageVW) intentionally does not return values for sa')
insert into #StoredProcs values ('dbo.DNTopTenGetAll','','')
insert into #StoredProcs values ('dbo.DNTopTenRestWinnerListWithRegion ',',RID','')
insert into #StoredProcs values ('dbo.DNValueIDLookups',',ValueID','')
insert into #StoredProcs values ('dbo.GetHolidaysAll',',Holiday_Date,CountryID','OK. Underlying View (HolidaysVW) intentionally does not return values for sa')
insert into #StoredProcs values ('dbo.GetPasswordQuestions ','','')
insert into #StoredProcs values ('dbo.MacroNeighborhoodListAll',',LanguageID','')
insert into #StoredProcs values ('dbo.RestaurantNearby_GetDistanceList ','','')
insert into #StoredProcs values ('dbo.RestaurantUserSimilar_GetList ','','')

-- Insert WebUserRegion
INSERT INTO [#Users] ( [userName], [LanguageID]) VALUES ('WebuserRegion', 1)

declare @dbName nvarchar(1000)
select @dbName = db_name(db_id())

if (@dbName = 'WebDB')
BEGIN
	INSERT INTO [#Users] ( [userName], [LanguageID]) VALUES ('WebUserUS', 1)
	INSERT INTO [#Users] ( [userName], [LanguageID]) VALUES ('WebUserMX', 6)
--	INSERT INTO [#Users] ( [userName], [LanguageID]) VALUES ('WebUserUK', 70)
	INSERT INTO [#Users] ( [userName], [LanguageID]) VALUES ('WebUserUSMX', 1)
	INSERT INTO [#Users] ( [userName], [LanguageID]) VALUES ('WebUserFRCA', 82)
END
else if (@dbName = 'WebDB_ASIA')
BEGIN
	INSERT INTO [#Users] ( [userName], [LanguageID]) VALUES ('WebUserJP', 2)
	INSERT INTO [#Users] ( [userName], [LanguageID]) VALUES ('WebUserENJP', 70)
END
else if (@dbName = 'WebDB_EU')
BEGIN
	INSERT INTO [#Users] ( [userName], [LanguageID]) VALUES ('WebUserDE', 3)
	INSERT INTO [#Users] ( [userName], [LanguageID]) VALUES ('WebUserENDE', 70)
	INSERT INTO [#Users] ( [userName], [LanguageID]) VALUES ('WebUserES', 5)
	INSERT INTO [#Users] ( [userName], [LanguageID]) VALUES ('WebUserFR', 4)
END




DECLARE  @dbuser	 NVARCHAR(200),
		 @LanguageID INT,
		 @ProcName	AS NVARCHAR(200),
		 @ExecProcStatement	AS NVARCHAR(400),
		 @RowCount	AS INT,
		 @ColName  AS NVARCHAR(200),
		 @PrimaryColName  AS NVARCHAR(200),
		 @sql NVARCHAR(4000)

DECLARE cur CURSOR FAST_FORWARD FOR
SELECT 
  [username],
  [languageid],
  [ProcName],
  [colname]
FROM   
  [#users],
  [#StoredProcs]

OPEN cur

FETCH  cur
INTO @dbuser,
	 @LanguageID,
	 @ProcName,
	 @ColName

-- Iterate over views and users. Run a select on each view with each user. Find the unique number of 
-- items in that view with regard to language. We should only return back one per language
WHILE @@fetch_status = 0
BEGIN

	-- Add value to report table in case the second query fails	
	SELECT 
	  @sql = 'INSERT INTO [#Report] ([userName],[LanguageID],[ProcName],[ColumnNames],[PrimaryKeyCount],[Rows],[RegionUserRowCount])'
			   + 'SELECT '''
			   + @dbuser
			   + ''','''
			   + CAST(@LanguageID AS NVARCHAR(10))
			   + ''','''
			   + @ProcName
			   + ''','''
			   + @ColName
			   + ''', -1, -1, -1'
	
	PRINT @sql	
		exec (@sql)

		SET @ExecProcStatement = 'EXEC ' + @dbName + '.' + @ProcName
		
	SELECT 
		@sql  = 'SELECT a.* INTO [##test]
		FROM OPENROWSET(''SQLOLEDB'', ''.'';''' + @dbuser + ''';''0pentab1e'', ''' + @ExecProcStatement + ''') AS a'

	PRINT @sql	
	
	exec (@sql)

	SELECT @RowCount = COUNT(1) FROM ##test

	SELECT @PrimaryColName = c.name
	FROM tempdb..syscolumns c
	INNER JOIN tempdb..sysobjects o
	ON c.id = o.id
	WHERE o.name like '##test%'
	AND colorder = 1

	SET @ColName = @PrimaryColName + @ColName
		
	SELECT 
	  @sql = 'UPDATE #Report set [ROWS] = ' + CAST(@RowCount AS VARCHAR(20)) + ', ' 
			   + '[ColumnNames] = ''' + @ColName + ''', [PrimaryKeyCount] = '
			   + '(SELECT COALESCE((SELECT COUNT(1) FROM [##test] GROUP BY '
			   + @ColName
			   + ' HAVING COUNT(1) > 1),1))'
			   + ' WHERE [userName] = '''
			   + @dbuser
			   + ''' AND [ProcName] = '''
			   + @ProcName
			   + ''' '
	PRINT @sql	

		exec (@sql)

	DROP TABLE ##test


	if @dbuser != 'WebuserRegion'
	BEGIN
		UPDATE #Report SET [RegionUserRowCount] = (Select [ROWS] from #Report WHERE [userName] = 'WebuserRegion' AND [ProcName] = @ProcName)
		WHERE [userName] = @dbuser AND [ProcName] = @ProcName
	END

	-- Update secondary Languages
	if @dbuser = 'WebUserFRCA'
	BEGIN
		UPDATE #Report SET [PrimaryLanguageUserRowCount] = (Select [ROWS] from #Report WHERE [userName] = 'WebUserUS' AND [ProcName] = @ProcName)
		WHERE [userName] = @dbuser AND [ProcName] = @ProcName
	END
	
	if @dbuser = 'WebUserUSMX'
	BEGIN
		UPDATE #Report SET [PrimaryLanguageUserRowCount] = (Select [ROWS] from #Report WHERE [userName] = 'WebUserUS' AND [ProcName] = @ProcName)
		WHERE [userName] = @dbuser AND [ProcName] = @ProcName
	END

	if @dbuser = 'WebUserENJP'
	BEGIN
		UPDATE #Report SET [PrimaryLanguageUserRowCount] = (Select [ROWS] from #Report WHERE [userName] = 'WebUserJP' AND [ProcName] = @ProcName)
		WHERE [userName] = @dbuser AND [ProcName] = @ProcName
	END

	if @dbuser = 'WebUserENDE'
	BEGIN
		UPDATE #Report SET [PrimaryLanguageUserRowCount] = (Select [ROWS] from #Report WHERE [userName] = 'WebUserDE' AND [ProcName] = @ProcName)
		WHERE [userName] = @dbuser AND [ProcName] = @ProcName
	END



	FETCH  cur
	INTO @dbuser,
		 @LanguageID,
		 @ProcName,
		 @ColName
END
	
CLOSE cur
DEALLOCATE cur

UPDATE #report
SET	status = 'OK'
WHERE  [PrimaryKeyCount] = 1

UPDATE #report
SET	status = 'NOT OK! Please Review this Proc!'
WHERE  [PrimaryKeyCount] != 1

UPDATE #report  	
SET status = ( SELECT Note
FROM #StoredProcs
WHERE #StoredProcs.ProcName = #report.ProcName)
WHERE RegionUserRowCount = 0 and (status = 'OK' or status = '')

UPDATE #report
SET	status = 'Not OK! Primary Language User has less info'
WHERE [Rows] > PrimaryLanguageUserRowCount AND (status = 'OK' or status = '') and PrimaryLanguageUserRowCount is not null

/*
-- This additional check would ensure parity between secondary and primary languages, but not sure if we want to enforce it
UPDATE #report
SET	status = 'Not OK! Primary Language User has more info'
WHERE [Rows] < PrimaryLanguageUserRowCount AND (status = 'OK' or status = '') and PrimaryLanguageUserRowCount is not null
*/

UPDATE #report
SET	status = 'Not OK! Region User has less info'
WHERE [Rows] > RegionUserRowCount AND (status = 'OK' or status = '')

UPDATE #report
SET	status = 'OK, no data to return'
WHERE status = ''


SELECT 
  *
FROM   
  #report
WHERE username != 'WebUserRegion'
ORDER by UserName, ProcName

DROP TABLE #StoredProcs
DROP TABLE #users
DROP TABLE #report



go



GRANT EXECUTE ON [DBCheckI18nWebCache] TO ExecuteOnlyRole

GO