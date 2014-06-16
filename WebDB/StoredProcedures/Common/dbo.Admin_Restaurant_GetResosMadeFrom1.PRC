if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_GetResosMadeFrom1]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_GetResosMadeFrom1]
GO

create procedure [dbo].[Admin_Restaurant_GetResosMadeFrom1]                        
(                        
  @Restaurant_ID int                        
 ,@StartDate datetime                        
 ,@EndDate datetime                        
)                        
as                        
set NOCOUNT on                        
set transaction ISOLATION LEVEL read UNCOMMITTED                        
                        
  --This Proc will fetch reservation data depend on @StartDate,@EndDate                         
                         
  --This forces to get floor value of @StartDate E.g. 2008-01-01 00:00:00.000                        
  set @StartDate =convert(datetime, floor(convert(float, @StartDate)))                        
                         
  --This forces to get floor value of (@EndDate+1)                        
  set @EndDate =dateadd(dd,1, convert(datetime, floor(convert(float, @EndDate))))                         
      
  --This calculates the shiftdate          
  declare @dShiftDate datetime           
  set  @dShiftDate = dateadd(dd, -30, @StartDate)       
  
  --This table variable is used to store the common reservation data for customer and caller.      
  create table  #tempreservationdata  
  (                      
     resid  int                      
    ,ShiftDate datetime                  
    ,ResTime  datetime                      
    ,seatedSize  int                      
    ,Partysize  int                      
    ,ResPoints  int                      
    ,IncentiveID  int                      
    ,ContactPhone  varchar(24)                      
    ,UseDiningCheque bit                      
    ,custID  int                      
    ,datemade  datetime                      
    ,ConfNumber  int                      
    ,RStateID  int                      
    ,RStateName nvarchar(20)                    
    ,PartnerID  int                      
    ,RID  int                      
    ,CallerID int              
    ,PartnerName nvarchar(25)            
    ,PartnerTypeID int   
    ,VVOffer nvarchar(20)
    ,FirstTimeDiner bit                             
  )          
    
  --Inserting common data in table variable              
  insert into #tempreservationdata                       
  (           
     resid                        
    ,ShiftDate                        
    ,ResTime                        
    ,seatedSize                        
    ,Partysize                        
    ,ResPoints                        
    ,IncentiveID                        
    ,ContactPhone                        
    ,UseDiningCheque                        
    ,custID                        
    ,datemade                        
    ,ConfNumber                        
    ,RStateID                      
    ,RStateName                      
    ,PartnerID                        
    ,RID                        
    ,CallerID              
    ,PartnerName            
    ,PartnerTypeID   
    ,VVOffer
    ,FirstTimeDiner                
  )                      
                                       
  select                        
     Reservation.resid                   
    ,ShiftDate                        
    ,ResTime                        
    ,seatedSize                        
    ,Partysize                        
    ,ResPoints                        
    ,IncentiveID                        
    ,ContactPhone                        
    ,UseDiningCheque                        
    ,custID                        
    ,datemade                        
    ,ConfNumber                        
    ,Reservation.RStateID                        
    ,RStateName                    
    ,Reservation.PartnerID                        
    ,Reservation.RID                        
    ,CallerID            
    ,PartnerName            
    ,PartnerTypeID  
	,(case when reservOfferVw.OfferClassID is not null then 'VV' else 'No' end) as VVOffer
    ,FirstTime                                              
  from       
    Reservation                         
        
   inner join reservationState                         
   on Reservation.RStateID = reservationState.RStateID                        
      
   inner join Partner       
   on Reservation.PartnerID = Partner.PartnerID   
   
	left join	ReservationOffer reservOffer
	on			reservOffer.ResID = Reservation.resId
	left join	ReservationOfferVW reservOfferVw
	on			reservOffer.OfferID = reservOfferVw.OfferID
	and			reservOfferVw.OfferClassID = 3
      
  where       
    ShiftDate >=  @dShiftDate  and       
    Reservation.RID = @Restaurant_ID and      
    ConfNumber > 0 and       
    DateMade >= @StartDate  and      
    DateMade < @EndDate                                        
       
  select                         
    Reservation.ResID as Reservation_ID                        
    ,ShiftDate as Shift_Date                        
    ,ResTime as Reservation_Time                        
    ,case                         
      when(coalesce(seatedSize,0) < 1) then Partysize                         
    else seatedSize                         
    end                        
    as Party_size                        
    ,ResPoints as Points_for_Reservation                        
    ,coalesce(IncentiveID,0) as Incentive_ID                        
    ,ContactPhone as Contact_Phone                        
    ,'' as Notes                        
    ,coalesce(UseDiningCheque,0) as useCheque                        
    ,Customer.FName as First_Name                        
    ,Customer.LName as Last_Name                        
    ,Customer.SFName as First_Name_phonetic                        
    ,Customer.SLName as Last_Name_phonetic                        
    ,Null as Booker_Lname                        
    ,Null as Booker_Fname                        
    ,Null as Booker_Lname_phonetic                        
    ,Null as Booker_Fname_phonetic                        
    ,Reservation.custID as CID                        
    ,DateMade as Date_Made                        
    -- Convert DateMade from PST to JST                        
    ,dbo.fTimeConvert (DateMade,4,27) as Date_Made_JST                        
    ,email                   
    ,referrer.referrerID as referrer_ID                        
    ,RStateName as resoState                        
    ,ConfNumber as Confirmation_Number                        
    ,ReferrerRestaurantReservationVW.rid as restref                        
    ,referrer.referrername as Ref_Name                        
    ,Reservation.PartnerID                        
    ,PartnerName                        
    ,PartnerTypeID                        
    ,VVOffer
    ,( case 
	   when(Reservation.FirstTimeDiner = 0) then 'No'
	   when(Reservation.FirstTimeDiner = 1) then 'Yes'
	   else 'N/A'
	   end
	 ) as First_Time_Diner

  from       
      
    #tempreservationdata as Reservation                              
      
    inner join Customer                        
    on Reservation.custID = Customer.custID                        
       
    left outer join ReferrerReservationVW                         
    on ReferrerReservationVW.ResID = reservation.ResID                        
       
    left outer join referrer                         
    on referrer.referrerid = ReferrerReservationVW.referrerid                        
       
    left outer join ReferrerRestaurantReservationVW                           
    on reservation.resid = ReferrerRestaurantReservationVW.resid and       
    reservation.RID = ReferrerRestaurantReservationVW.RID                                      
      
  where       
    Reservation.CallerID  is null                        
                               
