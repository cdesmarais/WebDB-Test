if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNChangeRealCustomerToAAUser]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNChangeRealCustomerToAAUser]
GO

CREATE PROCEDURE dbo.DNChangeRealCustomerToAAUser  
(  
 @CustomerEmail nvarchar(255),  
 @Debug int = 0  
)  
 AS  
  
set nocount on  
  
declare @custID int  
  ,@CallerID int  
  ,@AAUserID int  
  ,@message nvarchar(255)  
  
--*** Check if customer does not exist then exit  
select @custID = CustID from Customer where email = @CustomerEmail  
if @custID is null goto NoSuchCustomer  
  
  
--*** Check if a caller already exists  
if exists(select callerid from caller where loginname = @CustomerEmail) goto CallerExists  
  
  
  
declare @NewDinerID int,  
  @Points int,  
  @PositionID int,  
  @FName nvarchar(255),  
  @LName nvarchar(255),  
  @Email nvarchar(255),  
  @MetroAreaID int,  
  @PwdQuestionID int,  
  @PwdAnswer nvarchar(255),   
  @LastPointsGainDate datetime,  
  @PartnerID int,  
  @PhoneCountryID char(2),  
  @Phone nvarchar(255),  
  @IsPhonePrimary bit,   
  @MobilePhoneCountryID char(2),  
  @MobilePhone nvarchar(255),  
  @IsMobilePrimary bit,   
  @Salutation int,  
  @SendAnnouncements BIT,  
  @ConsumerType int,   
  @CreateDate datetime,  
  @LastResoPhoneTypeID int,  
  @Address1 nvarchar(40),  
  @Address2 nvarchar(40),  
  @City nvarchar(40),  
  @State nvarchar(40),  
  @Zip nvarchar(20),  
  @Country char(2),  
  @Notes nvarchar(255),  
  @DiningFormEmailOptIn bit  
  
declare @SFName nvarchar(255)  
declare @SLName nvarchar(255)  
  
select  @Points = Points,  
   @PositionID = 3,  
   @FName = FName,  
   @LName = LName,  
   @SFName = SFName,  
   @SLName = SLName,  
   @Email = Email,  
   @MetroAreaID = metroareaid,  
   @PwdQuestionID = isnull(Customer.PwdQuestionID,1),  
   @PwdAnswer = Customer.PwdAnswer,  
   @PartnerID = Customer.PartnerID,  
   @PhoneCountryID = d.PhoneCountryID,  
   @Phone = d.Phone,  
   @IsPhonePrimary = d.IsPrimary,  
   @MobilePhoneCountryID = m.PhoneCountryID,   
   @MobilePhone = m.Phone,  
   @IsMobilePrimary = m.IsPrimary,  
   @SendAnnouncements = SendAnnouncements,  
   @ConsumerType = isnull(ConsumerType,1),  
   @Salutation = Salutation,  
   @CreateDate = CreateDate,  
   @LastPointsGainDate = LastPointsGainDate,  
   @LastResoPhoneTypeID = CASE When LastResoPhoneTypeID = 2 THEN 6 Else LastResoPhoneTypeID END,--Convert Regulare User's Home PhoneType (ID=2) to Caller's equivalent Home Phone(ID=6)  
   @Address1 = Address1,  
   @Address2 = Address2,  
   @City = City,  
   @State = State,  
   @Zip = Zip,  
   @Country = Country,  
   @Notes = Special,  
   @DiningFormEmailOptIn = DiningFormEmailOptIn  
from   Customer   
left join CustomerPhone d  
ON       Customer.CustID = d.CustID   
and   d.PhoneTypeID = 2 --work  
left join   CustomerPhone m  
ON       Customer.CustID = m.CustID   
and   m.PhoneTypeID = 4 --mobile  
where  Customer.CustID = @custID  
  
  
  
