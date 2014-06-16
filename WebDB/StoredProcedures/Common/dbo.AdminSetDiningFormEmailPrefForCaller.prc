
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AdminSetDiningFormEmailPrefForCaller]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AdminSetDiningFormEmailPrefForCaller]
GO

create procedure dbo.AdminSetDiningFormEmailPrefForCaller
(
	@theCallerID int
	,@theOptOutFlag bit
)
as

-- Save dining form email opt in settings for caller

update 
	caller 
set 
	DiningFormEmailOptIn=@theOptOutFlag
where 
	callerID = @theCallerID


GO

GRANT EXECUTE ON [AdminSetDiningFormEmailPrefForCaller] TO ExecuteOnlyRole

GO



