if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OTR_CoversGetIncrReservationDetails]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[OTR_CoversGetIncrReservationDetails]
GO


-- Get detail reso details for restaurants, using RID..  
Create  procedure [dbo].[OTR_CoversGetIncrReservationDetails]   
(  
 @theRIDList varchar(1000),  
 @theStartDate DateTime,  
 @theEndDate DateTime,  
 @thePageNumber int  ,
 @theMaxShiftDate DateTime
)  
as  
declare @startRow INT  
declare @endRow INT  
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
-- Get batch of 1000 records  
set @startRow = @thePageNumber * 1000 + 1;  
set @endRow = (@thePageNumber + 1) * 1000; 
   
 with OrderedCovers AS  
( 
SELECT 
 ROW_NUMBER() OVER (ORDER BY r.Shiftdate asc, r.Shiftdatetime asc, r.ResID) AS RowNumber,     
 r.rname collate DATABASE_DEFAULT as 'RestaurantName',  
 Day(r.Shiftdate) as [Day],
 r.Shiftdate as ShiftDate,   
 r.Shiftdatetime AS ResTime,  
 (coalesce(nullif(lower(nullif(ud.SLName,'')),'none'),ud.FName) + ' ' + 
  coalesce(nullif(lower(nullif(ud.SFName,'')),'none'),ud.LName)) collate DATABASE_DEFAULT as DinerName,
 r.PartySize as SeatedSize,  
 r.PartnerID as PartnerID,  
 isnull(r.ReferrerID,0) as ReferrerID ,  
 r.BillingType collate DATABASE_DEFAULT as CoverType, 
  case when CAST(r.RStateID as smallint) = 1 then 'Pending'  
     else 'Seated'
 end as Status 
FROM ReservationVW r  
inner join UserDinerVW ud   
on ud.CustID = r.CustID    
 inner join   
fIDStrToTab(@theRIDList,',') tempTable  
 on r.RID = tempTable.Id   
WHERE r.Shiftdate >=  @theMaxShiftDate
and
	r.Shiftdate between @theStartDate and  @theEndDate
and 
	r.RStateID in (1,2,5,6,7)
)  
select *   
 from OrderedCovers  
 where RowNumber between @startRow and @endRow; 
 
  GO
GRANT EXECUTE ON [OTR_CoversGetIncrReservationDetails] TO ExecuteOnlyRole
GO
