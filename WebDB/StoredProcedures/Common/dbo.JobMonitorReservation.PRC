
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobMonitorReservation]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobMonitorReservation]
GO


CREATE procedure dbo.JobMonitorReservation
as
declare @alert int
declare @text nvarchar(3000)

/*This store procedure monitors website reservation activity
if there are no reservation made for the past 5 minutes from our website.  This stored procedure will be run
  within a SQL job every 5 minutes between 6am - 11PM PST*/

set @alert = 0

set transaction isolation level read uncommitted

--This checks the last reso time--
select	datemade 
from 	reservation 
where 	resID = (select max(resID) from reservation) 
and 	datemade < DATEADD ( mi ,-5, getdate()) 
 

IF (@@rowcount) >0
 BEGIN
      set @alert = 1
      set @text  =  'ALERT: No web reservation made for the past 5 minutes' + char(13)
END


IF @alert=1
BEGIN

	exec 	DNErrorAdd 10000, 'JobMonitorReservation', @text, 1

	exec	master..sp_send_cdosysmail 
		@From = 'webdev@opentable.com'
		,@To = 'webdev@opentable.com;4152238019@my2way.com;4152238099@my2way.com;it@opentable.com'
		,@Subject = 'Reservation Alert'
		,@Body = @text
END
GO


GRANT  EXECUTE  ON [dbo].[JobMonitorReservation]  TO [ExecuteOnlyRole]
GO

