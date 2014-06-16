if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_ManageDIPExclusionList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_ManageDIPExclusionList]
GO



-- Handle all updates/inserts to the DIP Promo exclusion list. This proc controls how 
-- restaurants can allow DIP specifically for certain shifts during a promo period when normally 
-- DIP slots are not provided
-- In a single call you can only set one or both the options(lunch/dinner) for a group of restaurants
CREATE PROCEDURE dbo.Admin_ManageDIPExclusionList
(	
	@PromoID int,
	@AllowDIPLunchList varchar(8000),		-- Comma Separated list of restauantID's that allow lunch DIP [EV: List of Int IDs]
	@AllowDIPDinnerList varchar(8000),		-- Comma Separated list of restauantID's that allow Dinner DIP [EV: List of Int IDs]
	@AllowDIPBothShiftsList varchar(8000),		-- Comma Separated list of restauantID's that allow DIP both shifts [EV: List of Int IDs]
	@ChangedBy nvarchar(100)
)
AS

declare @IsDIPSupressedForPromo int
declare @SuppressDIPLunch int
declare @SuppressDIPDinner int


-- find out if promo support DIP supression, if not then exclusion settings are meaningless
select @IsDIPSupressedForPromo=SuppressDIP from PromoPages p where p.promoid=@promoid

if @IsDIPSupressedForPromo = 1
BEGIN
	-- delete ANY older entries for this group of restaurants if they existed for this promo
	-- also delete any entries where both dinner/lunch are NOT supressed, this is the default anyhow! 
	delete from PromoDIPSupressExclusion 
	where promoid=@promoid 
	OR (SupressDIPLunch= 1 AND SupressDIPDinner=1)

	-- update the DIP lunch list..	
	if @AllowDIPLunchList <> '' 
		BEGIN
			-- allow DIP lunch slot..
			set @SuppressDIPLunch = 0
			set @SuppressDIPDinner = 1
			
			insert into PromoDIPSupressExclusion(PromoID,RID,SupressDIPLunch,SupressDIPDinner,ChangedBy)
				select	@PromoID,
						id, --RID
						@SuppressDIPLunch,
						@SuppressDIPDinner,
						@ChangedBy
				from fIDStrToTab(@AllowDIPLunchList, ',')
				

		END 

	-- update the DIP Dinner list..	
	if @AllowDIPDinnerList <> '' 
		BEGIN
			-- allow DIP lunch slot..
			set @SuppressDIPLunch = 1
			set @SuppressDIPDinner = 0

			insert into PromoDIPSupressExclusion(PromoID,RID,SupressDIPLunch,SupressDIPDinner,ChangedBy)
				select	@PromoID,
						id, --RID
						@SuppressDIPLunch,
						@SuppressDIPDinner,
						@ChangedBy
				from fIDStrToTab(@AllowDIPDinnerList, ',')
		END

	-- update the BOTH shifts supressed list..
	if @AllowDIPBothShiftsList <> ''
		BEGIN
			-- allow DIP lunch slot..
			set @SuppressDIPLunch = 0
			set @SuppressDIPDinner = 0

			insert into PromoDIPSupressExclusion(PromoID,RID,SupressDIPLunch,SupressDIPDinner,ChangedBy)
				select	@PromoID,
						id, --RID
						@SuppressDIPLunch,
						@SuppressDIPDinner,
						@ChangedBy
				from fIDStrToTab(@AllowDIPBothShiftsList, ',')

		END

END	
GO

GRANT EXECUTE ON [Admin_ManageDIPExclusionList] TO ExecuteOnlyRole

GO
