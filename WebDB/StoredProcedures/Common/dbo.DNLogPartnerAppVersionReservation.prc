if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNLogPartnerAppVersionReservation]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNLogPartnerAppVersionReservation]
go


create procedure dbo.DNLogPartnerAppVersionReservation
( 
      	@ResID int,      	
      	@PartnerID int,
      	@Version nvarchar(20)
)
As

set nocount on
declare @error int

	insert into			PartnerAppVersionReservation 
						(ResID, PartnerID, Version)
	values				(@ResID, @PartnerID, @Version)

	if @@error != 0
		goto ErrBlock

return

ErrBlock:
	declare @ErrorMsg as nvarchar(4000)
	set @ErrorMsg = 'DNLogPartnerAppVersionReservation Failed ' +
		' @ResID: '+ cast(ISNULL(@ResID, '') as nvarchar) +
		' @PartnerID: '+ cast(ISNULL(@PartnerID, '') as nvarchar) + 
		' @Version: '+ @Version
	exec DNErrorAdd 555, 'DNLogPartnerAppVersionReservation', @ErrorMsg, 1

return 


go


grant execute on [DNLogPartnerAppVersionReservation] TO ExecuteOnlyRole

go
