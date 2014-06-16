

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AdminPromoPages_Discount_PromoReferrerOverrideAddUpdate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AdminPromoPages_Discount_PromoReferrerOverrideAddUpdate]
go

--Updates the PromoReferrer Details details

create procedure dbo.AdminPromoPages_Discount_PromoReferrerOverrideAddUpdate
 (
	@PromoReferrerId int
	,@SubmittedBy varchar(50)
	,@ChangeDate datetime
	,@ReferrerId int  
	,@PromoID int
	,@StartDate datetime
	,@EndDate datetime
 )
as
set nocount on
set transaction isolation level read uncommitted

declare @PromoRefIdForLog int = -1;

-- Check if the referrer promo details overlap any of the entries.  
if exists ( select StartDT
			from ReferrerOverrideToRestRef
			where (
				-- proposed start date falls within or exactly in existing date range
				(StartDT <= @StartDate and @StartDate< EndDT)

				or
				-- proposed end date falls within or exactly in existing date range
				(StartDT < @EndDate and @EndDate<= EndDT)

				or
				-- proposed date range overlaps an existing date range start date
				(@StartDate <= StartDT and StartDT< @EndDate)

				or
				-- proposed date range overlaps an existing date range end date
				(@StartDate < EndDT and EndDT<= @EndDate)
				)

				and
				ReferrerID= @ReferrerId

				and
				PromoID=@PromoID

				and
				-- dont look at the existing record to check for overlaps!
				PromoReferrerId!=@PromoReferrerId) Goto Dates_Overlapp
else
	begin
		begin transaction
		--Updating ReferrerOverrideToRestRef for the given PromoReferrerId
		if(@PromoReferrerId > 0)
			begin
				--update the details
				update 
					ReferrerOverrideToRestRef
				set
					StartDT = @StartDate
					,EndDT = @EndDate
				where
					PromoReferrerId = @PromoReferrerId
					
				if (@@ERROR <> 0)
					goto general_error
				
				set @PromoRefIdForLog = @PromoReferrerId;
				
			end
		else
			begin
				--Create a new row in the table.  
				insert into ReferrerOverrideToRestRef  
				(
					ReferrerID  
					,PromoID  
					,StartDT   
					,EndDT
				)  
				values   
				(  
					@ReferrerId
					,@PromoID
					,@StartDate
					,@EndDate
				) 		
		 
				set @PromoRefIdForLog = @@IDENTITY;

				if (@@ERROR <> 0) 
					goto general_error  
				
			end

		--Update the History for the Referrer Promo
		if(@PromoRefIdForLog<>-1)
		begin
			Insert into PromoReferrerChangeLog
			(
				PromoReferrerId
				,ModifyDTUTC
				,SubmittedBy
				,StartDTUTC
				,ExpDTUTC
			)
			values
			(
				@PromoRefIdForLog
				,@ChangeDate
				,@SubmittedBy
				,@StartDate
				,@EndDate
			)
			if (@@ERROR <> 0)
				goto general_error
		end
		
		commit transaction
		return(0)
end
	
Dates_Overlapp:  
	raiserror('The Dates OverLap.',17,1)
	return(1)  


general_error:
	rollback transaction
	return(0)
go

grant execute on [AdminPromoPages_Discount_PromoReferrerOverrideAddUpdate] to ExecuteOnlyRole

go