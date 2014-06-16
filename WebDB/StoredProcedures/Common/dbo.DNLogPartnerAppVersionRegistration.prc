if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNLogPartnerAppVersionRegistration]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNLogPartnerAppVersionRegistration]
go


create procedure dbo.DNLogPartnerAppVersionRegistration
( 
      	@CustID int,
      	@CallerID int,
      	@PartnerID int,
      	@Version nvarchar(20)
)
As

set nocount on
declare @error int

--cust and caller id cannot both be null
if @CustID is null and @CallerID is null
	goto ErrBlock

	insert into			PartnerAppVersionRegistration 
						(CustID, CallerID, PartnerID, Version)
	values				(@CustID, @CallerID, @PartnerID, @Version)

	if @@error != 0
		goto ErrBlock

return

ErrBlock:
	declare @ErrorMsg as nvarchar(4000)
	set @ErrorMsg = 'DNLogPartnerAppVersionRegistration Failed ' +
		' @CustID: '+ cast(ISNULL(@CustID,'') as nvarchar) +
		' @CallerID: '+ cast(ISNULL(@CallerID, '') as nvarchar) +
		' @PartnerID: '+ cast(ISNULL(@PartnerID, '') as nvarchar) + 
		' @Version: '+ @Version
	exec DNErrorAdd 555, 'DNLogPartnerAppVersionRegistration', @ErrorMsg, 1

return 


go


grant execute on [DNLogPartnerAppVersionRegistration] TO ExecuteOnlyRole

go
