if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TopTenListInstanceInsert]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[TopTenListInstanceInsert]
GO
/*	
	Procedure to insert a Top Ten list instance
	and return the instance id in the output param 
*/
CREATE PROCEDURE dbo.TopTenListInstanceInsert

( @TopTenListID			int
 ,@TopTenImportJobID	int
 ,@IsActive				bit
 ,@ReferallID			int )

AS
SET NOCOUNT ON
					
------------------------------------------------------------------------------
-- This insert is part of a TopTen Job
------------------------------------------------------------------------------

INSERT INTO [dbo].[TopTenListInstance]
           ([TopTenListID]
           ,[TopTenImportJobID]
           ,[IsActive]
           ,[ReferallID])
     VALUES
           (@TopTenListID
           ,@TopTenImportJobID
           ,@IsActive
           ,@ReferallID)

------------------------------------------------------------------------------
-- This identity is used to reference ranked restaurants in a top ten list
------------------------------------------------------------------------------           
SELECT scope_identity()
           
GO


GRANT EXECUTE ON [dbo].[TopTenListInstanceInsert] TO ExecuteOnlyRole

GO