BEGIN TRANSACTION  
  
 Insert into Caller  
	(Points,PositionID,FName,LName,SFName,SLName,Email,metroareaid,LoginName,
 PwdQuestionID,PwdAnswer, PartnerID,SendAnnouncements, ConsumerType,Salutation,CreateDate,  
 LastPointsGainDate, LastResoPhoneTypeID, Address1, Address2, City, State, Zip, Country, Notes, DiningFormEmailOptIn, SendPromoEmail)  
 values  
   (@Points,@PositionID,@FName,@LName,@SFName,@SLName,@Email,@MetroAreaID,@Email,  
	@PwdQuestionID,@PwdAnswer, @PartnerID,@SendAnnouncements, @ConsumerType,@Salutation,@CreateDate,
 @LastPointsGainDate, @LastResoPhoneTypeID,@Address1,@Address2,@City,@State,@Zip,@Country, @Notes, @DiningFormEmailOptIn, @SendAnnouncements)  
   
 if @@error <> 0  
  goto Error  
  
 set @CallerID = scope_identity()  
   
   
 -- DeActivate User; Change Email to a unique name   
 -- Set Points to 0; set create relation between old customer and new caller  
   
 UPDATE Customer   
 SET  email = email +  '_' + CONVERT(VARCHAR(20),@custID) + '_isAAUser',  
   active = 0,   
   points = 0,  
   CallerID = @CallerID  
 WHERE CustID = @custID  
 if @@error <> 0  
  goto Error  
  
 -- TODO: EV: Review this log it's probably obsolete  
 Exec dbo.DNLogDeActivatedUsers @custID, 0, 4  
 if @@error <> 0  
  goto Error  
 
 --***************************************************************************************
 --Update GlobalPerson table
 DECLARE	@Error INT, @RowCount INT
 
 UPDATE		GlobalPerson
 SET		CallerID = @CallerID,
			CustID = NULL
 WHERE		CustID = @custID
 
 SELECT		@Error = @@ERROR, @RowCount = @@ROWCOUNT
 
 IF @Error <> 0  
  GOTO Error 
 
 --If for some reason there was no record of this person then create one
 IF (@RowCount < 1)
  BEGIN
	INSERT	INTO	GlobalPerson (CustID, CallerID) VALUES(NULL, @CallerID)
	IF @@ERROR <> 0  
		GOTO error	
  END
