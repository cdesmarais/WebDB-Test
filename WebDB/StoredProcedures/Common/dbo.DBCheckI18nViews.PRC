if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DBCheckI18nViews]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DBCheckI18nViews]
GO

CREATE Procedure dbo.DBCheckI18nViews
 
As

-- Create Temp table for all views
CREATE TABLE #Views
(
	ViewName NVARCHAR(200),
	ColName NVARCHAR(200)
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
	viewname NVARCHAR(200),
	PrimaryKeyUnique INT,
	Rows INT,
	ColumnNames NVARCHAR(400),
	Status NVARCHAR(400)
)


-- Insert all views that have local info in them
INSERT INTO [#Views] (
	[ViewName],
	[ColName]	
) 
SELECT 
  o.[name],
  co.name
FROM   
  dbo.sysobjects o
  INNER JOIN dbo.syscomments c
	ON o.[id] = c.[id]
  INNER JOIN dbo.syscolumns co
	ON co.id = o.id
WHERE  o.xtype = 'v'
AND o.[name] LIKE '%VW'
--AND o.[name] NOT LIKE '%AVW' COLLATE sql_latin1_general_cp1_cs_as
AND o.[name] != 'RestNameChangeVW'
AND o.[name] != '_RestaurantVW'
AND o.[name] != 'OTConReservationDetailVW'
AND o.[name] != 'GlobalRestaurantVW'
AND (TEXT LIKE '%local%'
	  OR TEXT LIKE '%LanguageID%')
	  --OR o.[name] = 'GlobalReservationRPTSummaryVW'
	  --OR (o.[name] = 'GlobalRestaurantVW' and @@SERVERNAME like 'OTSQL%')) -- This Check is only done in production
AND colorder = 1


