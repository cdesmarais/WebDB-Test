if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Restaurant_HeartBeat]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Restaurant_HeartBeat]
GO


CREATE PROCEDURE dbo.Restaurant_HeartBeat
(               
    @RID int
,	@Method nvarchar(50) = ''
)
AS
/*
SET NOCOUNT ON

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 

update dbo.lastTimeContacted
set ltc = getdate() 
where lastTimeContacted.RID = @RID
option (keepfixed plan)

-- Reset the status if it was updating it's book
update restaurant 
set restStateID = 1 
where RID = @RID 
and restStateID = 13

-- status tracking
declare @bStateUpdated bit
set @bStateUpdated = @@rowcount

if (@bStateUpdated = 1)
BEGIN
	-- track change 
	EXEC dbo.Admin_AuditRestStatusChg @RID,'Website4.0(Auto)',1
END

	*/
/* CK - Commented out for performance
insert into erbConnectionLog (RID,Method)
Select @RID as RID, @Method as Method 
from erbRestaurant er
where er.RID = @RID 
and er.Track = 1
*/

GO



GRANT EXECUTE ON [Restaurant_HeartBeat] TO ExecuteOnlyRole

GO