--*************************************************************************************** 
    
 if(IsNull(@PhoneCountryID, '') <> '' AND IsNull(@Phone, '') <> '')  
 Begin  
  Insert into CallerPhone (PhoneTypeID,CallerID,PhoneCountryID,Phone, IsPrimary) values (6, @CallerID,@PhoneCountryID, @Phone, @IsPhonePrimary)  
  if @@error <> 0  
   goto Error  
 End  
  
 -- Create Mobile phone row if information is available  
 if(IsNull(@MobilePhoneCountryID, '') <> '' AND IsNull(@MobilePhone, '') <> '')  
 Begin  
  Insert into CallerPhone (PhoneTypeID,CallerID,PhoneCountryID,Phone, IsPrimary) VALUES (4,@CallerID,@MobilePhoneCountryID ,@MobilePhone, @IsMobilePrimary)  
  if @@error <> 0  
   goto Error  
 End  
  
  
 INSERT INTO CallCusNextID (CustomerType) VALUES ('S')  
 if @@error <> 0  
  goto Error  
  
  
  set @NewDinerID = scope_identity()  
 if @Debug = 1  
  BEGIN  
  print @NewDinerID  
  print 'new Customer added'  
  END  
  
 if @@error <> 0  
  goto Error  
  
  
 Insert into CallerCustomer (CustID,CallerID,FName,LName,SFName,SLName,Email, PhoneCountryID, ContactPhone, IsAdmin)  
 values (@NewDinerID,@CallerID,@FName,@LName,@SFName,@SLName,@Email,@PhoneCountryID,@Phone, 1)  
 if @@error <> 0  
  goto Error  
  
  
 Insert into CustomerPhone (PhoneTypeID,CustID,PhoneCountryID, Phone) values (5,@NewDinerID,@PhoneCountryID,@Phone)  
 if @@error <> 0  
  goto Error  
  
  
 insert into CallerRestaurants (CallerId, RID, FolderID)
 (select @CallerID,  
   RID,  
   0 as folder_ID
 from Favorites   
 where CustID = @custID ) 
 
 if @@error <> 0  
  goto Error  
  
 --***************************************************  
 --** Associate old transaction with new Caller   
 --** Update: Reservation, GiftRedemption, PromoUse, PointsAdjustment  
 --** Update Referalls, and Logs  
 --***************************************************  
 update Reservation   
 set  CustID = @NewDinerID,  
   CallerID = @CallerID   
 where CustID = @custID  
 if @@error <> 0  
  goto Error  
  
 update GiftRedemption   
 set  CallerID = @CallerID, custID = null  
 where CustID = @custID  
 if @@error <> 0  
  goto Error  
  
 update PromoUse   
 set  CallerID = @CallerID,  
   custID = null  
 where CustID = @custID  
 if @@error <> 0  
  goto Error   
  
 update PointsAdjustment   
 set  CallerID = @CallerID,   
   custID = null  
 where CustID = @custID  
 if @@error <> 0  
  goto Error  
  
 update referrerRegistration   
 set  CallerID = @CallerID,   
   custid = null   
 where custid = @custID  
  
 update referrerRestaurantRegistration  
 set  CallerID = @CallerID,  
   custid = null  
 where custid = @custID  
  
 update referrerUserRegistration   
 set  CallerID = @CallerID,  
   custid = null   
 where custid = @custID  
   
   
 -- ***Set Email Opt-In preferences  
 -- update Customer to Caller for all previous email preferences     
    update  UserOptIn  
 set  CallerID = @CallerID,  
   CustID = null,  
   UpdatedDtUTC = getutcdate()  
 where  CustID = @CustID  
  
    -- if a new metro, insert the new record for that caller  
 if not exists (select CallerID from UserOptIn with (nolock) where CallerID = @CallerID)   
 insert UserOptIn (CallerID, Insider,DinersChoice,NewHot,RestaurantWeek,Promotional,SpotLight, Product, MetroAreaID)   
  Values (@CallerID, @SendAnnouncements,@SendAnnouncements,@SendAnnouncements,@SendAnnouncements,@SendAnnouncements,@SendAnnouncements,@SendAnnouncements, @MetroAreaID)     
      
    if (@@error <> 0)  
  GOTO Error  
    
  
 -- TODO: EV: Review this seems a little strange. This table could be used to track a conversion from Cust to Caller, but we would need to change the reassociation currently occuring  
 update consumertypeConvertlog  
 set  CallerID = @CallerID,   
   custid = null   
 where custid = @custID  
   
 insert into SocialCaller (CallerID, SiteUserID, SocialTypeID, CreateDate, SocialAccessToken)  
  select @CallerID, SiteUserID, SocialTypeID, CreateDate, SocialAccessToken from SocialCustomer where CustID = @custID  
 delete from SocialCustomer where CustID = @custID  
  
  
 if @Debug = 1  
 BEGIN  
  set @callerID = @CallerID  
  print 'the following Caller information was inserted:'  
  select * from Caller where CallerID = @callerID  
  select * from CallerCustomer where CallerID = @callerID--20259
  select * from CallerPhone where CallerID =@callerID
  select * from CustomerPhone where CustID = (select CustID  
  from CallerCustomer where CallerID = @callerID)  
  select * from CallerRestaurants where CallerID = @callerID  
  select * from Reservation where CallerID = @callerID  
  
  select * from customer where CallerID = @callerID  
  select * from PromoUse where CallerID = @callerID  
  select * from PointsAdjustment where CallerID = @callerID  
  select * from GiftRedemption where CallerID = @callerID  
 END  
  
COMMIT TRANSACTION  
  
if @Debug = 1  
 print 'TRANSACTION COMPLETE!'  
Return(0)  
  
  
NoSuchCustomer:  
 set @message = 'no Customer was found with the following email address: ' + @CustomerEmail  
 Raiserror(@message,16,1)  
 Return(1)  
   
  
CallerExists:  
 set @message = 'Caller already exists with that loginName email address: ' + @CustomerEmail  
 Raiserror(@message,16,1)  
 Return(1)  
  
  
Error:  
 Rollback Transaction  
 set @message = 'There was an Error while making the following Customer an AAUser: ' + @CustomerEmail  
 Raiserror(@message,16,1)  
 Return(2)  
  
  
GO

GRANT EXECUTE ON [DNChangeRealCustomerToAAUser] TO ExecuteOnlyRole

GO
