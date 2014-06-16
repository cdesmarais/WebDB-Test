if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_BlockDays_GetReasons]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_BlockDays_GetReasons]
GO


CREATE PROCEDURE dbo.Admin_BlockDays_GetReasons

As
SET NOCOUNT ON


Select	br.ReasonID,
	br.BlockReason
from	BlockedDayReason br
order by br.ReasonID

GO


GRANT EXECUTE ON [Admin_BlockDays_GetReasons] TO ExecuteOnlyRole

GO
