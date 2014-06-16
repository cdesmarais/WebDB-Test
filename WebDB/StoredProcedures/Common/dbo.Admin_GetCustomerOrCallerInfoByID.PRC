if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_GetCustomerOrCallerInfoByID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_GetCustomerOrCallerInfoByID]
GO


CREATE PROCEDURE dbo.Admin_GetCustomerOrCallerInfoByID

@CustomerOrCallerID int

AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

--This sproc checks both Customer and Caller for CustomerOrCallerID info
(	
 select 
  	 Customer.CustID as customer_id,
     Customer.FName as first_name,
     Customer.LName as last_name,
	 Customer.sfname as first_name_phonetic,
 	 Customer.slname as last_name_phonetic,
	 Customer.email as email,
	 '' as password,
	 '' as password_question,
	 '' as password_answer,
	 Customer.address1 as address,
	 Customer.address2 as address2,
	 Customer.city as city,
	 Customer.state as state,
	 Customer.zip as zip,
	 d.phone as phone,
	 d.PhoneTypeID as phone_id,
	 m.phone as mobilephone,
	 m.PhoneTypeID as mobile_phone_id,
	 Customer.CreateDate as create_date,
     IsCaller = 0,
     Customer.points as points,
	 Customer.Active,
	 Customer.email as login,
	 ma.MetroAreaName as MetroName,
	 ConsumerType as Consumer_Type,
	 '' as Caller_First_Name,
	 '' as Caller_Last_Name,
	 '' as Caller_Email,
	 ma.metroareaid as Metro_Area_ID,
	 0 as Company_ID,
	 PartnerID as Partner_ID,
	 SendAnnouncements,
	 DiningFormEmailOptIn,
	 '' as CompanyName,
	 ConvertDate as Convert_Date,
	 LoginFailedCount as PwdAttempt,
	 cd.ReasonID as DeactivatedReasonID,
	 fs.FraudStatusID,
	 fs.FraudStatusDescription,
	 coalesce(fb.CustID, 0) as fbID,
	 cn.Notes as Notes,
	 uoi.DinersChoice,
	 uoi.Insider,
	 uoi.NewHot,
	 uoi.Promotional,
	 uoi.RestaurantWeek,
	 uoi.Spotlight,
	 uoi.Product
	 from		Customer
	 INNER JOIN MetroAreaAVW ma
	 on			Customer.metroareaid = ma.metroareaid
	 AND		ma.PrimaryLanguageID = ma.LanguageID
	 LEFT JOIN CustomerPhone d
	 on			d.CustID = Customer.CustID AND d.PhoneTypeID = 2 --Work Phone	
	 LEFT JOIN CustomerPhone m
	 on			m.CustID = Customer.CustID AND m.PhoneTypeID = 4 --MObile Phone
	 left JOIN	ConsumerTypeConvertLog 
	 on			Customer.CustID = ConsumerTypeConvertLog.CustID 
	 and		OriginalConsumerTypeID = 8
	 left JOIN	FailedLoginCounter 
	 on			Customer.CustID = FailedLoginCounter.UserID 
	 and		isAdmin = 0
	 LEFT JOIN	CustomersDeactivated cd
	 ON			cd.CustID = Customer.CustID AND cd.ReasonID = 8 -- only interested in blacklist deactivations
	 left join	SuspectedFraudulentAccounts sfa
	 on			Customer.CustID = sfa.CustID
	 left join	FraudStatus fs
	 on			sfa.FraudStatusID = fs.FraudStatusID
	 left outer join SocialCustomer fb
	 on			fb.CustID = Customer.CustID and fb.SocialTypeID = 1
	 left outer join CustomerNotes cn
	 on			Customer.CustID = cn.CustomerID
	 left outer join UserOptIn uoi
	 on			Customer.CustID = uoi.CustID
	 and Customer.MetroAreaID = uoi.MetroAreaID
	 where		Customer.CustID = @CustomerOrCallerID	 
)
union all
(
Select 
	 Caller.CallerID as Customer_ID,
     Caller.FName as first_name,
     Caller.LName as last_name,
	 Caller.sfname as first_name_phonetic,
 	 Caller.slname as last_name_phonetic,
	 Caller.email as email,
	 '' as password,
	 '' as password_question,
	 '' as password_answer,
	 Caller.Address1 as address,
	 Caller.address2,
	 Caller.city,
	 Caller.state,
	 Caller.zip,
	 d.phone as phone,
	 d.PhoneTypeID as phone_id,
	 m.phone as mobilephone,
	 m.PhoneTypeID as mobile_phone_id,
	 Caller.createdate as create_date,
     IsCaller = 1,
     Caller.points as points,
	 CallerStatusID as Active,
	 Caller.LoginName as login,
	 ma.MetroAreaName as MetroName,
	 ConsumerType as Consumer_Type,
	 '' as Caller_First_Name,
	 '' as Caller_Last_Name,
	 '' as Caller_Email,
	 ma.metroareaid as Metro_Area_ID,
	 coalesce(Caller.CompanyID,0) as Company_ID,
	 PartnerID as Partner_ID,
	 SendAnnouncements,
	 DiningFormEmailOptIn,
	 Company.CompanyName as CompanyName,
	 ConvertDate as Convert_Date,
	 LoginFailedCount as PwdAttempt,
	 cd.ReasonID as DeactivatedReasonID,
	 fs.FraudStatusID,
	 fs.FraudStatusDescription,
	 coalesce(fb.CallerID, 0) as fbID,
	 cn.Notes as Notes,
	 uoi.DinersChoice,
	 uoi.Insider,
	 uoi.NewHot,
	 uoi.Promotional,
	 uoi.RestaurantWeek,
	 uoi.Spotlight,
	 uoi.Product
	 from		Caller
	 INNER JOIN MetroAreaAVW ma
	 on			Caller.metroareaid = ma.metroareaid
	 AND		ma.PrimaryLanguageID = ma.LanguageID
	 LEFT JOIN CallerPhone d
	 on			d.CallerID = Caller.CallerID AND d.PhoneTypeID = 6 --Work Phone	for Caller	
	 LEFT JOIN CallerPhone m
	 on			m.CallerID = Caller.CallerID AND m.PhoneTypeID = 4 --MObile Phone
	 left JOIN	Company 
	 on			Caller.CompanyID = Company.CompanyID
	 left JOIN	ConsumerTypeConvertLog 
	 on			Caller.CallerID = ConsumerTypeConvertLog.CallerID 
	 and		OriginalConsumerTypeID = 8
	 left JOIN	FailedLoginCounter 
	 on			Caller.CallerID = FailedLoginCounter.UserID 
	 and		isAdmin = 1
	 LEFT JOIN	CustomersDeactivated cd
	 ON			cd.CallerID = Caller.CallerID AND cd.ReasonID = 8 -- only interested in blacklist deactivations
	 left join	SuspectedFraudulentAccounts sfa
	 on			Caller.CallerID = sfa.CallerID
	 left join	FraudStatus fs
	 on			sfa.FraudStatusID = fs.FraudStatusID
	 left outer join SocialCaller fb
	 on			fb.CallerID = Caller.CallerID and fb.SocialTypeID = 1
	 left outer join CallerNotes cn
	 on			Caller.CallerID = cn.CallerID
	 left outer join UserOptIn uoi
	 on			Caller.CallerID = uoi.CallerID
	 and Caller.MetroAreaID = uoi.MetroAreaID
	 where		Caller.CallerID = @CustomerOrCallerID
)
return 0

GO

GRANT EXECUTE ON [Admin_GetCustomerOrCallerInfoByID] TO ExecuteOnlyRole

GO

