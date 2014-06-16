if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TopTen_TopTenListType_Get]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[TopTen_TopTenListType_Get]
GO


CREATE PROCEDURE [dbo].[TopTen_TopTenListType_Get]
(
    @TopTenListTypeID int = NULL --optional
)
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

Select 
			TTLT.TopTenListTypeID,
			TTLT.ListName,
			TTLT.ListDisplayOrderNationalOverride,
			TTLT.TopTenListTypeClassID,
            TTLTC.TopTenListTypeClassName,
			REPLACE(TTLT.ListDisplayOrderNationalOverride,0,99) As ListDisplayOrderNationalOverride_Sort
from		[dbo].[TopTenListType] TTLT
            join [dbo].[TopTenListTypeClass] TTLTC on TTLT.TopTenListTypeClassID = TTLTC.TopTenListTypeClassID
where       TopTenListTypeID = ISNULL(@TopTenListTypeID, TopTenListTypeID)
and         TTLT.TopTenListTypeClassID != 4 -- exclude regional list type
order by	ListDisplayOrderNationalOverride_Sort ASC, TTLT.TopTenListTypeClassID ASC, TTLT.ListName ASC

GO

GRANT EXECUTE ON [dbo].[TopTen_TopTenListType_Get] TO ExecuteOnlyRole

GO

