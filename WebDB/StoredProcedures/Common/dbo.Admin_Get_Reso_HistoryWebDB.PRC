
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Get_Reso_HistoryWebDB]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Get_Reso_HistoryWebDB]
GO


CREATE Procedure dbo.Admin_Get_Reso_HistoryWebDB
 (
  @RID int,
  @ConfNumber nvarchar(20)
 )
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

--This proc works in conjunction with another proc in WebLogDB named Admin_Get_Reso_HistoryWebLogDB. So any changes made to this proc should also be done in the other one.

Select 		WLogType, 
		Status,
		FuncEntryPt as MessageFrom, 
		CreateDt, 
		WlogMsgIn.Msg as Msg, 
		WlogMsgOut.Msg as OutMsg

from 		WLogVW WL

left outer join 	WLogMsgVW WlogMsgIn on WL.inWlogMsgID = WlogMsgIn.WlogMsgID
left outer join 	WLogMsgVW WlogMsgOut on WL.outWlogMsgID = WlogMsgOut.WlogMsgID

where 		WL.confnumber = @ConfNumber and WL.rid = @RID

order by 	CreateDt asc
GO


GRANT  EXECUTE  ON [dbo].[Admin_Get_Reso_HistoryWebDB]  TO [ExecuteOnlyRole]
GO

