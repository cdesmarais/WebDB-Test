if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheCuisineMacroToMicroMapping]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheCuisineMacroToMicroMapping]
GO

CREATE PROCEDURE dbo.DNCacheCuisineMacroToMicroMapping

AS

set transaction isolation level read uncommitted

select	distinct 
		fsm.SearchFoodTypeID as MacroCuisineID 
		,dbo.fGetMicroCuisineListByMacroCuisine(fsm.SearchFoodTypeID) as MicroCuisineList
from		FoodTypeSearchMap fsm
inner join	FoodType ft
on			fsm.foodtypeid = ft.foodtypeid
inner join	dbo.DBUserDistinctLanguageVW db 
on			db.languageid = ft.LanguageID

GO

GRANT EXECUTE ON [DNCacheCuisineMacroToMicroMapping] TO ExecuteOnlyRole

GO