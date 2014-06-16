if exists (select * from dbo.sysobjects where ID = object_id(N'[dbo].[SFBShareFeedbackCountGet]') and OBJECTPROPERTY(ID, N'IsProcedure') = 1)
drop procedure [dbo].[SFBShareFeedbackCountGet]
go

-- Retrieves the count of emails sent for the specified reservation
create procedure dbo.SFBShareFeedbackCountGet
(
	 @ResID				int -- the reservationid
	,@CustID			int	-- user id 
	,@IsAnonymous		bit -- anonymous flag	
	,@TotalShared		int  output	-- total number of emails sent for this reso
)
as
	set nocount on
	set transaction isolation level read uncommitted 

	declare  @consumertype int
	declare  @error	int
	
	set @TotalShared = 0
	
	select	@consumertype = ISNULL(ConsumerType,-1)
	from	dbo.Customer 
	where	CustID = @CustID

		
if(@IsAnonymous = 0 AND @consumertype = 8)	
begin

	set @TotalShared = -1	

end
else
	begin
		select 	@TotalShared = SendEmailCount
		from	dbo.SFBEmailCountByReso
		where	ResID = @ResID
		
	end

	select @error = @@error
		if @error != 0 goto ErrBlock
		
		
return(0)
	
	
ErrBlock:
	return -1
	
go


grant execute on [SFBShareFeedbackCountGet] to ExecuteOnlyRole
go