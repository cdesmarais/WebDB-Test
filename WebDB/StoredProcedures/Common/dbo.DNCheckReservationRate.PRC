GO



if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCheckReservationRate]') and OBJECTPROPERTY(id,N'IsProcedure') = 1)
drop procedure [dbo].[DNCheckReservationRate]
GO



CREATE PROCEDURE dbo.DNCheckReservationRate

As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

Declare @DateMade datetime
Declare @MinuteThreshold int
Declare @ResoStatus int
Declare @ResoMessage nvarchar(1000)
Declare @UpdateDate datetime
Set @UpdateDate = getdate()

if datepart(hh,getdate()) > 5 and datepart(hh,getdate()) < 21
BEGIN
	Set @MinuteThreshold = -7
END
else
BEGIN
	Set @MinuteThreshold = -12
END


select 	@DateMade = datemade 
from 	reservation 
where 	resID =	
	(select max(resid) 
	from 	reservation) 
and 	datemade > DATEADD ( mi ,@MinuteThreshold, getdate()) 



if @DateMade is null
BEGIN
	Set @ResoStatus = 2
	Set @ResoMessage = 'Reso Rate Not OK'
END
else
BEGIN
	Set @ResoStatus = 0
	Set @ResoMessage = 'Reso Rate OK Last one made ' + cast(@DateMade as nvarchar(24))
END	

	Exec dbo.DNNagiosWriteStatus @NagiosTaskID = 1, 
		@Host = '(NULL)', 
		@Status = @ResoStatus, 
		@UpdateDT = @UpdateDate,
		@Msg = @ResoMessage


GO


GRANT EXECUTE ON [DNCheckReservationRate] TO ExecuteOnlyRole

GO
