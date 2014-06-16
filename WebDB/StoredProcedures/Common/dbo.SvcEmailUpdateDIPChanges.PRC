if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SvcEmailUpdateDIPChanges]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[SvcEmailUpdateDIPChanges]
GO


CREATE PROCEDURE [dbo].[SvcEmailUpdateDIPChanges]
(
	@IncHistIDList varchar(8000) -- List of IncHistIDs ('|' separator)
)
AS
	SET NOCOUNT ON

	-- Update batch
	update	IncentiveHistory
	set		EmailSentDate	= getdate()
	where	IncHistID in (select distinct ID from dbo.fIDStrToTab(@IncHistIDList, '|')) 
GO


GRANT EXECUTE ON [SvcEmailUpdateDIPChanges] TO ExecuteOnlyRole
GO
