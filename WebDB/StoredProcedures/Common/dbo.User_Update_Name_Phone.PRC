if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[User_Update_Name_Phone]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[User_Update_Name_Phone]
GO

CREATE PROCEDURE dbo.User_Update_Name_Phone
@UserID			int,
@isCaller		int,
@First_Name		nvarchar(255),
@Last_Name		nvarchar(255),
@Phone			nvarchar(255),
@DefaultGeoID		int,
@SendAnnouncements	int = 1

AS

--**************************************************************************************
--** Begin OBOSLETE LOG
--** The following will log the fact that this obsolete proc was exectured into LogDB..ErrorLog
--** This snippet can be cut and pasted in to any block of code that is thought to be obsolete
-- ** Embedded for WR9 2010
--**************************************************************************************
	declare @_ErrorMessage nvarchar(1000)
	set @_ErrorMessage = 'PROC called'

	declare @_objName nvarchar(1000)
	SELECT	@_objName = OBJECT_NAME(@@PROCID), 
			@_ErrorMessage = @_ErrorMessage 
							+ ': '+ @_objName
							+ '  by host: ' + rtrim(isnull(hostname, 'unknown'))
							+ '  User: ' + rtrim(isnull(loginame, 'unknown'))
	FROM	sys.sysprocesses 
	WHERE	spid = @@spid  
	exec procLogProcedureError 9, @_objName, 'OBSOLETE', @_ErrorMessage
--**************************************************************************************
--** End OBOSLETE LOG
--**************************************************************************************

if @isCaller = 1
BEGIN
UPDATE Caller
SET FName = @First_Name,
	LName = @Last_Name,
	metroareaid = @DefaultGeoID,
	SendAnnouncements = @SendAnnouncements
WHERE CallerID = @UserID

Update CallerPhone 
set Phone = @Phone 
where CallerID = @UserID
AND IsPrimary = 1

UPDATE UserOptin
	SET Insider = @SendAnnouncements, DinersChoice= @SendAnnouncements, NewHot= @SendAnnouncements, RestaurantWeek= @SendAnnouncements, Promotional= @SendAnnouncements, SpotLight= @SendAnnouncements,Product= @SendAnnouncements,UpdatedDtUTC= getutcdate()
WHERE CallerID = @UserID
AND MetroAreaID = @DefaultGeoID

END
else
BEGIN

UPDATE Customer
SET FName = @First_Name,
	LName = @Last_Name,
	metroareaid = @DefaultGeoID,
	SendAnnouncements = @SendAnnouncements
WHERE CustID = @UserID

Update CustomerPhone 
set    Phone = @Phone 
where  CustID = @UserID 
AND IsPrimary = 1


UPDATE UserOptin
	SET Insider = @SendAnnouncements, DinersChoice= @SendAnnouncements, NewHot= @SendAnnouncements, RestaurantWeek= @SendAnnouncements, Promotional= @SendAnnouncements, SpotLight= @SendAnnouncements,Product= @SendAnnouncements,UpdatedDtUTC= getutcdate()
WHERE CustID = @UserID
AND MetroAreaID = @DefaultGeoID

END
GO

GRANT EXECUTE ON [User_Update_Name_Phone] TO ExecuteOnlyRole

GO
