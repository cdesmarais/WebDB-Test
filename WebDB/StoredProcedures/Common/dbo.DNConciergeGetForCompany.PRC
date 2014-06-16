if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNConciergeGetForCompany]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNConciergeGetForCompany]
GO

CREATE PROCEDURE dbo.DNConciergeGetForCompany
(
    @CompanyID int
)
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT  c.CallerID,
        isnull(Fname,'') + ' ' + isnull(Lname, '') FullName,
        LoginName,
       	coalesce(CallerPhone.PhoneCountryID, 'US') as PhoneCountryID,
        CallerPhone.Phone,
        CallerStatusID,
		Fname,
		Lname,
		coalesce(SFname,'') as SFname,
		coalesce(SLname,'') as SLname
FROM    Caller c
LEFT OUTER JOIN		CallerPhone 
			ON		c.CallerID = CallerPhone.CallerID
WHERE   c.companyID = @CompanyID
    and c.PositionID = 2 -- Only allow concierges
order by FullName
       
GO


GRANT EXECUTE ON [DNConciergeGetForCompany] TO ExecuteOnlyRole

GO
