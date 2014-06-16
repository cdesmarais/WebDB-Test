if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TopTen_TopTenListType_Update]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[TopTen_TopTenListType_Update]
GO


CREATE PROCEDURE [dbo].[TopTen_TopTenListType_Update]
(
    @TopTenListTypeID int,    
    @ListDisplayOrderNationalOverride int    
)
As

update  [dbo].[TopTenListType]
set     ListDisplayOrderNationalOverride = @ListDisplayOrderNationalOverride    
where   TopTenListTypeID = @TopTenListTypeID

GO

GRANT EXECUTE ON [dbo].[TopTen_TopTenListType_Update] TO ExecuteOnlyRole

GO