union all                        
                         
  select                         
    Reservation.ResID as Reservation_ID                        
    ,ShiftDate as Shift_Date                        
    ,ResTime as Reservation_Time                        
    ,case                         
     when(Coalesce(seatedSize,0) < 1) then Partysize                        
    else seatedSize                         
    End                        
    as Party_size                        
    ,ResPoints as Points_for_Reservation                        
    ,coalesce(IncentiveID,0) as Incentive_ID                        
    ,Reservation.ContactPhone as Contact_Phone                        
    ,'' as Notes                        
    ,coalesce(UseDiningCheque,0) as useCheque                        
    ,CallerCustomer.FName as First_Name                        
    ,CallerCustomer.LName as Last_Name                      
    ,CallerCustomer.SFName as First_Name_phonetic                        
    ,CallerCustomer.SLName as Last_Name_phonetic                        
    ,Caller.LName as Booker_Lname                        
    ,Caller.FName as Booker_Fname                        
    ,Caller.SLName as Booker_Lname_phonetic                        
    ,Caller.SFName as Booker_Fname_phonetic                        
    ,Reservation.custID as CID                        
    ,DateMade as Date_Made                        
    -- Convert DateMade from PST to JST                        
    ,dbo.fTimeConvert (DateMade,4,27) as Date_Made_JST                        
    ,Caller.email                        
    ,referrer.referrerID as referrer_ID                    
    ,RStateName as resoState                    
    ,ConfNumber as Confirmation_Number                        
    ,ReferrerRestaurantReservationVW.rid as restref                        
    ,referrer.referrername as Ref_Name                        
    ,Reservation.PartnerID                        
    ,PartnerName                        
    ,PartnerTypeID                        
    ,VVOffer       
    ,( case 
	   when(Reservation.FirstTimeDiner = 0) then 'No'
	   when(Reservation.FirstTimeDiner = 1) then 'Yes'
	   else 'N/A'
	   end
	 ) as First_Time_Diner
  from       
     
    #tempreservationdata as Reservation                        
         
  inner join CallerCustomer                         
  on Reservation.custID = CallerCustomer.custID                        
      
  inner join Caller                         
  on Reservation.CallerID = caller.CallerID                        
      
  left outer join ReferrerReservationVW                         
  on ReferrerReservationVW.ResID = reservation.ResID                        
      
  left outer join referrer                        
  on referrer.referrerid = ReferrerReservationVW.referrerid                        
      
  left outer join ReferrerRestaurantReservationVW                          
  on reservation.resid = ReferrerRestaurantReservationVW.resid and       
  reservation.RID =ReferrerRestaurantReservationVW.RID                               
      
  where       
    reservation.CallerID is not null                
      
 order by       
  Reservation.DateMade       
      
GO

GRANT EXECUTE ON dbo.[Admin_Restaurant_GetResosMadeFrom1] TO ExecuteOnlyRole
go

GRANT EXECUTE ON dbo.[Admin_Restaurant_GetResosMadeFrom1] TO WebUserUS
go



