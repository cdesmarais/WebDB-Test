if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Extranet_Incentive_DRCovers]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Extranet_Incentive_DRCovers]
GO

CREATE  PROCEDURE dbo.Extranet_Incentive_DRCovers
(
@RestID int,
@startdate datetime,
@enddate datetime
)
 
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

Select Sum(Case when(Coalesce(seatedSize,0) < 1) Then Partysize Else seatedSize End) as DRCovers 
from Reservation
where Reservation.RID = @RestID 
and Reservation.ShiftDate > @startdate 
and Reservation.ShiftDate < @enddate 
and Reservation.incentiveid > 0 
and Reservation.RStateID in (1,2,5,6,7)

GO

GRANT EXECUTE ON [Extranet_Incentive_DRCovers] TO ExecuteOnlyRole

GO
