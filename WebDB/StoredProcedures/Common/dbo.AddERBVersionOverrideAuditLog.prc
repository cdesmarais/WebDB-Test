

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AddERBVersionOverrideAuditLog]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AddERBVersionOverrideAuditLog]
GO

create procedure dbo.AddERBVersionOverrideAuditLog 
(
	@RID int
	,@PrevERBVersion varchar(50) 
	,@ERBVersion varchar(50) 
	,@CHARMUserName nvarchar(100)
)
as 

	/* This SP is used to Insert into ERBVersionOverrideAuditLog */	
	insert into ERBVersionOverrideAuditLog  
	(
		RID
		,PrevERBVersion
		,ERBVersion
		,CHARMUserName
		,ERBVersionChangeDTUTC 
	)
	values
	(
		@RID
		,@PrevERBVersion
		,@ERBVersion
		,@CHARMUserName
		,getutcdate()
	)

GO

GRANT EXECUTE ON [AddERBVersionOverrideAuditLog] TO ExecuteOnlyRole
GO


 