if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[procDNUserGetInfo_Cust]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[procDNUserGetInfo_Cust]
GO

CREATE Procedure dbo.procDNUserGetInfo_Cust
 (
  @UserID int
 )
As

SET NOCOUNT ON
set transaction isolation level read uncommitted


SELECT		Customer.FName AS FirstName,
			Customer.LName AS LastName,
			Customer.SFName AS SortableFirstName,
			Customer.SLName AS SortableLastName,
			Customer.EMail,
			Customer.EMail as LoginName,
			Customer.metroareaid AS DefaultGeoID,
			'' as MetroName,  -- TODO: EV: This field can be removed after i18n p2 Deploy
			Customer.Special AS DefaultRequests,
			'' AS Password,
			d.PhoneCountryID as PhoneCountryID,	
			d.Phone,
			m.PhoneCountryID as MobilePhoneCountryID,	
			m.Phone as MobilePhone,
			Customer.LastResoPhoneTypeID,	
			Customer.Points,
			Customer.SendAnnouncements AS SendAnnouncements,
			Customer.DiningFormEmailOptIn AS DiningFormEmailOptIn,
			Salutation, 
			ConsumerType as Consumer_Type,
			0 as PositionID,
			UpdatedFavorites,
			Customer.Active, '' as CompanyName, '' as CompanyPhone, 0 as CompanyID,
			'' as CompanyAddress1,
			'' as CompanyAddress2,
			'' as CompanyCity,
			'' as CompanyState,
			'' as CompanyZip,
			'' as CompanyLogo,
			98 PwdQuestionID,
			'' PwdAnswer,
			usa1.AttributeValue RecentDines,
			usa2.AttributeValue DislikedDines,
			IsNull(u.SpotLight, Customer.SendPromoEmail)  as SendPromoEmail    
			
FROM		Customer 
LEFT JOIN	CustomerPhone d
ON			Customer.CustID = d.CustID AND d.PhoneTypeID = 2
LEFT JOIN	CustomerPhone m
ON			Customer.CustID = m.CustID AND m.PhoneTypeID = 4
LEFT JOIN	UserSuggestionAttribute usa1
on			Customer.CustID = usa1.CustID
and			usa1.SuggestionAttributeID = 1
LEFT JOIN	UserSuggestionAttribute usa2
on			Customer.CustID = usa2.CustID
and			usa2.SuggestionAttributeID = 2
LEFT JOIN   UserOptIn u
on 			Customer.CustID = u.CustID
AND			Customer.MetroAreaID = u.MetroAreaID
WHERE		(Customer.CustID = @UserID)
		
--order by	phoneTypeID

GO



GRANT EXECUTE ON [procDNUserGetInfo_Cust] TO ExecuteOnlyRole
GO
