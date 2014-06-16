

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobGetSameDayPopRestaurants]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobGetSameDayPopRestaurants]
GO


CREATE Procedure [dbo].[JobGetSameDayPopRestaurants]
As

SET NOCOUNT ON
set transaction isolation level read uncommitted
 
;With i1(RID, IncentiveID)
AS
(
	SELECT     
	 i.Rid AS RID  		 
	 ,max(i.IncentiveID) AS IncentiveID
	FROM       
		Incentive i  			
	WHERE      
		i.LastMinutePopThresholdTime is not null  
	GROUP BY  
		i.RID  
)
,i11(RID, IncentiveID,IncentiveHistID)
AS
(
	SELECT
	    i1.RID AS RID, 
	    i1.IncentiveID AS IncentiveID,
	    CASE
			WHEN inc.ActiveIncHistID < inc.DeActiveIncHistID THEN inc.DeActiveIncHistID
			ELSE inc.ActiveIncHistID
		END AS IncentiveHistID
	FROM	
		i1
	INNER JOIN
		Incentive inc
	ON 
		i1.IncentiveID = inc.IncentiveID
)

SELECT 
	i2.RID, 
	r.rName AS [Restaurant Name], 
	CASE
		WHEN i2.Active = 1 THEN
			'TRUE'
		ELSE
			'FALSE'
	END AS [SDPOP Status], 
	convert(VARCHAR(10),i2.CreateDate,101) as EnabledDate, 
	CASE
		WHEN i2.Active = 1 and i2.DateDisabled is not null THEN
			null
		ELSE
			convert(VARCHAR(10),i2.DateDisabled,101)		
	END AS DisabledDate,
	CASE 
		WHEN ih.IsCommissionable = 0 THEN 
			'FALSE' 
		WHEN ih.IsCommissionable = 1 THEN
			'TRUE'
	END AS Commissionable,
	substring(ih.ContractSoldBy,0,charindex('[',ih.ContractSoldBy)) AS [Rep 1 Name],
	ih.ContractSoldByID AS [Rep 1 ID],
	substring(ih.SecondarySalesRep,0,charindex('[',ih.SecondarySalesRep)) AS [Rep 2 Name],
	ih.SecondarySalesRepID AS [Rep 2 ID]
FROM 
	 i11
INNER JOIN 
	Incentive i2
ON
	i11.RID = i2.RID and i11.IncentiveID = i2.IncentiveID
INNER JOIN 
	IncentiveHistory ih
ON
	i11.IncentiveHistID = ih.IncHistID
INNER JOIN 
	RestaurantVW r 
ON 
	i2.Rid = r.Rid  

Go

GRANT EXECUTE ON [JobGetSameDayPopRestaurants] TO ExecuteOnlyRole

Go


