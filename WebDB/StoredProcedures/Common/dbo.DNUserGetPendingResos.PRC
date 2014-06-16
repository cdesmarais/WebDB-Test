if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNUserGetPendingResos]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNUserGetPendingResos]
GO



CREATE Procedure dbo.DNUserGetPendingResos
 (
  @UserID int
, @IsCaller int=0
 )
As

SET NOCOUNT ON
set transaction isolation level read uncommitted
if @IsCaller = 0
BEGIN
	Select	rname, 
			RStateID,
			ShiftDate + 2 + ResTime AS ResDateTime,
			partysize 
	from		Reservation res
	inner join	RestaurantLocal r  -- Use Local table becuase no references are made to parent table
	on			r.RID = res.RID
	and			r.LanguageID = res.LanguageID
	where	custID = @UserID 
	and		RStateID = 1
END
else
BEGIN
	Select	rname,
			RStateID,
			ShiftDate + 2 + ResTime AS ResDateTime,
			partysize 
	from		Reservation res
	inner join	RestaurantLocal r  -- Use Local table becuase no references are made to parent table
	on			r.RID = res.RID
	and			r.LanguageID = res.LanguageID
	where	CallerID = @UserID 
	and		RStateID = 1
END
GO


GRANT EXECUTE ON [DNUserGetPendingResos] TO ExecuteOnlyRole

GO
