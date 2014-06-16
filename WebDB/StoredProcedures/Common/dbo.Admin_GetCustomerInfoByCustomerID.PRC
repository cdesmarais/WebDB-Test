
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_GetCustomerInfoByCustomerID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[Admin_GetCustomerInfoByCustomerID]
GO


create procedure dbo.Admin_GetCustomerInfoByCustomerID

	@CustomerID int,
	@IsCaller bit

as
set nocount on
set transaction isolation level read uncommitted

--This sproc checks both Customer and Caller for CallCusNextID info

	if @IsCaller = 0
	begin
		select 
			Customer.CustID as customer_id
			,Customer.FName as first_name
			,Customer.LName as last_name
			,Customer.sfname as first_name_phonetic
			,Customer.slname as last_name_phonetic
			,Customer.email as email
			,'' as password
			,'' as password_question
			,'' as password_answer
			,Customer.address1 as address
			,Customer.address2 as address2
			,Customer.city as city
			,Customer.state as state
			,Customer.zip as zip
			,d.phone as phone
			,d.PhoneTypeID as phone_id
			,m.phone as mobilephone
			,m.PhoneTypeID as mobile_phone_id
			,Customer.CreateDate as create_date
			,IsCaller = 0
			,Customer.points as points
			,Customer.Active
			,Customer.email as login
			,ma.MetroAreaName as MetroName
			,ConsumerType as Consumer_Type
			,'' as Caller_First_Name
			,'' as Caller_Last_Name
			,'' as Caller_Email
			,ma.metroareaid as Metro_Area_ID
			,0 as Company_ID
			,PartnerID as Partner_ID
			,SendAnnouncements
			,DiningFormEmailOptIn
			,'' as CompanyName
			,ConvertDate as Convert_Date
			,LoginFailedCount as PwdAttempt
			,cd.ReasonID as DeactivatedReasonID
			,fs.FraudStatusID
			,fs.FraudStatusDescription
			,coalesce(fb.CustID, 0) as fbID
			,cn.Notes as Notes
			,uoi.Spotlight
			,uoi.Insider
			,uoi.DinersChoice
			,uoi.NewHot
			,uoi.RestaurantWeek
			,uoi.Promotional
			,uoi.Product
		from		
			Customer
		inner join
			MetroAreaAVW ma
		on	Customer.metroareaid = ma.metroareaid 
		and ma.PrimaryLanguageID = ma.LanguageID

		left join 
			CustomerPhone d
		on	d.CustID = Customer.CustID 
		and d.PhoneTypeID = 2

		left join 
			CustomerPhone m
		on	m.CustID = Customer.CustID 
		and m.PhoneTypeID = 4

		left join
			ConsumerTypeConvertLog 
		on	Customer.CustID = ConsumerTypeConvertLog.CustID 
		and	OriginalConsumerTypeID = 8

		left join
			FailedLoginCounter 
		on	Customer.CustID = FailedLoginCounter.UserID 
		and	isAdmin = 0

		left join	
			CustomersDeactivated cd
		on	cd.CustID = Customer.CustID 
		and cd.ReasonID = 8 -- only interested in blacklist deactivations

		left join	
			SuspectedFraudulentAccounts sfa
		on	Customer.CustID = sfa.CustID

		left join	
			FraudStatus fs
		on	sfa.FraudStatusID = fs.FraudStatusID

		left outer join 
			SocialCustomer fb
		on	fb.CustID = Customer.CustID and fb.SocialTypeID = 1
		left outer join
			CustomerNotes cn
		on	Customer.CustID = cn.CustomerID		
	
		left outer join
			UserOptIn uoi
		on Customer.CustID = uoi.CustID
	
		where		
			Customer.CustID = @CustomerID

	end
	else
	begin

		select 
			c.CallerID as Customer_ID
			,c.FName as first_name
			,c.LName as last_name
			,c.sfname as first_name_phonetic
			,c.slname as last_name_phonetic
			,c.email as email
			,'' as password
			,'' as password_question
			,'' as password_answer
			,c.Address1 as address
			,c.address2
			,c.city
			,c.state
			,c.zip
			,d.phone as phone
			,d.PhoneTypeID as phone_id
			,m.phone as mobilephone
			,m.PhoneTypeID as mobile_phone_id
			,c.createdate as create_date
			,IsCaller = 1
			,c.points as points
			,CallerStatusID as Active
			,c.LoginName as login
			,ma.MetroAreaName as MetroName
			,ConsumerType as Consumer_Type
			,'' as Caller_First_Name
			,'' as Caller_Last_Name
			,'' as Caller_Email
			,ma.metroareaid as Metro_Area_ID
			,coalesce(c.CompanyID,0) as Company_ID
			,PartnerID as Partner_ID
			,SendAnnouncements
			,DiningFormEmailOptIn
			,Company.CompanyName as CompanyName
			,ConvertDate as Convert_Date
			,LoginFailedCount as PwdAttempt
			,cd.ReasonID as DeactivatedReasonID
			,fs.FraudStatusID
			,fs.FraudStatusDescription
			,coalesce(fb.CallerID, 0) as fbID
			,c.CompanyMetroID as Company_Metro_ID
			,ccl.CreatedBy
			,c.CreateDate
			,mav.MetroAreaName as CompanyMetroName
			,d.PhoneCountryID
			,cn.Notes as Notes
			,uoi.Spotlight
			,uoi.Insider
			,uoi.DinersChoice
			,uoi.NewHot
			,uoi.RestaurantWeek
			,uoi.Promotional
			,uoi.Product
		from		
			Caller c
		inner join 
			MetroAreaAVW ma
		on	c.metroareaid = ma.metroareaid
		and	ma.PrimaryLanguageID = ma.LanguageID

		left join 
			CallerPhone d 
		on	d.CallerID = c.CallerID 
		and d.PhoneTypeID = 6

		left join 
			CallerPhone m
		on	m.CallerID = c.CallerID 
		and m.PhoneTypeID = 4

		left join	
			Company 
		on	c.CompanyID = Company.CompanyID

		left join	
			ConsumerTypeConvertLog 
		on	c.CallerID = ConsumerTypeConvertLog.CallerID 
		and	OriginalConsumerTypeID = 8

		left join	
			FailedLoginCounter 
		on	c.CallerID = FailedLoginCounter.UserID 
		and	isAdmin = 1

		left join	
			CustomersDeactivated cd
		on	cd.CallerID = c.CallerID AND cd.ReasonID = 8 -- only interested in blacklist deactivations

		left join	
			SuspectedFraudulentAccounts sfa
		on	c.CallerID = sfa.CallerID

		left join	
			FraudStatus fs
		on	sfa.FraudStatusID = fs.FraudStatusID

		left outer join 
			SocialCaller fb
		on	fb.CallerID = c.CallerID and fb.SocialTypeID = 1
		
		left outer join
			ConciergeChangeLog ccl
		on	c.CallerID = ccl.CallerID
		
		left outer join
			MetroAreaAVW mav
		on c.CompanyMetroID = mav.metroareaid
		and	mav.PrimaryLanguageID = mav.LanguageID
		
		left outer join 
			CallerNotes cn
		on  c.CallerID = cn.CallerID
		
		left outer join
			UserOptIn uoi
		on c.CallerID = uoi.CallerID
		
		where		
			c.CallerID = @CustomerID

	end

	return 0

go

grant execute on [Admin_GetCustomerInfoByCustomerID] to ExecuteOnlyRole

go



