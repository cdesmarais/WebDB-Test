GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ComputePoints]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ComputePoints]
GO




create procedure dbo.ComputePoints  @custid int, @CallerID int
as
begin

declare @curDate datetime
set @curDate = getdate()
--******
--** Points Redmeption
--******
declare Points_Redeem CURSOR LOCAL READ_ONLY STATIC FOR
	select 
			datepart(yy, RedemptionDate),
			datepart(q, RedemptionDate),
		   min(RedemptionDate) DateRedeem,
		   sum(PointsRedeemed) Points,
		   'Redeem' type
	from GiftRedemption
	where ((@custid is not null and custid = @custid) or
			(@callerId is not null and callerId = @callerId) )
	group by custID,
			datepart(yy, RedemptionDate),
			datepart(q, RedemptionDate)
	order by DateRedeem

--******
--** Points Accumulated
--******
declare Points_Accum CURSOR LOCAL READ_ONLY STATIC FOR
	select 
		datepart(yy, DateAccum) yearDT,
		datepart(q, DateAccum) quarterDT,
		   DateAccum,
		   Points,
		   type
	from (
		select custID, 
			   RedeemDate DateAccum,
			   Points,
			   case when PromoID = 1 then 'Reg' else 'Promo' end type
		from PromoUse p 
		where ((@custid is not null and custid = @custid) or
			(@callerId is not null and callerId = @callerId) )
	union
		select custID, 
			   AdjustmentDate DateAccum,
			   AdjustmentAmount Points,
			  'Adj' type
		from PointsAdjustment p 
		where ((@custid is not null and custid = @custid) or
			(@callerId is not null and callerId = @callerId) )
	union
		select custID, 
			   ShiftDate DateAccum,
			   ResPoints Points,
			   (case when ResPoints = 1000 then 'DIP'
				else 'Res' end) type
		from Reservation r 
		where ((@custid is not null and custid = @custid) or
			(@callerId is not null and callerId = @callerId) )
		and RStateID in (1,2,5,6,7)
	) t
	where DateAccum < @curDate
	order by DateAccum

