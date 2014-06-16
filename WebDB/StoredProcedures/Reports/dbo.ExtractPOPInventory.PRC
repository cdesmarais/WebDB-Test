 if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ExtractPOPInventory]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
 drop procedure [dbo].[ExtractPOPInventory]
 GO

 CREATE PROCEDURE dbo.ExtractPOPInventory

 As

 set nocount on
 set transaction isolation level read uncommitted


 SELECT R.RID,
	   R.Rname as [Restaurant Name],
	   sum(Datediff(mi,i.StartTime,i.EndTime)/15) as [Total Slots]
 FROM IncentiveVW I
 INNER JOIN IncentiveRestaurantStatus IR
 ON I.RID = IR.RID
 INNER JOIN RestaurantVW r
 ON I.RID = R.RID
 WHERE I.Active = 1
 AND I.LastMinutePopThresholdTime IS NULL
 AND IR.Active = 1
 GROUP BY R.RID, R.Rname
 ORDER BY R.Rname

 GO

 GRANT EXECUTE ON [ExtractPOPInventory] TO ExecuteOnlyRole
 GRANT EXECUTE ON [ExtractPOPInventory] TO DTR_User
 GO
