if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_ZagatUpdate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_ZagatUpdate]
GO

CREATE PROCEDURE dbo.Admin_Restaurant_ZagatUpdate
(
  @RID int
  ,@Food nvarchar(255) = null
  ,@Decor nvarchar(255) = null
  ,@Service nvarchar(255) = null
  ,@Cost nvarchar(255) = 'VE'
  ,@url nvarchar(255)
)
AS

BEGIN TRANSACTION

Update ContentValue Set ContentValue= Cast(@Food as int)  Where ContentID IN (Select ContentID From Content Where RID = @RID And ContentTypeID = 1) 
Update ContentValue Set ContentValue= Cast(@Decor as int)  Where ContentID IN (Select ContentID From Content Where RID = @RID And ContentTypeID = 2) 
Update ContentValue Set ContentValue= Cast(@Service as int)  Where ContentID IN (Select ContentID From Content Where RID = @RID And ContentTypeID = 3) 
Update ContentValue Set ContentValue= @Cost Where ContentID IN (Select ContentID From Content Where RID = @RID And ContentTypeID = 4) 
Update ContentValue Set ContentValue= @url Where ContentID IN (Select ContentID From Content Where RID = @RID And ContentTypeID = 7)
if (@@ERROR <> 0)
	goto general_error

COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION
	Return(0)

GO

GRANT EXECUTE ON [Admin_Restaurant_ZagatUpdate] TO ExecuteOnlyRole

GO
