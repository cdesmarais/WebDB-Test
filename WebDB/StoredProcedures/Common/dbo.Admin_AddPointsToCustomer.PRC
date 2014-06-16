if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_AddPointsToCustomer]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_AddPointsToCustomer]
GO





CREATE PROCEDURE dbo.Admin_AddPointsToCustomer 
  @CustomerID int=0,
  @IsCaller int=0,
  @Points int,
  @Reason int,
  @CharmUserID int = null,
  @CharmUserEmail varchar(50) = null,
  @SourceIPAddress varchar(25) = null,
  @AdjusterOtherReason varchar(100) = null

AS 

/**************************************************************
Purpose : Add Points in Customer/Caller account and log entries
		  in pointsadjustment table for audit.
***************************************************************/
Declare @ConsumerType int 

--Check to see if user can get points if @isCaller = 0 
begin   
	select @ConsumerType = ConsumerType from Customer where CustID=@CustomerID   
end   
if @IsCaller > 0 
begin   
	select @ConsumerType = ConsumerType from Caller where CallerID=@CustomerID   
end   

if @IsCaller = 0 and @ConsumerType <> 8   
begin   
	-- update Customer points.
	update Customer   
	set Points = Points + @points   
	where CustID=@CustomerID   

	-- insert entry in log table for point adjustment.
	insert into PointsAdjustment(
		CustID,
		AdjustmentAmount,
		AdjReasonID,
		AdjusterCharmUserId,
		AdjusterCharmUserEmail,
		SourceIPAddress,
		AdjusterOtherReason,
		SysUser,
		Host
	)values(
		@CustomerID,
		@points,
		@Reason,
		@CharmUserID,
		@CharmUserEmail,
		@SourceIPAddress,
		@AdjusterOtherReason,
		system_user,
		Host_Name()
	)   
	return(0)   
end   
if @IsCaller > 0 and @ConsumerType <> 8   
begin 
	-- update Caller points.  
	update Caller   
	set Points = Points + @points   
	where CallerID=@CustomerID   

	-- insert entry in log table for point adjustment.
	insert into PointsAdjustment(
		CallerID,
		AdjustmentAmount,
		AdjReasonID,
		AdjusterCharmUserId,
		AdjusterCharmUserEmail,
		SourceIPAddress,
		AdjusterOtherReason,
		SysUser,
		Host
	)values(
		@CustomerID,
		@points,
		@Reason,
		@CharmUserID,
		@CharmUserEmail,
		@SourceIPAddress,
		@AdjusterOtherReason,
		system_user,
		Host_Name()
	)   
	return(1)   
end  

GO

GRANT EXECUTE ON [Admin_AddPointsToCustomer] TO ExecuteOnlyRole
GO
