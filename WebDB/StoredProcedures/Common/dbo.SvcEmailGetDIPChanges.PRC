if exists (select * from dbo.sysobjects where ID = object_ID(N'[dbo].[SvcEmailGetDIPChanges]') and OBJECTPROPERTY(ID, N'IsProcedure') = 1)
drop procedure [dbo].[SvcEmailGetDIPChanges]
GO


CREATE PROCEDURE [dbo].[SvcEmailGetDIPChanges]
AS
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	select		 ih.IncHistID			'IncHistID'
				,ih.RID					'RID'
				,ih.CreateDate			'CreateDate'
				,ihs.Status				'Status'
				,ihs.IncHistStatusID	'IncHistStatusID'
				,ih.ChangedBy			'ChangedBy'
				,ih.NewDipSlots			'NewDipSlots'
				,ih.OldStartEndDates	'OldStartEndDates'
				,ih.NewStartEndDates	'NewStartEndDates'
				,ih.OriginalDipSlots	'OriginalDipSlots'
				,ih.EmailSentDate		'EmailSentDate'
				,r.RName				'RName'
				,ma.MetroAreaName		'RestaurantMetro'
				,case 
					when	(ma.ShortDisplayName is null or ma.ShortDisplayName = '')
						then	ma.MetroAreaName
					else		ma.ShortDisplayName
				end						'MetroShortName'
				,irs.StartDate			'StartDate'
				,irs.EndDate			'EndDate'
				,irs.ContractSignedBy	'ContractSignedBy'
				,ma.CountryID			'CountryID'
	from		IncentiveHistory ih
	inner join	IncentiveHistoryStatus ihs
	on			ihs.IncHistStatusID	= ih.IncHistStatusID
	inner join	RestaurantVW r
	on			r.RID				= ih.RID
	inner join	Neighborhood n
	on			n.NeighborhoodID	= r.NeighborhoodID
	inner join	MetroAreaAVW ma
	on			ma.MetroAreaID		= n.MetroAreaID
	and			ma.LanguageID		= r.LanguageID
	left join	IncentiveRestaurantStatus irs
	on			irs.RID				= ih.RID
	and			irs.Active			= 1
	where		ih.CreateDate		> getdate()-1
	and			ih.EmailSentDate	is null
GO


GRANT EXECUTE on [SvcEmailGetDIPChanges] TO ExecuteOnlyRole
GO
