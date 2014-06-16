if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNSaveDiningFormLiterals]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNSaveDiningFormLiterals]
GO


-- Save Responses to the DiningFormResponses table
CREATE PROCEDURE dbo.DNSaveDiningFormLiterals
(
     @theResID int,
     @theComments nvarchar(1000),
     @theDateSent datetime,
     @theDiningFormID int,
     @thePoints int
)

AS

-- check if reservation object follows rules..
if exists(select resid from diningformresponses where resid=@theResID)
BEGIN
    return;
END

if (@theDateSent is null)
begin
	-- Retrieve the sent date
	select @theDateSent = createDT
	from DFBEmailSentLog
	where ResID = @theResID
end

-- insert feedback..
insert into DiningFormResponses(ResID,Comments,DateTS,SentDateTS,DiningFormID)
values (@theResID,@theComments,getdate(),@theDateSent,@theDiningFormID)

-- if points value is set to greater than zero
-- insert a points adjustment for the amount defined
declare @AdjReasonID int
declare @theCallerID int
declare @theCustID int

if @thePoints > 0
BEGIN
	-- get adjustment Id
	select @AdjReasonID=adjreasonid from pointsadjustmentreason where explanation='Dining Form Feedback'
	
	-- if @AdjReasonID is null - log an error in errolog and dont continue..
	if @AdjReasonID Is null 
	BEGIN
		-- insert into errorlog
		exec DNErrorAdd 0, 'DNSaveDiningFormLiterals', N'Unable to award dining points, unable to find points adjustment ID', 2
		return;
	END
	
	
	-- add points adjustment..
	insert into pointsadjustment(custid,callerid,adjustmentamount,adjreasonid,adjustmentdate)
	(select top 1 --** Tuned for partition
		case 
		when callerid is null then custid else null
		end as custid,
		callerid,@thePoints as AdjustmentAmount,@AdjReasonID as AdjReasonID,
		getdate() as AdjustmentDate 
		from reservation with (nolock)
		where resid=@theResID)
	
END

GO

GRANT EXECUTE ON [DNSaveDiningFormLiterals] TO ExecuteOnlyRole

GO
