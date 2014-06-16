if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FailedResoLog]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[FailedResoLog]
GO







CREATE PROCEDURE dbo.FailedResoLog
(
@UserID int
,@RestaurantID int
,@ResDateTime nvarchar(255)
,@PartySize int
,@PartnerID int
,@BrowserVersion nvarchar(255)
,@AllHttp nvarchar(255)
,@Cookie nvarchar(255)
,@Description nvarchar(255)
)
AS
/*created 9-11-2002,the original must've gotten lost and it was not noticed missing
 because of 'On Error ResumeNext' statement in asp code...*/
 /* call from middle tier logFailedReso method

	m_dbh.RunSP "FailedResoLog",_
        mp("@UserID",adInteger,4,UserID),_
        mp("@RestaurantID",adInteger,4,RestaurantID),_
        mp("@ResDateTime",adVarChar,255,ResDateTime),_
        mp("@PartySize",adInteger,4,PartySize),_
        mp("@PartnerID",adInteger,4,PartnerID),_
        mp("@BrowserVersion",adVarChar,255,BrowserVersion),_
        mp("@AllHttp",adVarChar,255,AllHttp),_
        mp("@Cookie",adVarChar,255,Cookie),_
        mp("@Description",adVarChar,255,Description)
*/

Insert into LogFailedResos (userid,RID,ResDateTime,PartySize,PartnerID,
  BrowserVersion,AllHttp,CookieInfo,ErrDescription) values
(@UserID,@RestaurantID,cast(@ResDateTime as datetime),@PartySize,@PartnerID,@BrowserVersion,@AllHttp,@Cookie,@Description)
GO

GRANT EXECUTE ON [FailedResoLog] TO ExecuteOnlyRole

GO
