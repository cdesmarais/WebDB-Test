
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Job_Report_Weekly_24HourEmail]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Job_Report_Weekly_24HourEmail]
GO


CREATE PROCEDURE [dbo].[Job_Report_Weekly_24HourEmail]
as

SET NOCOUNT ON  
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE @startDate VARCHAR(20), @endDate VARCHAR(20), @MinResID INT


-- sum(case when RegPriorToReso = 0 and ConvAtDayOfReso = 1 then 1 else 0 end) 'Registration Conversion',
-- This is weekly report
-- StartDate is Sunday at midnight AND EndDate is following Sunday at midnight of the previous week

SELECT 	@startDate = CONVERT(VARCHAR(20), DATEADD(DAY, -(DATEPART(dw,GETDATE()) + 6), GETDATE()), 101)
SELECT 	@endDate = DATEADD(DAY, 7, @startDate)

SELECT 	@MinResID = MIN(resID) FROM dbo.ReminderSentLog 
WHERE  	CreateDT > @startDate 
AND     CreateDT < @endDate

SELECT      CONVERT(VARCHAR(20), rsl.CreateDT, 101) AS ReservationDate
            ,sum(case when rest.Country = 'US' then 1 else 0 end) AS ImpressionCount   
FROM  		dbo.ReminderSentLog rsl
RIGHT JOIN	reservation reso
            ON reso.ResID = rsl.ResID
INNER JOIN	restaurant rest
            ON reso.RID = rest.RID
WHERE		rsl.CreateDT > @startDate 
AND         rsl.CreateDT < @endDate 
AND			reso.ResID >= @MinResID
GROUP BY CONVERT(VARCHAR(20), rsl.CreateDT, 101)
ORDER BY CONVERT(VARCHAR(20), rsl.CreateDT, 101)


GO

GRANT EXECUTE ON [Job_Report_Weekly_24HourEmail] TO ExecuteOnlyRole

GO