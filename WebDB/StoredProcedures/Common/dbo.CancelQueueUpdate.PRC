if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CancelQueueUpdate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[CancelQueueUpdate]
GO


CREATE Procedure dbo.CancelQueueUpdate
(@CancelQueueIDs varchar(8000), -- [EV: List of Int IDs]
@active bit,
@MailSent bit,
@Canceled bit
)
 AS
 SET NOCOUNT ON

update CancelQueue 
set Active = @active, 
	MailSent = @MailSent,
	Canceled = @Canceled 
where charindex( ',' + cast(CancelQueueID as nvarchar(16)) + ',' , @CancelQueueIDs) > 0
	
GO

GRANT EXECUTE ON [CancelQueueUpdate] TO ExecuteOnlyRole

GO
