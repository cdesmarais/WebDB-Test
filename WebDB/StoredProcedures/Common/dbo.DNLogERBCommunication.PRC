if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNLogERBCommunication]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNLogERBCommunication]
GO

CREATE PROCEDURE dbo.DNLogERBCommunication 
(
	@RID int,
	@Method nvarchar(50),
	@QueryString nvarchar(255),
	@RemoteAddress nvarchar(50)
)

AS

set nocount on
/*

if exists(Select RID from erbrestaurant where track = 1 and rid = @RID)
BEGIN
	
	Exec dbo.WLog_Add -1, @Method, 0,0,0,@RID,0,0,0,'unknown',@RemoteAddress,@QueryString,'',getdate

END
*/

GO


GRANT EXECUTE ON [DNLogERBCommunication] TO ExecuteOnlyRole

GO
