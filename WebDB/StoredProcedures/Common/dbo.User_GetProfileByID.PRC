if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[User_GetProfileByID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[User_GetProfileByID]
GO


CREATE Procedure dbo.User_GetProfileByID
 (
  @UserID int,
  @IsCaller int = 0
 )
As

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

if(@IsCaller = 0)
Begin
	SELECT 
					Customer.FName AS FirstName,
					Customer.LName AS LastName,
					Customer.EMail,
					Customer.Address1 as Address,Customer.City,
					Customer.Address2,
					Customer.State,Customer.Zip AS ZipCode,
					Customer.Country,
					Customer.metroareaid AS DefaultGeoID,ma.MetroAreaName as MetroName,
					Customer.Special AS DefaultRequests,
					PasswordQuestion.Question As PasswordQuestion,
					'' AS Password,
					Customer.PwdAnswer As PasswordAnswer,
					Customer.PwdQuestionID AS PasswordQuestionID,
					CustomerPhone.PhoneTypeID AS PhoneType,
					CustomerPhone.Phone,
					Customer.SendAnnouncements AS SendAnnouncements,
					0 as creditcheck,
					BirthMonth as Birth_month,
					BirthYear as Birth_Year,
					Salutation,
					Exported,
					ConsumerType as Consumer_Type
	FROM			Customer 
	INNER JOIN	    PasswordQuestion 
	ON			    Customer.PwdQuestionID = PasswordQuestion.PwdQuestionID
	INNER JOIN		MetroAreaVW ma 
	ON				Customer.metroareaid = ma.metroareaid
	LEFT JOIN	    CustomerPhone 
	ON			    Customer.CustID = CustomerPhone.CustID AND CustomerPhone.IsPrimary = 1
	LEFT JOIN	    EmailUpdates 
	ON			    Customer.CustID = EmailUpdates.userid 
	and				isCaller = 0 
	and				EmailUpdates.PartnerID = Customer.PartnerID
	WHERE			(Customer.CustID = @UserID)
End

if(@IsCaller <> 0)
Begin
	SELECT 
					Caller.FName AS FirstName,
					Caller.LName AS LastName,
					Caller.EMail,
					--Re-Add When Schema changes have been made
					--Caller.Address,Caller.City,Caller.Address2,Caller.State,Caller.Zip AS ZipCode,
					Caller.metroareaid AS DefaultGeoID,
					ma.MetroAreaName as MetroName,
					Caller.Notes AS DefaultRequests,
					PasswordQuestion.Question As PasswordQuestion,
					'' AS Password,
					Caller.PwdAnswer As PasswordAnswer,
					Caller.PwdQuestionID AS PasswordQuestionID,
					CallerPhone.PhoneTypeID AS PhoneType,
					CallerPhone.Phone,
					0 as creditcheck,
					Exported,
					ConsumerType as Consumer_Type
	FROM Caller 
	INNER JOIN	    PasswordQuestion 
	ON			    Caller.PwdQuestionID = PasswordQuestion.PwdQuestionID
	INNER JOIN		CallerCustomer 
	ON				Caller.CallerID = CallerCustomer.CallerID
	INNER JOIN		MetroAreaVW ma 
	ON				Caller.metroareaid = ma.metroareaid
	LEFT JOIN	    CallerPhone 
	ON			    Caller.CallerID = CallerPhone.CallerID AND CallerPhone.IsPrimary = 1
	LEFT JOIN		EmailUpdates 
	ON			    Caller.CallerID = EmailUpdates.userid 
	and				EmailUpdates.isCaller = 1 
	and				EmailUpdates.PartnerID = Caller.PartnerID
	WHERE			(Caller.CallerID = @UserID)
End

GO

GRANT EXECUTE ON [User_GetProfileByID] TO ExecuteOnlyRole

GO
