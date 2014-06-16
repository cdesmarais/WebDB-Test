if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobReportResoAnomalies]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobReportResoAnomalies]
go



CREATE  PROCEDURE dbo.JobReportResoAnomalies 
(
	@EmailTo nvarchar(4000)
)

as 


-- 129936643 ResID of first reso made on 11-29-2011
select ra.*, (case when ra.ResID >= 129936643 then 1 else 0 end) NewAttribution
into #TempData
from reservationAnalysisVW ra
inner join
(
		-- Set of reservations that have been recently modified
		select distinct resid
		from ReservationLog 
		where reslogid >= (select MAX(reslogid) - 1000000 from ReservationLog )
		and UpdateDT >= Dateadd(dd,-1, CONVERT(date, GETDATE())) 
	) rl
on ra.ResID = rl.ResID
where ra.shiftdate > GETDATE() - 5
and ra.Anomalies != ''



declare @Message nvarchar(4000)
declare @Subject nvarchar(4000)

select @Subject = Isnull(@Subject ,'')  
				+ 'Reso Anomalies '
				+ convert(nvarchar(1000),Dateadd(dd,-1, CONVERT(date, GETDATE())))
				+ ' Total: '
				+ convert(nvarchar(1000),COUNT(1)) 
from #TempData
where isnull(Anomalies, '') != ''


select @Message = Isnull(@Message,'')  
		+ 'Occurrence: '+ convert(nvarchar(1000),count(1)) 
		+ ' New Attribution: '+ convert(nvarchar(1000),NewAttribution)		
		+ ' Anomaly: '+ convert(nvarchar(1000),Anomalies)
		+ char(13)+CHAR(10)
from #TempData
where isnull(Anomalies, '') != ''
group by NewAttribution, Anomalies

set @Message = @Message + char(13)+CHAR(10) + char(13)+CHAR(10) + 'Details: ' + char(13)+CHAR(10) 

select @Message = Isnull(@Message,'')  + 'Sample ResID: '+ convert(nvarchar(1000),max(t.ResID)) + char(13)+CHAR(10)
		+ ' New Attribution: '+ convert(nvarchar(1000),NewAttribution) + char(13)+CHAR(10)	
		+ ' Occurence: '+ convert(nvarchar(1000),COUNT(1)) + char(13)+CHAR(10)
		+ ' BillingType: '+ convert(nvarchar(1000),BillingType) + char(13)+CHAR(10)
		+ ' ResPoints: '+ convert(nvarchar(1000),ResPoints) + char(13)+CHAR(10)
		+ ' ZeroReason: '+ convert(nvarchar(1000),ZeroReason) + char(13)+CHAR(10)
		+ ' PointRuleApplied: '+ convert(nvarchar(1000),PointsRuleDescription) + char(13)+CHAR(10)
		+ ' Anomalies: '+ convert(nvarchar(1000),Anomalies) + char(13)+CHAR(10)
		+ ' PointsOn: '+ convert(nvarchar(1000),PointsOn) + char(13)+CHAR(10)
		+ ' IsHotelConcierge: '+ convert(nvarchar(1000),IsHotelConcierge) + char(13)+CHAR(10)
		+ ' UserAcceptsPoints: '+ convert(nvarchar(1000),UserAcceptsPoints) + char(13)+CHAR(10)
		+ ' IsZeroPointRestRef: '+ convert(nvarchar(1000),IsZeroPointRestRef) + char(13)+CHAR(10)
		+ ' HasZeroPointRestRef: '+ convert(nvarchar(1000),HasZeroPointRestRef) + char(13)+CHAR(10)		
		+ ' IsReferral: '+ convert(nvarchar(1000),IsReferral) + char(13)+CHAR(10)
		+ ' AnonConvert: '+ convert(nvarchar(1000),AnonConvert) + char(13)+CHAR(10)
		+ char(13)+CHAR(10) + char(13)+CHAR(10)
from #TempData  t
cross apply (select Top 1 * from ResPointsRuleLog r where r.ResID = t.resid order by 1 desc) rl
left join   Attribution_PointsCalculatorRule pr
on          rl.PointsRuleID = pr.PointsRuleID
group by    NewAttribution, BillingType, ResPoints, zeroreason, pr.PointsRuleDescription, 
            anomalies, pointson, IsHotelConcierge,
            UserAcceptsPoints, IsZeroPointRestRef, HasZeroPointRestRef, IsReferral,AnonConvert
order by    NewAttribution, count(1) desc

if isnull(@message,'') != ''
begin
	set @Message = 'This email contains a summary of Reservation Anomalies that may have occurred ' + convert(nvarchar(1000),Dateadd(dd,-1, CONVERT(date, GETDATE()))) + '. '
	+ char(13)+CHAR(10)+ 'This is based on any reservations that were modified ' + convert(nvarchar(1000),Dateadd(dd,-1, CONVERT(date, GETDATE()))) + '. '
	+ char(13)+CHAR(10)+ 'Known Possible Anomalies are: '
	+ char(13)+CHAR(10)+ '     [DIP Reso Should be 1000 points]'
	+ char(13)+CHAR(10)+ '     [Reso Should be 100 points]' 
	+ char(13)+CHAR(10)+ '     [RestRef should be zero points]'
	+ char(13)+CHAR(10)+ '     [Zero Points for unknown Reason]'
	+ char(13)+CHAR(10)
	+ char(13)+CHAR(10)
	+ @message


	exec master..sp_send_cdosysmail 
	 @From = 'db_reports@opentable.com'
	,@To = @EmailTo 
	,@Subject = @Subject 
	,@Body = @Message

end



GO

GRANT EXECUTE ON [JobReportResoAnomalies] TO ExecuteOnlyRole

GO
