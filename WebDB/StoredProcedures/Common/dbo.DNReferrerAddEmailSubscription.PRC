if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNReferrerAddEmailSubscription]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNReferrerAddEmailSubscription]
GO

CREATE PROCEDURE dbo.DNReferrerAddEmailSubscription
(
    @ReferrerID int,
    @UserID INT,
    @IsAdmin bit
)
AS

  BEGIN  
	  IF (@IsAdmin = 1)  
  		 If Exists(Select 1 From ReferrerCustomerEmail Where CallerID = @UserID And ReferrerID = @ReferrerID)
			RETURN(1)
		 ELSE
			Insert Into ReferrerCustomerEmail (CallerID,ReferrerID,LastUpdated)
			Values(@UserID,@ReferrerID,getDate())
	  ELSE  
		If Exists(Select 1 From ReferrerCustomerEmail Where CustID = @UserID And ReferrerID = @ReferrerID)
			RETURN(2)   
		ELSE
			Insert Into ReferrerCustomerEmail (CustID,ReferrerID,LastUpdated)
			Values(@UserID,@ReferrerID,getDate())		
  END
GO

GRANT EXECUTE ON [DNReferrerAddEmailSubscription] TO ExecuteOnlyRole

GO
