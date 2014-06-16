if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Reservation_GetNoShowInfo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Reservation_GetNoShowInfo]
GO

CREATE PROCEDURE dbo.Reservation_GetNoShowInfo 

( 
@ReservationID int 
) 
 AS 

 SET NOCOUNT ON 
set transaction isolation level read uncommitted 

declare @debugging as bit,@debuggingEmail nvarchar(60),@minNoShowDate datetime 

set @debugging = 0 /*this determines whether or not no-show notifications are sent to the consumers ... 1 = true; 0 = false*/

set @debuggingEmail = 'webdev@opentable.com' /*change this to copy webdev on production*/ 

set @minNoShowDate = '10-3-2000'  /*this is the time after which we are counting no-shows*/ 

declare    @isCallerReso int 
        ,@isAAUser int 
        ,@Source nvarchar(60) 
        ,@RestaurantName nvarchar(40) 
        ,@ResDateTime nvarchar(40) 
        ,@Dest nvarchar(60) 
        ,@ResTime nvarchar(255) 
        ,@ResDate nvarchar(255) 
        ,@BCC nvarchar(60) 
        ,@Points int 
        ,@ConsumerType int 
        ,@PartnerID int 



set @Source = 'no-show@opentable.com' 
set @BCC = @debuggingEmail 

--is this a Caller reso? 
select @isCallerReso = 
        (CASE WHEN CallerID is null then 0 
        ELSE 1 END) from Reservation where ResID = @ReservationID 
--is this an AAUser reso? 
select @isAAUser = isnull((select CASE when PositionID = 3 then 1 else 0 END 
        from Caller inner join Reservation on 
        Caller.CallerID = Reservation.CallerID 
        where Reservation.ResID = @ReservationID),0) 
if @isCallerReso = 0 /*THIS IS AN OTConsumer Reso so send back Consumer Information*/ 
        BEGIN 
        declare @count int 
        ,@CustID int 
        ,@LName nvarchar(30) 
        ,@FName nvarchar(30) 

        select @count = count(Reservation.ResID) 
                from Reservation 
                where Reservation.RStateID = 4 -- no-show 
                and Reservation.ShiftDate > dateadd(year,-1,getDate()) -- in the past year 
                and Reservation.ShiftDate > @minNoShowDate --after the date we start checking 
                and Reservation.CustID = 
                        (select CustID from Reservation where ResID = @ReservationID) 

        select  @CustID = Customer.CustID 
                ,@LName =  Customer.LName 
                ,@FName = Customer.FName 
                ,@RestaurantName = r.RName 
                ,@ResDateTime = 
                        convert(nvarchar,(Reservation.ShiftDate + 2 + Reservation.ResTime)) 
                ,@Dest = Customer.email 
                ,@ResDate = 
                        convert(nvarchar,Reservation.ShiftDate,107) 
                        --left((convert(nvarchar,(Reservation.ShiftDate + 2 + Reservation.ResTime),109)),11)

                ,@ResTime = 
                        convert(nvarchar,Reservation.ResTime,8) 
                        --right((convert(nvarchar,(Reservation.ShiftDate + 2 + Reservation.ResTime))),7) 
                ,@Points = Reservation.ResPoints 
                ,@ConsumerType = Customer.ConsumerType 
                ,@PartnerID = Reservation.PartnerID 
        from Reservation 
                inner join Customer on Reservation.CustID = Customer.CustID 
                inner join RestaurantVW r on r.RID = Reservation.RID 
                where ResID = @ReservationID 
        group by Customer.CustID 
                ,FName 
                ,LName 
                ,r.RName 
                ,Reservation.ShiftDate 
                ,Reservation.ResTime 
                ,Customer.email 
                ,Reservation.ResPoints 
                ,Customer.ConsumerType 
                ,Reservation.PartnerID 

        if @debugging = 1 
        Begin 
                set @Dest = @debuggingEmail 
        End 

        select @count as noshowcount 
                ,isnull(@CustID,0) as CustID 
                ,isnull(@FName,'') + ' ' + isnull(@LName,'') as name 
                ,isnull(@RestaurantName,'') as RestaurantName 
                ,isnull(@ResDateTime,'') as ResDateTime 
                ,@Source as source 
                ,@Dest as destination 
                ,@BCC  as bcc 
                ,@isCallerReso as isCallerReso 
                ,@isAAUser as isAAUser 
                ,@ResDate as ResDate 
                ,@ResTime as ResTime 
                ,@Points as Points 
                ,isnull(@FName,'') as FName 
                ,@ConsumerType as ConsumerType 
                ,@PartnerID as PartnerID 
                /* 
                ,@isAAUser as isAAUser 
                DH 4.3.01 commented out - this looks redundant*/ 
        END 
