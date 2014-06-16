



/*Procedure to Create the Conceirge Report*/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobReportConciergeCompaniesAccountsCovers]') and objectproperty(id, N'IsProcedure') = 1)
	drop procedure [dbo].[JobReportConciergeCompaniesAccountsCovers]
go

create Procedure dbo.JobReportConciergeCompaniesAccountsCovers AS

	set transaction isolation level read uncommitted

	select			
					ca.fname  + ' ' + ca.lname 'Concierge Name'
					,ca.Email 'Concierge Email'
					,m.MetroAreaName 'Concierge Default Search City'
					,co.CompanyName 'Hotel Name'
					,co.CompanyID  'Concierge Company ID'
					,co.Phone	'Hotel Phone'
					,ca.CreateDate 'Created Date'
					,ca.callerid 'Concierge ID'   
					,sum( case when convert(char(6), r.shiftdate, 112) = convert(char(6), dateadd(month, -2, getdate()), 112) 
								then r.ResPoints 
								else 0
								end ) 'Previous Month Points'
					,sum( case when convert(char(6), r.shiftdate, 112) = convert(char(6), dateadd(month, -2, getdate()), 112) and r.BillingType = 'OTReso' 
								then r.BillableSize 
								else 0 
								end ) 'Previous Month Standard Covers'  
					,sum( case when convert(char(6), r.shiftdate, 112) = convert(char(6), dateadd(month, -2, getdate()), 112) and r.BillingType = 'DIPReso' 
								then r.BillableSize 
								else 0 
								end ) 'Previous Month POP Covers'  
					,sum( case when convert(char(6), r.shiftdate, 112) = convert(char(6), dateadd(month, -1, getdate()), 112) 
								then r.ResPoints 
								else 0 
								end ) 'Last Month Points'  
					,sum( case when convert(char(6), r.shiftdate, 112) = convert(char(6), dateadd(month, -1, getdate()), 112) and r.BillingType = 'OTReso' 
								then r.BillableSize 
								else 0 
								end ) 'Last Month Standard Covers'  
					,sum( case when convert(char(6), r.shiftdate, 112) = convert(char(6), dateadd(month, -1, getdate()), 112) and r.BillingType = 'DIPReso' 
								then r.BillableSize 
								else 0 
								end ) 'Last Month POP Covers'  
					,sum( case when convert(char(6), r.shiftdate, 112) = convert(char(6), getdate(), 112) 
								then r.ResPoints 
								else 0 
								end ) 'Current Month Points'  
					,sum( case when convert(char(6), r.shiftdate, 112) = convert(char(6), getdate(), 112) and r.BillingType = 'OTReso' 
								then r.BillableSize 
								else 0 
								end ) 'Current Month Standard Covers'  
					,sum( case when convert(char(6), r.shiftdate, 112) = convert(char(6), getdate(), 112) and r.BillingType = 'DIPReso' 
								then r.BillableSize 
								else 0 
								end ) 'Current Month POP Covers'
					,coalesce(ccl.CreatedBy,'NA') 'Concierge Created By'  /*TT44757 : This Column is added to track the user information for the Conceirge : "CreatedBy" user */
	from			
					company  co 
	inner join		caller  ca  
	on				co.companyID = ca.companyID 
	inner join		MetroAreaVW m 
	on				m.MetroAreaID = ca.MetroAreaID 
	left outer join	reservationvw r 
	on				r.callerid = ca.callerid 
	left outer join	ConciergeChangeLog ccl	/*TT44757 : This Table is added to track the user information for the Conceirge : "CreatedBy" user */
	on				ca.CallerID = ccl.CallerID
	where
					r.shiftdate >= dateadd(month, -3, getdate()) and 	-- going back 3 months to improve performance
					r.RStateID IN (1, 2, 5, 6, 7) and					-- billable states
					co.companyTypeID = 1 and
					ca.PositionID = 2 and
					ca.CallerStatusID = 1
	group by
					ca.fname  + ' ' + ca.lname
					,ca.Email
					,m.MetroAreaName
					,co.CompanyName
					,co.CompanyID
					,co.Phone
					,ca.CreateDate
					,ca.callerid
					,ccl.CreatedBy

go

grant execute on [JobReportConciergeCompaniesAccountsCovers] to ExecuteOnlyRole
grant execute on [JobReportConciergeCompaniesAccountsCovers] to DTR_User

go



