if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AA_DinerDelete]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AA_DinerDelete]
GO




CREATE PROCEDURE dbo.AA_DinerDelete 

@DinerID int

AS
SET NOCOUNT ON
--we do not actually delete here but just set the diner to inactive
Update CallerCustomer set Active = 0  where CustID = @DinerID

Exec dbo.DNLogDeActivatedUsers @DinerID, 0, 3



GO

GRANT EXECUTE ON [AA_DinerDelete] TO ExecuteOnlyRole

GO
