if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Job_Active_Concierge_Companies_Accounts]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Job_Active_Concierge_Companies_Accounts]
GO

CREATE Procedure dbo.Job_Active_Concierge_Companies_Accounts AS

set transaction isolation level read uncommitted

DECLARE @currentdate DATETIME, @lastmonthdate DATETIME
DECLARE @startDate AS VARCHAR(20), @endDate AS VARCHAR(20)

SELECT @currentdate = GETDATE()
SELECT @lastmonthdate = DATEADD(mm, -1, @currentdate)
SELECT @startDate = CAST(MONTH(@lastmonthdate) AS VARCHAR) + '/01/' + CAST(YEAR(@lastmonthdate) AS VARCHAR) 
SELECT @endDate = CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(@currentdate)),@currentdate),101) 
    
SELECT		co.CompanyName 'Concierge Company Name'
			,co.CompanyID  'Concierge Company ID'
			,co.Address1 
			,co.Address2 
			,co.City	
			,co.State
			,co.ZIP		'Postal Code'	
			,co.Country
			,ca.callerid 'Concierge ID'   
			,ca.fname 'Concierge First Name'
			,ca.lname 'Concierge Last Name'
			,ca.LoginName 'Concierge Login Name'
			,ca.Email 'Concierge Email'
			,m.MetroAreaName 'Concierge Default Search City' 	
			,SUM(CASE WHEN r.RStateID IN (1, 2, 5, 7) THEN r.partysize ELSE 0 END) 'Total Covers'  
			,ma.MetroAreaName 'Hotel Metro'
			,co.Phone	'Hotel Phone'
			,co.Email	'Hotel Email'
FROM 			company  co
INNER JOIN	dbo.MetroAreaVW ma
ON			co.MetroAreaID = ma.MetroAreaID
INNER JOIN	        caller  ca
ON			co.companyID = ca.companyID
INNER JOIN 		dbo.MetroAreaVW m
ON 			m.MetroAreaID = ca.MetroAreaID           
LEFT OUTER JOIN 	reservation r   
on   			r.callerid = ca.callerid   
AND 			r.shiftdate BETWEEN @startdate AND @endDate 
WHERE 			co.companyTypeID = 1  
AND			ca.PositionID =2 
AND 			ca.CallerStatusID = 1
group by		co.CompanyName
			,co.CompanyID
			,co.Address1
			,co.Address2
			,co.City
			,co.State
			,co.ZIP
			,co.Country
			,ca.callerid     
			,ca.fname  
			,ca.lname   
			,ca.LoginName
			,ca.EMail
			,ca.MetroAreaID 
			,m.MetroAreaName
			,ma.MetroAreaName
			,co.Phone
			,co.Email

GO

GRANT EXECUTE ON [Job_Active_Concierge_Companies_Accounts] TO ExecuteOnlyRole

GO
