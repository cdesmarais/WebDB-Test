if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Report_Reservation]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Report_Reservation]
GO

CREATE   PROCEDURE dbo.Report_Reservation

@reportDate	datetime,
@ui		nvarchar(100)

AS 

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON


SELECT metro.MetroAreaID, metro.MetroAreaName, 
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
						DateMade < DATEADD(d, 1, @reportDate) AND
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
						DateMade < DATEADD(d, 1, @reportDate) AND
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
						DateMade < DATEADD(d, 1, @reportDate) AND
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
						DateMade < DATEADD(d, 1, @reportDate) AND
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
						DateMade < DATEADD(d, 1, @reportDate) AND
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
						DateMade < DATEADD(d, 1, @reportDate) AND
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
	                    r.RStateID not in  (3,4,8,9,10) 
	                    AND             r.PartnerID = 1
	                --//////////////////////////////////////////////////
	                UNION
	                --This gets Caller Resos
	                --//////////////////////////////////////////////////
	                SELECT r.RID, r.ResID
	                FROM Reservation r
	                    INNER JOIN Caller c ON r.CallerID = c.CallerID
	                WHERE datediff(day,r.DateMade,@reportDate) between 0 and 6 AND
	                    r.RStateID not in  (3,4,8,9,10) AND
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
						DateMade < DATEADD(d, 1, @reportDate) AND
	                    ConsumerType <> 8 AND
	                    r.RStateID not in  (3,4,8,9,10) AND
	                    r.PartnerID = 1
	                --//////////////////////////////////////////////////
	                UNION
	                --This gets Caller Resos
	                --//////////////////////////////////////////////////
	                SELECT r.RID, r.ResID
	                FROM Reservation r
	                    INNER JOIN Caller c ON r.CallerID = c.CallerID
	                WHERE datediff(month,r.DateMade,@reportDate) = 0 AND
						DateMade < DATEADD(d, 1, @reportDate) AND
	                    r.RStateID not in  (3,4,8,9,10) AND
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
						DateMade < DATEADD(d, 1, @reportDate) AND
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
						DateMade < DATEADD(d, 1, @reportDate) AND
	                    r.RStateID not in  (3,4,8,9,10) AND
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
						DateMade < DATEADD(d, 1, @reportDate) AND
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
						DateMade < DATEADD(d, 1, @reportDate) AND
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

RETURN




GO


GRANT EXECUTE ON [Report_Reservation] TO ExecuteOnlyRole

GO
