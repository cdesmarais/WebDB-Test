

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_LogDFFDateActivity]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_LogDFFDateActivity]
GO

create procedure dbo.Admin_LogDFFDateActivity
(
	@MetroAreaID int
	,@DFFStartDTPST datetime = null
	,@DFFChangeActionDTUTC datetime = null
)
as 
	/* Insert DFF Date Activity Log for Metro */	
	insert into DFFDateActivityLog  
	(
		MetroAreaID
		,DFFStartDTPST
		,DFFChangeActionDTUTC
	)
	values
	(
		@MetroAreaID
		,@DFFStartDTPST
		,@DFFChangeActionDTUTC
	)

GO

GRANT EXECUTE ON [Admin_LogDFFDateActivity] TO ExecuteOnlyRole
GO


 