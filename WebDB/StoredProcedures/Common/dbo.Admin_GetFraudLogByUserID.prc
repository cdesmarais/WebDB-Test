if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_GetFraudLogByUserID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_GetFraudLogByUserID]
GO

CREATE PROCEDURE dbo.Admin_GetFraudLogByUserID(
@UserID int,
@IsCaller bit
)

AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

--Fetch all fraud log info on the user.
if @IsCaller = 0
	(
	select			fs.FraudStatusDescription LogDescription,
					fcl.CreateDT LogDate,
					fcl.ChangedBy LogChangedBy
	from			FraudChangeLog fcl
	inner join		FraudStatus fs
	on				fcl.FraudStatusID = fs.FraudStatusID
	where			fcl.CustID = @UserID
	)
	union all
	(
	select			'Active' LogDescription,
					c.CreateDate LogDate,
					'System' LogChangedBy
	from			Customer c
	where			c.CustID = @UserID			
	)
	order by LogDate desc

else
	(
	select			fs.FraudStatusDescription LogDescription,
					fcl.CreateDT LogDate,
					fcl.ChangedBy LogChangedBy
	from			FraudChangeLog fcl
	inner join		FraudStatus fs
	on				fcl.FraudStatusID = fs.FraudStatusID
	where			fcl.CallerID = @UserID
	)
	union all
	(
	select			'Active' LogDescription,
					c.CreateDate LogDate,
					'System' LogChangedBy
	from			Caller c
	where			c.CallerID = @UserID			
	)
return 0

GO


GRANT EXECUTE ON [Admin_GetFraudLogByUserID] TO ExecuteOnlyRole

GO

