if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNDinerDelete]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNDinerDelete]
GO

CREATE PROCEDURE dbo.DNDinerDelete 

@DinerID int

AS
SET NOCOUNT ON
--we do not actually delete here but just set the diner to inactive
Update CallerCustomer set Active = 0  where CustID = @DinerID

Exec dbo.DNLogDeActivatedUsers @DinerID, 0, 3

GO

GRANT EXECUTE ON [DNDinerDelete] TO ExecuteOnlyRole

GO
