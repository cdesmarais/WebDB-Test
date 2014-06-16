if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Restaurant_BuildAllEmailSubscriptionUpdateInfo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Restaurant_BuildAllEmailSubscriptionUpdateInfo]
GO


CREATE Procedure dbo.Restaurant_BuildAllEmailSubscriptionUpdateInfo

As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[EmailSubscriptionUpdates]') and OBJECTPROPERTY(id,N'IsUserTable') = 1)
	truncate table EmailSubscriptionUpdates
else
	BEGIN
		CREATE TABLE [dbo].[EmailSubscriptionUpdates] (
			[RestaurantID] [int] NOT NULL ,
			[NetAddress] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
			[Pwd] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
			[EmailList] [nvarchar] (999) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
			[Send] [int] NOT NULL ,
			[UpdateError] [bit] NOT NULL 
		) ON [PRIMARY]
	END
/*must be created here if it doesn't exist ... before cursor creation!*/
if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Restaurant_EmailSubscriptionNotification]') and OBJECTPROPERTY(id,N'IsUserTable') = 1)
	BEGIN
		create table dbo.Restaurant_EmailSubscriptionNotification
		(RID int not null Primary key references Restaurant (RID),
		 LastSubNotification datetime not null,
		 LastUnsubNotification datetime not null)
	END

declare @pingtimeoffset int /*FIXME: set this to less when our ping is more stable???*/
set @pingtimeoffset = 3
declare @RestaurantID int,@NetAddress nvarchar(255),@Password nvarchar(255)

DECLARE EmailUpdateListCursor CURSOR 
LOCAL   FAST_FORWARD 
FOR 

SELECT    r.RID AS Restaurant_ID
	,ERBRestaurant.ServerIP AS NetAddress
    	,ERBRestaurant.serverPwd AS Password 
    --,ERBRestaurant.LastTimeContacted AS LastTimeContacted
FROM Restaurant r INNER JOIN
    ERBRestaurant ON 
    r.RID = ERBRestaurant.RID
WHERE (r.RestStateID = 1) and r.Allotment <> 1
	and (r.IsReachable = 1)
	/*ie. don't waste our time trying to unsubscribe customers at unreachable restaurants...*/
	and ERBRestaurant.ProductID >= 6 /*only OT40 and Parity listeners support this functionality*/
	


OPEN EmailUpdateListCursor

FETCH NEXT FROM EmailUpdateListCursor 
	INTO @RestaurantID,@NetAddress,@Password

WHILE @@FETCH_STATUS = 0
	BEGIN
	  
	/*this sproc will build all update information for r...*/
	
	exec dbo.Restaurant_BuildSubscriptionUpdateInfo @RestaurantID,@NetAddress,@Password
	
	FETCH NEXT FROM EmailUpdateListCursor 
		INTO @RestaurantID,@NetAddress,@Password
	
	END

CLOSE EmailUpdateListCursor
DEALLOCATE EmailUpdateListCursor

select * from EmailSubscriptionUpdates
GO

GRANT EXECUTE ON [Restaurant_BuildAllEmailSubscriptionUpdateInfo] TO ExecuteOnlyRole

GO
