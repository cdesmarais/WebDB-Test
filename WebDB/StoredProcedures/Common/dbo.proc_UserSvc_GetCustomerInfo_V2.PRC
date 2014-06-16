if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[proc_UserSvc_GetCustomerInfo_V2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[proc_UserSvc_GetCustomerInfo_V2]
GO

CREATE Procedure dbo.proc_UserSvc_GetCustomerInfo_V2
 (
  @UserID int
 )
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

SELECT
		gp._GlobalPersonID as GlobalPersonID,
		c.CustID as UserID,
		c.Email as LoginName,
		c.Email as Email,
		c.ConsumerType as Type,
		c.ConsumerType as Status,
		c.Active as Active,
		c.FName as FirstName,
		c.LName as LastName,
		c.SFName as SortableFirstName,
		c.SLName as SortableLastName,
		c.Points as Points,
		c.metroareaid as MetroId,
		c.Special as DefaultRequests,
		c.DiningFormEmailOptIn as DiningFormOptIn,
		-1 as CompanyID,
		p.PhoneCountryID as PhoneCountryID,
		p.Phone,
		mp.PhoneCountryID as MobilePhoneCountryID,
		mp.Phone as MobilePhone,
		m.CountryID as CountryID,
		c.ZIP as ZIP,
		c.Address1 as Address1,
		c.Address2 as Address2,
		c.State as State,
		c.City as City,
		coalesce(ctcl.ConvertDate, c.CreateDate) as CreateDate
		

FROM		Customer c
INNER JOIN	MetroArea m
ON			c.metroareaid = m.MetroAreaID
LEFT JOIN	CustomerPhone p
ON			c.CustID = p.CustID and p.PhoneTypeID = 2
LEFT JOIN	CustomerPhone mp
ON			c.CustID = mp.CustID and mp.PhoneTypeID = 4
INNER JOIN	GlobalPerson gp
ON			gp.CustID = c.CustID
LEFT JOIN 	ConsumerTypeConvertLog ctcl 
ON 	 		c.CustID = ctcl.CustID
AND 		ctcl.OriginalConsumerTypeID = 8
AND 		ctcl.ConvertDate > c.CreateDate
WHERE		(c.CustID = @UserID)

EXEC proc_UserSvc_GetCustomerSocialInfo @UserID

GO

GRANT EXECUTE ON [proc_UserSvc_GetCustomerInfo_V2] TO ExecuteOnlyRole
GO
