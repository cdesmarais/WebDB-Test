--Create Stored Proc.
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[svcVVSync]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[svcVVSync]
GO

CREATE PROCEDURE [dbo].[svcVVSync]
AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON

declare @errormessage nvarchar(500)

if (not exists (select 1 from ValueLookup where LKey = 'VVSYNC_WATERMARK'))
begin 
	set @errormessage = 
		'Missing VVSYNC_WATERMARK from ValueLookup; please run VVSyncSetup.sql before running svcVVSync proc' 
	RAISERROR(@errormessage, 16, 1)
    return -1
end

-------------------------------------------
-- Watermark initialization
-------------------------------------------

-- Get current high water mark from VVSyncLog and ValueLookup
-- We will process resos at or above this value
DECLARE @CurrentWaterMark INT
SELECT  @CurrentWaterMark=MAX(ResLogID)
FROM		(
						-- Add 1 to the ResLogID of the most recently successfully sent message
						-- VVSyncLog contains only successfully sent messages
						SELECT	MAX(ResLogID) + 1 as ResLogID 
						FROM	dbo.VVSyncLog

						
						-- We write the max + 1 of the scanned reslog range to valuelookup 
						-- at the end any successful run.
						-- This gives a lower bound for searched range of reservation log (which is huge)
				UNION	SELECT ValueInt as ResLogID from ValueLookup where LKey = 'VVSYNC_WATERMARK' 
			) as a

-- Get next high water mark from Res Log
-- We will process resos below this value
DECLARE @NextWaterMark INT
SELECT  @NextWaterMark=MAX(ResLogID) + 1 from ReservationLog where	resLogID >= @CurrentWaterMark and UpdateDT < DATEADD(MINUTE, -1, GETDATE())

----------------------------------------------------------------
-- Create temp table of notifications to send to VV from ResLog
----------------------------------------------------------------
SELECT		rlog.ResID								ResID,
			rlog.ResLogID							ResLogID,
			rlog.RID								RID,
			rlog.PartySize							PartySize,
			rlog.ShiftDT 							ShiftDate,
			rlog.UpdateDT							UpdateDate,
			resto.RName								RName,
			resto.Address1							Address1,
			resto.Address2							Address2,
			resto.City								City,
			resto.State								State,
			resto.ZIP								ZIP,
			offer.ThirdPartyOfferID					ThirdPartyOfferID,
			case
				when plog.RecCount = 0 and rlog.RStateID not in (3,8) then 1
				else 0
			end										IsMake,
			case
				when plog.RecCount > 0 and rlog.RStateID not in (3,8) then 1
				else 0
			end										IsChange,
			case
				when rlog.RStateID in (3,8) then 1
				else 0
			end										IsCancel
			
INTO		#notification
FROM		ReservationLog				rlog

inner join	RestaurantVW				resto
on			resto.RID					= rlog.RID

inner join	ReservationOffer			ro
on			ro.ResID					= rlog.ResID

inner join	RestaurantOffer				offer
on			offer.RestaurantOfferID		= ro.OfferID
and			offer.OfferClassID			= 3

CROSS APPLY (	
			-- to distinguish between Make and Change
			SELECT		COUNT(ResLogID) AS RecCount
			FROM		dbo.ReservationLog 
			WHERE		ResID = rlog.ResID
			AND			ResLogID < rlog.ResLogID 
			)  plog
		
WHERE		rlog.ResLogID				>= @CurrentWaterMark		-- at or above current watermark
and			rlog.ResLogID				<  @NextWaterMark			-- below next watermark
and			rlog.RStateID				in ( 1		-- Pending
											,3		-- Cancelled Web
											,8		-- Cancelled Restaurant
											)


----------------------------------------------------------------
-- Add detail to the notifications from the larger more expensive tables:
-- Reservation, Customer, Caller
----------------------------------------------------------------
SELECT		n.ResID								ResID,
			n.ResLogID							ResLogID,
			r.ConfNumber							ConfNumber,
			n.RID								RID,
			n.PartySize							PartySize,
			n.ShiftDate 							ShiftDate,
			n.UpdateDate							UpdateDate,
			r.ContactPhone							ContactPhone,
			r.DateMade								DateMade,
			coalesce(c.LName, cc.LName)				LName,
			coalesce(c.FName, cc.FName)				FName,
			n.RName								RName,
			n.Address1							Address1,
			n.Address2							Address2,
			n.City								City,
			n.State								State,
			n.ZIP								ZIP,
			n.ThirdPartyOfferID					ThirdPartyOfferID,
			n.IsMake,
			n.IsChange,
			n.IsCancel
into        #notification_detail			
from        #notification n
inner join	Reservation					r
on			r.ResID						= n.ResID

