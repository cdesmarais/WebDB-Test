if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_DeActivateDinerForNoShow]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_DeActivateDinerForNoShow]
GO




CREATE PROCEDURE dbo.Admin_DeActivateDinerForNoShow
(
@CallerID int,
@DinerID int
)
 AS

update CallerCustomer set active = 0 where
CustID = @DinerID
and CallerID = @CallerID

Exec dbo.DNLogDeActivatedUsers @DinerID, 0, 1

GO

GRANT EXECUTE ON [Admin_DeActivateDinerForNoShow] TO ExecuteOnlyRole

GO
