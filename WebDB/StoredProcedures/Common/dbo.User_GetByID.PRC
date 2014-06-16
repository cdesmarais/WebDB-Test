if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[User_GetByID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[User_GetByID]
GO

CREATE Procedure dbo.User_GetByID
 (
  @UserID int,
  @IsCaller int=0
 )
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

if(@IsCaller = 0)
BEGIN
  SELECT          Customer.FName          AS FirstName
                 ,Customer.LName           AS LastName
                 ,Customer.EMail
                 ,''				 	as Password
                 ,Customer.metroareaid       AS DefaultGeoID
                 ,Customer.Points
                 ,CustomerPhone.Phone              AS DayPhone
                 ,Customer.Special
                 ,0 as Card_Number
                 ,getdate() as last_modified,ConsumerType as Consumer_Type
  FROM            Customer 
  LEFT OUTER JOIN CustomerPhone 
  ON              Customer.CustID        = CustomerPhone.CustID
  AND            (CustomerPhone.IsPrimary = 1)
  WHERE          (Customer.CustID        = @UserID) 
END

if(@IsCaller <> 0)

BEGIN
  SELECT          Caller.FName                 AS FirstName
                 ,Caller.LName                  AS LastName
                 ,Caller.EMail
				 ,''						as Password
                 ,Caller.metroareaid              AS DefaultGeoID
                 ,Caller.Points
                 ,CallerPhone.Phone                AS DayPhone
                 ,Caller.Notes                      AS Special
                 ,0 as Card_Number
                 ,getdate() as last_modified,ConsumerType as Consumer_Type
  FROM            Caller 
  LEFT OUTER JOIN CallerPhone 
  ON              Caller.CallerID               = CallerPhone.CallerID 
  AND            (CallerPhone.IsPrimary = 1) 
  WHERE          (Caller.CallerID               = @UserID) 
  AND            (Caller.PositionID             = 3)
End

GO

GRANT EXECUTE ON [User_GetByID] TO ExecuteOnlyRole

GO
