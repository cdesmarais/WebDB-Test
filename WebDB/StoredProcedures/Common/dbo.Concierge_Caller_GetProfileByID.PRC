if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_Caller_GetProfileByID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_Caller_GetProfileByID]
GO



CREATE PROCEDURE dbo.Concierge_Caller_GetProfileByID
 (
  @UserID int
 )
As
SET NOCOUNT ON
SELECT 
	Caller.FName AS FirstName,
    Caller.LName AS LastName,
    Caller.EMail,
	'' as Password,
    Caller.metroareaid AS DefaultGeoID,
    PasswordQuestion.Question As PasswordQuestion,
    Caller.PwdAnswer As PasswordAnswer,
    Caller.PwdQuestionID AS PasswordQuestionID,
    CallerPhone.PhoneTypeID AS PhoneType,
    CallerPhone.Phone
FROM Caller INNER JOIN
    PasswordQuestion ON
    Caller.PwdQuestionID = PasswordQuestion.PwdQuestionID 
LEFT OUTER JOIN
    CallerPhone ON 
    Caller.CallerID = CallerPhone.CallerID And CallerPhone.IsPrimary = 1
WHERE (Caller.CallerID = @UserID)
GO

GRANT EXECUTE ON [Concierge_Caller_GetProfileByID] TO ExecuteOnlyRole

GO
