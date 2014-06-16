if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Restaurant_SetListenerVersion]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Restaurant_SetListenerVersion]
GO



CREATE PROCEDURE dbo.Restaurant_SetListenerVersion

(@RestaurantID int,
@TypeID int,
@Version nvarchar(255),
@ProductID int
)
AS
/*
create table [dbo].[ListenerVersions]
( RID int not null,
  Type_ID int not null,
  Version nvarchar (255),
  UpdateTime datetime not null default getdate())*/

INSERT INTO ListenerVersions (RID,TypeID,Version,ProductID,UpdateTime)
values(@RestaurantID,@TypeID,@Version,@ProductID,getdate())
GO

GRANT EXECUTE ON [Restaurant_SetListenerVersion] TO ExecuteOnlyRole

GO
