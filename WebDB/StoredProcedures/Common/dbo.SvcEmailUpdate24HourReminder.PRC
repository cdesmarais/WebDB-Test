if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SvcEmailUpdate24HourReminder]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[SvcEmailUpdate24HourReminder]
GO


CREATE PROCEDURE dbo.SvcEmailUpdate24HourReminder
(
	@ResIDList varchar(8000) -- List of ResIDs ('|' separator)
)
AS
	SET NOCOUNT ON

	--Batch insert
	insert into ReminderSentLog (ResID)
		select		distinct ID 
		from		dbo.fIDStrToTab(@ResIDList, '|') i
		left join	ReminderSentLog r
		on			r.ResID = i.ID
		where		r.resID is null -- Do not include ID that have already been marked as sent
GO


GRANT EXECUTE ON [SvcEmailUpdate24HourReminder] TO ExecuteOnlyRole
GO
