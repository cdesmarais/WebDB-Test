if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_Company_GetByCallerID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_Company_GetByCallerID]
GO




CREATE PROCEDURE dbo.Concierge_Company_GetByCallerID
 (
  @CompanyID int
 )
As
SET NOCOUNT ON
SELECT Company.CompanyID AS CompanyID,
    Company.CompanyName as CompanyName,
    Company.Logo as CompanyLogo,
    Company.Address1 as Address,
    Company.City as City,
    Company.State as State,
    Company.Zip as Zipcode,
    Company.Phone as Phone,
    Company.EMail as EMail
FROM Company
WHERE (Company.CompanyID = @CompanyID)
GO

GRANT EXECUTE ON [Concierge_Company_GetByCallerID] TO ExecuteOnlyRole

GO
