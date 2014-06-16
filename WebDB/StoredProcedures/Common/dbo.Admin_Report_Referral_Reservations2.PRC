if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Report_Referral_Reservations2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Report_Referral_Reservations2]
GO


CREATE PROCEDURE dbo.Admin_Report_Referral_Reservations2 --'2003-05-12 16:10:22.707'
(
@date datetime
)
 AS
--select current_timestamp
set @date = (select left(@date,11))

select * 
from   VAdminReportReferralReservations 
where  resodatemade  = @date or resodatemade = 'June 30 2003'
order by resodatemade desc
,MetroAreaID
,totalreso
,Name
GO

GRANT EXECUTE ON [Admin_Report_Referral_Reservations2] TO ExecuteOnlyRole

GO
