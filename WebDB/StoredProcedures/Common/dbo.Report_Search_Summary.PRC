if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Report_Search_Summary]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Report_Search_Summary]
GO

CREATE PROCEDURE dbo.Report_Search_Summary

@reportDate 	datetime,
@ui		nvarchar(50)

AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON

If @reportDate is null select @reportDate = getdate()

IF @ui = '1,2,3' or @ui = '2,3'
	BEGIN

	SELECT metro.MetroAreaID, metro.MetroAreaName, 
		/*Previously Report_Search_ByRest*/
		/*************************************/
		COALESCE(SingleYes, 0) AS SingleYes,
		COALESCE(SinglePrior, 0) AS SinglePrior,
		COALESCE(SingleWeek, 0) AS SingleWeek,
		COALESCE(SingleMonth, 0) AS SingleMonth,
		COALESCE(SingleYear, 0) AS SingleYear,

		COALESCE(MultiYes, 0) AS MultiYes,
		COALESCE(MultiPrior, 0) AS MultiPrior,
		COALESCE(MultiWeek, 0) AS MultiWeek,
		COALESCE(MultiMonth, 0) AS MultiMonth,
		COALESCE(MultiYear, 0) AS MultiYear,
		/*Previously Report_Search_ByNieghborhood*/
		/*************************************/
	 	COALESCE(NeighborhoodYes, 0) AS NeighborhoodYes,
		COALESCE(NeighborhoodPrior, 0) AS NeighborhoodPrior,
		COALESCE(NeighborhoodWeek, 0) AS NeighborhoodWeek,
		COALESCE(NeighborhoodMonth, 0) AS NeighborhoodMonth,
		COALESCE(NeighborhoodYear, 0) AS NeighborhoodYear,

		/*************************************/
		/*Previously Report_SearchByMacroNeighborhood*/
		/*************************************/
		COALESCE(MacroYes, 0) AS MacroYes,
		COALESCE(MacroPrior, 0) AS MacroPrior,
		COALESCE(MacroWeek, 0) AS MacroWeek,
		COALESCE(MacroMonth, 0) AS MacroMonth,
		COALESCE(MacroYear, 0) AS MacroYear,

		/*All Resos/Registered Users*/
		/*************************************/
		COALESCE(RegUserAllResoYes, 0) AS RegUserAllResoYes,
		COALESCE(RegUserAllResoPrior, 0) AS RegUserAllResoPrior,
		COALESCE(RegUserAllResoWeek, 0) AS RegUserAllResoWeek,	
		COALESCE(RegUserAllResoMonth, 0) AS RegUserAllResoMonth,
		COALESCE(RegUserAllResoYear, 0) AS RegUserAllResoYear,
		/*************************************/
	
		/*All Resos/Anonymous Users*/
		/*************************************/
		COALESCE(AnonUserAllResoYes, 0) AS AnonUserAllResoYes,
		COALESCE(AnonUserAllResoPrior, 0) AS AnonUserAllResoPrior,
		COALESCE(AnonUserAllResoWeek, 0) AS AnonUserAllResoWeek,	
		COALESCE(AnonUserAllResoMonth, 0) AS AnonUserAllResoMonth,
		COALESCE(AnonUserAllResoYear, 0) AS AnonUserAllResoYear,
		/*************************************/

	        /*Billable Resos/Registered Users*/
	        /*************************************/
	        COALESCE(RegUserBillableResoYes, 0) AS RegUserBillableResoYes,
	        COALESCE(RegUserBillableResoPrior, 0) AS RegUserBillableResoPrior,
	        COALESCE(RegUserBillableResoWeek, 0) AS RegUserBillableResoWeek,
	        COALESCE(RegUserBillableResoMonth, 0) AS RegUserBillableResoMonth,
	        COALESCE(RegUserBillableResoYear, 0) AS RegUserBillableResoYear,
	        /*************************************/
	
	        /*Billable Resos/Anonymous Users*/
	        /*************************************/
	        COALESCE(AnonUserBillableResoYes, 0) AS AnonUserBillableResoYes,
	        COALESCE(AnonUserBillableResoPrior, 0) AS AnonUserBillableResoPrior,
	        COALESCE(AnonUserBillableResoWeek, 0) AS AnonUserBillableResoWeek,
	        COALESCE(AnonUserBillableResoMonth, 0) AS AnonUserBillableResoMonth,
	        COALESCE(AnonUserBillableResoYear, 0) AS AnonUserBillableResoYear
	        /*************************************/


	FROM MetroAreaVW AS metro
		/*Previously Report_Search_ByRest*/
		/***************************************************************************************************/	
		/***************************************************************************************************/	
		LEFT JOIN (
			/*Single Yes*/
			SELECT SearchMetroAreaID, COUNT(br.SearchID) AS SingleYes
			FROM SearchByRestaurant br		
			WHERE datediff(day,br.SearchLogDate,@reportDate) = 0 AND
				RID NOT LIKE '%,%' AND
				CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0
			GROUP BY SearchMetroAreaID
			) AS tSingleYes ON metro.MetroAreaID = tSingleYes.SearchMetroAreaID
	
		LEFT JOIN (
			/*SinglePrior*/
			SELECT SearchMetroAreaID, COUNT(br.SearchID) AS SinglePrior
			FROM SearchByRestaurant br			
			WHERE datediff(month,br.SearchLogDate,@reportDate) = 1 AND
				RID NOT LIKE '%,%' AND
				CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0
			GROUP BY SearchMetroAreaID
			) AS tSinglePrior ON metro.MetroAreaID = tSinglePrior.SearchMetroAreaID
		LEFT JOIN (
			/*SingleWeek*/
			SELECT SearchMetroAreaID, COUNT(br.SearchID) AS SingleWeek
			FROM SearchByRestaurant br			
			WHERE datediff(day,br.SearchLogDate,@reportDate) between 0 and 6 And 
				RID NOT LIKE '%,%' AND
				CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0
			GROUP BY SearchMetroAreaID
			) AS tSingleWeek ON metro.MetroAreaID = tSingleWeek.SearchMetroAreaID
		LEFT JOIN (
			/*SingleMonth*/
			SELECT SearchMetroAreaID, COUNT(br.SearchID) AS SingleMonth
			FROM SearchByRestaurant br
			WHERE datediff(month,br.SearchLogDate,@reportDate) = 0 AND
				RID NOT LIKE '%,%' AND
				CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0
			GROUP BY SearchMetroAreaID
			) AS tSingleMonth ON metro.MetroAreaID = tSingleMonth.SearchMetroAreaID

		LEFT JOIN (
			--SingleYear
			SELECT SearchMetroAreaID, COUNT(br.SearchID) AS SingleYear
			FROM SearchByRestaurant br			
			WHERE datediff(year,br.SearchLogDate,@reportDate) = 0 AND 
				datediff(day,br.SearchLogDate,@reportDate) >= 0 And 
				RID NOT LIKE '%,%' AND
				CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0
			GROUP BY SearchMetroAreaID
			) AS tSingleYear ON metro.MetroAreaID = tSingleYear.SearchMetroAreaID

		LEFT JOIN (
			/*MultiYes*/
			SELECT SearchMetroAreaID, COUNT(br.SearchID) AS MultiYes
			FROM SearchByRestaurant br			
			WHERE datediff(day,br.SearchLogDate,@reportDate) = 0 And 	
				RID LIKE '%,%' AND
				CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0
			GROUP BY SearchMetroAreaID
			) AS tMultiYes ON metro.MetroAreaID = tMultiYes.SearchMetroAreaID
		LEFT JOIN (
			/*Multi Prior*/
			SELECT SearchMetroAreaID, COUNT(br.SearchID) AS MultiPrior
			FROM SearchByRestaurant br
			WHERE datediff(month,br.SearchLogDate,@reportDate) = 1 AND 
				RID LIKE '%,%' AND
				CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0
			GROUP BY SearchMetroAreaID
			) AS tMultiPrior ON metro.MetroAreaID = tMultiPrior.SearchMetroAreaID
		LEFT JOIN (
			/*MultiWeek*/
			SELECT SearchMetroAreaID, COUNT(br.SearchID) AS MultiWeek
			FROM SearchByRestaurant br
			WHERE datediff(day,br.SearchLogDate,@reportDate) between 0 and 6 And 
				RID LIKE '%,%' AND
				CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0
			GROUP BY SearchMetroAreaID
			) AS tMultiWeek ON metro.MetroAreaID = tMultiWeek.SearchMetroAreaID
		LEFT JOIN (
			/*MultiMonth*/
			SELECT SearchMetroAreaID, COUNT(br.SearchID) AS MultiMonth
			FROM SearchByRestaurant br
			WHERE datediff(month,br.SearchLogDate,@reportDate) = 0 AND 
				RID LIKE '%,%' AND
				CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0
			GROUP BY SearchMetroAreaID
			) AS tMultiMonth ON metro.MetroAreaID = tMultiMonth.SearchMetroAreaID

		LEFT JOIN (
			--Multi Year
			SELECT SearchMetroAreaID, COUNT(br.SearchID) AS MultiYear
			FROM SearchByRestaurant br
			WHERE datediff(year,br.SearchLogDate,@reportDate) = 0 AND 
				datediff(day,br.SearchLogDate,@reportDate) >= 0 And 
				RID LIKE '%,%' AND
				CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0
			GROUP BY SearchMetroAreaID
			) AS tMultiYear ON metro.MetroAreaID = tMultiYear.SearchMetroAreaID

		/***************************************************************************************************/	
		/*Previously Report_Search_ByNieghborhood*/
		/***************************************************************************************************/	
		LEFT JOIN (
			/*NeighborhoodYes*/
			SELECT SearchMetroAreaID, COUNT(SearchID) AS NeighborhoodYes
			FROM SearchByNeighborhood
			WHERE datediff(day,SearchLogDate,@reportDate) = 0 AND 
				CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0
			GROUP BY SearchMetroAreaID
			) AS tNeighborhoodYes ON metro.MetroAreaID = tNeighborhoodYes.SearchMetroAreaID
	
		LEFT JOIN (
			/*NeighborhoodPrior*/
			SELECT SearchMetroAreaID, COUNT(SearchID) AS NeighborhoodPrior
			FROM SearchByNeighborhood
			WHERE datediff(month,SearchLogDate,@reportDate) = 1 AND 
				CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0
			GROUP BY SearchMetroAreaID
			) AS tNeighborhoodPrior ON metro.MetroAreaID = tNeighborhoodPrior.SearchMetroAreaID
		LEFT JOIN (	
			/*NeighborhoodWeek*/
			SELECT SearchMetroAreaID, COUNT(SearchID) AS NeighborhoodWeek
			FROM SearchByNeighborhood
			WHERE datediff(day,SearchLogDate,@reportDate) between 0 and 6 AND  
				CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0
			GROUP BY SearchMetroAreaID
			) AS tNeighborhoodWeek ON metro.MetroAreaID = tNeighborhoodWeek.SearchMetroAreaID
		LEFT JOIN (
			/*NeighborhoodMonth*/
			SELECT SearchMetroAreaID, COUNT(SearchID) AS NeighborhoodMonth
			FROM SearchByNeighborhood
			WHERE datediff(month,SearchLogDate,@reportDate) = 0 AND
				CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0
			GROUP BY SearchMetroAreaID
			) AS tNeighborhoodMonth ON metro.MetroAreaID = tNeighborhoodMonth.SearchMetroAreaID

		LEFT JOIN (
			--NeighborhoodYear
			SELECT SearchMetroAreaID, COUNT(SearchID) AS NeighborhoodYear
			FROM SearchByNeighborhood
			WHERE datediff(year,SearchLogDate,@reportDate) = 0 AND 
				datediff(day,SearchLogDate,@reportDate) >= 0 AND 
				CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0
			GROUP BY SearchMetroAreaID
			) AS tNeighborhoodYear ON metro.MetroAreaID = tNeighborhoodYear.SearchMetroAreaID


		/***************************************************************************************************/	
		/*Report_SearchByMacroNeighborhood*/
		/***************************************************************************************************/	
		LEFT JOIN (
			SELECT SearchMetroAreaID, COUNT(SearchID) AS MacroYes
			FROM SearchByMacroNeighborhood
			WHERE 	DATEDIFF(DAY,SearchLogDate,@reportDate) = 0 AND 
				CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0
			GROUP BY SearchMetroAreaID
			) AS tMacroYes ON metro.MetroAreaID = tMacroYes.SearchMetroAreaID
		LEFT JOIN (
			SELECT SearchMetroAreaID, COUNT(SearchID) AS MacroPrior
			FROM SearchByMacroNeighborhood
			WHERE 	datediff(month,SearchLogDate,@reportDate) = 1 AND 
				CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0
			GROUP BY SearchMetroAreaID
			) AS tMacroPrior ON metro.MetroAreaID = tMacroPrior.SearchMetroAreaID
		LEFT JOIN (
			SELECT SearchMetroAreaID, COUNT(SearchID) AS MacroWeek
			FROM SearchByMacroNeighborhood
			WHERE datediff(day,SearchLogDate,@reportDate) between 0 and 6 AND 
				CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0
			GROUP BY SearchMetroAreaID
			) AS tMacroWeek ON metro.MetroAreaID = tMacroWeek.SearchMetroAreaID
		LEFT JOIN (
			SELECT SearchMetroAreaID, COUNT(SearchID) AS MacroMonth
			FROM SearchByMacroNeighborhood
			WHERE datediff(month,SearchLogDate,@reportDate) = 0 AND 
				CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0
			GROUP BY SearchMetroAreaID
			) AS tMacroMonth ON metro.MetroAreaID = tMacroMonth.SearchMetroAreaID

		LEFT JOIN (
			SELECT SearchMetroAreaID, COUNT(SearchID) AS MacroYear
			FROM SearchByMacroNeighborhood
			WHERE datediff(year,SearchLogDate,@reportDate) = 0 AND 
				datediff(day,SearchLogDate,@reportDate) >= 0 AND 
				CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0
			GROUP BY SearchMetroAreaID
			) AS tMacroYear ON metro.MetroAreaID	= tMacroYear.SearchMetroAreaID

