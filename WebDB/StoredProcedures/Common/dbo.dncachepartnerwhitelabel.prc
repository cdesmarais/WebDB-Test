if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCachePartnerWhitelabel]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].DNCachePartnerWhitelabel
GO

create procedure dbo.DNCachePartnerWhitelabel  
As  
  
SET NOCOUNT ON  
  
select   
 pwl.partnerid,   
 pwl.PartnerEmailImageURL,  
 pwl.partnercancelurl,  
 pwl.PartnerCompanyInfo,   
 pwl.PartnerPhoneNumber,   
 pwl.partnerfromemail,  
 pwl.partnerfromdisplayname,   
 p.partnername,  
 pwl.PartnerNoShowPhoneNumber,
 pwl.CustomConfirmationNumber,
 pwl.Advert1,
 pwl.Advert2,
 pwl.Advert3
from PartnerWhiteLabel pwl  
 inner join partner p   
   on p.partnerid = pwl.partnerid  

GO

GRANT EXECUTE ON DNCachePartnerWhitelabel TO ExecuteOnlyRole

GO
