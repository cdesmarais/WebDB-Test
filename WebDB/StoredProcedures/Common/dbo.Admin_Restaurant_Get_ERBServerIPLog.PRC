if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_Get_ERBServerIPLog]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_Get_ERBServerIPLog]
GO
Create procedure dbo.Admin_Restaurant_Get_ERBServerIPLog
(
	@RID int
)
As

SELECT ServerIP,
	   StartDt, 
	   EndDt
FROM   RestERBServerIPLog
WHERE  RID = @RID
Order by EndDt desc

Go


GRANT EXECUTE ON [Admin_Restaurant_Get_ERBServerIPLog] TO ExecuteOnlyRole


GO


