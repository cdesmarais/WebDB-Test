if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobCircleConciergeFraudRpt]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobCircleConciergeFraudRpt]
go


CREATE  PROCEDURE dbo.JobCircleConciergeFraudRpt
as

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

select		createDate
			,consumerTypeTypeName
			,callerID
			,Fname
			,Lname
			,Email
			,Address1
			,address2
			,loginName
			,points
			,CSDesc 
from		caller C
inner join	callerStatus CS
on			C.CallerStatusID = CS.CallerStatusID
inner join	consumertypes CT
on			c.consumertype = cT.consumertypeID
where		companyID = 538


GO

GRANT EXECUTE ON [JobCircleConciergeFraudRpt] TO ExecuteOnlyRole

GO