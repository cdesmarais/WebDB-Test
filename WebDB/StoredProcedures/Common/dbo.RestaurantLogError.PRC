if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RestaurantLogError]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[RestaurantLogError]
GO

CREATE Procedure dbo.RestaurantLogError
 (               
        @RID int
,	@Message nvarchar(255) = ''
,	@ErrCode nvarchar(50) = ''
)
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 

Insert into RestaurantErrorLog (RID,ErrorCode,ErrorMessage)
VALUES
(@RID,@ErrCode,@Message)

GO


GRANT EXECUTE ON [RestaurantLogError] TO ExecuteOnlyRole

GO
