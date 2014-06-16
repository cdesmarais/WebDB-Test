if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[procDNUserGetInfo_Caller_v2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[procDNUserGetInfo_Caller_v2]
GO

CREATE Procedure dbo.procDNUserGetInfo_Caller_v2
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
EXEC dbo.procSocialCaller_GetUserById @UserID

DECLARE	@SocialTypes  NVARCHAR(2000)
SELECT	@SocialTypes = COALESCE(@SocialTypes + ',', '') + CAST(s.SocialTypeID as nvarchar(20)) + '|' + s.SiteUserID + '|' + s.SocialAccessToken
FROM	@SocialInfo s

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
			IsNull(u.SpotLight, Caller.SendPromoEmail) AS SendPromoEmail,
			t.UserTokenTypeID,
			t.[Hash],
			t.Salt,
			@SocialTypes AS SocialTypes,
			Coalesce(gp._GlobalPersonID, 0) AS GlobalPersonID

FROM		Caller 
LEFT JOIN 	CallerToken t
ON			Caller.CallerID = t.CallerID
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
LEFT JOIN	GlobalPerson gp
on			gp.CallerID = Caller.CallerID
WHERE		(Caller.CallerID = @UserID)
--order by	phoneTypeID desc

GO



GRANT EXECUTE ON [procDNUserGetInfo_Caller_v2] TO ExecuteOnlyRole
GO
