if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[procDNUserGetInfo_Caller]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[procDNUserGetInfo_Caller]
GO

CREATE Procedure dbo.procDNUserGetInfo_Caller
 (
  @UserID int
 )
As

SET NOCOUNT ON
set transaction isolation level read uncommitted


SELECT		Caller.FName AS FirstName,
			Caller.LName AS LastName,
			Caller.SFName AS SortableFirstName,
			Caller.SLName AS SortableLastName,
			Caller.EMail,
			Caller.LoginName,
			Caller.metroareaid AS DefaultGeoID,
			'' as MetroName,  -- TODO: EV: This field can be removed after i18n p2 Deploy
			Caller.Notes AS DefaultRequests,
			'' AS Password,
			p.PhoneCountryID as PhoneCountryID,
			p.Phone,
			m.PhoneCountryID as MobilePhoneCountryID,
			m.Phone as MobilePhone,
			Caller.LastResoPhoneTypeID,
			Caller.Points,
			ConsumerType as Consumer_Type,
			PositionID,
			Caller.SendAnnouncements AS SendAnnouncements,
			Caller.DiningFormEmailOptIn,
			Salutation,
			UpdatedFavorites,
		   (CASE WHEN(Caller.CallerStatusID > 1) then 0 ELSE 1 END) as Active, 
			CompanyName, Company.Phone as CompanyPhone, 
			coalesce(Caller.CompanyID,0) as CompanyID,
			Company.Address1 as CompanyAddress1,
			Company.Address2 as CompanyAddress2,
			Company.City as CompanyCity,
			Company.State as CompanyState,
			Company.Zip as CompanyZip,
			Company.Logo as CompanyLogo,
			PwdQuestionID,
			IsNull(PwdAnswer, '') PwdAnswer,
			usa1.AttributeValue RecentDines,
			usa2.AttributeValue DislikedDines,
			IsNull(u.SpotLight, Caller.SendPromoEmail) AS SendPromoEmail		
FROM		Caller 
LEFT JOIN	CallerPhone p 
ON			Caller.CallerID = p.CallerID and p.PhoneTypeID = 6
LEFT JOIN	CallerPhone m
ON			Caller.CallerID = m.CallerID and m.PhoneTypeID = 4
LEFT JOIN	Company 
ON			Caller.CompanyID = Company.CompanyID
LEFT JOIN	UserSuggestionAttribute usa1
on			Caller.CallerID = usa1.CallerID
and			usa1.SuggestionAttributeID = 1
LEFT JOIN	UserSuggestionAttribute usa2
on			Caller.CallerID = usa2.CallerID
and			usa2.SuggestionAttributeID = 2
LEFT JOIN   UserOptIn u
on 			Caller.CallerID = u.CallerID
and			Caller.MetroAreaID = u.MetroAreaID
WHERE		(Caller.CallerID = @UserID)
--order by	phoneTypeID desc

GO



GRANT EXECUTE ON [procDNUserGetInfo_Caller] TO ExecuteOnlyRole
GO
