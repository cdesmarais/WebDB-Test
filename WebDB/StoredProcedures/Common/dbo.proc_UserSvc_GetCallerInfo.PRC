if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[proc_UserSvc_GetCallerInfo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[proc_UserSvc_GetCallerInfo]
GO

CREATE Procedure dbo.proc_UserSvc_GetCallerInfo
 (
  @UserID int
 )
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

SELECT
		gp._GlobalPersonID as GlobalPersonID,
		c.CallerID as UserID,
		c.LoginName as LoginName,
		c.Email as Email,
		c.PositionID as Type,
		c.ConsumerType as Status,
		(CASE WHEN(c.CallerStatusID > 1) then 0 ELSE 1 END) as Active, 
		c.FName as FirstName,
		c.LName as LastName,
		c.SFName as SortableFirstName,
		c.SLName as SortableLastName,
		c.Points as Points,
		c.metroareaid as MetroId,
		c.Notes as DefaultRequests,
		c.DiningFormEmailOptIn as DiningFormOptIn,
		ISNULL(c.CompanyID, -1) as CompanyID,
		p.PhoneCountryID as PhoneCountryID,
		p.Phone,
		mp.PhoneCountryID as MobilePhoneCountryID,
		mp.Phone as MobilePhone,
		m.CountryID as CountryID,
		c.ZIP as ZIP,
		c.Address1 as Address1,
		c.Address2 as Address2,
		c.State as State,
		c.City as City

FROM		Caller c
INNER JOIN	MetroArea m
ON			c.metroareaid = m.MetroAreaID
LEFT JOIN	CallerPhone p 
ON			c.CallerID = p.CallerID and p.PhoneTypeID = 6
LEFT JOIN	CallerPhone mp
ON			c.CallerID = mp.CallerID and mp.PhoneTypeID = 4
INNER JOIN	GlobalPerson gp
ON			gp.CallerID = c.CallerID
WHERE		(c.CallerID = @UserID)

GO

GRANT EXECUTE ON [proc_UserSvc_GetCallerInfo] TO ExecuteOnlyRole
GO
