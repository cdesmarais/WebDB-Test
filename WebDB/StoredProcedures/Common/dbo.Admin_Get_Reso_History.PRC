

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Get_Reso_History]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Get_Reso_History]
GO



CREATE Procedure dbo.Admin_Get_Reso_History
 (
  @RID int,
  @ConfNumber nvarchar(20)
 )
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

declare @ResID int
declare @CallerID int
declare @CustID int

select @ResID = ResID, 
		@CallerID = CallerID, 
		@CustID = CustID 
from reservation
where rid = @RID
and confNumber = @ConfNumber


Select 
	WLogType, 
	Status,
	FuncEntryPt as MessageFrom, 
	CreateDt, 
	WlogMsgIn.Msg as Msg, 
	WlogMsgOut.Msg as OutMsg, 
	@ResID ResID, 
	@CallerID CallerID, 
	@CustID CustID 
from WLogVW WL
left outer join WLogMsgVW WlogMsgIn on WL.inWlogMsgID = WlogMsgIn.WlogMsgID
left outer join WLogMsgVW WlogMsgOut on WL.outWlogMsgID = WlogMsgOut.WlogMsgID
where WL.confnumber = @ConfNumber and WL.rid = @RID
order by CreateDt asc
GO



GRANT EXECUTE ON [Admin_Get_Reso_History] TO ExecuteOnlyRole

GO
