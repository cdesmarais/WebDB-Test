if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Report_DailySystemHealth_Update]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Report_DailySystemHealth_Update]
GO

CREATE Procedure dbo.Report_DailySystemHealth_Update

AS
SET NOCOUNT ON

update Reservation
set RStateID = 1
where ResID in (select ResID from Reservation where ShiftDate > (getdate()-5) and RStateID = 5)

update Reservation
set RStateID = 5
where ResID in (select ResID from Reservation where datediff(d,ShiftDate,getdate()) >= 7 and RStateID = 1)

--exec Restaurant_Search_Archive

--exec User_Calculate_Total

--exec dbo.AA_Calculate_Total
GO


GRANT EXECUTE ON [Report_DailySystemHealth_Update] TO ExecuteOnlyRole

GO
