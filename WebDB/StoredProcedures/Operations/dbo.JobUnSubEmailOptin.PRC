if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobUnSubEmailOptin]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobUnSubEmailOptin]
GO

CREATE PROCEDURE dbo.JobUnSubEmailOptin
As

Set Nocount on

--**************************************************************************************
--** DTS package called "Unsub Optin Email User"  is scheduled to run daily.  
--** This DTS package imports a text file that Marketing creates (used to be every quarter) 
--** on \\tron\shared\Engineering\OTReports\Marketing\Unsub 
--** File folder and is called OpenTable_unsub.txt.  Populates the UnsubEmails table in WebDB. 
--**************************************************************************************

/*
Declare @Debug bit
Set @Debug = 1

CREATE table ##Update_Progress  ( 
    UpdaetMESSAGE VARCHAR(500),
    UpdateTime DATETIME
)

if (@Debug = 1)
BEGIN
      INSERT INTO ##Update_Progress ( UpdaetMESSAGE, UpdateTime ) 
      VALUES ( 'Begin', GETDATE() ) 
END
*/
DECLARE @i int
DECLARE @Email nvarchar(255)
DECLARE @numrows int

-- enumerate the table 
SET @i = (SELECT Min(ID) FROM UnsubEmails )
SET @numrows = (SELECT MAX(ID) FROM UnsubEmails )
--SET @numrows = 10
/*
INSERT INTO ##Update_Progress ( UpdaetMESSAGE, UpdateTime ) 
VALUES ( CAST(@numrows AS VARCHAR(25)) + ' rows to process', GETDATE() ) 
*/
      
IF @numrows > 0
BEGIN
    WHILE @i <= @numrows
    BEGIN

        -- get the next Caller primary key
        SET @Email = (SELECT Email FROM UnsubEmails  WHERE ID = @i)
            
            declare @UserID  int
            set @UserID = null
            
            select @UserID = CustID 
            from Customer with (nolock)
            where Email = @Email 

            if (@UserID is not null)
            begin 
                  UPDATE Customer SET SendAnnouncements = 0, SendPromoEmail = 0 WHERE CustID =@UserID and (isnull(SendAnnouncements,0) = 1 or isnull(SendPromoEmail,0) = 1)
                  UPDATE UserOptIn
                        set Insider = 0, DinersChoice = 0,NewHot = 0,RestaurantWeek = 0,Promotional = 0, SpotLight = 0, Product = 0, UpdatedDtUTC = getutcdate()
                  where CustID =@UserID and (SpotLight <> 0 OR Insider <> 0 OR  DinersChoice <> 0 OR NewHot <> 0 OR RestaurantWeek <> 0 OR Promotional <> 0 OR Product <> 0)
            end else
            begin
                  select @UserID = CallerID 
                  from Caller with (nolock)
                  where LoginName = @Email
                  
                  if (@UserID is not null)
                  begin
                        UPDATE Caller SET SendAnnouncements = 0, SendPromoEmail = 0 WHERE CallerID =@UserID and (isnull(SendAnnouncements,0) = 1 or isnull(SendPromoEmail,0) = 1)               
                        update UserOptIn
                              set Insider = 0, DinersChoice = 0,NewHot = 0,RestaurantWeek = 0,Promotional = 0, SpotLight = 0, Product = 0, UpdatedDtUTC = getutcdate()
                        where CallerID =@UserID  and (SpotLight <> 0 OR Insider <> 0 OR  DinersChoice <> 0 OR NewHot <> 0 OR RestaurantWeek <> 0 OR Promotional <> 0 OR Product <> 0)
                  end
            end
                        
            /*
        IF (@i % 1000) = 0 and (@Debug = 1)
            BEGIN
                  INSERT INTO ##Update_Progress ( UpdaetMESSAGE, UpdateTime ) 
                  VALUES ( CAST(@i AS VARCHAR(25)) + ' complete', GETDATE() ) 
            END
            */
        
        -- increment counter for next Caller
        SET @i = @i + 1
        
    END
END
/*
if (@Debug = 1)
BEGIN
      INSERT INTO ##Update_Progress ( UpdaetMESSAGE, UpdateTime ) 
      VALUES ('Finished with ' +  CAST(@numrows AS VARCHAR(25)) + ' updated', GETDATE() ) 
      SELECT * FROM ##Update_Progress ORDER BY UpdateTime
END

DROP TABLE ##Update_Progress
*/


GO

GRANT EXECUTE ON [JobUnSubEmailOptin] TO ExecuteOnlyRole
GRANT EXECUTE ON [JobUnSubEmailOptin] TO DTR_User

GO
