
IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[dbo].[JobReportFlemingsPOPFTD]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[JobReportFlemingsPOPFTD]
GO

CREATE PROCEDURE [dbo].[JobReportFlemingsPOPFTD] (
@StartDT	Datetime = NULL,
@EndDT		Datetime = NULL
) 

AS

IF @StartDT IS NULL
	SET @StartDT = DATEADD(mm, DATEDIFF(m,0,getdate())-1,0)
	
IF @EndDT IS NULL
	SET @EndDT =  DATEADD(mm, DATEDIFF(m,0,GETDATE()),0)

SELECT		reso.RID	
			,rest.RName
			,reso.ShiftDateTime
			,case when reso.callerid is null then cust.FName + ' ' + cust.LName else callcust.FName + ' ' + callcust.LName end 'Diner Name'
			,BillableSize
			,case when reso.FirstTime = 1 then 'Y' else 'N' end 'First Time Diner'
FROM		Reservationvw reso	
LEFT JOIN	Customer cust		
ON			reso.CustID = cust.CustID
INNER JOIN	RestaurantVW rest		
ON			reso.RID = rest.RID
LEFT JOIN	CallerCustomer callcust		
ON			reso.CallerID = callcust.CallerID and reso.CustID = callcust.CustID
WHERE		reso.RID in (
						39910, 
						39898, 
						40000, 
						40015, 
						40057, 
						40066, 
						39928, 
						39931, 
						39964, 
						39961, 
						39991, 
						40012, 
						40030, 
						39937 )	
AND			reso.RStateID in (1,2,5,6,7)
AND			reso.BillingType = 'DIPReso'
AND			reso.Shiftdate >= @StartDT and reso.Shiftdate < @EndDT 
ORDER BY	reso.RID		

GO

GRANT EXECUTE ON [JobReportFlemingsPOPFTD] TO ExecuteOnlyRole
GRANT EXECUTE ON [JobReportFlemingsPOPFTD] TO DTR_User

GO