left join   Customer                    c
on          c.CustID                    = r.CustID
and         r.CallerID					is null

left join   CallerCustomer				cc
on          cc.CustID					= r.CustID   
and         r.CallerID                  is not null


-------------------------------------------------------------------
-- Loop over the notifications and send email for each one
-------------------------------------------------------------------
declare @ResLogID			as int
declare @ConfNumber			as int
declare @RID				as int
declare @PartySize			as int
declare @ShiftDate			as datetime
declare @ContactPhone		as varchar(24)
declare @DateMade			as datetime 
declare @UpdateDate			as datetime 
declare @LName 				as nvarchar(40)
declare @FName 				as nvarchar(40)
declare @RName 				as nvarchar(255)
declare @Address1 			as nvarchar(128)
declare @Address2 			as nvarchar(128)
declare @City				as nvarchar(40)
declare @State				as nvarchar(40)
declare @ZIP				as nvarchar(20)
declare @ThirdPartyOfferID	as int
declare @IsMake				as int
declare @IsChange			as int
declare @IsCancel			as int

declare		NotificationCursor CURSOR READ_ONLY FAST_FORWARD FOR
Select 		 ResLogID			
	   		,ConfNumber			
	   		,RID				
	   		,PartySize			
	   		,ShiftDate
	   		,UpdateDate
	   		,ContactPhone		
	   		,DateMade			
	   		,LName 				
	   		,FName 				
	   		,RName 				
	   		,Address1 			
	   		,Address2 			
	   		,City				
	   		,State				
	   		,ZIP				
	   		,ThirdPartyOfferID	
	   		,IsMake				
	   		,IsChange			
	   		,IsCancel			
from		#notification_detail
order by	ResLogID asc

OPEN NotificationCursor
FETCH NEXT FROM NotificationCursor
INTO	 @ResLogID			
		,@ConfNumber			
		,@RID				
		,@PartySize			
		,@ShiftDate
		,@UpdateDate
		,@ContactPhone		
		,@DateMade			
		,@LName 				
		,@FName 				
		,@RName 				
		,@Address1 			
		,@Address2 			
		,@City				
		,@State				
		,@ZIP				
		,@ThirdPartyOfferID	
		,@IsMake				
		,@IsChange			
		,@IsCancel			

WHILE @@FETCH_STATUS = 0
BEGIN

declare @Operation as nvarchar(10) = case 
										when @IsMake = 1 then 'Make'
										when @IsChange = 1 then 'Change'
										when @IsCancel = 1 then 'Cancel'
										else 'Unknown'
									end
-----------------------------------------------
-- form email message 
-----------------------------------------------
declare @VVEmailBody as nvarchar(4000) = ''

-- form human readable part of email body

set @VVEmailBody = @VVEmailBody + 'Diner Name: ' + coalesce(@FName, '') + ' ' + coalesce(@LName, '') + CHAR(13) + CHAR(10)
set @VVEmailBody = @VVEmailBody + 'Party Size: ' + convert(nvarchar, @PartySize) + CHAR(13) + CHAR(10)
set @VVEmailBody = @VVEmailBody + 'Restaurant Name: ' + coalesce(@RName, '') + CHAR(13) + CHAR(10)
set @VVEmailBody = @VVEmailBody + 'Operation: ' + coalesce(@Operation, '') + CHAR(13) + CHAR(10)
set @VVEmailBody = @VVEmailBody + 'Booking Date: ' + convert(nvarchar, CAST(@ShiftDate as date)) + CHAR(13) + CHAR(10)
set @VVEmailBody = @VVEmailBody + 'Booking Time: ' + convert(nvarchar, CAST(@ShiftDate as time), 100) + CHAR(13) + CHAR(10)
set @VVEmailBody = @VVEmailBody + 'Phone Number: ' + coalesce(@ContactPhone, '') + CHAR(13) + CHAR(10)
set @VVEmailBody = @VVEmailBody + 'Receipt Number: ' + coalesce(convert(nvarchar, @ConfNumber), '') + CHAR(13) + CHAR(10)
set @VVEmailBody = @VVEmailBody + 'City Region: ' + coalesce(@City,'') + ', ' + coalesce(@State, '') + ' ' + coalesce(@ZIP, '') + CHAR(13) + CHAR(10)
set @VVEmailBody = @VVEmailBody + 'Purchase Date: ' + convert(nvarchar, cast(@DateMade as DATE)) + CHAR(13) + CHAR(10)
set @VVEmailBody = @VVEmailBody + 'Purchase Time: ' + convert(nvarchar, cast(@DateMade as time), 100) + CHAR(13) + CHAR(10)
set @VVEmailBody = @VVEmailBody + 'SequenceID: ' + convert(nvarchar, @ResLogID) + CHAR(13) + CHAR(10)
set @VVEmailBody = @VVEmailBody + 'Update Date: ' + CONVERT(nvarchar, @UpdateDate, 120) + CHAR(13) + CHAR(10)

