if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CancelQueueAdd]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[CancelQueueAdd]
GO


CREATE Procedure dbo.CancelQueueAdd
(@RID int,
@ConfNumber int,
@ShiftDT datetime,
@PartySize int
)
 AS
 SET NOCOUNT ON

insert into CancelQueue	(RID, ConfNumber, ShiftDT, PartySize)
	values (@RID, @ConfNumber, @ShiftDT, @PartySize)
	
GO

GRANT EXECUTE ON [CancelQueueAdd] TO ExecuteOnlyRole

GO
