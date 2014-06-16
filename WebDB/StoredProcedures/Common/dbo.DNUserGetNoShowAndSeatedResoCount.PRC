if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNUserGetNoShowAndSeatedResoCount]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNUserGetNoShowAndSeatedResoCount]
GO


CREATE PROCEDURE dbo.DNUserGetNoShowAndSeatedResoCount
(
	@nCustomerID int,
	@nIsCaller int
)
 AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

declare @dSearchStartDate datetime
SET @dSearchStartDate = ((getdate()) - 365) -- search 1 year back
if @nIsCaller = 0 -- not caller
begin
    select	sum(case when RStateID = 4 then 1 else 0 end) as NoShowCount,
			sum(case when RStateID in (2,5) then 1 else 0 end) as SeatedReservationCount,
			sum(case when RStateID in  (6,7,9,10) then 1 else 0 end) as DisputedCount
    from	Reservation r 
	where	R.CustID = @nCustomerID 
	and		R.ShiftDate > @dSearchStartDate
	

end
if @nIsCaller = 1 -- caller
begin

    select	sum(case when RStateID = 4 then 1 else 0 end) as NoShowCount,
			sum(case when RStateID in (2,5) then 1 else 0 end) as SeatedReservationCount,
			sum(case when RStateID in  (6,7,9,10) then 1 else 0 end) as DisputedCount
    from	Reservation r 
	where	R.CallerID = @nCustomerID
	and		R.ShiftDate > @dSearchStartDate

end
GO


GRANT EXECUTE ON [DNUserGetNoShowAndSeatedResoCount] TO ExecuteOnlyRole

GO
