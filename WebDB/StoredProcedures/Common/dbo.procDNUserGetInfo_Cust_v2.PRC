if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[procDNUserGetInfo_Cust_v2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[procDNUserGetInfo_Cust_v2]
GO

CREATE Procedure dbo.procDNUserGetInfo_Cust_v2
 (
  @UserID int
 )
As

SET NOCOUNT ON
set transaction isolation level read uncommitted


DECLARE @SocialInfo TABLE
(
	UserID int
	,SocialTypeID int
	,SiteUserID nvarchar(50)
	,SocialAccessToken varchar(255)
)
INSERT INTO @SocialInfo (UserID, SocialTypeID, SiteUserID, SocialAccessToken)
EXEC dbo.procSocialCustomer_GetUserById @UserID

DECLARE	@SocialTypes  NVARCHAR(2000)
SELECT	@SocialTypes = COALESCE(@SocialTypes + ',', '') + CAST(s.SocialTypeID as nvarchar(20)) + '|' + s.SiteUserID + '|' + s.SocialAccessToken
FROM	@SocialInfo s

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
			IsNull(u.SpotLight, Customer.SendPromoEmail)  as SendPromoEmail,
			t.UserTokenTypeID,
			t.[Hash],
			t.Salt,
			@SocialTypes AS SocialTypes,
			Coalesce(gp._GlobalPersonID, 0) AS GlobalPersonID

FROM		Customer 
LEFT JOIN   CustomerToken t
ON			Customer.CustID = t.CustID
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
LEFT JOIN	GlobalPerson gp
on			gp.CustID = Customer.CustID
WHERE		(Customer.CustID = @UserID)
		
--order by	phoneTypeID

GO



GRANT EXECUTE ON [procDNUserGetInfo_Cust_v2] TO ExecuteOnlyRole
GO