--THE MESS
--STARTS HERE
/*All Resos/Registered Users*/
	/***************************************************************************************************/	
	LEFT JOIN (
			SELECT n.MetroAreaID, COUNT(resos.ResID) AS RegUserAllResoYes
			FROM 	(
					--This gets Real Customer Resos
					--//////////////////////////////////////////////////
					SELECT r.RID, r.ResID
					FROM Reservation r
						INNER JOIN Customer rc ON r.CustID = rc.CustID
					WHERE datediff(day,DateMade,@reportDate) = 0 AND
						ConsumerType <> 8 AND
						r.PartnerID = 1
					--//////////////////////////////////////////////////		
					UNION		
					--This gets Caller Resos
					--//////////////////////////////////////////////////
					SELECT r.RID, r.ResID
					FROM Reservation r
						INNER JOIN Caller c ON r.CallerID = c.CallerID
					WHERE datediff(day,DateMade,@reportDate) = 0 AND
						ConsumerType <> 8 AND
						r.PartnerID = 1
					--//////////////////////////////////////////////////
					) AS resos
				INNER JOIN Restaurant Rest ON resos.RID = Rest.RID
				INNER JOIN Neighborhood n ON n.NeighborhoodID = Rest.NeighborhoodID
			GROUP BY n.MetroAreaID
		) AS tRegUserAllResoYes ON metro.MetroAreaID = tRegUserAllResoYes.MetroAreaID
	LEFT JOIN (

			SELECT n.MetroAreaID, COUNT(resos.ResID) AS RegUserAllResoPrior
			FROM 	(
					--This gets Real Customer Resos
					--//////////////////////////////////////////////////
					SELECT r.RID, r.ResID
					FROM Reservation r
						INNER JOIN Customer rc ON r.CustID = rc.CustID
					WHERE datediff(month,DateMade,@reportDate) = 1 AND
						ConsumerType <> 8 AND
						r.PartnerID = 1
					--//////////////////////////////////////////////////		
					UNION		
					--This gets Caller Resos
					--//////////////////////////////////////////////////
					SELECT r.RID, r.ResID
					FROM Reservation r
						INNER JOIN Caller c ON r.CallerID = c.CallerID
					WHERE datediff(month,DateMade,@reportDate) = 1 AND
						ConsumerType <> 8 AND
						r.PartnerID = 1
					--//////////////////////////////////////////////////
					) AS resos
				INNER JOIN Restaurant Rest ON resos.RID = Rest.RID
				INNER JOIN Neighborhood n ON n.NeighborhoodID = Rest.NeighborhoodID
			GROUP BY n.MetroAreaID

		) AS tRegUserAllResoPrior ON metro.MetroAreaID = tRegUserAllResoPrior.MetroAreaID
	LEFT JOIN (
			
			SELECT n.MetroAreaID, COUNT(resos.ResID) AS RegUserAllResoWeek
			FROM 	(
					--This gets Real Customer Resos
					--//////////////////////////////////////////////////
					SELECT r.RID, r.ResID
					FROM Reservation r
						INNER JOIN Customer rc ON r.CustID = rc.CustID
					WHERE datediff(day,r.DateMade,@reportDate) between 0 and 6 AND
						ConsumerType <> 8 AND
						r.PartnerID = 1
					--//////////////////////////////////////////////////		
					UNION		
					--This gets Caller Resos
					--//////////////////////////////////////////////////
					SELECT r.RID, r.ResID
					FROM Reservation r
						INNER JOIN Caller c ON r.CallerID = c.CallerID
					WHERE datediff(day,r.DateMade,@reportDate) between 0 and 6 AND
						ConsumerType <> 8 AND
						r.PartnerID = 1
					--//////////////////////////////////////////////////
					) AS resos
				INNER JOIN Restaurant Rest ON resos.RID = Rest.RID
				INNER JOIN Neighborhood n ON n.NeighborhoodID = Rest.NeighborhoodID
			GROUP BY n.MetroAreaID


		) AS tRegUserAllResoWeek ON metro.MetroAreaID = tRegUserAllResoWeek.MetroAreaID
	LEFT JOIN (

			SELECT n.MetroAreaID, COUNT(resos.ResID) AS RegUserAllResoMonth
			FROM 	(
					--This gets Real Customer Resos
					--//////////////////////////////////////////////////
					SELECT r.RID, r.ResID
					FROM Reservation r
						INNER JOIN Customer rc ON r.CustID = rc.CustID
					WHERE datediff(month,r.DateMade,@reportDate) = 0 AND
						ConsumerType <> 8 AND
						r.PartnerID = 1
					--//////////////////////////////////////////////////		
					UNION		
					--This gets Caller Resos
					--//////////////////////////////////////////////////
					SELECT r.RID, r.ResID
					FROM Reservation r
						INNER JOIN Caller c ON r.CallerID = c.CallerID
					WHERE datediff(month,r.DateMade,@reportDate) = 0 AND
						ConsumerType <> 8 AND
						r.PartnerID = 1
					--//////////////////////////////////////////////////
					) AS resos
				INNER JOIN Restaurant Rest ON resos.RID = Rest.RID
				INNER JOIN Neighborhood n ON n.NeighborhoodID = Rest.NeighborhoodID
			GROUP BY n.MetroAreaID
		) AS tRegUserAllResoMonth ON metro.MetroAreaID = tRegUserAllResoMonth.MetroAreaID

	LEFT JOIN (


			SELECT n.MetroAreaID, COUNT(resos.ResID) AS RegUserAllResoYear
			FROM 	(
					--This gets Real Customer Resos
					--//////////////////////////////////////////////////
					SELECT r.RID, r.ResID
					FROM Reservation r
						INNER JOIN Customer rc ON r.CustID = rc.CustID
					WHERE YEAR(r.DateMade) = YEAR(@reportDate) AND
						ConsumerType <> 8 AND
						r.PartnerID = 1
					--//////////////////////////////////////////////////		
					UNION		
					--This gets Caller Resos
					--//////////////////////////////////////////////////
					SELECT r.RID, r.ResID
					FROM Reservation r
						INNER JOIN Caller c ON r.CallerID = c.CallerID
					WHERE YEAR(r.DateMade) = YEAR(@reportDate) AND
						ConsumerType <> 8 AND
						r.PartnerID = 1
					--//////////////////////////////////////////////////
					) AS resos
				INNER JOIN Restaurant Rest ON resos.RID = Rest.RID
				INNER JOIN Neighborhood n ON n.NeighborhoodID = Rest.NeighborhoodID
			GROUP BY n.MetroAreaID

		) AS tRegUserAllResoYear ON metro.MetroAreaID = tRegUserAllResoYear.MetroAreaID

	/***************************************************************************************************/	



	/*All Resos/Anonymous Users*/
	/***************************************************************************************************/	
	LEFT JOIN (
			SELECT n.MetroAreaID, COUNT(resos.ResID) AS AnonUserAllResoYes
			FROM 	(
					--This gets Real Customer Resos
					--//////////////////////////////////////////////////
					SELECT r.RID, r.ResID
					FROM Reservation r
						INNER JOIN Customer rc ON r.CustID = rc.CustID
					WHERE datediff(day,DateMade,@reportDate) = 0 AND
						ConsumerType = 8 AND
						r.PartnerID = 1
					--//////////////////////////////////////////////////		
					UNION		
					--This gets Caller Resos
					--//////////////////////////////////////////////////
					SELECT r.RID, r.ResID
					FROM Reservation r
						INNER JOIN Caller c ON r.CallerID = c.CallerID
					WHERE datediff(day,DateMade,@reportDate) = 0 AND
						ConsumerType = 8 AND
						r.PartnerID = 1
					--//////////////////////////////////////////////////
					) AS resos
				INNER JOIN Restaurant Rest ON resos.RID = Rest.RID
				INNER JOIN Neighborhood n ON n.NeighborhoodID = Rest.NeighborhoodID
			GROUP BY n.MetroAreaID
		) AS tAnonUserAllResoYes ON metro.MetroAreaID = tAnonUserAllResoYes.MetroAreaID
	LEFT JOIN (

			SELECT n.MetroAreaID, COUNT(resos.ResID) AS AnonUserAllResoPrior
			FROM 	(
					--This gets Real Customer Resos
					--//////////////////////////////////////////////////
					SELECT r.RID, r.ResID
					FROM Reservation r
						INNER JOIN Customer rc ON r.CustID = rc.CustID
					WHERE datediff(month,DateMade,@reportDate) = 1 AND
						ConsumerType = 8 AND
						r.PartnerID = 1
					--//////////////////////////////////////////////////		
					UNION		
					--This gets Caller Resos
					--//////////////////////////////////////////////////
					SELECT r.RID, r.ResID
					FROM Reservation r
						INNER JOIN Caller c ON r.CallerID = c.CallerID
					WHERE datediff(month,DateMade,@reportDate) = 1 AND
						ConsumerType = 8 AND
						r.PartnerID = 1
					--//////////////////////////////////////////////////
					) AS resos
				INNER JOIN Restaurant Rest ON resos.RID = Rest.RID
				INNER JOIN Neighborhood n ON n.NeighborhoodID = Rest.NeighborhoodID
			GROUP BY n.MetroAreaID

		) AS tAnonUserAllResoPrior ON metro.MetroAreaID = tAnonUserAllResoPrior.MetroAreaID
	LEFT JOIN (
			
			SELECT n.MetroAreaID, COUNT(resos.ResID) AS AnonUserAllResoWeek
			FROM 	(
					--This gets Real Customer Resos
					--//////////////////////////////////////////////////
					SELECT r.RID, r.ResID
					FROM Reservation r
						INNER JOIN Customer rc ON r.CustID = rc.CustID
					WHERE datediff(day,r.DateMade,@reportDate) between 0 and 6 AND
						ConsumerType = 8 AND
						r.PartnerID = 1
					--//////////////////////////////////////////////////		
					UNION		
					--This gets Caller Resos
					--//////////////////////////////////////////////////
					SELECT r.RID, r.ResID
					FROM Reservation r
						INNER JOIN Caller c ON r.CallerID = c.CallerID
					WHERE datediff(day,r.DateMade,@reportDate) between 0 and 6 AND
						ConsumerType = 8 AND
						r.PartnerID = 1
					--//////////////////////////////////////////////////
					) AS resos
				INNER JOIN Restaurant Rest ON resos.RID = Rest.RID
				INNER JOIN Neighborhood n ON n.NeighborhoodID = Rest.NeighborhoodID
			GROUP BY n.MetroAreaID


		) AS tAnonUserAllResoWeek ON metro.MetroAreaID = tAnonUserAllResoWeek.MetroAreaID
	LEFT JOIN (

			SELECT n.MetroAreaID, COUNT(resos.ResID) AS AnonUserAllResoMonth
			FROM 	(
					--This gets Real Customer Resos
					--//////////////////////////////////////////////////
					SELECT r.RID, r.ResID
					FROM Reservation r
						INNER JOIN Customer rc ON r.CustID = rc.CustID
					WHERE datediff(month,r.DateMade,@reportDate) = 0 AND
						ConsumerType = 8 AND
						r.PartnerID = 1
					--//////////////////////////////////////////////////		
					UNION		
					--This gets Caller Resos
					--//////////////////////////////////////////////////
					SELECT r.RID, r.ResID
					FROM Reservation r
						INNER JOIN Caller c ON r.CallerID = c.CallerID
					WHERE datediff(month,r.DateMade,@reportDate) = 0 AND
						ConsumerType = 8 AND
						r.PartnerID = 1
					--//////////////////////////////////////////////////
					) AS resos
				INNER JOIN Restaurant Rest ON resos.RID = Rest.RID
				INNER JOIN Neighborhood n ON n.NeighborhoodID = Rest.NeighborhoodID
			GROUP BY n.MetroAreaID


		) AS tAnonUserAllResoMonth ON metro.MetroAreaID = tAnonUserAllResoMonth.MetroAreaID

	LEFT JOIN (
			SELECT n.MetroAreaID, COUNT(resos.ResID) AS AnonUserAllResoYear
			FROM 	(
					--This gets Real Customer Resos
					--//////////////////////////////////////////////////
					SELECT r.RID, r.ResID
					FROM Reservation r
						INNER JOIN Customer rc ON r.CustID = rc.CustID
					WHERE YEAR(r.DateMade) = YEAR(@reportDate) AND
						ConsumerType = 8 AND
						r.PartnerID = 1
					--//////////////////////////////////////////////////		
					UNION		
					--This gets Caller Resos
					--//////////////////////////////////////////////////
					SELECT r.RID, r.ResID
					FROM Reservation r
						INNER JOIN Caller c ON r.CallerID = c.CallerID
					WHERE YEAR(r.DateMade) = YEAR(@reportDate) AND
						ConsumerType = 8 AND
						r.PartnerID = 1
					--//////////////////////////////////////////////////
					) AS resos
				INNER JOIN Restaurant Rest ON resos.RID = Rest.RID
				INNER JOIN Neighborhood n ON n.NeighborhoodID = Rest.NeighborhoodID
			GROUP BY n.MetroAreaID

		) AS tAnonUserAllResoYear ON metro.MetroAreaID = tAnonUserAllResoYear.MetroAreaID

	/***************************************************************************************************/	

	/*Billable Resos/Registered Users*/
	/***************************************************************************************************/
	LEFT JOIN (
	        SELECT n.MetroAreaID, COUNT(resos.ResID) AS RegUserBillableResoYes
	        FROM    (
	                --This gets Real Customer Resos
	                --//////////////////////////////////////////////////
	                SELECT r.RID, r.ResID
	                FROM Reservation r
	                    INNER JOIN Customer rc ON r.CustID = rc.CustID
	                WHERE datediff(day,DateMade,@reportDate) = 0 AND
	                    ConsumerType <> 8 AND
	                    r.RStateID not in (3,4,8,9,10) AND
	                    r.PartnerID = 1
	                --//////////////////////////////////////////////////
	                UNION
	                --This gets Caller Resos
	                --//////////////////////////////////////////////////
	                SELECT r.RID, r.ResID
	                FROM Reservation r
	                    INNER JOIN Caller c ON r.CallerID = c.CallerID
	                WHERE datediff(day,DateMade,@reportDate) = 0 AND
	                    ConsumerType <> 8 AND
	                    r.RStateID not in (3,4,8,9,10) AND
	                    r.PartnerID = 1
	                --//////////////////////////////////////////////////
	                ) AS resos
	            INNER JOIN Restaurant Rest ON resos.RID = Rest.RID
	            INNER JOIN Neighborhood n ON n.NeighborhoodID = Rest.NeighborhoodID
	        GROUP BY n.MetroAreaID
	    ) AS tRegUserBillableResoYes ON metro.MetroAreaID = tRegUserBillableResoYes.MetroAreaID
	LEFT JOIN (
	
	        SELECT n.MetroAreaID, COUNT(resos.ResID) AS RegUserBillableResoPrior
	        FROM    (
	                --This gets Real Customer Resos
	                --//////////////////////////////////////////////////
	                SELECT r.RID, r.ResID
	                FROM Reservation r
	                    INNER JOIN Customer rc ON r.CustID = rc.CustID
	                WHERE datediff(month,DateMade,@reportDate) = 1 AND
	                    ConsumerType <> 8 AND
	                    r.RStateID not in (3,4,8,9,10) AND
	                    r.PartnerID = 1
	                --//////////////////////////////////////////////////
	                UNION
	                --This gets Caller Resos
	                --//////////////////////////////////////////////////
	                SELECT r.RID, r.ResID
	                FROM Reservation r
	                    INNER JOIN Caller c ON r.CallerID = c.CallerID
	                WHERE datediff(month,DateMade,@reportDate) = 1 AND
	                    ConsumerType <> 8 AND
	                    r.RStateID not in (3,4,8,9,10) AND
	                    r.PartnerID = 1
	                --//////////////////////////////////////////////////
	                ) AS resos
	            INNER JOIN Restaurant Rest ON resos.RID = Rest.RID
	            INNER JOIN Neighborhood n ON n.NeighborhoodID = Rest.NeighborhoodID
	        GROUP BY n.MetroAreaID
	
	    ) AS tRegUserBillableResoPrior ON metro.MetroAreaID = tRegUserBillableResoPrior.MetroAreaID
	LEFT JOIN (
	
	        SELECT n.MetroAreaID, COUNT(resos.ResID) AS RegUserBillableResoWeek
	        FROM    (
	                --This gets Real Customer Resos
	                --//////////////////////////////////////////////////
	                SELECT r.RID, r.ResID
	                FROM Reservation r
	                    INNER JOIN Customer rc ON r.CustID = rc.CustID
	                WHERE datediff(day,r.DateMade,@reportDate) between 0 and 6 AND
	                    ConsumerType <> 8 AND
	                    r.RStateID not in (3,4,8,9,10) AND
	                    r.PartnerID = 1
	                --//////////////////////////////////////////////////
	                UNION
	                --This gets Caller Resos
	                --//////////////////////////////////////////////////
	                SELECT r.RID, r.ResID
	                FROM Reservation r
	                    INNER JOIN Caller c ON r.CallerID = c.CallerID
	                WHERE datediff(day,r.DateMade,@reportDate) between 0 and 6 AND
	                    ConsumerType <> 8 AND
	                    r.RStateID not in (3,4,8,9,10) AND
	                    r.PartnerID = 1
	                --//////////////////////////////////////////////////
	                ) AS resos
	            INNER JOIN Restaurant Rest ON resos.RID = Rest.RID
	            INNER JOIN Neighborhood n ON n.NeighborhoodID = Rest.NeighborhoodID
	        GROUP BY n.MetroAreaID
	
	
	    ) AS tRegUserBillableResoWeek ON metro.MetroAreaID = tRegUserBillableResoWeek.MetroAreaID
	LEFT JOIN (
	
	        SELECT n.MetroAreaID, COUNT(resos.ResID) AS RegUserBillableResoMonth
	        FROM    (
	                --This gets Real Customer Resos
	                --//////////////////////////////////////////////////
	                SELECT r.RID, r.ResID
	                FROM Reservation r
	                    INNER JOIN Customer rc ON r.CustID = rc.CustID
	                WHERE datediff(month,r.DateMade,@reportDate) = 0 AND
	                    ConsumerType <> 8 AND
	                    r.RStateID not in (3,4,8,9,10) AND
	                    r.PartnerID = 1
	                --//////////////////////////////////////////////////
	                UNION
	                --This gets Caller Resos
	                --//////////////////////////////////////////////////
	                SELECT r.RID, r.ResID
	                FROM Reservation r
	                    INNER JOIN Caller c ON r.CallerID = c.CallerID
	                WHERE datediff(month,r.DateMade,@reportDate) = 0 AND
	                    ConsumerType <> 8 AND
	                    r.RStateID not in (3,4,8,9,10) AND
	                    r.PartnerID = 1
	                --//////////////////////////////////////////////////
	                ) AS resos
	            INNER JOIN Restaurant Rest ON resos.RID = Rest.RID
	            INNER JOIN Neighborhood n ON n.NeighborhoodID = Rest.NeighborhoodID
	        GROUP BY n.MetroAreaID
	
	
	    ) AS tRegUserBillableResoMonth ON metro.MetroAreaID = tRegUserBillableResoMonth.MetroAreaID
	
	LEFT JOIN (
	
	        SELECT n.MetroAreaID, COUNT(resos.ResID) AS RegUserBillableResoYear
	        FROM    (
	                --This gets Real Customer Resos
	                --//////////////////////////////////////////////////
	                SELECT r.RID, r.ResID
	                FROM Reservation r
	                    INNER JOIN Customer rc ON r.CustID = rc.CustID
	                WHERE YEAR(r.DateMade) = YEAR(@reportDate) AND
	                    ConsumerType <> 8 AND
	                    r.RStateID not in (3,4,8,9,10) AND
	                    r.PartnerID = 1
	                --//////////////////////////////////////////////////
	                UNION
	                --This gets Caller Resos
	                --//////////////////////////////////////////////////
	                SELECT r.RID, r.ResID
	                FROM Reservation r
	                    INNER JOIN Caller c ON r.CallerID = c.CallerID
	                WHERE YEAR(r.DateMade) = YEAR(@reportDate) AND
	                    ConsumerType <> 8 AND
	                    r.RStateID not in (3,4,8,9,10) AND
	                    r.PartnerID = 1
	                --//////////////////////////////////////////////////
	                ) AS resos
	            INNER JOIN Restaurant Rest ON resos.RID = Rest.RID
	            INNER JOIN Neighborhood n ON n.NeighborhoodID = Rest.NeighborhoodID
	        GROUP BY n.MetroAreaID
	
	    ) AS tRegUserBillableResoYear ON metro.MetroAreaID = tRegUserBillableResoYear.MetroAreaID
	
	/***************************************************************************************************/
	
	
	
	/*All Resos/Anonymous Users*/
	/***************************************************************************************************/
	LEFT JOIN (
	        SELECT n.MetroAreaID, COUNT(resos.ResID) AS AnonUserBillableResoYes
	        FROM    (
	                --This gets Real Customer Resos
	                --//////////////////////////////////////////////////
	                SELECT r.RID, r.ResID
	                FROM Reservation r
	                    INNER JOIN Customer rc ON r.CustID = rc.CustID
	                WHERE datediff(day,DateMade,@reportDate) = 0 AND
	                    ConsumerType = 8 AND
	                    r.RStateID not in (3,4,8,9,10) AND
	                    r.PartnerID = 1
	                --//////////////////////////////////////////////////
	                UNION
	                --This gets Caller Resos
	                --//////////////////////////////////////////////////
	                SELECT r.RID, r.ResID
	                FROM Reservation r
	                    INNER JOIN Caller c ON r.CallerID = c.CallerID
	                WHERE datediff(day,DateMade,@reportDate) = 0 AND
	                    ConsumerType = 8 AND
	                    r.RStateID not in (3,4,8,9,10) AND
	                    r.PartnerID = 1
	                --//////////////////////////////////////////////////
	                ) AS resos
	            INNER JOIN Restaurant Rest ON resos.RID = Rest.RID
	            INNER JOIN Neighborhood n ON n.NeighborhoodID = Rest.NeighborhoodID
	        GROUP BY n.MetroAreaID
	    ) AS tAnonUserBillableResoYes ON metro.MetroAreaID = tAnonUserBillableResoYes.MetroAreaID
	LEFT JOIN (
	
	        SELECT n.MetroAreaID, COUNT(resos.ResID) AS AnonUserBillableResoPrior
	        FROM    (
	                --This gets Real Customer Resos
	                --//////////////////////////////////////////////////
	                SELECT r.RID, r.ResID
	                FROM Reservation r
	                    INNER JOIN Customer rc ON r.CustID = rc.CustID
	                WHERE datediff(month,DateMade,@reportDate) = 1 AND
	                    ConsumerType = 8 AND
	                    r.RStateID not in (3,4,8,9,10) AND
	                    r.PartnerID = 1
	                --//////////////////////////////////////////////////
	                UNION
	                --This gets Caller Resos
	                --//////////////////////////////////////////////////
	                SELECT r.RID, r.ResID
	                FROM Reservation r
	                    INNER JOIN Caller c ON r.CallerID = c.CallerID
	                WHERE datediff(month,DateMade,@reportDate) = 1 AND
	                    ConsumerType = 8 AND
	                    r.RStateID not in (3,4,8,9,10) AND
	                    r.PartnerID = 1
	                --//////////////////////////////////////////////////
	                ) AS resos
	            INNER JOIN Restaurant Rest ON resos.RID = Rest.RID
	            INNER JOIN Neighborhood n ON n.NeighborhoodID = Rest.NeighborhoodID
	        GROUP BY n.MetroAreaID
	
	    ) AS tAnonUserBillableResoPrior ON metro.MetroAreaID = tAnonUserBillableResoPrior.MetroAreaID
	LEFT JOIN (
	
	        SELECT n.MetroAreaID, COUNT(resos.ResID) AS AnonUserBillableResoWeek
	        FROM    (
	                --This gets Real Customer Resos
	                --//////////////////////////////////////////////////
	                SELECT r.RID, r.ResID
	                FROM Reservation r
	                    INNER JOIN Customer rc ON r.CustID = rc.CustID
	                WHERE datediff(day,r.DateMade,@reportDate) between 0 and 6 AND
	                    ConsumerType = 8 AND
	                    r.RStateID not in (3,4,8,9,10) AND
	                    r.PartnerID = 1
	                --//////////////////////////////////////////////////
	                UNION
	                --This gets Caller Resos
	                --//////////////////////////////////////////////////
	                SELECT r.RID, r.ResID
	                FROM Reservation r
	                    INNER JOIN Caller c ON r.CallerID = c.CallerID
	                WHERE datediff(day,r.DateMade,@reportDate) between 0 and 6 AND
	                    ConsumerType = 8 AND
	                    r.RStateID not in (3,4,8,9,10) AND
	                    r.PartnerID = 1
	                --//////////////////////////////////////////////////
	                ) AS resos
	            INNER JOIN Restaurant Rest ON resos.RID = Rest.RID
	            INNER JOIN Neighborhood n ON n.NeighborhoodID = Rest.NeighborhoodID
	        GROUP BY n.MetroAreaID
	
	
	    ) AS tAnonUserBillableResoWeek ON metro.MetroAreaID = tAnonUserBillableResoWeek.MetroAreaID
	LEFT JOIN (
	
	        SELECT n.MetroAreaID, COUNT(resos.ResID) AS AnonUserBillableResoMonth
	        FROM    (
	                --This gets Real Customer Resos
	                --//////////////////////////////////////////////////
	                SELECT r.RID, r.ResID
	                FROM Reservation r
	                    INNER JOIN Customer rc ON r.CustID = rc.CustID
	                WHERE datediff(month,r.DateMade,@reportDate) = 0 AND
	                    ConsumerType = 8 AND
	                    r.RStateID not in (3,4,8,9,10) AND
	                    r.PartnerID = 1
	                --//////////////////////////////////////////////////
	                UNION
	                --This gets Caller Resos
	                --//////////////////////////////////////////////////
	                SELECT r.RID, r.ResID
	                FROM Reservation r
	                    INNER JOIN Caller c ON r.CallerID = c.CallerID
	                WHERE datediff(month,r.DateMade,@reportDate) = 0 AND
	                    ConsumerType = 8 AND
	                    r.RStateID not in (3,4,8,9,10) AND
	                    r.PartnerID = 1
	                --//////////////////////////////////////////////////
	                ) AS resos
	            INNER JOIN Restaurant Rest ON resos.RID = Rest.RID
	            INNER JOIN Neighborhood n ON n.NeighborhoodID = Rest.NeighborhoodID
	        GROUP BY n.MetroAreaID
	
	
	    ) AS tAnonUserBillableResoMonth ON metro.MetroAreaID = tAnonUserBillableResoMonth.MetroAreaID
	
	LEFT JOIN (
	
	        SELECT n.MetroAreaID, COUNT(resos.ResID) AS AnonUserBillableResoYear
	        FROM    (
	                --This gets Real Customer Resos
	                --//////////////////////////////////////////////////
	                SELECT r.RID, r.ResID
	                FROM Reservation r
	                    INNER JOIN Customer rc ON r.CustID = rc.CustID
	                WHERE YEAR(r.DateMade) = YEAR(@reportDate) AND
	                    ConsumerType = 8 AND
	                    r.RStateID not in (3,4,8,9,10) AND
	                    r.PartnerID = 1
	                --//////////////////////////////////////////////////
	                UNION
	                --This gets Caller Resos
	                --//////////////////////////////////////////////////
	                SELECT r.RID, r.ResID
	                FROM Reservation r
	                    INNER JOIN Caller c ON r.CallerID = c.CallerID
	                WHERE YEAR(r.DateMade) = YEAR(@reportDate) AND
	                    ConsumerType = 8 AND
	                    r.RStateID not in (3,4,8,9,10) AND
	                    r.PartnerID = 1
	                --//////////////////////////////////////////////////
	                ) AS resos
	            INNER JOIN Restaurant Rest ON resos.RID = Rest.RID
	            INNER JOIN Neighborhood n ON n.NeighborhoodID = Rest.NeighborhoodID
	        GROUP BY n.MetroAreaID
	
	    ) AS tAnonUserBillableResoYear ON metro.MetroAreaID = tAnonUserBillableResoYear.MetroAreaID
        /***************************************************************************************************/

	WHERE metro.MetroAreaID <> 1
	ORDER BY metro.MetroAreaName
