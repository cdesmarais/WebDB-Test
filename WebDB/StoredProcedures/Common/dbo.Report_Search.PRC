if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Report_Search]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Report_Search]
GO

CREATE Procedure dbo.Report_Search

@reportDate 	datetime,
@ui		nvarchar(50)

AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON
if @reportDate is null select @reportDate = getdate()
/*
Since Report_Search_SavedResos had a IF statement resulting in 2 seperate recordsets,I had to do
the same thing here.  There are 2 SELECTS below,most of it is the same except for the part that came
from Report_Search_SavedResos.
*/

if @ui = '1,2,3' or @ui = '2,3'
	BEGIN

	SELECT metro.metroareaid,metro.Name,
		/*Previously Report_Search_ByRest*/
		/*************************************/
		COALESCE(Single_Yes,0) AS Single_Yes,
		COALESCE(Single_Prior,0) AS Single_Prior,
		COALESCE(Single_Week,0) AS Single_Week,
		COALESCE(Single_Month,0) AS Single_Month,
		COALESCE(Single_Year,0) AS Single_Year,
		COALESCE(Multi_Yes,0) AS Multi_Yes,
		COALESCE(Multi_Prior,0) AS Multi_Prior,
		COALESCE(Multi_Week,0) AS Multi_Week,
		COALESCE(Multi_Month,0) AS Multi_Month,
		COALESCE(Multi_Year,0) AS Multi_Year,
		/*Previously Report_Search_ByNieghborhood*/
		/*************************************/
	 	COALESCE(n.Yes,0) AS Neighborhood_Yes,
		COALESCE(n.Prior,0) AS Neighborhood_Prior,
		COALESCE(n.Week,0) AS Neighborhood_Week,
		COALESCE(n.Month,0) AS Neighborhood_Month,
		COALESCE(n.Year,0) AS Neighborhood_Year,

		/*************************************/
		/*Previously Report_Search_ByMacroNeighborhood*/
		/*************************************/
		COALESCE(Macro_Yes,0) AS Macro_Yes,
		COALESCE(Macro_Prior,0) AS Macro_Prior,
		COALESCE(Macro_Week,0) AS Macro_Week,
		COALESCE(Macro_Month,0) AS Macro_Month,
		COALESCE(Macro_Year,0) AS Macro_Year,

		/*Billable Resos*/
		/*************************************/
		COALESCE(Resos_Billable_Yes,0) AS Resos_Billable_Yes,
		COALESCE(Resos_Billable_Prior,0) AS Resos_Billable_Prior,
		COALESCE(Resos_Billable_Week,0) AS Resos_Billable_Week,	
		COALESCE(Resos_Billable_Month,0) AS Resos_Billable_Month,
		COALESCE(Resos_Billable_YTD,0) AS Resos_Billable_YTD,
		/*All Resos*/
		/*************************************/
		COALESCE(Resos_Yes,0) AS Resos_Yes,
		COALESCE(Resos_Prior,0) AS Resos_Prior,
		COALESCE(Resos_Week,0) AS Resos_Week,	
		COALESCE(Resos_Month,0) AS Resos_Month,
		COALESCE(Resos_YTD,0) AS Resos_YTD
		/*************************************/
	FROM MetroArea AS metro
		/*Previously Report_Search_ByRest*/
		/***************************************************************************************************/	
		/***************************************************************************************************/	
		LEFT JOIN (
			/*Single Yes*/
			SELECT search_metroareaid,COUNT(br.Search_ID) AS Single_Yes
			FROM Search_ByRestaurant br		
			WHERE datediff(day,br.Search_Log_Date,@reportDate) = 0 AND
				RID NOT LIKE '%,%'
			GROUP BY search_metroareaid
			) AS tSingle_yes ON metro.metroareaid = tSingle_Yes.search_metroareaid
	
		LEFT JOIN (
			/*Single_Prior*/
			SELECT search_metroareaid,COUNT(br.Search_ID) AS Single_Prior
			FROM Search_ByRestaurant br			
			WHERE datediff(month,br.Search_Log_Date,@reportDate) = 1 AND
				RID NOT LIKE '%,%' AND
				CHARINDEX(CAST(UIType AS nvarchar(500)),@ui) > 0
			GROUP BY search_metroareaid
			) AS tSingle_Prior ON metro.metroareaid = tSingle_Prior.search_metroareaid
		LEFT JOIN (
			/*Single_Week*/
			SELECT search_metroareaid,COUNT(br.Search_ID) AS Single_Week
			FROM Search_ByRestaurant br			
			WHERE datediff(day,br.Search_Log_Date,@reportDate) between 0 and 6 And 
				RID NOT LIKE '%,%' AND
				CHARINDEX(CAST(UIType AS nvarchar(500)),@ui) > 0
			GROUP BY search_metroareaid
			) AS tSingle_Week ON metro.metroareaid = tSingle_Week.search_metroareaid
		LEFT JOIN (
			/*Single_Month*/
			SELECT search_metroareaid,COUNT(br.Search_ID) AS Single_Month
			FROM Search_ByRestaurant br
			WHERE datediff(month,br.Search_Log_Date,@reportDate) = 0 AND
				RID NOT LIKE '%,%' AND
				CHARINDEX(CAST(UIType AS nvarchar(500)),@ui) > 0
			GROUP BY search_metroareaid
			) AS tSingle_Month ON metro.metroareaid = tSingle_Month.search_metroareaid
		LEFT JOIN (
			/*Single_Year*/
			SELECT search_metroareaid,COUNT(br.Search_ID) AS Single_Year
			FROM Search_ByRestaurant br			
			WHERE datediff(year,br.Search_Log_Date,@reportDate) = 0 AND 
				datediff(day,br.Search_Log_Date,@reportDate) >= 0 And 
				RID NOT LIKE '%,%' AND
				CHARINDEX(CAST(UIType AS nvarchar(500)),@ui) > 0
			GROUP BY search_metroareaid
			) AS tSingle_Year ON metro.metroareaid = tSingle_Year.search_metroareaid
		LEFT JOIN (
			/*multi_Yes*/
			SELECT search_metroareaid,COUNT(br.Search_ID) AS multi_Yes
			FROM Search_ByRestaurant br			
			WHERE datediff(day,br.Search_Log_Date,@reportDate) = 0 And 	
				RID LIKE '%,%' AND
				CHARINDEX(CAST(UIType AS nvarchar(500)),@ui) > 0
			GROUP BY search_metroareaid
			) AS tMulti_Yes ON metro.metroareaid = tMulti_Yes.search_metroareaid
		LEFT JOIN (
			/*Multi Prior*/
			SELECT search_metroareaid,COUNT(br.Search_ID) AS multi_prior
			FROM Search_ByRestaurant br
			WHERE datediff(month,br.Search_Log_Date,@reportDate) = 1 AND 
				RID LIKE '%,%' AND
				CHARINDEX(CAST(UIType AS nvarchar(500)),@ui) > 0
			GROUP BY search_metroareaid
			) AS tMulti_Prior ON metro.metroareaid = tMulti_Prior.search_metroareaid
		LEFT JOIN (
			/*multi_Week*/
			SELECT search_metroareaid,COUNT(br.Search_ID) AS multi_Week
			FROM Search_ByRestaurant br
			WHERE datediff(day,br.Search_Log_Date,@reportDate) between 0 and 6 And 
				RID LIKE '%,%' AND
				CHARINDEX(CAST(UIType AS nvarchar(500)),@ui) > 0
			GROUP BY search_metroareaid
			) AS tMulti_Week ON metro.metroareaid = tMulti_Week.search_metroareaid
		LEFT JOIN (
			/*multi_Month*/
			SELECT search_metroareaid,COUNT(br.Search_ID) AS multi_Month
			FROM Search_ByRestaurant br
			WHERE datediff(month,br.Search_Log_Date,@reportDate) = 0 AND 
				RID LIKE '%,%' AND
				CHARINDEX(CAST(UIType AS nvarchar(500)),@ui) > 0
			GROUP BY search_metroareaid
			) AS tMulti_Month ON metro.metroareaid = tMulti_Month.search_metroareaid
		LEFT JOIN (
			/*Multi Year*/
			SELECT search_metroareaid,COUNT(br.Search_ID) AS multi_Year
			FROM Search_ByRestaurant br
			WHERE datediff(year,br.Search_Log_Date,@reportDate) = 0 AND 
				datediff(day,br.Search_Log_Date,@reportDate) >= 0 And 
				RID LIKE '%,%' AND
				CHARINDEX(CAST(UIType AS nvarchar(500)),@ui) > 0
			GROUP BY search_metroareaid
			) AS tMulti_Year ON metro.metroareaid = tMulti_Year.search_metroareaid
		/***************************************************************************************************/	
		/*Previously Report_Search_ByNieghborhood*/
		/***************************************************************************************************/	
		LEFT JOIN (
			/*Neighborhood_Yes*/
			SELECT Search_metroareaid,COUNT(Search_ID) AS Neighborhood_Yes
			FROM Search_ByNeighborhood
			WHERE datediff(day,Search_Log_Date,@reportDate) = 0 AND 
				CHARINDEX(CAST(UIType AS nvarchar(20)),@ui) > 0
			GROUP BY Search_metroareaid
			) AS tNeighborhood_Yes ON metro.metroareaid = tNeighborhood_Yes.Search_metroareaid
	
		LEFT JOIN (
			/*Neighborhood_Prior*/
			SELECT Search_metroareaid,COUNT(Search_ID) AS Neighborhood_Prior
			FROM Search_ByNeighborhood
			WHERE datediff(month,Search_Log_Date,@reportDate) = 1 AND 
				CHARINDEX(CAST(UIType AS nvarchar(20)),@ui) > 0
			GROUP BY Search_metroareaid
			) AS tNeighborhood_Prior ON metro.metroareaid = tNeighborhood_Prior.Search_metroareaid
		LEFT JOIN (	
			/*Neighborhood_Week*/
			SELECT Search_metroareaid,COUNT(Search_ID) AS Neighborhood_Week
			FROM Search_ByNeighborhood
			WHERE datediff(day,Search_Log_Date,@reportDate) between 0 and 6 AND  
				CHARINDEX(CAST(UIType AS nvarchar(20)),@ui) > 0
			GROUP BY Search_metroareaid
			) AS tNeighborhood_Week ON metro.metroareaid = tNeighborhood_Week.Search_metroareaid
		LEFT JOIN (
			/*Neighborhood_Month*/
			SELECT Search_metroareaid,COUNT(Search_ID) AS Neighborhood_Month
			FROM Search_ByNeighborhood
			WHERE datediff(month,Search_Log_Date,@reportDate) = 0 AND
				CHARINDEX(CAST(UIType AS nvarchar(20)),@ui) > 0
			GROUP BY Search_metroareaid
			) AS tNeighborhood_Month ON metro.metroareaid = tNeighborhood_Month.Search_metroareaid
		LEFT JOIN (
			/*Neighborhood_Year*/
			SELECT Search_metroareaid,COUNT(Search_ID) AS Neighborhood_Year
			FROM Search_ByNeighborhood
			WHERE datediff(year,Search_Log_Date,@reportDate) = 0 AND 
				datediff(day,Search_Log_Date,@reportDate) >= 0 AND 
				CHARINDEX(CAST(UIType AS nvarchar(20)),@ui) > 0
			GROUP BY Search_metroareaid
			) AS tNeighborhood_Year ON metro.metroareaid = tNeighborhood_Year.Search_metroareaid

		/***************************************************************************************************/	
		/*Report_Search_ByMacroNeighborhood*/
		/***************************************************************************************************/	
		LEFT JOIN	(
				SELECT Search_metroareaid,COUNT(Search_ID) AS Macro_Yes
				FROM Search_ByMacroNeighborhood
				WHERE 	DATEDIFF(DAY,Search_Log_Date,@reportDate) = 0 AND 
					CHARINDEX(CAST(UIType AS nvarchar(500)),@ui) > 0
				GROUP BY Search_metroareaid
				) AS tMacro_Yes ON metro.metroareaid = tMacro_Yes.Search_metroareaid
		LEFT JOIN 	(
				SELECT Search_metroareaid,COUNT(Search_ID) AS Macro_Prior
				FROM Search_ByMacroNeighborhood
				WHERE 	datediff(month,Search_Log_Date,@reportDate) = 1 AND 
					CHARINDEX(CAST(UIType AS nvarchar(500)),@ui) > 0
				GROUP BY Search_metroareaid
				) AS tMacro_Prior ON metro.metroareaid = tMacro_Prior.Search_metroareaid
		LEFT JOIN	(
				SELECT Search_metroareaid,COUNT(Search_ID) AS Macro_Week
				FROM Search_ByMacroNeighborhood
				WHERE datediff(day,Search_Log_Date,@reportDate) between 0 and 6 AND 
					CHARINDEX(CAST(UIType AS nvarchar(500)),@ui) > 0
				GROUP BY Search_metroareaid
				) AS tMacro_Week ON metro.metroareaid = tMacro_Week.Search_metroareaid
		LEFT JOIN	(
				SELECT Search_metroareaid,COUNT(Search_ID) AS Macro_Month
				FROM Search_ByMacroNeighborhood
				WHERE datediff(month,Search_Log_Date,@reportDate) = 0 AND 
					CHARINDEX(CAST(UIType AS nvarchar(500)),@ui) > 0
				GROUP BY Search_metroareaid
				) AS tMacro_Month ON metro.metroareaid = tMacro_Month.Search_metroareaid
		LEFT JOIN	(
				SELECT Search_metroareaid,COUNT(Search_ID) AS Macro_Year
				FROM Search_ByMacroNeighborhood
				WHERE datediff(year,Search_Log_Date,@reportDate) = 0 AND 
					datediff(day,Search_Log_Date,@reportDate) >= 0 AND 
					CHARINDEX(CAST(UIType AS nvarchar(500)),@ui) > 0
				GROUP BY Search_metroareaid
				) AS tMacro_Year ON metro.metroareaid	= tMacro_Year.Search_metroareaid

		/***************************************************************************************************/	
		/*Report_Search_SavedResos*/
		/***************************************************************************************************/	
		LEFT JOIN 	(
				SELECT n.metroareaid,COUNT(r.ResID) AS Resos_Billable_Yes
				FROM Reservation r
					INNER JOIN Restaurant rest ON rest.RID = r.RID
					INNER JOIN Neighborhood n ON n.neighborhoodid = rest.neighborhoodid
				WHERE datediff(day,DateMade,@reportDate) = 0
					AND r.RStateID not in (3,4,8,9,10)
					AND r.PartnerID = 1
				GROUP BY n.metroareaid
				) AS tResos_Billable_Yes ON metro.metroareaid = tResos_Billable_Yes.metroareaid
		LEFT JOIN 	(
				SELECT n.metroareaid,COUNT(r.ResID) AS Resos_Billable_Prior
				FROM Reservation r
					INNER JOIN Restaurant rest ON rest.RID = r.RID
					INNER JOIN Neighborhood n ON n.neighborhoodid = rest.neighborhoodid
				WHERE datediff(month,DateMade,@reportDate) = 1
					AND r.RStateID not in (3,4,8,9,10)
					AND r.PartnerID = 1
				GROUP BY n.metroareaid
				) AS tResos_Billable_Prior ON metro.metroareaid = tResos_Billable_Prior.metroareaid
		LEFT JOIN 	(
				SELECT n.metroareaid,COUNT(r.ResID) AS Resos_Billable_Week
				FROM Reservation r
					INNER JOIN Restaurant rest ON rest.RID = r.RID
					INNER JOIN Neighborhood n ON n.neighborhoodid = rest.neighborhoodid
				WHERE datediff(day,r.DateMade,@reportDate) between 0 and 6
					AND r.RStateID not in (3,4,8,9,10)
					AND r.PartnerID = 1
				GROUP BY n.metroareaid
				) AS tResos_Billable_Week ON metro.metroareaid = tResos_Billable_Week.metroareaid
		LEFT JOIN 	(
				SELECT n.metroareaid,COUNT(r.ResID) AS Resos_Billable_Month
				FROM Reservation r
					INNER JOIN Restaurant rest ON rest.RID = r.RID
					INNER JOIN Neighborhood n ON n.neighborhoodid = rest.neighborhoodid
				WHERE datediff(month,r.DateMade,@reportDate) = 0
					AND r.RStateID not in (3,4,8,9,10)
					AND r.PartnerID = 1
				GROUP BY n.metroareaid
				) AS tResos_Billable_Month ON metro.metroareaid = tResos_Billable_Month.metroareaid
		LEFT JOIN 	(
				SELECT n.metroareaid,COUNT(r.ResID) AS Resos_Billable_YTD
				FROM Reservation r
					INNER JOIN Restaurant rest ON rest.RID = r.RID
					INNER JOIN Neighborhood n ON n.neighborhoodid = rest.neighborhoodid
				WHERE YEAR(r.DateMade) = YEAR(@reportDate)
					AND r.RStateID not in (3,4,8,9,10)
					AND r.PartnerID = 1
				GROUP BY n.metroareaid
				) AS tResos_Billable_YTD ON metro.metroareaid = tResos_Billable_YTD.metroareaid



		/*All Resos*/
		/***************************************************************************************************/	
		LEFT JOIN 	(
				SELECT n.metroareaid,COUNT(r.ResID) AS Resos_Yes
				FROM Reservation r
					INNER JOIN Restaurant rest ON rest.RID = r.RID
					INNER JOIN Neighborhood n ON n.neighborhoodid = rest.neighborhoodid
				WHERE datediff(day,DateMade,@reportDate) = 0
					AND r.PartnerID = 1
				GROUP BY n.metroareaid
				) AS tResos_Yes ON metro.metroareaid = tResos_Yes.metroareaid
		LEFT JOIN 	(
				SELECT n.metroareaid,COUNT(r.ResID) AS Resos_Prior
				FROM Reservation r
					INNER JOIN Restaurant rest ON rest.RID = r.RID
					INNER JOIN Neighborhood n ON n.neighborhoodid = rest.neighborhoodid
				WHERE datediff(month,DateMade,@reportDate) = 1
					AND r.PartnerID = 1
				GROUP BY n.metroareaid
				) AS tResos_Prior ON metro.metroareaid = tResos_Prior.metroareaid
		LEFT JOIN 	(
				SELECT n.metroareaid,COUNT(r.ResID) AS Resos_Week
				FROM Reservation r
					INNER JOIN Restaurant rest ON rest.RID = r.RID
					INNER JOIN Neighborhood n ON n.neighborhoodid = rest.neighborhoodid
				WHERE datediff(day,r.DateMade,@reportDate) between 0 and 6
					AND r.PartnerID = 1
				GROUP BY n.metroareaid
				) AS tResos_Week ON metro.metroareaid = tResos_Week.metroareaid
		LEFT JOIN 	(
				SELECT n.metroareaid,COUNT(r.ResID) AS Resos_Month
				FROM Reservation r
					INNER JOIN Restaurant rest ON rest.RID = r.RID
					INNER JOIN Neighborhood n ON n.neighborhoodid = rest.neighborhoodid
				WHERE datediff(month,r.DateMade,@reportDate) = 0
					AND r.PartnerID = 1
				GROUP BY n.metroareaid
				) AS tResos_Month ON metro.metroareaid = tResos_Month.metroareaid
		LEFT JOIN 	(
				SELECT n.metroareaid,COUNT(r.ResID) AS Resos_YTD
				FROM Reservation r
					INNER JOIN Restaurant rest ON rest.RID = r.RID
					INNER JOIN Neighborhood n ON n.neighborhoodid = rest.neighborhoodid
				WHERE YEAR(r.DateMade) = YEAR(@reportDate)
					AND r.PartnerID = 1
				GROUP BY n.metroareaid
				) AS tResos_YTD ON metro.metroareaid = tResos_YTD.metroareaid
		/***************************************************************************************************/	
	WHERE metro.metroareaid <> 1
	ORDER BY metro.Name

	END

