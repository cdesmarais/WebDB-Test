

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OTR_FoodType_ListByRestaurant]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[OTR_FoodType_ListByRestaurant]
GO

create procedure dbo.OTR_FoodType_ListByRestaurant
(
	@RestaurantID int
	,@LanguageID int
	,@IsProfileExists tinyint
)
as
set nocount on
set transaction isolation level read uncommitted

	/* 
		This SP is used to food type list by restaurnt as per given language id
		Content owned by India team, please notify asaxena@opentable.com if changing.
	*/
	
	/* If restaurant profile exists then get select food type as per the restaurant selection... 
	*/
	if (@IsProfileExists = 1 )
	begin
		/*	This section logic is same as Admin_FoodType_ListByRestaurant stored procedure */
		select     
			fts.foodtypeID as FoodTypeID
			,fts.IsPrimary as IsPrimary
			,ft.FoodType
			,@LanguageID as LanguageID
		from       
			FoodTypes fts
			inner join FoodType ft
			on  fts.foodtypeID  = ft.foodtypeID
			
		where     
			(fts.RID = @RestaurantID)
			and LanguageID = @LanguageID
			
		order by 
			fts.FTRank
	end
	else
	/*	This section logic is same as Admin_Restaurant_CloneToLanguage */
	begin	
			/* If Restaurant profile does not exists and selected lang is Mexico, 
				we have to take existing food types and add 600 */
			if @LanguageID = 6 
			begin
				select
					(fts.foodtypeid + 600) as FoodTypeID
					,isprimary as IsPrimary
					,ft.FoodType
					,@LanguageID as LanguageID
				from     
					[foodtypes] fts
					inner join FoodType ft
					on  fts.foodtypeID  = ft.foodtypeID
					
				where 
						rid = @RestaurantID 
						and fts.foodtypeid  < 100
				order by 
						fts.FTRank
			end
			/* Get first primary food type in case of language other than Mexico. */
			else
			begin
				select top 1
					[foodtype].[foodtypeid] as FoodTypeID
					,CAST(1 as bit)  as IsPrimary
					,FoodType
					,@LanguageID as LanguageID
				from     
					FoodType
					inner join FoodTypeSearchMap
					on foodtype.foodtypeid = foodtypesearchmap.foodtypeid
					and foodtype.foodtypeid = foodtypesearchmap.searchfoodtypeid
				where
					languageid = @LanguageID
			end
	end

go

grant execute on [OTR_FoodType_ListByRestaurant] to ExecuteOnlyRole

go


