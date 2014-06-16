if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Report_RestaurantMessages]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Report_RestaurantMessages]
GO

CREATE PROCEDURE dbo.Report_RestaurantMessages

As

SET NOCOUNT ON
set transaction isolation level read uncommitted

Select 
			 rm.RID
			,r.RName
			,rm.RMDesc
			,rm.ParkingDescription
			,rm.PrivatePartyDescription
			,rcm.Message 'ConfirmationMessage'
			,rm.BanquetDescription
			,rcm2.Message 'LargeMessage'
from		 RestaurantVW r
inner join	 RestaurantMessageAVW rm
on			 rm.RID = r.RID
and			 rm.LanguageID = r.LanguageID
inner join	 neighborhood n
on			 r.NeighborhoodID = n.NeighborhoodID
left join    RestaurantCustomMessage rcm
on           rcm.RID = r.RID
and			 rcm.LanguageID = r.LanguageID
and          rcm.MessageTypeID = 10 
left join    RestaurantCustomMessage rcm2
on           rcm2.RID = r.RID
and			 rcm2.LanguageID = r.LanguageID
and          rcm2.MessageTypeID = 12
where		 RestStateID = 1
and			 MetroAreaID <> 1

GO

GRANT EXECUTE ON [Report_RestaurantMessages] TO ExecuteOnlyRole

GO
