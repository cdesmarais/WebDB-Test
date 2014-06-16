if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Delete_Metro]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Delete_Metro]
GO


CREATE PROCEDURE dbo.Delete_Metro
(
    @metroareaID int
)

AS

Delete from metroarealocal where metroareaID = @metroareaID
Delete from metroarea where metroareaID = @metroareaID

GO

GRANT EXECUTE ON [Delete_Metro] TO ExecuteOnlyRole

GO