if @isCallerReso = 1  /*THIS IS AN OTAdmin  Reso so send back OTAdmin Information...*/ 
        BEGIN 
        declare  @CallerNoShowCount int 
        ,@DinerNoShowCount int 
        ,@CallerID As Int 
        ,@CallerEmail As nvarchar(60) 
        ,@CallerName as nvarchar(60) 
        ,@DinerID As Integer 
        ,@DinerEmail As nvarchar(60) 
        ,@DinerName as nvarchar(60) 
        ,@CallerFName as nvarchar(60) 
        ,@DinerFName as nvarchar(60) 

        select @CallerNoShowCount = count(Reservation.ResID) 
                from Reservation        where Reservation.RStateID = 4 -- no-show 
                and Reservation.ShiftDate > dateadd(year,-1,getDate()) -- in the past year 
                and Reservation.ShiftDate > @minNoShowDate 
                and Reservation.CallerID = 
                        (select CallerID from Reservation where ResID = @ReservationID) 

        select @DinerNoShowCount = count(Reservation.ResID) 
                from Reservation        where Reservation.RStateID = 4 -- no-show 
                and Reservation.ShiftDate > dateadd(year,-1,getDate()) -- in the past year 
                and Reservation.ShiftDate > @minNoShowDate 
                and Reservation.CallerID = 
                        (select CallerID from Reservation where ResID = @ReservationID) 
                and Reservation.CustID = 
                        (select CustID from Reservation where ResID = @ReservationID) 

        --GET CALLER,CUSTOMER,and Restaurant INFORMATION 
        select  @RestaurantName = isnull(r.RName,'') 
                ,@ResDateTime = convert(nvarchar,(Reservation.ShiftDate + 2 + Reservation.ResTime)) 
                ,@CallerID = isnull(Caller.CallerID,0) 
                ,@CallerEmail =  isnull(Caller.Email,'') 
                ,@CallerName = isnull(Caller.FName,'') + ' ' + isnull(Caller.LName,'') 
                ,@CallerFName = isnull(Caller.FName,'') 
                ,@DinerID = isnull(CallerCustomer.CustID,0) 
                ,@DinerEmail = isnull(CallerCustomer.email,'') 
                ,@DinerName = 
                        isnull(CallerCustomer.FName,'') + ' ' + isnull(CallerCustomer.LName,'') 
                ,@DinerFName = 
                        isnull(CallerCustomer.FName,'') 
                ,@ResDate = 
                        convert(nvarchar,Reservation.ShiftDate,107) 
                        --left((convert(nvarchar,(Reservation.ShiftDate + 2 + Reservation.ResTime),109)),11)

                ,@ResTime = 
                        convert(nvarchar,Reservation.ResTime,8) 
                        --right((convert(nvarchar,(Reservation.ShiftDate + 2 + Reservation.ResTime))),7) 
                ,@Points = Reservation.ResPoints 
                ,@ConsumerType = Caller.ConsumerType 
                ,@PartnerID = Reservation.PartnerID 
        from Caller 
                inner join Reservation on Reservation.CallerID = Caller.CallerID 
                inner join RestaurantVW r on r.RID = Reservation.RID 
                inner join CallerCustomer on CallerCustomer.CallerID = Caller.CallerID 
        where Reservation.ResID = @ReservationID 
                and CallerCustomer.CustID =  Reservation.CustID 
        if @debugging = 1 
        Begin 
                set @CallerEmail = @debuggingEmail 
                set @DinerEmail = @debuggingEmail 
        End 

        select    @RestaurantName As RestaurantName 
                ,@ResDateTime As ResDateTime 
                ,@CallerNoShowCount As CallerNoShowCount 
                ,@CallerID As CallerID 
                ,@CallerEmail As CallerEmail 
                ,@CallerName as CallerName 
                ,@CallerFName as CallerFirstName 
                ,@DinerID As DinerID 
                ,@DinerEmail As DinerEmail 
                ,@DinerName as DinerName 
                ,@Source As source 
                ,@BCC As bcc 
                ,@DinerNoShowCount as DinerNoShowCount 
                ,@ResDate as ResDate 
                ,@ResTime as ResTime 
                ,@Points as Points 
                ,@isCallerReso as isCallerReso 
                ,@isAAUser as isAAUser 
                ,@DinerFName as DinerFirstName 
                ,@ConsumerType as Consumer_Type 
                ,@PartnerID as PartnerID 

        END
GO

GRANT EXECUTE ON [Reservation_GetNoShowInfo] TO ExecuteOnlyRole

GO
