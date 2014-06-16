if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_Caller_GetByEmail]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_Caller_GetByEmail]
GO


CREATE PROCEDURE dbo.Concierge_Caller_GetByEmail
 (
  @Email nvarchar(255)
 )
As
SET NOCOUNT ON
SELECT 
	CallerID AS UserID,
	FName AS FName,
    LName AS LName,
	'' as Password,
    metroareaid AS DefaultGeoID
FROM dbo.Caller
WHERE (LoginName = @Email) AND (PositionID = 2) and callerStatusID = 1

GO

GRANT EXECUTE ON [Concierge_Caller_GetByEmail] TO ExecuteOnlyRole

GO
