
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Get_Reso_Info]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Get_Reso_Info]
GO


CREATE Procedure dbo.Admin_Get_Reso_Info
 (
  @RID int,
  @ConfNumber nvarchar(20)
 )
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


select		ResID, 
		CallerID, 
		CustID 
from 		reservation
where 		rid = @RID
and 		confNumber = @ConfNumber
GO


GRANT  EXECUTE  ON [dbo].[Admin_Get_Reso_Info]  TO [ExecuteOnlyRole]
GO