--THE MESS
--ENDS HERE


	END
/*()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()*/
/*()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()*/
/*()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()*/
/*()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()*/
/*()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()*/
/*()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()*/



ELSE



/*()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()*/
/*()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()*/
/*()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()*/
/*()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()*/
/*()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()*/
/*()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()()*/
	BEGIN
	    /*
	    This will only be used if we implement the Distance & Recommended Search Results
            (delete this comment after we implement)
 	    */
	    SELECT metro.MetroAreaID, Metro.MetroAreaName,
	        /*Previously Report_Search_ByRest*/
	        /*************************************/
	        COALESCE(SingleYes, 0) AS SingleYes,
	        COALESCE(SinglePrior, 0) AS SinglePrior,
	        COALESCE(SingleWeek, 0) AS SingleWeek,
	        COALESCE(SingleMonth, 0) AS SingleMonth,
	        COALESCE(SingleYear, 0) AS SingleYear,
	
	        COALESCE(MultiYes, 0) AS MultiYes,
	        COALESCE(MultiPrior, 0) AS MultiPrior,
	        COALESCE(MultiWeek, 0) AS MultiWeek,
	        COALESCE(MultiMonth, 0) AS MultiMonth,
	        COALESCE(MultiYear, 0) AS MultiYear,
	        /*Previously Report_Search_ByNieghborhood*/
	        /*************************************/
	        COALESCE(NeighborhoodYes, 0) AS NeighborhoodYes,
	        COALESCE(NeighborhoodPrior, 0) AS NeighborhoodPrior,
	        COALESCE(NeighborhoodWeek, 0) AS NeighborhoodWeek,
	        COALESCE(NeighborhoodMonth, 0) AS NeighborhoodMonth,
	        COALESCE(NeighborhoodYear, 0) AS NeighborhoodYear,
	
	        /*************************************/
	        /*Previously Report_SearchByMacroNeighborhood*/
	        /*************************************/
	        COALESCE(MacroYes, 0) AS MacroYes,
	        COALESCE(MacroPrior, 0) AS MacroPrior,
	        COALESCE(MacroWeek, 0) AS MacroWeek,
	        COALESCE(MacroMonth, 0) AS MacroMonth,
	        COALESCE(MacroYear, 0) AS MacroYear,
	
	        /*All Resos/Registered Users*/
	        /*************************************/
	        COALESCE(RegUserAllResoYes, 0) AS RegUserAllResoYes,
	        COALESCE(RegUserAllResoPrior, 0) AS RegUserAllResoPrior,
	        COALESCE(RegUserAllResoWeek, 0) AS RegUserAllResoWeek,
	        COALESCE(RegUserAllResoMonth, 0) AS RegUserAllResoMonth,
	        COALESCE(RegUserAllResoYear, 0) AS RegUserAllResoYear,
	        /*************************************/
	
	        /*All Resos/Anonymous Users*/
	        /*************************************/
	        COALESCE(AnonUserAllResoYes, 0) AS AnonUserAllResoYes,
	        COALESCE(AnonUserAllResoPrior, 0) AS AnonUserAllResoPrior,
	        COALESCE(AnonUserAllResoWeek, 0) AS AnonUserAllResoWeek,
	        COALESCE(AnonUserAllResoMonth, 0) AS AnonUserAllResoMonth,
	        COALESCE(AnonUserAllResoYear, 0) AS AnonUserAllResoYear,
	        /*************************************/
	
	            /*Billable Resos/Registered Users*/
	            /*************************************/
	            COALESCE(RegUserBillableResoYes, 0) AS RegUserBillableResoYes,
	            COALESCE(RegUserBillableResoPrior, 0) AS RegUserBillableResoPrior,
	            COALESCE(RegUserBillableResoWeek, 0) AS RegUserBillableResoWeek,
	            COALESCE(RegUserBillableResoMonth, 0) AS RegUserBillableResoMonth,
	            COALESCE(RegUserBillableResoYear, 0) AS RegUserBillableResoYear,
	            /*************************************/
	
	            /*Billable Resos/Anonymous Users*/
	            /*************************************/
	            COALESCE(AnonUserBillableResoYes, 0) AS AnonUserBillableResoYes,
	            COALESCE(AnonUserBillableResoPrior, 0) AS AnonUserBillableResoPrior,
	            COALESCE(AnonUserBillableResoWeek, 0) AS AnonUserBillableResoWeek,
	            COALESCE(AnonUserBillableResoMonth, 0) AS AnonUserBillableResoMonth,
	            COALESCE(AnonUserBillableResoYear, 0) AS AnonUserBillableResoYear
	            /*************************************/
	
	
	    FROM MetroAreaVW AS metro
	        /*Previously Report_Search_ByRest*/
	        /***************************************************************************************************/
	        /***************************************************************************************************/
	        LEFT JOIN (
	            /*Single Yes*/
	            SELECT SearchMetroAreaID, COUNT(br.SearchID) AS SingleYes
	            FROM SearchByRestaurant br
	            WHERE datediff(day,br.SearchLogDate,@reportDate) = 0 AND
	                RID NOT LIKE '%,%' AND
	                CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0
	            GROUP BY SearchMetroAreaID
	            ) AS tSingleYes ON metro.MetroAreaID = tSingleYes.SearchMetroAreaID
	
	        LEFT JOIN (
	            /*SinglePrior*/
	            SELECT SearchMetroAreaID, COUNT(br.SearchID) AS SinglePrior
	            FROM SearchByRestaurant br
	            WHERE datediff(month,br.SearchLogDate,@reportDate) = 1 AND
	                RID NOT LIKE '%,%' AND
	                CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0
	            GROUP BY SearchMetroAreaID
	            ) AS tSinglePrior ON metro.MetroAreaID = tSinglePrior.SearchMetroAreaID
	        LEFT JOIN (
	            /*SingleWeek*/
	            SELECT SearchMetroAreaID, COUNT(br.SearchID) AS SingleWeek
	            FROM SearchByRestaurant br
	            WHERE datediff(day,br.SearchLogDate,@reportDate) between 0 and 6 And
	                RID NOT LIKE '%,%' AND
	                CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0
	            GROUP BY SearchMetroAreaID
	            ) AS tSingleWeek ON metro.MetroAreaID = tSingleWeek.SearchMetroAreaID
	        LEFT JOIN (
	            /*SingleMonth*/
	            SELECT SearchMetroAreaID, COUNT(br.SearchID) AS SingleMonth
	            FROM SearchByRestaurant br
	            WHERE datediff(month,br.SearchLogDate,@reportDate) = 0 AND
	                RID NOT LIKE '%,%' AND
	                CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0
	            GROUP BY SearchMetroAreaID
	            ) AS tSingleMonth ON metro.MetroAreaID = tSingleMonth.SearchMetroAreaID
	
	        LEFT JOIN (
	            --SingleYear
	            SELECT SearchMetroAreaID, COUNT(br.SearchID) AS SingleYear
	            FROM SearchByRestaurant br
	            WHERE datediff(year,br.SearchLogDate,@reportDate) = 0 AND
	                datediff(day,br.SearchLogDate,@reportDate) >= 0 And
	                RID NOT LIKE '%,%' AND
	                CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0
	            GROUP BY SearchMetroAreaID
	            ) AS tSingleYear ON metro.MetroAreaID = tSingleYear.SearchMetroAreaID
	
	        LEFT JOIN (
	            /*MultiYes*/
	            SELECT SearchMetroAreaID, COUNT(br.SearchID) AS MultiYes
	            FROM SearchByRestaurant br
	            WHERE datediff(day,br.SearchLogDate,@reportDate) = 0 And
	                RID LIKE '%,%' AND
	                CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0
	            GROUP BY SearchMetroAreaID
	            ) AS tMultiYes ON metro.MetroAreaID = tMultiYes.SearchMetroAreaID
	        LEFT JOIN (
	            /*Multi Prior*/
	            SELECT SearchMetroAreaID, COUNT(br.SearchID) AS MultiPrior
	            FROM SearchByRestaurant br
	            WHERE datediff(month,br.SearchLogDate,@reportDate) = 1 AND
	                RID LIKE '%,%' AND
	                CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0
	            GROUP BY SearchMetroAreaID
	            ) AS tMultiPrior ON metro.MetroAreaID = tMultiPrior.SearchMetroAreaID
	        LEFT JOIN (
	            /*MultiWeek*/
	            SELECT SearchMetroAreaID, COUNT(br.SearchID) AS MultiWeek
	            FROM SearchByRestaurant br
	            WHERE datediff(day,br.SearchLogDate,@reportDate) between 0 and 6 And
	                RID LIKE '%,%' AND
	                CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0
	            GROUP BY SearchMetroAreaID
	            ) AS tMultiWeek ON metro.MetroAreaID = tMultiWeek.SearchMetroAreaID
	        LEFT JOIN (
	            /*MultiMonth*/
	            SELECT SearchMetroAreaID, COUNT(br.SearchID) AS MultiMonth
	            FROM SearchByRestaurant br
	            WHERE datediff(month,br.SearchLogDate,@reportDate) = 0 AND
	                RID LIKE '%,%' AND
	                CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0
	            GROUP BY SearchMetroAreaID
	            ) AS tMultiMonth ON metro.MetroAreaID = tMultiMonth.SearchMetroAreaID
	
	        LEFT JOIN (
	            --Multi Year
	            SELECT SearchMetroAreaID, COUNT(br.SearchID) AS MultiYear
	            FROM SearchByRestaurant br
	            WHERE datediff(year,br.SearchLogDate,@reportDate) = 0 AND
	                datediff(day,br.SearchLogDate,@reportDate) >= 0 And
	                RID LIKE '%,%' AND
	                CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0
	            GROUP BY SearchMetroAreaID
	            ) AS tMultiYear ON metro.MetroAreaID = tMultiYear.SearchMetroAreaID
	
	        /***************************************************************************************************/
	        /*Previously Report_Search_ByNieghborhood*/
	        /***************************************************************************************************/
	        LEFT JOIN (
	            /*NeighborhoodYes*/
	            SELECT SearchMetroAreaID, COUNT(SearchID) AS NeighborhoodYes
	            FROM SearchByNeighborhood
	            WHERE datediff(day,SearchLogDate,@reportDate) = 0 AND
	                CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0
	            GROUP BY SearchMetroAreaID
	            ) AS tNeighborhoodYes ON metro.MetroAreaID = tNeighborhoodYes.SearchMetroAreaID
	
	        LEFT JOIN (
	            /*NeighborhoodPrior*/
	            SELECT SearchMetroAreaID, COUNT(SearchID) AS NeighborhoodPrior
	            FROM SearchByNeighborhood
	            WHERE datediff(month,SearchLogDate,@reportDate) = 1 AND
	                CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0
	            GROUP BY SearchMetroAreaID
	            ) AS tNeighborhoodPrior ON metro.MetroAreaID = tNeighborhoodPrior.SearchMetroAreaID
	        LEFT JOIN (
	            /*NeighborhoodWeek*/
	            SELECT SearchMetroAreaID, COUNT(SearchID) AS NeighborhoodWeek
	            FROM SearchByNeighborhood
	            WHERE datediff(day,SearchLogDate,@reportDate) between 0 and 6 AND
	                CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0
	            GROUP BY SearchMetroAreaID
	            ) AS tNeighborhoodWeek ON metro.MetroAreaID = tNeighborhoodWeek.SearchMetroAreaID
	        LEFT JOIN (
	            /*NeighborhoodMonth*/
	            SELECT SearchMetroAreaID, COUNT(SearchID) AS NeighborhoodMonth
	            FROM SearchByNeighborhood
	            WHERE datediff(month,SearchLogDate,@reportDate) = 0 AND
	                CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0
	            GROUP BY SearchMetroAreaID
	            ) AS tNeighborhoodMonth ON metro.MetroAreaID = tNeighborhoodMonth.SearchMetroAreaID
	
	        LEFT JOIN (
	            --NeighborhoodYear
	            SELECT SearchMetroAreaID, COUNT(SearchID) AS NeighborhoodYear
	            FROM SearchByNeighborhood
	            WHERE datediff(year,SearchLogDate,@reportDate) = 0 AND
	                datediff(day,SearchLogDate,@reportDate) >= 0 AND
	                CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0
	            GROUP BY SearchMetroAreaID
	            ) AS tNeighborhoodYear ON metro.MetroAreaID = tNeighborhoodYear.SearchMetroAreaID
	
	
	        /***************************************************************************************************/
	        /*Report_SearchByMacroNeighborhood*/
	        /***************************************************************************************************/
	        LEFT JOIN (
	            SELECT SearchMetroAreaID, COUNT(SearchID) AS MacroYes
	            FROM SearchByMacroNeighborhood
	            WHERE   DATEDIFF(DAY,SearchLogDate,@reportDate) = 0 AND
	                CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0
	            GROUP BY SearchMetroAreaID
	            ) AS tMacroYes ON metro.MetroAreaID = tMacroYes.SearchMetroAreaID
	        LEFT JOIN (
	            SELECT SearchMetroAreaID, COUNT(SearchID) AS MacroPrior
	            FROM SearchByMacroNeighborhood
	            WHERE   datediff(month,SearchLogDate,@reportDate) = 1 AND
	                CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0
	            GROUP BY SearchMetroAreaID
	            ) AS tMacroPrior ON metro.MetroAreaID = tMacroPrior.SearchMetroAreaID
	        LEFT JOIN (
	            SELECT SearchMetroAreaID, COUNT(SearchID) AS MacroWeek
	            FROM SearchByMacroNeighborhood
	            WHERE datediff(day,SearchLogDate,@reportDate) between 0 and 6 AND
	                CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0
	            GROUP BY SearchMetroAreaID
	            ) AS tMacroWeek ON metro.MetroAreaID = tMacroWeek.SearchMetroAreaID
	        LEFT JOIN (
	            SELECT SearchMetroAreaID, COUNT(SearchID) AS MacroMonth
	            FROM SearchByMacroNeighborhood
	            WHERE datediff(month,SearchLogDate,@reportDate) = 0 AND
	                CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0
	            GROUP BY SearchMetroAreaID
	            ) AS tMacroMonth ON metro.MetroAreaID = tMacroMonth.SearchMetroAreaID
	
	        LEFT JOIN (
	            SELECT SearchMetroAreaID, COUNT(SearchID) AS MacroYear
	            FROM SearchByMacroNeighborhood
	            WHERE datediff(year,SearchLogDate,@reportDate) = 0 AND
	                datediff(day,SearchLogDate,@reportDate) >= 0 AND
	                CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0
	            GROUP BY SearchMetroAreaID
	            ) AS tMacroYear ON metro.MetroAreaID = tMacroYear.SearchMetroAreaID
	
	
	
	        /*All Resos/Registered Users*/
	        /***************************************************************************************************/
	        LEFT JOIN (
	                SELECT n.MetroAreaID, COUNT(resos.RID) AS RegUserAllResoYes
	                FROM    (
	                        --This gets Real Customer Resos
	                        --//////////////////////////////////////////////////
	                        SELECT r.RID
	                        FROM Reservation r
	                            INNER JOIN Customer rc ON r.CustID = rc.CustID
	                            INNER JOIN ReservationUI ui ON r.ResID = UI.ResID
	                        WHERE datediff(day,DateMade,@reportDate) = 0 AND
	                            ConsumerType <> 8 AND
	                            CHARINDEX(',' + CAST(ui.UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0 AND
	                            r.PartnerID = 1
	                        --//////////////////////////////////////////////////
	                        UNION
	                        --This gets Caller Resos
	                        --//////////////////////////////////////////////////
	                        SELECT r.RID
	                        FROM Reservation r
	                            INNER JOIN Caller c ON r.CallerID = c.CallerID
	                            INNER JOIN ReservationUI ui ON r.ResID = UI.ResID
	                        WHERE datediff(day,DateMade,@reportDate) = 0 AND
	                            ConsumerType <> 8 AND
	                            CHARINDEX(',' + CAST(ui.UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0 AND
	                            r.PartnerID = 1
	                        --//////////////////////////////////////////////////
	                        ) AS resos
	                    INNER JOIN Restaurant Rest ON resos.RID = Rest.RID
	                    INNER JOIN Neighborhood n ON n.NeighborhoodID = Rest.NeighborhoodID
	                GROUP BY n.MetroAreaID
	            ) AS tRegUserAllResoYes ON metro.MetroAreaID = tRegUserAllResoYes.MetroAreaID
	        LEFT JOIN (
	
	                SELECT n.MetroAreaID, COUNT(resos.RID) AS RegUserAllResoPrior
	                FROM    (
	                        --This gets Real Customer Resos
	                        --//////////////////////////////////////////////////
	                        SELECT r.RID
	                        FROM Reservation r
	                            INNER JOIN Customer rc ON r.CustID = rc.CustID
	                            INNER JOIN ReservationUI ui ON r.ResID = UI.ResID
	                        WHERE datediff(month,DateMade,@reportDate) = 1 AND
	                            ConsumerType <> 8 AND
	                            CHARINDEX(',' + CAST(ui.UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0 AND
	                            r.PartnerID = 1
	                        --//////////////////////////////////////////////////
	                        UNION
	                        --This gets Caller Resos
	                        --//////////////////////////////////////////////////
	                        SELECT r.RID
	                        FROM Reservation r
	                            INNER JOIN Caller c ON r.CallerID = c.CallerID
	                            INNER JOIN ReservationUI ui ON r.ResID = UI.ResID
	                        WHERE datediff(month,DateMade,@reportDate) = 1 AND
	                            ConsumerType <> 8 AND
	                            CHARINDEX(',' + CAST(ui.UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0 AND
	                            r.PartnerID = 1
	                        --//////////////////////////////////////////////////
	                        ) AS resos
	                    INNER JOIN Restaurant Rest ON resos.RID = Rest.RID
	                    INNER JOIN Neighborhood n ON n.NeighborhoodID = Rest.NeighborhoodID
	                GROUP BY n.MetroAreaID
	
	            ) AS tRegUserAllResoPrior ON metro.MetroAreaID = tRegUserAllResoPrior.MetroAreaID
	        LEFT JOIN (
	
	                SELECT n.MetroAreaID, COUNT(resos.RID) AS RegUserAllResoWeek
	                FROM    (
	                        --This gets Real Customer Resos
	                        --//////////////////////////////////////////////////
	                        SELECT r.RID
	                        FROM Reservation r
	                            INNER JOIN Customer rc ON r.CustID = rc.CustID
	                            INNER JOIN ReservationUI ui ON r.ResID = UI.ResID
	                        WHERE datediff(day,r.DateMade,@reportDate) between 0 and 6 AND
	                            ConsumerType <> 8 AND
	                            CHARINDEX(',' + CAST(ui.UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0 AND
	                            r.PartnerID = 1
	                        --//////////////////////////////////////////////////
	                        UNION
	                        --This gets Caller Resos
	                        --//////////////////////////////////////////////////
	                        SELECT r.RID
	                        FROM Reservation r
	                            INNER JOIN Caller c ON r.CallerID = c.CallerID
	                            INNER JOIN ReservationUI ui ON r.ResID = UI.ResID
	                        WHERE datediff(day,r.DateMade,@reportDate) between 0 and 6 AND
	                            ConsumerType <> 8 AND
	                            CHARINDEX(',' + CAST(ui.UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0 AND
	                            r.PartnerID = 1
	                        --//////////////////////////////////////////////////
	                        ) AS resos

	                    INNER JOIN Restaurant Rest ON resos.RID = Rest.RID
	                    INNER JOIN Neighborhood n ON n.NeighborhoodID = Rest.NeighborhoodID
	                GROUP BY n.MetroAreaID
	
	
	            ) AS tRegUserAllResoWeek ON metro.MetroAreaID = tRegUserAllResoWeek.MetroAreaID
	        LEFT JOIN (
	
	                SELECT n.MetroAreaID, COUNT(resos.RID) AS RegUserAllResoMonth
	                FROM    (
	                        --This gets Real Customer Resos
	                        --//////////////////////////////////////////////////
	                        SELECT r.RID
	                        FROM Reservation r
	                            INNER JOIN Customer rc ON r.CustID = rc.CustID
	                            INNER JOIN ReservationUI ui ON r.ResID = UI.ResID
	                        WHERE datediff(month,r.DateMade,@reportDate) = 0 AND
	                            ConsumerType <> 8 AND
	                            CHARINDEX(',' + CAST(ui.UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0 AND
	                            r.PartnerID = 1
	                        --//////////////////////////////////////////////////
	                        UNION
	                        --This gets Caller Resos
	                        --//////////////////////////////////////////////////
	                        SELECT r.RID
	                        FROM Reservation r
	                            INNER JOIN Caller c ON r.CallerID = c.CallerID
	                            INNER JOIN ReservationUI ui ON r.ResID = UI.ResID
	                        WHERE datediff(month,r.DateMade,@reportDate) = 0 AND
	                            ConsumerType <> 8 AND
	                            CHARINDEX(',' + CAST(ui.UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0 AND
	                            r.PartnerID = 1
	                        --//////////////////////////////////////////////////
	                        ) AS resos
	                    INNER JOIN Restaurant Rest ON resos.RID = Rest.RID
	                    INNER JOIN Neighborhood n ON n.NeighborhoodID = Rest.NeighborhoodID
	                GROUP BY n.MetroAreaID
	            ) AS tRegUserAllResoMonth ON metro.MetroAreaID = tRegUserAllResoMonth.MetroAreaID
	
	        LEFT JOIN (
	
	
	                SELECT n.MetroAreaID, COUNT(resos.RID) AS RegUserAllResoYear
	                FROM    (
	                        --This gets Real Customer Resos
	                        --//////////////////////////////////////////////////
	                        SELECT r.RID
	                        FROM Reservation r
	                            INNER JOIN Customer rc ON r.CustID = rc.CustID
	                            INNER JOIN ReservationUI ui ON r.ResID = UI.ResID
	                        WHERE YEAR(r.DateMade) = YEAR(@reportDate) AND
	                            ConsumerType <> 8 AND
	                            CHARINDEX(',' + CAST(ui.UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0 AND
	                            r.PartnerID = 1
	                        --//////////////////////////////////////////////////
	                        UNION
	                        --This gets Caller Resos
	                        --//////////////////////////////////////////////////
	                        SELECT r.RID
	                        FROM Reservation r
	                            INNER JOIN Caller c ON r.CallerID = c.CallerID
	                            INNER JOIN ReservationUI ui ON r.ResID = UI.ResID
	                        WHERE YEAR(r.DateMade) = YEAR(@reportDate) AND
	                            ConsumerType <> 8 AND
	                            CHARINDEX(',' + CAST(ui.UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0 AND
	                            r.PartnerID = 1
	                        --//////////////////////////////////////////////////
	                        ) AS resos
	                    INNER JOIN Restaurant Rest ON resos.RID = Rest.RID
	                    INNER JOIN Neighborhood n ON n.NeighborhoodID = Rest.NeighborhoodID
	                GROUP BY n.MetroAreaID
	
	            ) AS tRegUserAllResoYear ON metro.MetroAreaID = tRegUserAllResoYear.MetroAreaID
	
	        /***************************************************************************************************/
	
	
	
	        /*All Resos/Anonymous Users*/
	        /***************************************************************************************************/
	        LEFT JOIN (
	                SELECT n.MetroAreaID, COUNT(resos.RID) AS AnonUserAllResoYes
	                FROM    (
	                        --This gets Real Customer Resos
	                        --//////////////////////////////////////////////////
	                        SELECT r.RID
	                        FROM Reservation r
	                            INNER JOIN Customer rc ON r.CustID = rc.CustID
	                            INNER JOIN ReservationUI ui ON r.ResID = UI.ResID
	                        WHERE datediff(day,DateMade,@reportDate) = 0 AND
	                            ConsumerType = 8 AND
	                            CHARINDEX(',' + CAST(ui.UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0 AND
	                            r.PartnerID = 1
	                        --//////////////////////////////////////////////////
	                        UNION
	                        --This gets Caller Resos
	                        --//////////////////////////////////////////////////
	                        SELECT r.RID
	                        FROM Reservation r
	                            INNER JOIN Caller c ON r.CallerID = c.CallerID
	                            INNER JOIN ReservationUI ui ON r.ResID = UI.ResID
	                        WHERE datediff(day,DateMade,@reportDate) = 0 AND
	                            ConsumerType = 8 AND
	                            CHARINDEX(',' + CAST(ui.UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0 AND
	                            r.PartnerID = 1
	                        --//////////////////////////////////////////////////
	                        ) AS resos
	                    INNER JOIN Restaurant Rest ON resos.RID = Rest.RID
	                    INNER JOIN Neighborhood n ON n.NeighborhoodID = Rest.NeighborhoodID
	                GROUP BY n.MetroAreaID
	            ) AS tAnonUserAllResoYes ON metro.MetroAreaID = tAnonUserAllResoYes.MetroAreaID
	        LEFT JOIN (
	
	                SELECT n.MetroAreaID, COUNT(resos.RID) AS AnonUserAllResoPrior
	                FROM    (
	                        --This gets Real Customer Resos
	                        --//////////////////////////////////////////////////
	                        SELECT r.RID
	                        FROM Reservation r
	                            INNER JOIN Customer rc ON r.CustID = rc.CustID
	                            INNER JOIN ReservationUI ui ON r.ResID = UI.ResID
	                        WHERE datediff(month,DateMade,@reportDate) = 1 AND
	                            ConsumerType = 8 AND
	                            CHARINDEX(',' + CAST(ui.UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0 AND
	                            r.PartnerID = 1
	                        --//////////////////////////////////////////////////
	                        UNION
	                        --This gets Caller Resos
	                        --//////////////////////////////////////////////////
	                        SELECT r.RID
	                        FROM Reservation r
	                            INNER JOIN Caller c ON r.CallerID = c.CallerID
	                            INNER JOIN ReservationUI ui ON r.ResID = UI.ResID
	                        WHERE datediff(month,DateMade,@reportDate) = 1 AND
	                            ConsumerType = 8 AND
	                            CHARINDEX(',' + CAST(ui.UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0 AND
	                            r.PartnerID = 1
	                        --//////////////////////////////////////////////////
	                        ) AS resos
	                    INNER JOIN Restaurant Rest ON resos.RID = Rest.RID
	                    INNER JOIN Neighborhood n ON n.NeighborhoodID = Rest.NeighborhoodID
	                GROUP BY n.MetroAreaID
	
	            ) AS tAnonUserAllResoPrior ON metro.MetroAreaID = tAnonUserAllResoPrior.MetroAreaID
	        LEFT JOIN (
	
	                SELECT n.MetroAreaID, COUNT(resos.RID) AS AnonUserAllResoWeek
	                FROM    (
	                        --This gets Real Customer Resos
	                        --//////////////////////////////////////////////////
	                        SELECT r.RID
	                        FROM Reservation r
	                            INNER JOIN Customer rc ON r.CustID = rc.CustID
	                            INNER JOIN ReservationUI ui ON r.ResID = UI.ResID
	                        WHERE datediff(day,r.DateMade,@reportDate) between 0 and 6 AND
	                            ConsumerType = 8 AND
	                            CHARINDEX(',' + CAST(ui.UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0 AND
	                            r.PartnerID = 1
	                        --//////////////////////////////////////////////////
	                        UNION
	                        --This gets Caller Resos
	                        --//////////////////////////////////////////////////
	                        SELECT r.RID
	                        FROM Reservation r
	                            INNER JOIN Caller c ON r.CallerID = c.CallerID
	                            INNER JOIN ReservationUI ui ON r.ResID = UI.ResID
	                        WHERE datediff(day,r.DateMade,@reportDate) between 0 and 6 AND
	                            ConsumerType = 8 AND
	                            CHARINDEX(',' + CAST(ui.UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0 AND
	                            r.PartnerID = 1
	                        --//////////////////////////////////////////////////
	                        ) AS resos
	                    INNER JOIN Restaurant Rest ON resos.RID = Rest.RID
	                    INNER JOIN Neighborhood n ON n.NeighborhoodID = Rest.NeighborhoodID
	                GROUP BY n.MetroAreaID
	
	
	            ) AS tAnonUserAllResoWeek ON metro.MetroAreaID = tAnonUserAllResoWeek.MetroAreaID
	        LEFT JOIN (
	
	                SELECT n.MetroAreaID, COUNT(resos.RID) AS AnonUserAllResoMonth
	                FROM    (
	                        --This gets Real Customer Resos
	                        --//////////////////////////////////////////////////
	                        SELECT r.RID
	                        FROM Reservation r
	                            INNER JOIN Customer rc ON r.CustID = rc.CustID
	                            INNER JOIN ReservationUI ui ON r.ResID = UI.ResID
	                        WHERE datediff(month,r.DateMade,@reportDate) = 0 AND
	                            ConsumerType = 8 AND
	                            CHARINDEX(',' + CAST(ui.UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0 AND
	                            r.PartnerID = 1
	                        --//////////////////////////////////////////////////
	                        UNION
	                        --This gets Caller Resos
	                        --//////////////////////////////////////////////////
	                        SELECT r.RID
	                        FROM Reservation r
	                            INNER JOIN Caller c ON r.CallerID = c.CallerID
	                            INNER JOIN ReservationUI ui ON r.ResID = UI.ResID
	                        WHERE datediff(month,r.DateMade,@reportDate) = 0 AND
	                            ConsumerType = 8 AND
	                            CHARINDEX(',' + CAST(ui.UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0 AND
	                            r.PartnerID = 1
	                        --//////////////////////////////////////////////////
	                        ) AS resos
	                    INNER JOIN Restaurant Rest ON resos.RID = Rest.RID
	                    INNER JOIN Neighborhood n ON n.NeighborhoodID = Rest.NeighborhoodID
	                GROUP BY n.MetroAreaID
	
	
	            ) AS tAnonUserAllResoMonth ON metro.MetroAreaID = tAnonUserAllResoMonth.MetroAreaID
	
	        LEFT JOIN (
	                SELECT n.MetroAreaID, COUNT(resos.RID) AS AnonUserAllResoYear
	                FROM    (
	                        --This gets Real Customer Resos
	                        --//////////////////////////////////////////////////
	                        SELECT r.RID
	                        FROM Reservation r
	                            INNER JOIN Customer rc ON r.CustID = rc.CustID
	                            INNER JOIN ReservationUI ui ON r.ResID = UI.ResID
	                        WHERE YEAR(r.DateMade) = YEAR(@reportDate) AND
	                            ConsumerType = 8 AND
	                            CHARINDEX(',' + CAST(ui.UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0 AND
	                            r.PartnerID = 1
	                        --//////////////////////////////////////////////////
	                        UNION
	                        --This gets Caller Resos
	                        --//////////////////////////////////////////////////
	                        SELECT r.RID
	                        FROM Reservation r
	                            INNER JOIN Caller c ON r.CallerID = c.CallerID
	                            INNER JOIN ReservationUI ui ON r.ResID = UI.ResID
	                        WHERE YEAR(r.DateMade) = YEAR(@reportDate) AND
	                            ConsumerType = 8 AND
	                            CHARINDEX(',' + CAST(ui.UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0 AND
	                            r.PartnerID = 1
	                        --//////////////////////////////////////////////////
	                        ) AS resos
	                    INNER JOIN Restaurant Rest ON resos.RID = Rest.RID
	                    INNER JOIN Neighborhood n ON n.NeighborhoodID = Rest.NeighborhoodID
	                GROUP BY n.MetroAreaID
	
	            ) AS tAnonUserAllResoYear ON metro.MetroAreaID = tAnonUserAllResoYear.MetroAreaID
	
	        /***************************************************************************************************/
	
	
	    /*Billable Resos/Registered Users*/
	        /***************************************************************************************************/
	        LEFT JOIN (
	                SELECT n.MetroAreaID, COUNT(resos.RID) AS RegUserBillableResoYes
	                FROM    (
	                        --This gets Real Customer Resos
	                        --//////////////////////////////////////////////////
	                        SELECT r.RID
	                        FROM Reservation r
	                            INNER JOIN Customer rc ON r.CustID = rc.CustID
	                            INNER JOIN ReservationUI ui ON r.ResID = UI.ResID
	                        WHERE datediff(day,DateMade,@reportDate) = 0 AND
	                            ConsumerType <> 8 AND
	                            r.RStateID not in (3,4,8,9,10) AND
	                            CHARINDEX(',' + CAST(ui.UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0 AND
	                            r.PartnerID = 1
	                        --//////////////////////////////////////////////////
	                        UNION
	                        --This gets Caller Resos
	                        --//////////////////////////////////////////////////
	                        SELECT r.RID
	                        FROM Reservation r
	                            INNER JOIN Caller c ON r.CallerID = c.CallerID
	                            INNER JOIN ReservationUI ui ON r.ResID = UI.ResID
	                        WHERE datediff(day,DateMade,@reportDate) = 0 AND
	                            ConsumerType <> 8 AND
	                            r.RStateID not in (3,4,8,9,10) AND
	                            CHARINDEX(',' + CAST(ui.UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0 AND
	                            r.PartnerID = 1
	                        --//////////////////////////////////////////////////
	                        ) AS resos
	                    INNER JOIN Restaurant Rest ON resos.RID = Rest.RID
	                    INNER JOIN Neighborhood n ON n.NeighborhoodID = Rest.NeighborhoodID
	                GROUP BY n.MetroAreaID
	            ) AS tRegUserBillableResoYes ON metro.MetroAreaID = tRegUserBillableResoYes.MetroAreaID
	        LEFT JOIN (
	
	                SELECT n.MetroAreaID, COUNT(resos.RID) AS RegUserBillableResoPrior
	                FROM    (
	                        --This gets Real Customer Resos
	                        --//////////////////////////////////////////////////
	                        SELECT r.RID
	                        FROM Reservation r
	                            INNER JOIN Customer rc ON r.CustID = rc.CustID
	                            INNER JOIN ReservationUI ui ON r.ResID = UI.ResID
	                        WHERE datediff(month,DateMade,@reportDate) = 1 AND
	                            ConsumerType <> 8 AND
	                            r.RStateID not in (3,4,8,9,10) AND
	                            CHARINDEX(',' + CAST(ui.UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0 AND
	                            r.PartnerID = 1
	                        --//////////////////////////////////////////////////
	                        UNION
	                        --This gets Caller Resos
	                        --//////////////////////////////////////////////////
	                        SELECT r.RID
	                        FROM Reservation r
	                            INNER JOIN Caller c ON r.CallerID = c.CallerID
	                            INNER JOIN ReservationUI ui ON r.ResID = UI.ResID
	                        WHERE datediff(month,DateMade,@reportDate) = 1 AND
	                            ConsumerType <> 8 AND
	                            r.RStateID not in (3,4,8,9,10) AND
	                            CHARINDEX(',' + CAST(ui.UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0 AND
	                            r.PartnerID = 1
	                        --//////////////////////////////////////////////////
	                        ) AS resos
	                    INNER JOIN Restaurant Rest ON resos.RID = Rest.RID
	                    INNER JOIN Neighborhood n ON n.NeighborhoodID = Rest.NeighborhoodID
	                GROUP BY n.MetroAreaID
	
	            ) AS tRegUserBillableResoPrior ON metro.MetroAreaID = tRegUserBillableResoPrior.MetroAreaID
	        LEFT JOIN (
	
	                SELECT n.MetroAreaID, COUNT(resos.RID) AS RegUserBillableResoWeek
	                FROM    (
	                        --This gets Real Customer Resos
	                        --//////////////////////////////////////////////////
	                        SELECT r.RID
	                        FROM Reservation r
	                            INNER JOIN Customer rc ON r.CustID = rc.CustID
	                            INNER JOIN ReservationUI ui ON r.ResID = UI.ResID
	                        WHERE datediff(day,r.DateMade,@reportDate) between 0 and 6 AND
	                            ConsumerType <> 8 AND
	                            r.RStateID not in (3,4,8,9,10) AND
	                            CHARINDEX(',' + CAST(ui.UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0 AND
	                            r.PartnerID = 1
	                        --//////////////////////////////////////////////////
	                        UNION
	                        --This gets Caller Resos
	                        --//////////////////////////////////////////////////
	                        SELECT r.RID
	                        FROM Reservation r
	                            INNER JOIN Caller c ON r.CallerID = c.CallerID
	                            INNER JOIN ReservationUI ui ON r.ResID = UI.ResID
	                        WHERE datediff(day,r.DateMade,@reportDate) between 0 and 6 AND
	                            ConsumerType <> 8 AND
	                            r.RStateID not in (3,4,8,9,10) AND
	                            CHARINDEX(',' + CAST(ui.UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0 AND
	                            r.PartnerID = 1
	                        --//////////////////////////////////////////////////
	                        ) AS resos
	                    INNER JOIN Restaurant Rest ON resos.RID = Rest.RID
	                    INNER JOIN Neighborhood n ON n.NeighborhoodID = Rest.NeighborhoodID
	                GROUP BY n.MetroAreaID
	
	
	            ) AS tRegUserBillableResoWeek ON metro.MetroAreaID = tRegUserBillableResoWeek.MetroAreaID
	        LEFT JOIN (
	
	                SELECT n.MetroAreaID, COUNT(resos.RID) AS RegUserBillableResoMonth
	                FROM    (
	                        --This gets Real Customer Resos
	                        --//////////////////////////////////////////////////
	                        SELECT r.RID
	                        FROM Reservation r

	                            INNER JOIN Customer rc ON r.CustID = rc.CustID
	                            INNER JOIN ReservationUI ui ON r.ResID = UI.ResID
	                        WHERE datediff(month,r.DateMade,@reportDate) = 0 AND
	                            ConsumerType <> 8 AND
	                            r.RStateID not in (3,4,8,9,10) AND
	                            CHARINDEX(',' + CAST(ui.UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0 AND
	                            r.PartnerID = 1
	                        --//////////////////////////////////////////////////
	                        UNION
	                        --This gets Caller Resos
	                        --//////////////////////////////////////////////////
	                        SELECT r.RID
	                        FROM Reservation r
	                            INNER JOIN Caller c ON r.CallerID = c.CallerID
	                            INNER JOIN ReservationUI ui ON r.ResID = UI.ResID
	                        WHERE datediff(month,r.DateMade,@reportDate) = 0 AND
	                            ConsumerType <> 8 AND
	                            r.RStateID not in (3,4,8,9,10) AND
	                            CHARINDEX(',' + CAST(ui.UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0 AND
	                            r.PartnerID = 1
	                        --//////////////////////////////////////////////////
	                        ) AS resos
	                    INNER JOIN Restaurant Rest ON resos.RID = Rest.RID
	                    INNER JOIN Neighborhood n ON n.NeighborhoodID = Rest.NeighborhoodID
	                GROUP BY n.MetroAreaID
	
	
	            ) AS tRegUserBillableResoMonth ON metro.MetroAreaID = tRegUserBillableResoMonth.MetroAreaID
	
	        LEFT JOIN (
	
	                SELECT n.MetroAreaID, COUNT(resos.RID) AS RegUserBillableResoYear
	                FROM    (
	                        --This gets Real Customer Resos
	                        --//////////////////////////////////////////////////
	                        SELECT r.RID
	                        FROM Reservation r
	                            INNER JOIN Customer rc ON r.CustID = rc.CustID
	                            INNER JOIN ReservationUI ui ON r.ResID = UI.ResID
	                        WHERE YEAR(r.DateMade) = YEAR(@reportDate) AND
	                            ConsumerType <> 8 AND
	                            r.RStateID not in (3,4,8,9,10) AND
	                            CHARINDEX(',' + CAST(ui.UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0 AND
	                            r.PartnerID = 1
	                        --//////////////////////////////////////////////////
	                        UNION
	                        --This gets Caller Resos
	                        --//////////////////////////////////////////////////
	                        SELECT r.RID
	                        FROM Reservation r
	                            INNER JOIN Caller c ON r.CallerID = c.CallerID
	                            INNER JOIN ReservationUI ui ON r.ResID = UI.ResID
	                        WHERE YEAR(r.DateMade) = YEAR(@reportDate) AND
	                            ConsumerType <> 8 AND
	                            r.RStateID not in (3,4,8,9,10) AND
	                            CHARINDEX(',' + CAST(ui.UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0 AND
	                            r.PartnerID = 1
	                        --//////////////////////////////////////////////////
	                        ) AS resos
	                    INNER JOIN Restaurant Rest ON resos.RID = Rest.RID
	                    INNER JOIN Neighborhood n ON n.NeighborhoodID = Rest.NeighborhoodID
	                GROUP BY n.MetroAreaID
	
	            ) AS tRegUserBillableResoYear ON metro.MetroAreaID = tRegUserBillableResoYear.MetroAreaID
	
	        /***************************************************************************************************/
	
	
	
	        /*All Resos/Anonymous Users*/
	        /***************************************************************************************************/
	        LEFT JOIN (
	                SELECT n.MetroAreaID, COUNT(resos.RID) AS AnonUserBillableResoYes
	                FROM    (
	                        --This gets Real Customer Resos
	                        --//////////////////////////////////////////////////
	                        SELECT r.RID
	                        FROM Reservation r
	                            INNER JOIN Customer rc ON r.CustID = rc.CustID
	                            INNER JOIN ReservationUI ui ON r.ResID = UI.ResID
	                        WHERE datediff(day,DateMade,@reportDate) = 0 AND
	                            ConsumerType = 8 AND
	                            r.RStateID not in (3,4,8,9,10) AND
	                            CHARINDEX(',' + CAST(ui.UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0 AND
	                            r.PartnerID = 1
	                        --//////////////////////////////////////////////////
	                        UNION
	                        --This gets Caller Resos
	                        --//////////////////////////////////////////////////
	                        SELECT r.RID
	                        FROM Reservation r
	                            INNER JOIN Caller c ON r.CallerID = c.CallerID
	                            INNER JOIN ReservationUI ui ON r.ResID = UI.ResID
	                        WHERE datediff(day,DateMade,@reportDate) = 0 AND
	                            ConsumerType = 8 AND
	                            r.RStateID not in (3,4,8,9,10) AND
	                            CHARINDEX(',' + CAST(ui.UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0 AND
	                            r.PartnerID = 1
	                        --//////////////////////////////////////////////////
	                        ) AS resos
	                    INNER JOIN Restaurant Rest ON resos.RID = Rest.RID
	                    INNER JOIN Neighborhood n ON n.NeighborhoodID = Rest.NeighborhoodID
	                GROUP BY n.MetroAreaID
	            ) AS tAnonUserBillableResoYes ON metro.MetroAreaID = tAnonUserBillableResoYes.MetroAreaID
	        LEFT JOIN (
	
	                SELECT n.MetroAreaID, COUNT(resos.RID) AS AnonUserBillableResoPrior
	                FROM    (
	                        --This gets Real Customer Resos
	                        --//////////////////////////////////////////////////
	                        SELECT r.RID
	                        FROM Reservation r
	                            INNER JOIN Customer rc ON r.CustID = rc.CustID
	                            INNER JOIN ReservationUI ui ON r.ResID = UI.ResID
	                        WHERE datediff(month,DateMade,@reportDate) = 1 AND
	                            ConsumerType = 8 AND
	                            r.RStateID not in (3,4,8,9,10) AND
	                            CHARINDEX(',' + CAST(ui.UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0 AND
	                            r.PartnerID = 1
	                        --//////////////////////////////////////////////////
	                        UNION
	                        --This gets Caller Resos
	                        --//////////////////////////////////////////////////
	                        SELECT r.RID
	                        FROM Reservation r
	                            INNER JOIN Caller c ON r.CallerID = c.CallerID
	                            INNER JOIN ReservationUI ui ON r.ResID = UI.ResID
	                        WHERE datediff(month,DateMade,@reportDate) = 1 AND
	                            ConsumerType = 8 AND
	                            r.RStateID not in (3,4,8,9,10) AND
	                            CHARINDEX(',' + CAST(ui.UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0 AND
	                            r.PartnerID = 1
	                        --//////////////////////////////////////////////////
	                        ) AS resos
	                    INNER JOIN Restaurant Rest ON resos.RID = Rest.RID
	                    INNER JOIN Neighborhood n ON n.NeighborhoodID = Rest.NeighborhoodID
	                GROUP BY n.MetroAreaID
	
	            ) AS tAnonUserBillableResoPrior ON metro.MetroAreaID = tAnonUserBillableResoPrior.MetroAreaID
	        LEFT JOIN (
	
	                SELECT n.MetroAreaID, COUNT(resos.RID) AS AnonUserBillableResoWeek
	                FROM    (
	                        --This gets Real Customer Resos
	                        --//////////////////////////////////////////////////
	                        SELECT r.RID
	                        FROM Reservation r
	                            INNER JOIN Customer rc ON r.CustID = rc.CustID
	                            INNER JOIN ReservationUI ui ON r.ResID = UI.ResID
	                        WHERE datediff(day,r.DateMade,@reportDate) between 0 and 6 AND
	                            ConsumerType = 8 AND
	                            r.RStateID not in (3,4,8,9,10) AND
	                            CHARINDEX(',' + CAST(ui.UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0 AND
	                            r.PartnerID = 1
	                        --//////////////////////////////////////////////////
	                        UNION
	                        --This gets Caller Resos
	                        --//////////////////////////////////////////////////
	                        SELECT r.RID
	                        FROM Reservation r
	                            INNER JOIN Caller c ON r.CallerID = c.CallerID
	                            INNER JOIN ReservationUI ui ON r.ResID = UI.ResID
	                        WHERE datediff(day,r.DateMade,@reportDate) between 0 and 6 AND
	                            ConsumerType = 8 AND
	                            r.RStateID not in (3,4,8,9,10) AND
	                            CHARINDEX(',' + CAST(ui.UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0 AND
	                            r.PartnerID = 1
	                        --//////////////////////////////////////////////////
	                        ) AS resos
	                    INNER JOIN Restaurant Rest ON resos.RID = Rest.RID
	                    INNER JOIN Neighborhood n ON n.NeighborhoodID = Rest.NeighborhoodID
	                GROUP BY n.MetroAreaID
	
	
	            ) AS tAnonUserBillableResoWeek ON metro.MetroAreaID = tAnonUserBillableResoWeek.MetroAreaID
	        LEFT JOIN (
	
	                SELECT n.MetroAreaID, COUNT(resos.RID) AS AnonUserBillableResoMonth
	                FROM    (
	                        --This gets Real Customer Resos
	                        --//////////////////////////////////////////////////
	                        SELECT r.RID
	                        FROM Reservation r
	                            INNER JOIN Customer rc ON r.CustID = rc.CustID
	                            INNER JOIN ReservationUI ui ON r.ResID = UI.ResID
	                        WHERE datediff(month,r.DateMade,@reportDate) = 0 AND
	                            ConsumerType = 8 AND
	                            r.RStateID not in (3,4,8,9,10) AND
	                            CHARINDEX(',' + CAST(ui.UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0 AND
	                            r.PartnerID = 1
	                        --//////////////////////////////////////////////////
	                        UNION
	                        --This gets Caller Resos
	                        --//////////////////////////////////////////////////
	                        SELECT r.RID
	                        FROM Reservation r
	                            INNER JOIN Caller c ON r.CallerID = c.CallerID
	                            INNER JOIN ReservationUI ui ON r.ResID = UI.ResID
	                        WHERE datediff(month,r.DateMade,@reportDate) = 0 AND
	                            ConsumerType = 8 AND
	                            r.RStateID not in (3,4,8,9,10) AND
	                            CHARINDEX(',' + CAST(ui.UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0 AND
	                            r.PartnerID = 1
	                        --//////////////////////////////////////////////////
	                        ) AS resos
	                    INNER JOIN Restaurant Rest ON resos.RID = Rest.RID
	                    INNER JOIN Neighborhood n ON n.NeighborhoodID = Rest.NeighborhoodID
	                GROUP BY n.MetroAreaID
	
	
	            ) AS tAnonUserBillableResoMonth ON metro.MetroAreaID = tAnonUserBillableResoMonth.MetroAreaID
	
	        LEFT JOIN (
	
	                SELECT n.MetroAreaID, COUNT(resos.RID) AS AnonUserBillableResoYear
	                FROM    (
	                        --This gets Real Customer Resos
	                        --//////////////////////////////////////////////////
	                        SELECT r.RID
	                        
	                        FROM Reservation r
	                            INNER JOIN Customer rc ON r.CustID = rc.CustID
	                            INNER JOIN ReservationUI ui ON r.ResID = UI.ResID
	                        WHERE YEAR(r.DateMade) = YEAR(@reportDate) AND
	                            ConsumerType = 8 AND
	                            r.RStateID not in (3,4,8,9,10) AND
	                            CHARINDEX(',' + CAST(ui.UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0 AND
	                            r.PartnerID = 1
	                        --//////////////////////////////////////////////////
	                        UNION
	                        --This gets Caller Resos
	                        --//////////////////////////////////////////////////
	                        SELECT r.RID
	                        FROM Reservation r
	                            INNER JOIN Caller c ON r.CallerID = c.CallerID
	                            INNER JOIN ReservationUI ui ON r.ResID = UI.ResID
	                        WHERE YEAR(r.DateMade) = YEAR(@reportDate) AND
	                            ConsumerType = 8 AND
	                            r.RStateID not in (3,4,8,9,10) AND
	                            CHARINDEX(',' + CAST(ui.UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0 AND
	                            r.PartnerID = 1
	                        --//////////////////////////////////////////////////
	                        ) AS resos
	                    INNER JOIN Restaurant Rest ON resos.RID = Rest.RID
	                    INNER JOIN Neighborhood n ON n.NeighborhoodID = Rest.NeighborhoodID
	                GROUP BY n.MetroAreaID
	
	            ) AS tAnonUserBillableResoYear ON metro.MetroAreaID = tAnonUserBillableResoYear.MetroAreaID
	
	        /***************************************************************************************************/
	
	    WHERE metro.MetroAreaID <> 1
	    ORDER BY metro.MetroAreaName
	    

	END




GO


GRANT EXECUTE ON [Report_Search_Summary] TO ExecuteOnlyRole

GO
