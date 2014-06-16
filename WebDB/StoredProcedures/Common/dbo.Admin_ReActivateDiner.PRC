if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_ReActivateDiner]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_ReActivateDiner]
GO

CREATE PROCEDURE dbo.Admin_ReActivateDiner
(
@CallerID int,
@DinerID int
)
 AS

update CallerCustomer 
set active = 1 
where CustID = @DinerID
and CallerID = @CallerID

GO

GRANT EXECUTE ON [Admin_ReActivateDiner] TO ExecuteOnlyRole

GO
