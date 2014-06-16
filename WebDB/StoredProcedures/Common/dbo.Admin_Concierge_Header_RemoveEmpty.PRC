if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Concierge_Header_RemoveEmpty]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Concierge_Header_RemoveEmpty]
GO





CREATE Procedure dbo.Admin_Concierge_Header_RemoveEmpty
 (
  @Geo_ID int
 )
As
SET NOCOUNT ON


Delete CallerHeaders from CallerHeaders 
left outer join CallerHeaderLinks on CallerHeaders.HeaderID = CallerHeaderLinks.HeaderID 
where GeoID = @Geo_ID and LinkID is null




GO

GRANT EXECUTE ON [Admin_Concierge_Header_RemoveEmpty] TO ExecuteOnlyRole

GO
