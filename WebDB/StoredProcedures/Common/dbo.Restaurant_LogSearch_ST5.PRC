if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Restaurant_LogSearch_ST5]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Restaurant_LogSearch_ST5]
GO



CREATE PROCEDURE dbo.Restaurant_LogSearch_ST5
(
@CustomerID int
,@CallerID int
,@GeoID int
,@PartySize int
,@ResDateTime datetime
,@UIType int
)
AS
/*
set nocount on

declare  @rowcount      int
        	,@error         int

if @CallerID=0 (Select @CallerID=Null)
if @CustomerID=0 (Select @CustomerID=Null)

begin transaction
save transaction Restaurant_LogSearch_ST5

insert SearchLog
	(CustID
	,CallerID
	,SearchMetroareaid
	,SearchLogDate
	,SearchTypeID
	,PartySize
	,SearchRequestDate
	,UIType
	)
values
	(@CustomerID
	,@CallerID
	,@GeoID
	,getdate()
	,5
	,@PartySize
	,@ResDateTime
	,@UIType
	)

select  @rowcount = @@rowcount
           ,@error    = @@error

    if @rowcount  = 0
    or @error    != 0
      begin

        rollback transaction Restaurant_LogSearch_ST5
        commit transaction
        return -2
      end

commit transaction
*/
GO

GRANT EXECUTE ON [Restaurant_LogSearch_ST5] TO ExecuteOnlyRole

GO
