if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Restaurant_LogSearch_ST2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Restaurant_LogSearch_ST2]
GO



CREATE Procedure dbo.Restaurant_LogSearch_ST2
(
@CustomerID int
,@CallerID int
,@GeoID int
,@NeighborhoodID nvarchar(1000)
,@PartySize int
,@ResDateTime datetime
,@FoodType nvarchar(1000)
,@PriceRange nvarchar(1000)
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
save transaction Restaurant_LogSearch_ST2

insert SearchLog
	(CustID
	,CallerID
	,SearchMetroareaid
	,neighborhoodid
	,SearchLogDate
	,SearchTypeID
	,PartySize
	,SearchRequestDate
	,FoodType
	,PriceRange
	,UIType
	)
values
	(@CustomerID
	,@CallerID
	,@GeoID
	,@NeighborhoodID
	,getdate()
	,2
	,@PartySize
	,@ResDateTime
	,@FoodType
	,@PriceRange
	,@UIType
	)

select  @rowcount = @@rowcount
           ,@error    = @@error

    if @rowcount  = 0
    or @error    != 0
      begin

        rollback transaction Restaurant_LogSearch_ST2
        commit transaction
        return -2
      end

commit transaction
*/
GO

GRANT EXECUTE ON [Restaurant_LogSearch_ST2] TO ExecuteOnlyRole

GO
