if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Incentive_GetSuppressedDays]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Incentive_GetSuppressedDays]
GO

/****** Object:  StoredProcedure [dbo].[GetSuppressedDays]    Script Date: 11/19/2006 22:03:35 ******/

CREATE procedure [dbo].[Incentive_GetSuppressedDays]
(
	@RID int
)
AS

SELECT ISD.IncSuppressID, ISD.RID, ISD.SuppressedDate, DATENAME(dw, ISD.SuppressedDate) AS DayofWeek, IH.ChangedBy, ISD.Active, ISD.ActiveIncHistID, ISD.DeActiveIncHistID
from IncentiveSuppressDay ISD
INNER JOIN INCENTIVEHISTORY IH on ISD.ActiveIncHistID = IH.IncHistID
Where ISD.RID = @RID
AND ISD.Active = 1
Order by SuppressedDate desc

GO

GRANT EXECUTE ON [Incentive_GetSuppressedDays] TO ExecuteOnlyRole

GO
