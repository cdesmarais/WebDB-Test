if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_GetProfileByID2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_GetProfileByID2]
GO

-- This proc is used by CHARM to pull data         
-- required to render content on the Restaurant Add/Edit pages        
-- It is exclusively used by the new edit profile control.         
-- We will deprecate the other procs once this module has been live for some time        
-- This proc returns multiple recordsets        
create procedure [dbo].[Admin_Restaurant_GetProfileByID2]              
(              
  @RestaurantID  int = 0          
)              
              
as              
set nocount on              
set transaction isolation level read uncommitted              
        
-- get Confirmation Message Message ID        
declare @Confirmation int              
exec DNGetMessageTypeID 'Confirmation',@Confirmation output              
          
-- List of Master tables, master tables are tables containing data for dropdowns (e.g. Cuisine, Dining Stles...)        
        
-- Master List for Dining Style                  
exec Admin_DiningStyle_List                  
                  
--Master list of Price range                  
exec  Admin_AverageCheck_List @RestaurantID  
                  
--Master List of Payments                  
exec Admin_PaymentType_List                  
                  
--Master List for Dress Code                  
exec Admin_DressCode_List                  
                  
--Master List for Walkin Option                  
exec Admin_Walkin_List                  
                  
--Master List of Offers (0 is a bogus value for RID, causes proc to return ALL offers)                  
exec Admin_Offer_List 0        
                  
--Master List for Parking                  
exec Admin_Parking_List                  
         
-- Food Type / Cuisine              
exec Admin_FoodType_List            
              
-- Actual Values Pertaining to the restaurant        
select r.RID as RestaurantID,--0        
	r.RName as RestaurantName,--1        
	'1' as RestaurantUID,--2        
	r.RestaurantType as RestaurantType,--3        
	r.MinOnlineOptionID as MinOnlineOptionID,--4        
	r.ParkingID as ParkingID,--5        
	r.SmokingID as SmokingID,--6        
	DressCodeID as DressCodeID,--7        
	r.PriceQuartileID as PriceQuartileID,--8        
	r.CreditCardID as CreditCardID,--9        
	r.WOID as WalkinOptionID,--10        
	r.TZID as TimeZoneID,--11        
	r.neighborhoodid as NeighborhoodID,--13        
	r.MaxOnlineOptionID as MaxOnlineOptionID,--14        
	r.MinTipSizeOptionID as MinTipSizeOptionID,--15        
	r.MaxAdvanceOptionID as MaxAdvanceOptionID,--16        
	r.RestStateID as RestaurantStateID,--17        
	DiningStyleID as DiningStyleID,--18        
	r.createdate as CreateDate,--19              
	r.Address1 as Address1,--20              
	r.Address2 as Address2,--21              
	r.City as City,--22              
	r.State as State,--23             
	r.Zip as PostalCode,--24              
	r.Country as Country,--25              
	r.BanquetPhone as BanquetPhone,--26              
	r.Phone as BusinessPhone,--27              
	r.PrivatePartyPhone as PrivatePartyPhone,--28              
	r.ReservationPhone as ReservationPhone,--29              
	r.FaxPhone as FaxPhone,--30              
	r.UpdatePwd as UpdatePwd,--31              
	r.Chef as Chef,--32              
	r.Email as Email,--33              
	r.ExternalURL as ExternalURL,--34              
	r.ReserveCode as ReserveCode,--35              
	r.BanquetContact as BanquetContact,--36              
	r.CrossStreet as CrossStreet,--37              
	r.PrivatePartyContact as PrivatePartyContact,--38              
	r.HasBanquet as HasBanquet,--39              
	r.HasCatering as HasCatering,--40              
	r.HasPrivateParty as HasPrivateParty,--41              
	r.Longitude as Longitude,--42              
	r.LegacyID as LegacyID,--43              
	r.Latitude as Latitude,--44              
	rm.CaterDescription as CaterDescription,--45              
	rm.RMDesc as RestaurantMessage,--46              
	rm.Entertainment as Entertainment,--47              
	rm.ParkingDescription as ParkingDescription,--48              
	rm.PrivatePartyDescription as  PrivatePartyDescription,        
	coalesce(rcm.Message,       
	dbo.fGetRestaurantMessage(r.RID, @Confirmation)) as ConfirmationMessage,--50              
	rm.PublicTransit as PublicTransit,--51              
	rm.Hours as Hours,--52              
	rm.BanquetDescription  as BanquetDescription,--53              
	r.GiftCertificateCode as GiftCertificateCode,--54              
	r.HasGiftCertificate as HasGiftCertificate,--55              
	er.ServerIP as ERPServerIP,--56              
	er.serverPwd as ERPServerPwd,--57              
	er.ServerKey as ERPServerKey,--58              
	ltc.LTC as ERPLastTimeContacted,--59              
	2 as ERPVersion,--60              
	r.Allotment as Allotment,--61              
	r.Ping as IPPing,--62              
	er.ProductID as Product_ID,--63              
	coalesce(RestaurantNetvisit.NetvisitID,0) as NetvisitID, --64              
	rm.SpecialEvents as SpecialEvents,--65              
	r.MaxLargePartyID as MaxLargePartySize, -- 66               
	er.StaticIPAddress as IsStaticIP, -- 67              
	coalesce(Logo,'0') as RestaurantLogo, -- 68              
	coalesce(ImageName,'0') as RestaurantImage, -- 69              
	r.MenuURL, --70,              
	r.MappingAddress,--71              
	CONVERT(INT,r.MapAddrValid) as MapAddrValid,--72              
	c.MapLink, --73              
	r.rsname as RestaurantSName, --74              
	er.ERBLockFromROMS as ERBLockFromROMS --75
      
from RestaurantVW r          
  
inner join RestaurantMessageVW rm     
on r.RID = rm.RID    
and r.LanguageID = rm.LanguageID  
  
inner join ERBRestaurant er     
on r.RID = er.RID          
  
inner join LastTimeContacted ltc     
on r.RID = ltc.RID    
  
left join RestaurantNetvisit     
on r.RID = RestaurantNetvisit.RID          
  
left join RestaurantImage    
on r.RID = RestaurantImage.RID          
  
left join RestaurantCustomMessage rcm    
on r.RID = rcm.RID     
and r.LanguageID = rcm.LanguageID  
and rcm.MessageTypeID = @Confirmation          
  
left join CountryAVW c          
on   c.CountryID = r.Country  
and   c.LanguageID = r.LanguageID  
  
where r.RID = @RestaurantID        
              
--Payment List for Restaurant              
exec Admin_PaymentType_ListByRestaurant @RestaurantID              
              
--Offers List for Restaurant              
exec Admin_Offer_ListByRestaurant @RestaurantID              
            
-- Food Type for Restaurant               
exec Admin_FoodType_ListByRestaurant @RestaurantID        
        
-- Neighborhood Values    
exec Admin_Neighborhood_ListWithGeoName        
                  
--Country                  
exec Country_List    
                  
--State (the state change specific to country would be done at code level)                
exec State_List       
                  
 --Max party size                  
exec Admin_MaxOnlineOption_List        
              
-- Restaurant Status              
exec Admin_RestaurantState_List      
        
-- Max Advance Day Options              
exec Admin_MaxAdvanceOption_List           

GO

GRANT EXECUTE ON [Admin_Restaurant_GetProfileByID2] TO ExecuteOnlyRole
GO




