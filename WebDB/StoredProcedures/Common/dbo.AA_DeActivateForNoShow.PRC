if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AA_DeActivateForNoShow]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AA_DeActivateForNoShow]
GO

CREATE PROCEDURE dbo.AA_DeActivateForNoShow
(@CallerID int
)
 AS
 SET NOCOUNT ON

declare @points int
select @points = points 
from Caller 
where CallerID = @CallerID

update Caller 
set callerstatusid = 3 --disabled for no show
where CallerID = @CallerID

Exec dbo.DNLogDeActivatedUsers @CallerID, 1, 1

GO

GRANT EXECUTE ON [AA_DeActivateForNoShow] TO ExecuteOnlyRole

GO
