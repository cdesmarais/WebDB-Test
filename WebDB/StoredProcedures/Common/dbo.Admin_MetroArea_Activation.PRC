if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_MetroArea_Activation]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_MetroArea_Activation]
GO




CREATE PROCEDURE dbo.Admin_MetroArea_Activation
 (
  @Metro_Area_ID int,
  @Active bit
 )
As
SET NOCOUNT ON

BEGIN TRANSACTION
UPDATE MetroArea
SET active = @Active
WHERE metroareaid =  @Metro_Area_ID
if (@@ERROR <> 0)
	goto general_error

COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION
	Return(0)
GO

GRANT EXECUTE ON [Admin_MetroArea_Activation] TO ExecuteOnlyRole

GO
