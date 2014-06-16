if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNGetRestaurantPDRooms]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNGetRestaurantPDRooms]
GO

CREATE PROCEDURE dbo.DNGetRestaurantPDRooms
(
	@RID int
)

AS

SELECT rv.RID, 
      r.PrivatePartyPhone, 
      rv.PrivatePartyContact, 
      rv.PrivateDiningMenu, 
      rv.PrivatePartyEmail, 
      rv.LargestCapacity, 
	  rv.EnablePrivateDining,
	  rv.publishprivatedining,
	  (SELECT top 1 Message FROM dbo.[RestaurantCustomMessage] rc WHERE rc.rid = rv.rid AND rc.[MessageTypeID] = 54 and rc.LanguageID = rv.LanguageID) AS PartyShortDesc,
      (SELECT top 1 Message FROM dbo.[RestaurantCustomMessage] rc WHERE rc.rid = rv.rid AND rc.[MessageTypeID] = 59 and rc.LanguageID = rv.LanguageID) AS PartyLongDesc,
      RoomName, 
      RoomDescription, 
      SeatedSize, 
      StandingSize, 
      rr.ImageName, 
      ListingOrder, 
      rr.active,
	  ri.PrivateDiningThumbnail,
	  rv.HasPrivateParty,
	  pdul.ApprovedDTUTC,
	  pdul.ApprovedBy,
	  pdn.PhoneNumber AS [TrackedPhone]
FROM dbo.[RestaurantVW] rv
INNER JOIN dbo.[Restaurant] r
	ON 	rv.RID = r.RID
LEFT JOIN dbo.[CallProviderPrivateDiningNumberVW] pdn
	ON  r.RID = pdn.RID  
LEFT OUTER JOIN dbo.[RestaurantRooms] rr
	ON rv.[RID] = rr.[RID]
LEFT OUTER JOIN dbo.[RestaurantImage] ri 
	ON rv.RID = ri.rid
LEFT OUTER JOIN
	(
		select
			top 1 
			RID
			,ApprovedBy
			,ApprovedDTUTC
		from 
			PrivateDiningUpdateLog
		where
			ApprovedBy is not null
		and
			ApprovedDTUTC is not null
		order by 
			ApprovedDTUTC desc
	) pdul
	ON rv.RID = pdul.RID
where rv.rid = @rid order by ListingOrder

GO

GRANT EXECUTE ON [DNGetRestaurantPDRooms] TO ExecuteOnlyRole
GO