--*****************
--** Cursor through points
--** Order by:
--**	User
--**	Quarter
--**	Redeem Points
--**	Date
--*****************

	--*****************
	-- Open Redemption Cursor
	--*****************
	declare @RedeemStatus int
	declare @Cur_R_YearDT int
	declare @Cur_R_QuarterDT int
	declare @Cur_R_DT datetime
	declare @Cur_R_Points int
	declare @Cur_R_Type nvarchar(20)
	OPEN Points_Redeem

	FETCH NEXT FROM Points_Redeem 
	INTO @Cur_R_YearDT, @Cur_R_QuarterDT, @Cur_R_DT, @Cur_R_Points, @Cur_R_Type
	set @RedeemStatus = @@FETCH_STATUS 

	--*************************
	-- Open Accumulation Cursor
	--*************************
	declare @AccumStatus int
	declare @Cur_A_YearDT int
	declare @Cur_A_QuarterDT int
	declare @Cur_A_DT datetime
	declare @Cur_A_Points int
	declare @Cur_A_Type nvarchar(20)
	OPEN Points_Accum

	FETCH NEXT FROM Points_Accum 
	INTO @Cur_A_YearDT, @Cur_A_QuarterDT, @Cur_A_DT, @Cur_A_Points, @Cur_A_Type
	set @AccumStatus = @@FETCH_STATUS 

	declare @QA_Reg int, @QA_Res1 int, @QA_ResT int, @QA_DIP1 int, @QA_DIPT int, @QA_Adj int, @QA_Promo as int
	declare @QR_Reg int, @QR_Res1 int, @QR_ResT int, @QR_DIP1 int, @QR_DIPT int, @QR_Adj int, @QR_Promo as int

	select @QA_Reg = 0, @QA_Res1 = 0, @QA_ResT = 0, @QA_DIP1 = 0, @QA_DIPT = 0, @QA_Adj = 0, @QA_Promo = 0
	select @QR_Reg = 0, @QR_Res1 = 0, @QR_ResT = 0, @QR_DIP1 = 0, @QR_DIPT = 0, @QR_Adj = 0, @QR_Promo = 0

	declare @FirstRes int, @FirstDip as int
	set @FirstRes = 0 
	set @FirstDip = 0 
	declare @R_FirstRes int, @R_FirstDip as int
	set @R_FirstRes = 0 
	set @R_FirstDip = 0 
	
	declare @Last_A_QuarterDT int, @Last_A_YearDT int
	
	while (@AccumStatus = 0 or @RedeemStatus = 0)
	begin
		set @Last_A_YearDT = @Cur_A_YearDT 
		set @Last_A_QuarterDT = @Cur_A_QuarterDT

		--Accumulate Points
		if (@Cur_A_Type = 'Reg') 
			set @QA_Reg = @QA_Reg + @Cur_A_Points
		
		if (@Cur_A_Type = 'Promo') 
			set @QA_Promo = @QA_Promo + @Cur_A_Points

		if (@Cur_A_Type = 'Adj') 
			set @QA_Adj = @QA_Adj + @Cur_A_Points

		if  ((@Cur_A_Type = 'Res') and (@FirstRes = 1))
			set @QA_ResT = @QA_ResT + @Cur_A_Points

		if  ((@Cur_A_Type = 'Res') and (@FirstRes = 0))
		begin
			set @QA_Res1 = @QA_Res1 + @Cur_A_Points
			set @FirstRes = 1
		end

		if  ((@Cur_A_Type = 'DIP') and (@FirstDip = 1))
			set @QA_DIPT = @QA_DIPT + @Cur_A_Points

		if  ((@Cur_A_Type = 'DIP') and (@FirstDip = 0))
		begin
			set @QA_DIP1 = @QA_DIP1 + @Cur_A_Points
			set @FirstDip = 1
		end

		--If Redeeem Points exists, Redeem then
		--If Out of Points Fetch Next
		if (@RedeemStatus = 0)
		begin
			declare @CarryOver int
			set @CarryOver = 0;
			if (@Cur_A_Points > @Cur_R_Points)
			begin
				-- Compute carry over
				set @CarryOver = @Cur_A_Points - @Cur_R_Points
				set @Cur_A_Points = @Cur_R_Points
			end
			 
			if (@Cur_A_Type = 'Reg') 
				set @QR_Reg = @QR_Reg + @Cur_A_Points
			
			if (@Cur_A_Type = 'Promo') 
				set @QR_Promo = @QR_Promo + @Cur_A_Points

			if (@Cur_A_Type = 'Adj') 
				set @QR_Adj = @QR_Adj + @Cur_A_Points

			if  ((@Cur_A_Type = 'Res') and (@R_FirstRes = 1))
				set @QR_ResT = @QR_ResT + @Cur_A_Points

			if  ((@Cur_A_Type = 'Res') and (@R_FirstRes = 0))
			begin
				set @QR_Res1 = @QR_Res1 + @Cur_A_Points
				set @R_FirstRes = 1
			end


			if  ((@Cur_A_Type = 'DIP') and (@R_FirstDip = 1))
				set @QR_DIPT = @QR_DIPT + @Cur_A_Points

			if  ((@Cur_A_Type = 'DIP') and (@R_FirstDip = 0))
			begin
				set @QR_DIP1 = @QR_DIP1 + @Cur_A_Points
				set @R_FirstDip = 1
			end

			set @Cur_R_Points = @Cur_R_Points - @Cur_A_Points

			if (@Cur_R_Points <= 0)
			begin
				--*** Write out Redmption Record
				insert into ReportFinanceCustPoints values(
					@CustID, @CallerID, 'Redeem', @Cur_R_YearDT, @Cur_R_QuarterDT, 
					@QR_Reg , @QR_Res1 , @QR_ResT , @QR_DIP1 , @QR_DIPT , @QR_Adj , @QR_Promo 
				)
				select @QR_Reg = 0, @QR_Res1 = 0, @QR_ResT = 0, @QR_DIP1 = 0, @QR_DIPT = 0, @QR_Adj = 0, @QR_Promo = 0

				--*** Fetch Next Record
				FETCH NEXT FROM Points_Redeem 
				INTO @Cur_R_YearDT, @Cur_R_QuarterDT, @Cur_R_DT, @Cur_R_Points, @Cur_R_Type
				set @RedeemStatus = @@FETCH_STATUS 

				--**********************
				--** Carry Over
				--**********************
				if (@CarryOver > 0)
				begin
					set @Cur_R_Points = @Cur_R_Points - @CarryOver

					if (@Cur_A_Type = 'Reg') 
						set @QR_Reg = @QR_Reg + @CarryOver
					
					if (@Cur_A_Type = 'Promo') 
						set @QR_Promo = @QR_Promo + @CarryOver

					if (@Cur_A_Type = 'Adj') 
						set @QR_Adj = @QR_Adj + @CarryOver

					if  ((@Cur_A_Type = 'Res') and (@R_FirstRes = 1))
						set @QR_ResT = @QR_ResT + @CarryOver

					if  ((@Cur_A_Type = 'Res') and (@R_FirstRes = 0))
					begin
						set @QR_Res1 = @QR_Res1 + @CarryOver
						set @R_FirstRes = 1
					end


					if  ((@Cur_A_Type = 'DIP') and (@R_FirstDip = 1))
						set @QR_DIPT = @QR_DIPT + @CarryOver

					if  ((@Cur_A_Type = 'DIP') and (@R_FirstDip = 0))
					begin
						set @QR_DIP1 = @QR_DIP1 + @CarryOver
						set @R_FirstDip = 1
					end

				end
			end

		end -- End Redeem

		--Fetch Accumulate Points
		FETCH NEXT FROM Points_Accum 
		INTO @Cur_A_YearDT, @Cur_A_QuarterDT, @Cur_A_DT, @Cur_A_Points, @Cur_A_Type
		set @AccumStatus = @@FETCH_STATUS

		--IF Quarter changed or no more records 
		-- Wrtie out accumlate record
		if (@AccumStatus != 0 or @Cur_A_YearDT != @Last_A_YearDT or @Cur_A_QuarterDT != @Last_A_QuarterDT)
		begin
			insert into ReportFinanceCustPoints values (
				@CustID, @CallerID, 'Accum', @Last_A_YearDT, @Last_A_QuarterDT, 
				@QA_Reg , @QA_Res1 , @QA_ResT , @QA_DIP1 , @QA_DIPT , @QA_Adj , @QA_Promo 
			)
			select @QA_Reg = 0, @QA_Res1 = 0, @QA_ResT = 0, @QA_DIP1 = 0, @QA_DIPT = 0, @QA_Adj = 0, @QA_Promo = 0

		end
	end -- End Loop

end




GO


GRANT EXECUTE ON [ComputePoints] TO ExecuteOnlyRole

GO