-- Add Second columnNames Manually. This is our white list.
UPDATE [#views]
SET	[colname] = [colname]
					 + ',MessageTypeID'
WHERE  [viewname] in ('RestaurantCustomMessageVW','RestaurantCustomMessageAVW')

UPDATE [#views]
SET	[colname] = [colname]
					 + ',CurrencyType,CountryID'
WHERE  [viewname] in ('PriceQuartileVW','PriceQuartileAVW')

UPDATE [#views]
SET	[colname] = [colname]
					 + ',TopTenListInstanceID, RID'
WHERE  [viewname] in ('TopTenRestaurantVW','TopTenRestaurantAVW')

UPDATE [#views]
SET	[colname] = [colname]
					 + ',ReportDate'
WHERE  [viewname] in ('GlobalReservationRPTSummaryVW','GlobalReservationRPTSummaryAVW')

UPDATE [#views]
SET	[colname] = [colname]
					 + ',OfferDescription'
WHERE  [viewname] in ('GlobalOffersReportVW')

UPDATE [#views]
SET	[colname] = [colname]
					 + ',OfferTypeAttributeKeyID'
WHERE  [viewname] in ('OfferTypeAttributeKeyLookupVW')

UPDATE [#views]
SET	[colname] = [colname]
					 + ',CountryID'
WHERE  [viewname] in ('RestaurantOfferBeverageScopeAVW','RestaurantOfferComplimentaryItemAVW','RestaurantOfferMealDiscountItemAVW','RestaurantOfferTypeAVW','RestaurantOfferRequiredItemAVW','RestaurantOfferDiscountedItemAVW','RestaurantOfferBeverageDiscountItemAVW','RestaurantOfferBeverageScopeVW','RestaurantOfferComplimentaryItemVW','RestaurantOfferMealDiscountItemVW','RestaurantOfferRequiredItemVW','RestaurantOfferDiscountedItemVW','RestaurantOfferBeverageDiscountItemVW')



UPDATE [#views]
SET	[colname] = [colname]
					 + ',LanguageID'
WHERE  [viewname] LIKE '%AVW' COLLATE sql_latin1_general_cp1_cs_as


-- Insert WebReadRegion
INSERT INTO [#Users] ( [userName], [LanguageID]) VALUES ('WebReadRegion', 1)

declare @dbName nvarchar(1000)
select @dbName = db_name(db_id())

if (@dbName = 'WebDB')
BEGIN
	INSERT INTO [#Users] ( [userName], [LanguageID]) VALUES ('WebReadUS', 1)
	INSERT INTO [#Users] ( [userName], [LanguageID]) VALUES ('WebReadMX', 6)
--	INSERT INTO [#Users] ( [userName], [LanguageID]) VALUES ('WebReadUK', 70)
	INSERT INTO [#Users] ( [userName], [LanguageID]) VALUES ('WebReadUSMX', 1)
	INSERT INTO [#Users] ( [userName], [LanguageID]) VALUES ('WebReadFRCA', 82)
END
else if (@dbName = 'WebDB_ASIA')
BEGIN
	INSERT INTO [#Users] ( [userName], [LanguageID]) VALUES ('WebReadJP', 2)
	INSERT INTO [#Users] ( [userName], [LanguageID]) VALUES ('WebReadENJP', 70)
END
else if (@dbName = 'WebDB_EU')
BEGIN
	INSERT INTO [#Users] ( [userName], [LanguageID]) VALUES ('WebReadDE', 3)
	INSERT INTO [#Users] ( [userName], [LanguageID]) VALUES ('WebReadENDE', 70)
	INSERT INTO [#Users] ( [userName], [LanguageID]) VALUES ('WebReadES', 5)
	INSERT INTO [#Users] ( [userName], [LanguageID]) VALUES ('WebReadFR', 4)
END


DECLARE  @dbuser	 NVARCHAR(200),
		 @LanguageID INT,
		 @ViewName	AS NVARCHAR(200)
DECLARE  @ColName  AS NVARCHAR(200)
DECLARE  @sql NVARCHAR(4000)

DECLARE cur CURSOR FAST_FORWARD FOR
SELECT 
  [username],
  [languageid],
  [viewname],
  [colname]
FROM   
  [#users],
  [#views]

OPEN cur

FETCH  cur
INTO @dbuser,
	 @LanguageID,
	 @ViewName,
	 @ColName

-- Iterate over views and users. Run a select on each view with each user. Find the unique number of 
-- items in that view with regard to language. We should only return back one per language
WHILE @@fetch_status = 0
BEGIN
	EXECUTE AS USER = @dbuser
	
	-- Add value to report table in case the second query fails	
	SELECT 
	  @sql = 'INSERT INTO [#Report] ([userName],[LanguageID],[viewname],[ColumnNames],[PrimaryKeyUnique],[Rows])'
			   + 'SELECT '''
			   + @dbuser
			   + ''','''
			   + CAST(@LanguageID AS NVARCHAR(10))
			   + ''','''
			   + @ViewName
			   + ''','''
			   + @ColName
			   + ''', -1,1'
						
	PRINT @sql	
		exec (@sql)

	REVERT 

	SELECT 
	  @sql = 'UPDATE #Report set [Rows] = (SELECT COUNT(1) FROM ' + @ViewName + ')'
			   + ' WHERE [userName] = '''
			   + @dbuser
			   + ''' AND [viewname] = '''
			   + @ViewName
			   + ''' '

	PRINT @sql	
		exec (@sql)

	-- TODO: Select count distinct Language ID from table for the user
	SELECT 
	  @sql = 'UPDATE #Report set [PrimaryKeyUnique] = '
			   + '(SELECT COALESCE((SELECT COUNT(1) FROM ['
			   + @ViewName
			   + '] GROUP BY '
			   + @ColName
			   + ' HAVING COUNT(1) > 1),1))'
			   + ' WHERE [userName] = '''
			   + @dbuser
			   + ''' AND [viewname] = '''
			   + @ViewName
			   + ''' '
	PRINT @sql	
		exec (@sql)

	FETCH  cur
	INTO @dbuser,
		 @LanguageID,
		 @ViewName,
		 @ColName
END
	
CLOSE cur
DEALLOCATE cur

UPDATE #report
SET	status = 'OK'
WHERE  [PrimaryKeyUnique] = 1

UPDATE #report
SET	status = 'NOT OK! Please Review This View!'
WHERE  [PrimaryKeyUnique] != 1

SELECT 
  *
FROM   
  #report
ORDER by UserName, ViewName


DROP TABLE #views
DROP TABLE #users
DROP TABLE #report



go

GRANT EXECUTE ON [DBCheckI18nViews] TO ExecuteOnlyRole

GO
