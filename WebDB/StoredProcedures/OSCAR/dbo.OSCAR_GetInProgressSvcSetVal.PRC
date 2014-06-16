if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OSCAR_GetInProgressSvcSetVal]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[OSCAR_GetInProgressSvcSetVal]
GO

CREATE PROCEDURE dbo.OSCAR_GetInProgressSvcSetVal  
(  
	@RID  int    
	,@Key nvarchar(500)    
)  
AS  
  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
 
	select
		top 1 *
	from
		SetValQueue
	where
		RID = @RID and
		[Key] = @Key and
		SendSuccessDT is null
	order by
		QueueID
	desc	
		

go

		
GRANT EXECUTE ON [OSCAR_GetInProgressSvcSetVal] TO ExecuteOnlyRole

GO