ELSE
	BEGIN

	SELECT metro.metroareaid,metro.Name,
		/*Previously Report_Search_ByRest*/
		/*************************************/
		COALESCE(Single_Yes,0) AS Single_Yes,
		COALESCE(Single_Prior,0) AS Single_Prior,
		COALESCE(Single_Week,0) AS Single_Week,
		COALESCE(Single_Month,0) AS Single_Month,
		COALESCE(Single_Year,0) AS Single_Year,
		COALESCE(Multi_Yes,0) AS Multi_Yes,
		COALESCE(Multi_Prior,0) AS Multi_Prior,
		COALESCE(Multi_Week,0) AS Multi_Week,
		COALESCE(Multi_Month,0) AS Multi_Month,
		COALESCE(Multi_Year,0) AS Multi_Year,
		/*Previously Report_Search_ByNieghborhood*/
		/*************************************/
	 	COALESCE(n.Yes,0) AS Neighborhood_Yes,
		COALESCE(n.Prior,0) AS Neighborhood_Prior,
		COALESCE(n.Week,0) AS Neighborhood_Week,
		COALESCE(n.Month,0) AS Neighborhood_Month,
		COALESCE(n.Year,0) AS Neighborhood_Year,
		/*************************************/
		/*Previously Report_Search_ByMacroNeighborhood*/
		/*************************************/
		COALESCE(Macro_Yes,0) AS Macro_Yes,
		COALESCE(Macro_Prior,0) AS Macro_Prior,
		COALESCE(Macro_Week,0) AS Macro_Week,
		COALESCE(Macro_Month,0) AS Macro_Month,
		COALESCE(Macro_Year,0) AS Macro_Year,

		/*Report_Search_SavedResos*/
		/*************************************/
		COALESCE(Resos_Billable_Yes,0) AS Resos_Billable_Yes,
		COALESCE(Resos_Billable_Prior,0) AS Resos_Billable_Prior,
		COALESCE(Resos_Billable_Week,0) AS Resos_Billable_Week,	
		COALESCE(Resos_Billable_Month,0) AS Resos_Billable_Month,
		COALESCE(Resos_Billable_YTD,0) AS Resos_Billable_YTD,
		/*All Resos*/
		/*************************************/
		COALESCE(Resos_Yes,0) AS Resos_Yes,
		COALESCE(Resos_Prior,0) AS Resos_Prior,
		COALESCE(Resos_Week,0) AS Resos_Week,	
		COALESCE(Resos_Month,0) AS Resos_Month,
		COALESCE(Resos_YTD,0) AS Resos_YTD
		/*************************************/
	FROM MetroArea AS metro
		/*Previously Report_Search_ByRest*/
		/***************************************************************************************************/	
		/***************************************************************************************************/	
		LEFT JOIN (
			/*Single Yes*/
			SELECT search_metroareaid,COUNT(br.Search_ID) AS Single_Yes
			FROM Search_ByRestaurant br		
			WHERE datediff(day,br.Search_Log_Date,@reportDate) = 0 AND
				RID NOT LIKE '%,%'
			GROUP BY search_metroareaid
			) AS tSingle_yes ON metro.metroareaid = tSingle_Yes.search_metroareaid
	
		LEFT JOIN (
			/*Single_Prior*/
			SELECT search_metroareaid,COUNT(br.Search_ID) AS Single_Prior
			FROM Search_ByRestaurant br			
			WHERE datediff(month,br.Search_Log_Date,@reportDate) = 1 AND
				RID NOT LIKE '%,%' AND
				CHARINDEX(CAST(UIType AS nvarchar(500)),@ui) > 0
			GROUP BY search_metroareaid
			) AS tSingle_Prior ON metro.metroareaid = tSingle_Prior.search_metroareaid
		LEFT JOIN (
			/*Single_Week*/
			SELECT search_metroareaid,COUNT(br.Search_ID) AS Single_Week
			FROM Search_ByRestaurant br			
			WHERE datediff(day,br.Search_Log_Date,@reportDate) between 0 and 6 And 
				RID NOT LIKE '%,%' AND
				CHARINDEX(CAST(UIType AS nvarchar(500)),@ui) > 0
			GROUP BY search_metroareaid
			) AS tSingle_Week ON metro.metroareaid = tSingle_Week.search_metroareaid
		LEFT JOIN (
			/*Single_Month*/
			SELECT search_metroareaid,COUNT(br.Search_ID) AS Single_Month
			FROM Search_ByRestaurant br
			WHERE datediff(month,br.Search_Log_Date,@reportDate) = 0 AND
				RID NOT LIKE '%,%' AND
				CHARINDEX(CAST(UIType AS nvarchar(500)),@ui) > 0
			GROUP BY search_metroareaid
			) AS tSingle_Month ON metro.metroareaid = tSingle_Month.search_metroareaid
		LEFT JOIN (
			/*Single_Year*/
			SELECT search_metroareaid,COUNT(br.Search_ID) AS Single_Year
			FROM Search_ByRestaurant br			
			WHERE datediff(year,br.Search_Log_Date,@reportDate) = 0 AND 
				datediff(day,br.Search_Log_Date,@reportDate) >= 0 And 
				RID NOT LIKE '%,%' AND
				CHARINDEX(CAST(UIType AS nvarchar(500)),@ui) > 0
			GROUP BY search_metroareaid
			) AS tSingle_Year ON metro.metroareaid = tSingle_Year.search_metroareaid
		LEFT JOIN (
			/*multi_Yes*/
			SELECT search_metroareaid,COUNT(br.Search_ID) AS multi_Yes
			FROM Search_ByRestaurant br			
			WHERE datediff(day,br.Search_Log_Date,@reportDate) = 0 And 	
				RID LIKE '%,%' AND
				CHARINDEX(CAST(UIType AS nvarchar(500)),@ui) > 0
			GROUP BY search_metroareaid
			) AS tMulti_Yes ON metro.metroareaid = tMulti_Yes.search_metroareaid
		LEFT JOIN (
			/*Multi Prior*/
			SELECT search_metroareaid,COUNT(br.Search_ID) AS multi_prior
			FROM Search_ByRestaurant br
			WHERE datediff(month,br.Search_Log_Date,@reportDate) = 1 AND 
				RID LIKE '%,%' AND
				CHARINDEX(CAST(UIType AS nvarchar(500)),@ui) > 0
			GROUP BY search_metroareaid
			) AS tMulti_Prior ON metro.metroareaid = tMulti_Prior.search_metroareaid
		LEFT JOIN (
			/*multi_Week*/
			SELECT search_metroareaid,COUNT(br.Search_ID) AS multi_Week
			FROM Search_ByRestaurant br
			WHERE datediff(day,br.Search_Log_Date,@reportDate) between 0 and 6 And 
				RID LIKE '%,%' AND
				CHARINDEX(CAST(UIType AS nvarchar(500)),@ui) > 0
			GROUP BY search_metroareaid
			) AS tMulti_Week ON metro.metroareaid = tMulti_Week.search_metroareaid
		LEFT JOIN (
			/*multi_Month*/
			SELECT search_metroareaid,COUNT(br.Search_ID) AS multi_Month
			FROM Search_ByRestaurant br
			WHERE datediff(month,br.Search_Log_Date,@reportDate) = 0 AND 
				RID LIKE '%,%' AND
				CHARINDEX(CAST(UIType AS nvarchar(500)),@ui) > 0
			GROUP BY search_metroareaid
			) AS tMulti_Month ON metro.metroareaid = tMulti_Month.search_metroareaid
		LEFT JOIN (
			/*Multi Year*/
			SELECT search_metroareaid,COUNT(br.Search_ID) AS multi_Year
			FROM Search_ByRestaurant br
			WHERE datediff(year,br.Search_Log_Date,@reportDate) = 0 AND 
				datediff(day,br.Search_Log_Date,@reportDate) >= 0 And 
				RID LIKE '%,%' AND
				CHARINDEX(CAST(UIType AS nvarchar(500)),@ui) > 0
			GROUP BY search_metroareaid
			) AS tMulti_Year ON metro.metroareaid = tMulti_Year.search_metroareaid
		/***************************************************************************************************/	
		/*Previously Report_Search_ByNieghborhood*/
		/***************************************************************************************************/	
		LEFT JOIN (
			/*Neighborhood_Yes*/
			SELECT Search_metroareaid,COUNT(Search_ID) AS Neighborhood_Yes
			FROM Search_ByNeighborhood
			WHERE datediff(day,Search_Log_Date,@reportDate) = 0 AND 
				CHARINDEX(CAST(UIType AS nvarchar(20)),@ui) > 0
			GROUP BY Search_metroareaid
			) AS tNeighborhood_Yes ON metro.metroareaid = tNeighborhood_Yes.Search_metroareaid
	
		LEFT JOIN (
			/*Neighborhood_Prior*/
			SELECT Search_metroareaid,COUNT(Search_ID) AS Neighborhood_Prior
			FROM Search_ByNeighborhood
			WHERE datediff(month,Search_Log_Date,@reportDate) = 1 AND 
				CHARINDEX(CAST(UIType AS nvarchar(20)),@ui) > 0
			GROUP BY Search_metroareaid
			) AS tNeighborhood_Prior ON metro.metroareaid = tNeighborhood_Prior.Search_metroareaid
		LEFT JOIN (	
			/*Neighborhood_Week*/
			SELECT Search_metroareaid,COUNT(Search_ID) AS Neighborhood_Week
			FROM Search_ByNeighborhood
			WHERE datediff(day,Search_Log_Date,@reportDate) between 0 and 6 AND  
				CHARINDEX(CAST(UIType AS nvarchar(20)),@ui) > 0
			GROUP BY Search_metroareaid
			) AS tNeighborhood_Week ON metro.metroareaid = tNeighborhood_Week.Search_metroareaid
		LEFT JOIN (
			/*Neighborhood_Month*/
			SELECT Search_metroareaid,COUNT(Search_ID) AS Neighborhood_Month
			FROM Search_ByNeighborhood
			WHERE datediff(month,Search_Log_Date,@reportDate) = 0 AND
				CHARINDEX(CAST(UIType AS nvarchar(20)),@ui) > 0
			GROUP BY Search_metroareaid
			) AS tNeighborhood_Month ON metro.metroareaid = tNeighborhood_Month.Search_metroareaid
		LEFT JOIN (
			/*Neighborhood_Year*/
			SELECT Search_metroareaid,COUNT(Search_ID) AS Neighborhood_Year
			FROM Search_ByNeighborhood
			WHERE datediff(year,Search_Log_Date,@reportDate) = 0 AND 
				datediff(day,Search_Log_Date,@reportDate) >= 0 AND 
				CHARINDEX(CAST(UIType AS nvarchar(20)),@ui) > 0
			GROUP BY Search_metroareaid
			) AS tNeighborhood_Year ON metro.metroareaid = tNeighborhood_Year.Search_metroareaid

		/***************************************************************************************************/	
		/*Report_Search_ByMacroNeighborhood*/
		/***************************************************************************************************/	
		LEFT JOIN	(
				SELECT Search_metroareaid,COUNT(Search_ID) AS Macro_Yes
				FROM Search_ByMacroNeighborhood
				WHERE 	DATEDIFF(DAY,Search_Log_Date,@reportDate) = 0 AND 
					CHARINDEX(CAST(UIType AS nvarchar(500)),@ui) > 0
				GROUP BY Search_metroareaid
				) AS tMacro_Yes ON metro.metroareaid = tMacro_Yes.Search_metroareaid
		LEFT JOIN 	(
				SELECT Search_metroareaid,COUNT(Search_ID) AS Macro_Prior
				FROM Search_ByMacroNeighborhood
				WHERE 	datediff(month,Search_Log_Date,@reportDate) = 1 AND 
					CHARINDEX(CAST(UIType AS nvarchar(500)),@ui) > 0
				GROUP BY Search_metroareaid
				) AS tMacro_Prior ON metro.metroareaid = tMacro_Prior.Search_metroareaid
		LEFT JOIN	(
				SELECT Search_metroareaid,COUNT(Search_ID) AS Macro_Week
				FROM Search_ByMacroNeighborhood
				WHERE datediff(day,Search_Log_Date,@reportDate) between 0 and 6 AND 
					CHARINDEX(CAST(UIType AS nvarchar(500)),@ui) > 0
				GROUP BY Search_metroareaid
				) AS tMacro_Week ON metro.metroareaid = tMacro_Week.Search_metroareaid
		LEFT JOIN	(
				SELECT Search_metroareaid,COUNT(Search_ID) AS Macro_Month
				FROM Search_ByMacroNeighborhood
				WHERE datediff(month,Search_Log_Date,@reportDate) = 0 AND 
					CHARINDEX(CAST(UIType AS nvarchar(500)),@ui) > 0
				GROUP BY Search_metroareaid
				) AS tMacro_Month ON metro.metroareaid = tMacro_Month.Search_metroareaid
		LEFT JOIN	(
				SELECT Search_metroareaid,COUNT(Search_ID) AS Macro_Year
				FROM Search_ByMacroNeighborhood
				WHERE datediff(year,Search_Log_Date,@reportDate) = 0 AND 
					datediff(day,Search_Log_Date,@reportDate) >= 0 AND 
					CHARINDEX(CAST(UIType AS nvarchar(500)),@ui) > 0
				GROUP BY Search_metroareaid
				) AS tMacro_Year ON metro.metroareaid	= tMacro_Year.Search_metroareaid

		/***************************************************************************************************/	
		/***************************************************************************************************/	
		

		LEFT JOIN 	(
				SELECT n.metroareaid,COUNT(r.ResID) AS Resos_Billable_Yes
				FROM Reservation r
					INNER JOIN Restaurant rest ON rest.RID = r.RID
					INNER JOIN Neighborhood n ON n.neighborhoodid = rest.neighborhoodid
				WHERE datediff(day,DateMade,@reportDate) = 0
					AND r.RStateID not in (3,4,8,9,10)
					AND r.PartnerID = 1
				GROUP BY n.metroareaid
				) AS tResos_Billable_Yes ON metro.metroareaid = tResos_Billable_Yes.metroareaid
		LEFT JOIN 	(
				SELECT n.metroareaid,COUNT(r.ResID) AS Resos_Billable_Prior
				FROM Reservation r
					INNER JOIN Restaurant rest ON rest.RID = r.RID
					INNER JOIN Neighborhood n ON n.neighborhoodid = rest.neighborhoodid
				WHERE datediff(month,DateMade,@reportDate) = 1
					AND r.RStateID not in (3,4,8,9,10)
					AND r.PartnerID = 1
				GROUP BY n.metroareaid
				) AS tResos_Billable_Prior ON metro.metroareaid = tResos_Billable_Prior.metroareaid
		LEFT JOIN 	(
				SELECT n.metroareaid,COUNT(r.ResID) AS Resos_Billable_Week
				FROM Reservation r
					INNER JOIN Restaurant rest ON rest.RID = r.RID
					INNER JOIN Neighborhood n ON n.neighborhoodid = rest.neighborhoodid
				WHERE datediff(day,r.DateMade,@reportDate) between 0 and 6
					AND r.RStateID not in (3,4,8,9,10)
					AND r.PartnerID = 1
				GROUP BY n.metroareaid
				) AS tResos_Billable_Week ON metro.metroareaid = tResos_Billable_Week.metroareaid
		LEFT JOIN 	(
				SELECT n.metroareaid,COUNT(r.ResID) AS Resos_Billable_Month
				FROM Reservation r
					INNER JOIN Restaurant rest ON rest.RID = r.RID
					INNER JOIN Neighborhood n ON n.neighborhoodid = rest.neighborhoodid
				WHERE datediff(month,r.DateMade,@reportDate) = 0
					AND r.RStateID not in (3,4,8,9,10)
					AND r.PartnerID = 1
				GROUP BY n.metroareaid
				) AS tResos_Billable_Month ON metro.metroareaid = tResos_Billable_Month.metroareaid
		LEFT JOIN 	(
				SELECT n.metroareaid,COUNT(r.ResID) AS Resos_Billable_YTD
				FROM Reservation r
					INNER JOIN Restaurant rest ON rest.RID = r.RID
					INNER JOIN Neighborhood n ON n.neighborhoodid = rest.neighborhoodid
				WHERE YEAR(r.DateMade) = YEAR(@reportDate)
					AND r.RStateID not in (3,4,8,9,10)
					AND r.PartnerID = 1
				GROUP BY n.metroareaid
				) AS tResos_Billable_YTD ON metro.metroareaid = tResos_Billable_YTD.metroareaid

		/*All Resos*/
		/***************************************************************************************************/	
		LEFT JOIN 	(
				SELECT n.metroareaid,COUNT(r.ResID) AS Resos_Yes
				FROM Reservation r
					INNER JOIN Restaurant rest ON rest.RID = r.RID
					INNER JOIN Neighborhood n ON n.neighborhoodid = rest.neighborhoodid
				WHERE datediff(day,DateMade,@reportDate) = 0
					AND r.PartnerID = 1
				GROUP BY n.metroareaid
				) AS tResos_Yes ON metro.metroareaid = tResos_Yes.metroareaid
		LEFT JOIN 	(
				SELECT n.metroareaid,COUNT(r.ResID) AS Resos_Prior
				FROM Reservation r
					INNER JOIN Restaurant rest ON rest.RID = r.RID
					INNER JOIN Neighborhood n ON n.neighborhoodid = rest.neighborhoodid
				WHERE datediff(month,DateMade,@reportDate) = 1
					AND r.PartnerID = 1
				GROUP BY n.metroareaid
				) AS tResos_Prior ON metro.metroareaid = tResos_Prior.metroareaid
		LEFT JOIN 	(
				SELECT n.metroareaid,COUNT(r.ResID) AS Resos_Week
				FROM Reservation r
					INNER JOIN Restaurant rest ON rest.RID = r.RID
					INNER JOIN Neighborhood n ON n.neighborhoodid = rest.neighborhoodid
				WHERE datediff(day,r.DateMade,@reportDate) between 0 and 6
					AND r.PartnerID = 1
				GROUP BY n.metroareaid
				) AS tResos_Week ON metro.metroareaid = tResos_Week.metroareaid
		LEFT JOIN 	(
				SELECT n.metroareaid,COUNT(r.ResID) AS Resos_Month
				FROM Reservation r
					INNER JOIN Restaurant rest ON rest.RID = r.RID
					INNER JOIN Neighborhood n ON n.neighborhoodid = rest.neighborhoodid
				WHERE datediff(month,r.DateMade,@reportDate) = 0
					AND r.PartnerID = 1
				GROUP BY n.metroareaid
				) AS tResos_Month ON metro.metroareaid = tResos_Month.metroareaid
		LEFT JOIN 	(
				SELECT n.metroareaid,COUNT(r.ResID) AS Resos_YTD
				FROM Reservation r
					INNER JOIN Restaurant rest ON rest.RID = r.RID
					INNER JOIN Neighborhood n ON n.neighborhoodid = rest.neighborhoodid
				WHERE YEAR(r.DateMade) = YEAR(@reportDate)
					AND r.PartnerID = 1
				GROUP BY n.metroareaid
				) AS tResos_YTD ON metro.metroareaid = tResos_YTD.metroareaid
		/***************************************************************************************************/	


	WHERE metro.metroareaid <> 1
	ORDER BY metro.Name

	END

GO

GRANT EXECUTE ON [Report_Search] TO ExecuteOnlyRole

GO