set @VVEmailBody = @VVEmailBody + CHAR(13) + CHAR(10)

set @VVEmailBody = @VVEmailBody + '###START_JSON###' + CHAR(13) + CHAR(10)

-- build JSON 

set @VVEmailBody = @VVEmailBody + 
'{'
+ '"DinerFirstName":'			+ '"' +	coalesce(@FName, '') + '",'
+ '"DinerLastName":'			+ '"' + coalesce(@LName, '') + '",'
+ '"PartySize":'					  + convert(nvarchar, @PartySize) + ','
+ '"RestaurantName":'			+ '"' + coalesce(@RName, '') + '",'
+ '"Operation":'				+ '"' + coalesce(@Operation, '') + '",'
+ '"ReservationDateTime":'		+ '"' + convert(nvarchar, @ShiftDate, 120) + '",'
+ '"Phone":'					+ '"' + coalesce(@ContactPhone, '') + '",'
+ '"ConfirmationNumber":'			  + coalesce(convert(nvarchar, @ConfNumber), '') + ','
+ '"RID":'							  + convert(nvarchar, @RID) + ','
+ '"DealID":'						  + convert(nvarchar, coalesce(@ThirdPartyOfferID, -1)) + ','
+ '"RestaurantAddress":'		+ '"' + coalesce(@Address1, '') 
									  + case when @Address2 is null then '' else ' ' + @Address2 end + '",'							  
+ '"RestaurantCity":'			+ '"' + coalesce(@City, '')
									  + case when @State is null then '' else ' ' + @State end
									  + case when @Zip is null then '' else ' ' + @Zip end
									  + '",'
+ '"PurchaseDate":'				+ '"' + CONVERT(nvarchar, @DateMade, 120) + '",'
+ '"SequenceID":'				+		CONVERT(nvarchar, @ResLogID) + ','
+ '"UpdateDate":'				+ '"' + CONVERT(nvarchar, @UpdateDate, 120) + '"'
+ '}'

set @VVEmailBody = @VVEmailBody + CHAR(13) + CHAR(10) + '###END_JSON###' + CHAR(13) + CHAR(10)

------------------------------------------
-- Send email message
------------------------------------------
declare @VVEmailRecipient nvarchar(500) 
select @VVEmailRecipient = ValueChar from ValueLookup where LKey = 'VVEmailRecipient'
declare @VVEmailSubject as nvarchar(100) = 'OpenTable Bookings'
declare @SendEmailRC int

EXEC @SendEmailRC = msdb.dbo.sp_send_dbmail
						@recipients = @VVEmailRecipient,
						@subject = @VVEmailSubject,
						@body = @VVEmailBody

-- TODO: uncomment this to test the proc in an environment without DB email enabled
--set @SendEmailRC = 0 -- means success
--print '*****EMAIL NOTIFICATION*****'
--print 'Subject: ' + @VVEmailSubject + CHAR(13) + CHAR(10)
--print 'To: ' + @VVEmailRecipient
--print @VVEmailBody
--print ' '

if (@SendEmailRC is null or @SendEmailRC != 0)
begin 
	CLOSE NotificationCursor
	DEALLOCATE NotificationCursor
	set @errormessage = 
		'Error Sending EMail To: ' 
		+ coalesce(@VVEmailRecipient, 'Unknown') 
		+ 'For ResLogID: ' 
		+ convert(nvarchar, @ResLogID)
	RAISERROR(@errormessage, 16, 1)
    return -1
end

--------------------------------
-- update sync log
--------------------------------
insert	 dbo.VVSyncLog
(		 ResLogID, 
		 CreateDT )
values ( @ResLogID
		,GETDATE() )


FETCH NEXT FROM NotificationCursor
INTO	 @ResLogID			
		,@ConfNumber			
		,@RID				
		,@PartySize			
		,@ShiftDate
		,@UpdateDate
		,@ContactPhone		
		,@DateMade			
		,@LName 				
		,@FName 				
		,@RName 				
		,@Address1 			
		,@Address2 			
		,@City				
		,@State				
		,@ZIP				
		,@ThirdPartyOfferID	
		,@IsMake				
		,@IsChange			
		,@IsCancel			
END

CLOSE NotificationCursor
DEALLOCATE NotificationCursor

--------------------------------
-- success: update watermark
--------------------------------
update	ValueLookup
set		ValueInt	= @NextWaterMark
where	LKey		= 'VVSYNC_WATERMARK'


GO


GRANT EXECUTE ON [svcVVSync] TO ExecuteOnlyRole

GO
