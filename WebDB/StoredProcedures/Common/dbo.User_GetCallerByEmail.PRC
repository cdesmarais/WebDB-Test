if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[User_GetCallerByEmail]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[User_GetCallerByEmail]
GO


CREATE Procedure dbo.User_GetCallerByEmail
 (
  @Email nvarchar(255)
 )
As

SET NOCOUNT ON
SELECT 
	CallerID AS UserID,
	FName AS FirstName,
    LName AS LastName,
	'' as Password,
    metroareaid AS DefaultGeoID,
	callerstatusid As Active,
	ConsumerType as Consumer_Type
	,coalesce((Select LoginFailedCount from FailedLoginCounter 
where 
	UserID = Caller.CallerID and isAdmin = 1),0) as PwdAttempt

FROM Caller
WHERE (LoginName = @Email) AND PositionID=3
GO

GRANT EXECUTE ON [User_GetCallerByEmail] TO ExecuteOnlyRole

GO
