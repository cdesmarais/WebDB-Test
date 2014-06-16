if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Daily_AnonUser_ResoCount]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Daily_AnonUser_ResoCount]
GO

CREATE   PROCEDURE dbo.Daily_AnonUser_ResoCount
(
@rptID			int,
@strDateOffset		int
)
AS

--Totaly # of anonymous users that have made 1,2,3,4.....resos
--1st column is # of Resos
--2nd column is # of users

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON

declare rpt_cur CURSOR LOCAL READ_ONLY STATIC FOR
	SELECT Resos AS Anon_Resos,
			COUNT(CustID) AS Customer_Count
	FROM 	
	(
		SELECT Customer.CustID,COALESCE(Resos,0) AS Resos
		FROM Customer
			LEFT JOIN (	SELECT CustID, COUNT(ResID) AS Resos
					FROM Reservation
					GROUP BY CustID
					) AS tResoCount ON Customer.CustID = tResoCount.CustID
		WHERE ConsumerType = 8 AND
			DATEDIFF(d,createdate,getdate() ) >= @strDateOffSet	
	) AS AnonCustomers
	GROUP BY Resos



declare @strReport as nvarchar(4000)
declare @vbnewline as nvarchar(10)
set @vbnewline = CHAR(13) + CHAR(10)

set @strReport = @vbnewline + 'Anonymous User by Reso Counts (GROSS) : ' + @vbnewline
insert into DailyReport (reportid, linenum, txt) values(@rptID, 0, @strReport)


--cursor
	Declare @Anon_Resos nvarchar(255)
	Declare @Customer_Count nvarchar(255)
	Declare @i int

	set @i = 0
	
	OPEN rpt_cur
	FETCH NEXT FROM rpt_cur 
	INTO @Anon_Resos, @Customer_Count

	WHILE @@FETCH_STATUS = 0
	BEGIN
		set @i = @i + 1
		
		set @strReport = @Anon_Resos + ' - ' + @Customer_Count + @vbnewline
		
		insert into DailyReport (reportid, linenum, txt) values(@rptID, @i, @strReport)		

		FETCH NEXT FROM rpt_cur 
		INTO @Anon_Resos, @Customer_Count
	END
	CLOSE rpt_cur


GO

GRANT EXECUTE ON [Daily_AnonUser_ResoCount] TO ExecuteOnlyRole

GO
