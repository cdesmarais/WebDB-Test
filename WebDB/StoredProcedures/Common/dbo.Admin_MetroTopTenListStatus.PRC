if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_MetroTopTenListStatus]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_MetroTopTenListStatus]
GO




CREATE PROCEDURE dbo.Admin_MetroTopTenListStatus
(
  @toplist bit,
  @ID int
)
AS

BEGIN TRANSACTION
UPDATE MetroArea
SET
toptenlist=@toplist
Where metroareaid=@ID

if (@@ERROR <> 0)
	goto general_error

COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION
	Return(0)
GO

GRANT EXECUTE ON [Admin_MetroTopTenListStatus] TO ExecuteOnlyRole

GO
