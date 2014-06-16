
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobSelectROMSRestaurantGroup]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobSelectROMSRestaurantGroup]
GO

create Procedure [dbo].[JobSelectROMSRestaurantGroup]  
as  
/******************************************************************************  
Procedure select data from a GOD_RestToGroupAssoc and populates table ROMSRestaurantGroup  
This sets up the group relationships between GID and RID and GroupName  
Note: Procedure modified to removed the Link Server Dependency by creating new table
GOD_RestToGroupAssoc. This new table data will be populated by PJR job.
******************************************************************************/  
  
SET NOCOUNT ON  
  
declare @ErrorMsg as nvarchar(1000)  
declare @WEBDBgroupMembercount as int  
declare @ROMSgroupMembercount as int  
set @WEBDBgroupMemberCount=0  
set @ROMSgroupMembercount=0  
  
SET TRAN ISOLATION LEVEL READ UNCOMMITTED  
  
 SET IMPLICIT_TRANSACTIONS OFF  
  
 Truncate table ROMSrestaurantgroup  
 Set @ErrorMsg = 'Failed to truncate ROMSrestaurantgroup'  
 if @@ERROR <> 0  
  goto error  
  
 Insert into ROMSrestaurantGroup  
 Select r.RID, GID, GroupName   
 from dbo.[GOD_RestToGroupAssoc] OTRG  
 inner join Restaurant R  
 on OTRG.RID = R.RID  
  
 Set @ErrorMsg = 'Failed to Insert ROMSrestaurantgroup'  
 if @@ERROR <> 0  
  goto error  
  
 select @WEBDBgroupMemberCount=count(*) from ROMSRestaurantGroup  
  select @ROMSgroupMembercount =count(*) from dbo.[GOD_RestToGroupAssoc] OTRG
 inner join Restaurant R  
 on OTRG.RID = R.RID  
  
 --We currently have 3000 + rows for RestaurantGroup table,   
 -- This count should not be less then 2000  
 if  @WEBDBgroupMemberCount<>@ROMSgroupMembercount   
 goto error  
  
 Set @ErrorMsg = 'ROMSrestaurantgroup count does not match ROMS!'  
 if @@ERROR <> 0  
  goto error  
  
  
 --If all is well...  
 Return(0)  
  
error:  
 exec DNErrorAdd 88, 'JobSelectROMSRestaurantGroup', @ErrorMsg, 1  
 raisError ('throw error',15, 1)  
GO

GRANT EXECUTE ON [JobSelectROMSRestaurantGroup] TO ExecuteOnlyRole
GO

