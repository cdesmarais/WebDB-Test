if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_MediaActivate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_MediaActivate]
GO

CREATE PROCEDURE dbo.Admin_MediaActivate

(@active bit,
 @News_ID int=0,
 @Pub_ID int=0
 )

AS
SET NOCOUNT ON

BEGIN TRANSACTION
if @News_ID > 0
BEGIN
update Medianewsonline set active = @active where NewsID = @News_ID
END
if (@@ERROR <> 0)
	goto general_error
if @Pub_ID > 0
BEGIN
update MediaPublishers set active = @active where PubID = @Pub_ID
END
if (@@ERROR <> 0)
	goto general_error

COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION
	Return(0)
GO

GRANT EXECUTE ON [Admin_MediaActivate] TO ExecuteOnlyRole

GO
