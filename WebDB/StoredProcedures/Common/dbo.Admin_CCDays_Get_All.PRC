if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_CCDays_Get_All]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_CCDays_Get_All]
GO


CREATE PROCEDURE dbo.Admin_CCDays_Get_All

AS

SELECT RID
	,BlockedDate
	,StartTime
	,EndTime
FROM CreditCardDay

GO


GRANT EXECUTE ON [Admin_CCDays_Get_All] TO ExecuteOnlyRole

GO