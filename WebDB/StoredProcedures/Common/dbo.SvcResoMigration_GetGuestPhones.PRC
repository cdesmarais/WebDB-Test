if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SvcResoMigration_GetGuestPhones]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[SvcResoMigration_GetGuestPhones]
GO

CREATE Procedure dbo.SvcResoMigration_GetGuestPhones
(
    @CustID   int
)
As
SET NOCOUNT ON
set transaction isolation level read uncommitted

select	 ct.CountryCode + cp.Phone		PhoneNumber
		,pt.PhoneType						Label
		,cp.IsPrimary						IsPrimary
from CustomerPhone cp

inner join PhoneType pt
on pt.PhoneTypeID = cp.PhoneTypeID

inner join Country ct
on ct.CountryID = cp.PhoneCountryID

where CustID = @CustID
order by IsPrimary desc

GO

GRANT EXECUTE ON [SvcResoMigration_GetGuestPhones] TO ExecuteOnlyRole

GO
