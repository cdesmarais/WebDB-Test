if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Daily_UsersByResos]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Daily_UsersByResos]
GO

create proc dbo.Daily_UsersByResos
@rptID int
as 

set nocount on
set transaction isolation level read uncommitted

declare rpt_cur CURSOR LOCAL READ_ONLY STATIC FOR
	select count(rs.ResID) as ReservationCount
		,coalesce(rc.LName,cc.LName) as last_name
		,coalesce(rc.FName,cc.FName) as first_name  
	from Reservation rs
	left join Customer rc
	on rs.CustID = rc.CustID  
	left join CallerCustomer cc
	on rs.CustID = cc.CustID  
	inner join restaurant r
	on rs.RID = r.RID  
	inner join Neighborhood n
	on r.NeighborhoodID = n.NeighborhoodID  
	where rc.CustID = rs.CustID   
	and rs.RStateID in  (1,2,5,6,7)   
	and n.MetroAreaID <> 1  
	group by rc.LName
	,rc.FName
	,cc.FName
	,cc.LName  
	having count(rs.ResID) > 100  
	order by reservationCount desc	

--Format report
declare @strReport as nvarchar(4000)
declare @vbnewline as nvarchar(10)
set @vbnewline = CHAR(13) + CHAR(10)

set @strReport = @vbnewline + 'Reservations by customer (100 or more resos) : ' + @vbnewline
insert into DailyReport (reportid, linenum, txt) values(@rptID, 0, @strReport)


--cursor
	Declare @ReservationCount nvarchar(255)
	Declare @last_name nvarchar(255)
	Declare @first_name nvarchar(255)
	Declare @i int

	set @i = 0
	
	OPEN rpt_cur
	FETCH NEXT FROM rpt_cur 
	INTO @ReservationCount, @last_name, @first_name

	WHILE @@FETCH_STATUS = 0
	BEGIN
		set @i = @i + 1
		set @strReport = left(@first_name,3) + ' ' + left(@last_name,3) + ': ' + @ReservationCount + @vbnewline
		insert into DailyReport (reportid, linenum, txt) values(@rptID, @i, @strReport)		

		FETCH NEXT FROM rpt_cur 
		INTO @ReservationCount, @last_name, @first_name
	END
	CLOSE rpt_cur

GO

GRANT EXECUTE ON [Daily_UsersByResos] TO ExecuteOnlyRole

GO
