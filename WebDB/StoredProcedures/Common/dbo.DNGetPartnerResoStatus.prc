if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNGetPartnerResoStatus]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNGetPartnerResoStatus]
GO


CREATE PROCEDURE dbo.DNGetPartnerResoStatus(
			@partnerid int,
			@numdays int,
			@status nvarchar(100)
)
As

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

declare @today datetime
set @today = dbo.fGetDatePart(getdate())

declare @stattab table
(
	id int
)

--If no statuses are passed in, then just use all of the states
if len(@status) > 0
	insert into @stattab select id from fIDStrToTab(@status,',')
else
	insert into @stattab select RStateID from ReservationState
  
	select		ShiftDate + 2 + ResTime ResDateTime,
				PartySize,
				ConfNumber,
				RID,
				RStateID
	from		Reservation	r
	inner join	@stattab s
	on			r.RStateID = s.id
	where		PartnerID = @partnerid
	and			ShiftDate >= dateadd(dd, -@numdays, @today)

GO

GRANT EXECUTE ON [DNGetPartnerResoStatus] TO ExecuteOnlyRole

GO
