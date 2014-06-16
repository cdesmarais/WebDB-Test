if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AA_DeActivateDinerForNoShow]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AA_DeActivateDinerForNoShow]
GO






CREATE PROCEDURE dbo.AA_DeActivateDinerForNoShow
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

GRANT EXECUTE ON [AA_DeActivateDinerForNoShow] TO ExecuteOnlyRole

GO
