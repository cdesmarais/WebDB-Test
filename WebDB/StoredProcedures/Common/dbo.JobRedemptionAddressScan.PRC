if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobRedemptionAddressScan]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobRedemptionAddressScan]
go


create  Procedure [dbo].[JobRedemptionAddressScan]
as

	/*
		Find multiple accounts redeeming to the same address.  Do a little 
		munging on the addresses for better matching.
		
		Output of this proc will be emailed to a Fraud Distribution List (FraudTeam@opentable.com)
	*/

	set transaction isolation level read uncommitted
	set nocount on
	
	
	declare	@LookBackDays int

	-- Reviews rating display setting
	select @LookBackDays = ValueInt
	from ValueLookup   
	where LKey = 'RedemptionAddScanLookback'
	and  LType = 'DATABASE'  

	
	declare @startdate datetime
	set @startdate = GETDATE() - isnull(@LookBackDays, 120)

	select 'The following accounts have multiple accounts redeeming to the same address in the last ' + cast(@LookBackDays as nvarchar) +' days.'
	select 'This is a fraud indicator.  Please review the accounts below.'

	
	-- get all GiftRedemption data based on redemptiondate
	if object_id ('tempdb..#GiftRedemption_temp') > 0   
			drop table #GiftRedemption_temp
			
	select		custid
				,callerid
				,address1
				,address2
				,left(zip,5) zip
	into		#GiftRedemption_temp
	from		GiftRedemption 
	where		redemptiondate > @startdate

	if object_id ('tempdb..#GiftRedemption_temp2') > 0   
			drop table #GiftRedemption_temp2
			
	-- get count distinct		
	select		 dbo.fMatchableAddress(address1) MatchableAddress
				,left(zip,5) zip
				,count( distinct isnull(-1*callerid, custid) ) thecount
	into		#GiftRedemption_temp2
	from		#GiftRedemption_temp 
	group by	 dbo.fMatchableAddress(address1)
				,left(zip,5)
	having		count( distinct isnull(-1*callerid, custid) ) > 2
	and			count (distinct isnull(address2,'') ) < 3
	
	
	if object_id ('tempdb..#GiftRedemption_temp3') > 0   
			drop table #GiftRedemption_temp3		

	-- join back to #GiftRedemption_temp to custid/callerid	
	select distinct  t2.thecount 
					,t.address1
					,left(t.zip,5) zip
					,t.custid
					,t.callerid
	into			#GiftRedemption_temp3
	from			#GiftRedemption_temp t
	inner join		#GiftRedemption_temp2 t2
	on				t2.MatchableAddress = dbo.fMatchableAddress(t.address1)
	and				left(t2.zip,5) = left(t.zip,5)
	

	-- Select only a few fields and truncate long fields so that they will fit as text in an email.
	select distinct  gr.thecount NumAccounts
					,u.UserWebID
					,left(u.FName,10) FName
					,left(u.LName, 20) LName
					,left(gr.address1,25) address1
					,left(gr.zip,5) zip
					,left(isnull( bl.CurrentStatus , 'active'), 15) CurrentStatus
	from			#GiftRedemption_temp3 gr
	inner join		UserWebVW u
	on				u.UserWebID = isnull(-1*gr.callerid, gr.custid)
	left join (
		select		 gr.custid userwebid 
					,ReasonDesc	CurrentStatus
		from		#GiftRedemption_temp3 gr
		inner join	customersdeactivated cd
		on			cd.custid = gr.custid
		inner join	ReasonForDeactivation rfd
		on			rfd.reasonid = cd.reasonid
		union all 
		select		-1 * gr.callerid userwebid
					, CSDesc CurrentStatus
		from		#GiftRedemption_temp3 gr
		inner join	caller c 
		on			c.callerid = gr.callerid
		inner join	callerstatus cs
		on			cs.callerstatusid = c.callerstatusid
		where		c.callerstatusid != 1
	) bl
	on bl.userwebid = u.userwebid
	order by		 gr.thecount desc
					,left(gr.address1,25) 
					,u.UserWebID

	if object_id ('tempdb..#GiftRedemption_temp') > 0   
			drop table #GiftRedemption_temp
			
	if object_id ('tempdb..#GiftRedemption_temp2') > 0   
			drop table #GiftRedemption_temp2
			
	if object_id ('tempdb..#GiftRedemption_temp3') > 0   
			drop table #GiftRedemption_temp3		
		
go

grant execute on [JobRedemptionAddressScan] TO ExecuteOnlyRole
go