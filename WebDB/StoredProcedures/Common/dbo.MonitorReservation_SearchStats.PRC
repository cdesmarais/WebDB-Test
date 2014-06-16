if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[MonitorReservation_SearchStats]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[MonitorReservation_SearchStats]
GO

create procedure dbo.MonitorReservation_SearchStats
as
declare @alert int
declare @text nvarchar(3000)

/*This store procedure monitors website reservation activity and search statistics activity
  This store procedure will send out alert email if web servers have not been looging for last 10 minutes
  OR there are no reservation made for the past 5 minutes from our website.  This stored procedure will be run
  within a SQL job every 5 minutes between 6am - 11PM PST*/

set @alert = 0

set transaction isolation level read uncommitted
--Send out an email if the search stats for a specific web server have not been logging for the last 10 minutes:
select @text = isnull(@text, ' ') + hostname + ' ' + cast(max(datets)as nvarchar(24))+ char(13)
from SearchStatsVW
where searchstatsid > (select max(searchstatsid) - 50000 from SearchStatsVW)
group by hostname having max(datets)< DATEADD ( mi ,-10, getdate() ) 


IF (@@rowcount) >0
BEGIN
      set @alert=1
      set  @text = 'ALERT: ' +@text+ ' OTWebServer did not log search stats for the past 10 minutes!' + char(13)
END


--This check the last reso time--
select datemade from reservation where resID =(select max(resID) from reservation) 
and datemade < DATEADD ( mi ,-5, getdate()) 
 

IF (@@rowcount) >0
BEGIN
      set @alert=1
      set  @text = @text + '   ALERT: No web reservation made for the past 5 minutes' + char(13)
END

 

 
IF @alert=1
BEGIN

exec DNErrorAdd 10000, 'MonitorReservation_SearchStats', @text, 1

exec master..sp_send_cdosysmail 
@From = 'webdev@opentable.com'
,@To = 'webdev@opentable.com;4152238019@my2way.com;4152238099@my2way.com;it@opentable.com'
,@Subject = 'Reservation/SearchStats Alert'
,@Body = @text

END

GO

GRANT EXECUTE ON [MonitorReservation_SearchStats] TO ExecuteOnlyRole

GO
