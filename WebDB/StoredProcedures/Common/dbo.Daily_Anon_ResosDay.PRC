if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Daily_Anon_ResosDay]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Daily_Anon_ResosDay]
GO

CREATE  PROCEDURE dbo.Daily_Anon_ResosDay
(
@rptID int,
@strDateOffset	int
)
AS

--Reservations made by anonymous users for the previous day

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON

declare @Anon_Reso_Yesterday int
--Get from Customer
SELECT @Anon_Reso_Yesterday = COUNT(ResID)
FROM Reservation
INNER JOIN Customer 
ON Reservation.CustID = Customer.CustID
WHERE ConsumerType = 8 
AND DATEDIFF(d,DateMade,getdate() - @strDateOffset) = 0 --This returns only yesterdays resos

declare @strReport as nvarchar(4000)
declare @vbnewline as nvarchar(10)
set @vbnewline = CHAR(13) + CHAR(10)

set @strReport = @vbnewline + 'Anonymous Resos Yesterday (GROSS) : ' + cast(@Anon_Reso_Yesterday as nvarchar(20)) + @vbnewline
	
insert into DailyReport (reportid, linenum, txt) values(@rptID, 1, @strReport)


GO

GRANT EXECUTE ON [Daily_Anon_ResosDay] TO ExecuteOnlyRole

GO
