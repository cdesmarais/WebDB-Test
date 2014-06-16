if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Feature_Toggle]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Feature_Toggle]
GO

CREATE Procedure dbo.Feature_Toggle
 (
  @LType nvarchar(50),
  @LKey nvarchar(60),
  @ValueInt int
 )
As

update 	ValueLookup 
set 	ValueInt = @ValueInt 
where 	LType = @LType 
and 	LKey = @LKey

GO

GRANT EXECUTE ON [Feature_Toggle] TO ExecuteOnlyRole

GO
