if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DBCheckI18nOTReportViews]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DBCheckI18nOTReportViews]
GO

CREATE Procedure dbo.DBCheckI18nOTReportViews
 
As

-- Create Temp table for all views
CREATE TABLE #Views
(
	ViewName NVARCHAR(200),
	ColName NVARCHAR(200)
)

-- Create Temp table for final
CREATE TABLE #Report
(
	viewname NVARCHAR(200),
	PrimaryKeyCount INT,
	Rows INT,
	ColumnNames NVARCHAR(400),
	Status NVARCHAR(400)
)


-- Insert all views that have local info in them

INSERT INTO [#Views] ( [ViewName], [ColName] ) VALUES ( N'VWebDB_MetroArea', N'MetroAreaID' ) 
INSERT INTO [#Views] ( [ViewName], [ColName] ) VALUES ( N'VWebDB_Neighborhood', N'NeighborhoodID' ) 
INSERT INTO [#Views] ( [ViewName], [ColName] ) VALUES ( N'VWebDB_PointsAdjustmentReason', N'AdjReasonID' ) 
INSERT INTO [#Views] ( [ViewName], [ColName] ) VALUES ( N'VWebDB_position', N'PositionID' ) 
INSERT INTO [#Views] ( [ViewName], [ColName] ) VALUES ( N'VWebDB_Promos', N'PromoID' ) 
INSERT INTO [#Views] ( [ViewName], [ColName] ) VALUES ( N'VWebDB_PromoType', N'PromoTypeID' ) 
--INSERT INTO [#Views] ( [ViewName], [ColName] ) VALUES ( N'VWebDB_ReservationChange', N'ResID' )  -- No Uniqueness
INSERT INTO [#Views] ( [ViewName], [ColName] ) VALUES ( N'VWebDB_Restaurant', N'RID' ) 
INSERT INTO [#Views] ( [ViewName], [ColName] ) VALUES ( N'VWebDB_RestaurantDetailVW', N'RID' ) 
INSERT INTO [#Views] ( [ViewName], [ColName] ) VALUES ( N'VWebDB_RestaurantJustAdded', N'RID' ) 
INSERT INTO [#Views] ( [ViewName], [ColName] ) VALUES ( N'VWebDB_RestaurantState', N'RestStateID' ) 

INSERT INTO [#Views] ( [ViewName], [ColName] ) VALUES ( N'VWebDB_Reservation', N'ResID' ) 
INSERT INTO [#Views] ( [ViewName], [ColName] ) VALUES ( N'VWebDB_ReservationVW', N'ResID' ) 


--INSERT INTO [#Views] ( [ViewName], [ColName] ) VALUES ( N'OTRPFinanceExtractBillableVW', N'ResID' ) 
--INSERT INTO [#Views] ( [ViewName], [ColName] ) VALUES ( N'OTRPFinanceExtractVW', N'ResID' ) 
--INSERT INTO [#Views] ( [ViewName], [ColName] ) VALUES ( N'OTRPMonthlyAcctSummaryFULLVW', N'ResID' ) 
INSERT INTO [#Views] ( [ViewName], [ColName] ) VALUES ( N'OTRPMonthlyAcctSummaryVW', N'RID,ReportDT,ROMSID' ) 
--INSERT INTO [#Views] ( [ViewName], [ColName] ) VALUES ( N'OTRPMonthlyRestSummaryVW', N'RID' ) 
--INSERT INTO [#Views] ( [ViewName], [ColName] ) VALUES ( N'OTRPYTDRestSummaryVW', N'RID' ) 
INSERT INTO [#Views] ( [ViewName], [ColName] ) VALUES ( N'OTRPRestaurantVW', N'RID' ) 


DECLARE  @dbuser	 NVARCHAR(200),
		 @LanguageID INT,
		 @ViewName	AS NVARCHAR(200)
DECLARE  @ColName  AS NVARCHAR(200)
DECLARE  @sql NVARCHAR(4000)

DECLARE cur CURSOR FAST_FORWARD FOR
SELECT 
  [viewname],
  [colname]
FROM   
  [#views]

OPEN cur

FETCH  cur
INTO @ViewName,
	 @ColName

-- Iterate over views and users. Run a select on each view with each user. Find the unique number of 
-- items in that view with regard to language. We should only return back one per language
WHILE @@fetch_status = 0
BEGIN
	
	-- Add value to report table in case the second query fails	
	SELECT 
	  @sql = 'INSERT INTO [#Report] ([viewname],[ColumnNames],[PrimaryKeyCount],[Rows])'
			   + 'SELECT '''
			   + @ViewName
			   + ''','''
			   + @ColName
			   + ''', -1,1'
						
	PRINT @sql	
		exec (@sql)
	
	SELECT 
	  @sql = 'UPDATE #Report set [Rows] = (SELECT COUNT(*) FROM OTReports.dbo.' + @ViewName + ')'
			   + ' WHERE [viewname] = '''
			   + @ViewName
			   + ''' '

	PRINT @sql	
		exec (@sql)

	
	SELECT 
	  @sql = 'UPDATE #Report set [PrimaryKeyCount] = '
			   + '(SELECT COALESCE((SELECT COUNT(*) FROM OTReports.dbo.'
			   + @ViewName
			   + ' GROUP BY '
			   + @ColName
			   + ' HAVING COUNT(1) > 1),1))'
			   + ' WHERE [viewname] = '''
			   + @ViewName
			   + ''' '
	PRINT @sql	
		exec (@sql)


	SETUSER 

	FETCH  cur
	INTO @ViewName,
		 @ColName
END
	
CLOSE cur
DEALLOCATE cur

UPDATE #report
SET	status = 'OK'
WHERE  [PrimaryKeyCount] = 1

UPDATE #report
SET	status = 'NOT OK! Please Review This View!'
WHERE  [PrimaryKeyCount] != 1

SELECT 
  *
FROM   
  #report
ORDER by status

DROP TABLE #views
DROP TABLE #report



go

GRANT EXECUTE ON [DBCheckI18nOTReportViews] TO ExecuteOnlyRole

GO
