if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OSCAR_SvcSetValEnqueue]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[OSCAR_SvcSetValEnqueue]
GO

CREATE PROCEDURE dbo.OSCAR_SvcSetValEnqueue  
(  
	@RID  int    
	,@Key nvarchar(500)    
	,@Val nvarchar(500)    
	,@Reason nvarchar(500)  
)  
AS  
  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
 
declare @SFDCID nvarchar(500)
declare @DBRID nvarchar(500)

	select 
		@DBRID = RID, 
		@SFDCID = RestaurantSFDCID 
	from 
		Restaurant
	where 
		RID = @RID
 
	if @DBRID is null
	begin
		raiserror('1295', 15, 0)
		return
	end
 
	if @SFDCID is null
	begin
		raiserror('1320', 15, 0)
		return
	end
 
	exec SvcSetValEnqueue @RID, @Key, @Val, @Reason  
     
	select  
		top 1 QueueID  
	from  
		SetValQueue  
	where  
		RID = @RID and  
		SendSuccessDT is null  
	order by  
		QueueID desc  
  
go

GRANT EXECUTE ON [OSCAR_SvcSetValEnqueue] TO ExecuteOnlyRole

GO