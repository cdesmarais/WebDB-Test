if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Daily_NewMembers]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Daily_NewMembers]
GO



CREATE PROCEDURE dbo.Daily_NewMembers
(
@rptID int,
@strDateOffset int,
@TotalConversions int output
)

AS
set transaction isolation level read uncommitted
SET NOCOUNT ON


declare @NewAnon as integer
declare @JITC as integer
declare @StandardReg as integer
declare @Conversions as integer


--New anon users
select @NewAnon = count(rc.CustID)
from Customer rc
where datediff(d,rc.CreateDate,getdate()-@strDateOffset)=0
and rc.ConsumerType = 8

-- Just in Time Conversions (users made anon reso then converted to real Customer account),
select @JITC = count(rc.CustID) 
from Customer rc
inner join ConsumerTypeConvertLog cl on rc.CustID = cl.CustID
where datediff(d,rc.CreateDate,getdate()-@strDateOffset)=0
and datediff(d,cl.ConvertDate,getdate()-@strDateOffset)=0
and cl.OriginalConsumerTypeID = 8

--Standard regs
select @StandardReg = count(rc.CustID)
from Customer rc
where datediff(d,rc.CreateDate,getdate()-@strDateOffset)=0
and rc.ConsumerType <> 8
and not exists (select CustID from ConsumerTypeConvertLog cl
		 where datediff(d,cl.ConvertDate,getdate()-@strDateOffset)=0
		and cl.custid = rc.custid)
		

--Post first reso conversions
select @Conversions = count(rc.CustID) from Customer rc
inner join ConsumerTypeConvertLog cl on rc.CustID = cl.CustID
where datediff(d,cl.ConvertDate,rc.createdate)<>0
and datediff(d,cl.ConvertDate,getdate()-@strDateOffset)=0
and cl.OriginalConsumerTypeID = 8

declare @strReport as nvarchar(4000)
declare @vbnewline as nvarchar(10)
set @vbnewline = CHAR(13) + CHAR(10)

set @TotalConversions  = @JITC + @Conversions + @StandardReg

set	@strReport = 	'New Members (JITC/Std. Reg/anon conv/total): '  + 
		cast(@JITC as nvarchar(20)) + '/' +  cast(@StandardReg as nvarchar(20)) + '/' + cast(@Conversions as nvarchar(20)) + '/' + cast(@TotalConversions as nvarchar(20)) + @vbnewline + 
		'New Anononymous users: ' + cast(@NewAnon as nvarchar(20)) + @vbnewline

insert into DailyReport (reportid, linenum, txt) values(@rptID, 1, @strReport)



GO

GRANT EXECUTE ON [Daily_NewMembers] TO ExecuteOnlyRole

GO
