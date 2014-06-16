

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TopTen_GetRuleSetValueForAll]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[TopTen_GetRuleSetValueForAll]
go


/*
	The TopTen generator relies on this proc to convert -1 (which means ALL) to real ID's. E.g. if you want to generate
	a list for ALL metros, then you say -1 in the metroid column. THis proc is called to replace -1 with the real values. 
	Content owned by India team, please notify asaxena@opentable.com if changing.
*/

create procedure [dbo].[TopTen_GetRuleSetValueForAll] 
(
      @MetroIdList varchar(8000),
      @RegionIdList varchar(8000),
      @NbHoodIdList varchar(8000),
      @CuisineIdList varchar(8000),
	  @CountryCode varchar(100)
)
as

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

declare @MetroOutput as varchar(8000)  
declare @RegionOutput as varchar(8000)  
declare @NbHoodOutput as varchar(8000)  
declare @CuisineOutput as varchar(8000)  
  
declare @PrevMetroId as varchar(10)  
declare @PrevRegionId as varchar(10)  
declare @PrevNBHoodId as varchar(10)  
  
set @MetroOutput=''  
set @RegionOutput =''  
set @NbHoodOutput =''  
set @CuisineOutput = ''  
set @PrevMetroId=''  
set @PrevRegionId=''  
set @PrevNBHoodId = ''  
  
set @RegionIdList = replace (@RegionIdList,'#',',')  
set @NbHoodIdList = replace (@NbHoodIdList,'#',',')  
  
--Basic Implementation logic of this proc:-  
--We get metro, region and neighbourhood combination by applying joins over tables so data got in query is as --follows  
--M R N  
--1   40    793  
--1   40    1058  
--1   48    282  
--1   133   779  
--1   134   60  
  
-- In above example as we can see this proc iterates through every row ,while iterating it checks for certain conditions   
--such as MetroArea.MetroAreaID is equal to previos metroid or region id equals previous region id and goes on appending exact value  
-- to respective metro, region and neighbouhood output variables.  
  
if @MetroIdList is not null  
begin  
   
if len(@RegionIdList) <= 0   
      set @RegionIdList = null  
  
if len(@NbHoodIdList) <= 0  
      set @NbHoodIdList = null  
  
if len(@CuisineIdList) <= 0   
      set @CuisineIdList = null  
  
  
select @MetroOutput = @MetroOutput +  
-- get distinct metros as comma separated values so check if metro = previous metro value if equals then dont append metro   
-- if not then append that metro value with comma delimiter  
  
case when MetroArea.MetroAreaID <> @PrevMetroId then  
',' +  convert(varchar,MetroArea.MetroAreaID) else '' end,  
  
@RegionOutput = @RegionOutput + case  
  
-- if column metroid = previous metroid and region <> prev regionid and if input region list = -1 i.e get all regions  
-- then append that regionid to regionoutput with comma delimitter  
 when  MetroArea.MetroAreaID = @PrevMetroId and MacroNeighborhood.MacroID <> @PrevRegionId  and  charindex('-1',isnull(@RegionIdList, '-1'))= 1  then  
',' +  convert(varchar,MacroNeighborhood.MacroID)   
  
-- if column metroid <> previous metroid and if input region list = -1 i.e get all regions  
-- then append that regionid to regionoutput with "#" delimitter  
  
 when  MetroArea.MetroAreaID <> @PrevMetroId  and  charindex('-1',isnull(@RegionIdList, '-1'))= 1  then  
'#' +  convert(varchar,MacroNeighborhood.MacroID)  
  
-- if column metroid <> previous metroid and if input region list <> -1 i.e get only regions specified in regioninput list  
-- and if regionid is present in region input list then append that regionid to regionoutput with "#" delimitter  
  
when MetroArea.MetroAreaID <> @PrevMetroId  and (charindex(',' + cast( MacroNeighborhood.MacroID AS nvarchar) + ',', ',' + @RegionIdList + ',')>0 ) then  
'#' +  convert(varchar,MacroNeighborhood.MacroID)   
  
-- if column metroid = previous metroid and if input region list <> -1 i.e get only regions specified in regioninput list  
-- and if regionid is present in region input list then append that regionid to regionoutput with no comma delimitter   
-- bcoz regionoutput previous char is "#" delimiter so append only regionid without any delimiter.   
  
when MetroArea.MetroAreaID = @PrevMetroId and MacroNeighborhood.MacroID <> @PrevRegionId and (charindex(',' + cast( MacroNeighborhood.MacroID AS nvarchar) + ',', ',' + @RegionIdList + ',')>0 )  and charindex ('#',reverse(@RegionOutput))=1 then  
convert(varchar,MacroNeighborhood.MacroID)   
  
-- if column metroid = previous metroid and if input region list <> -1 i.e get only regions specified in regioninput list  
-- and if regionid is present in region input list then append that regionid to regionoutput with comma delimitter   
  
when MetroArea.MetroAreaID = @PrevMetroId and MacroNeighborhood.MacroID <> @PrevRegionId and (charindex(',' + cast( MacroNeighborhood.MacroID AS nvarchar) + ',', ',' + @RegionIdList + ',')>0 )  and charindex ('#',reverse(@RegionOutput))<>1 then  
',' +  convert(varchar,MacroNeighborhood.MacroID)   
  
-- if column metroid <> previous metroid and if input region list <> -1 i.e get only regions specified in regioninput list  
-- and if regionid is not present in region input list then append "#" delimiter with no regionid    
  
when MetroArea.MetroAreaID <> @PrevMetroId  and (charindex(',' + cast( MacroNeighborhood.MacroID AS nvarchar) + ',', ',' + @RegionIdList + ',')=0 ) then  
'#'  
  
-- or all other condition dont append anything.  
  
else   
''  
end,  
  
-- for neighbouhood all above conditions are repeated except that all checks are done against neighbourhood input values  
@NbHoodOutput = @NbHoodOutput + case  
  
when MetroArea.MetroAreaID = @PrevMetroId  and  charindex('-1',isnull(@NbHoodIdList, '-1'))= 1  then  
 ',' +  convert(varchar,NeighborhoodID)   
when MetroArea.MetroAreaID <> @PrevMetroId and  charindex('-1',isnull(@NbHoodIdList, '-1'))= 1 then  
 '#' +  convert(varchar,NeighborhoodID)   
when MetroArea.MetroAreaID <> @PrevMetroId  and   (charindex(',' + CAST( NeighborhoodID as nvarchar) + ',', ',' + @NbHoodIdList + ',')>0 )  then  
'#' +  convert(varchar,NeighborhoodID)   
when MetroArea.MetroAreaID = @PrevMetroId and  NeighborhoodID <>@PrevNBHoodId  and (charindex(',' + CAST( NeighborhoodID AS nvarchar) + ',', ',' + @NbHoodIdList + ',')>0 ) and charindex ('#',reverse(@NbHoodOutput))=1 then  
convert(varchar,NeighborhoodID)   
when MetroArea.MetroAreaID = @PrevMetroId and    NeighborhoodID <>@PrevNBHoodId and(CHARINDEX(',' + CAST( NeighborhoodID AS nvarchar) + ',', ',' + @NbHoodIdList + ',')>0 ) and  CHARINDEX ('#',reverse(@NbHoodOutput))<>1 then  
 ',' +  convert(varchar,NeighborhoodID)   
when MetroArea.MetroAreaID <> @PrevMetroId  and   (charindex(',' + cast( NeighborhoodID as nvarchar) + ',', ',' + @NbHoodIdList + ',')=0 ) then  
'#'  
else  
''  
end,  
  
@PrevMetroId=MetroArea.MetroAreaID, -- assign metroid to @PrevMetroId variable so as to compare values for next iteration  
@PrevRegionId = MacroNeighborhood.MacroID ,-- assign regionid to @PrevRegionId variable so as to compare values for next iteration  
@PrevNBHoodId = NeighborhoodID  
  
FROM    NeighborhoodVW as nh 
        inner join MetroAreaVW  MetroArea 
            ON nh.MetroAreaID = MetroArea.MetroAreaID 
            
        inner join MacroNeighborhoodVW MacroNeighborhood 
            ON nh.MacroID = MacroNeighborhood.MacroID  
  
where(MetroArea.active = 1 or MetroArea.MetroAreaID=1) /*explicitly added Demoland metroarea*/
    and MacroNeighborhood.Active=1
    and nh.Active=1
    and (charindex(',' + cast( MetroArea.MetroAreaID as nvarchar) + ',' , ',' + @MetroIdList + ',' ) > 0 or charindex('-1',isnull(@MetroIdList, '-1'))= 1)  
    and charindex(',' + cast( MetroArea.CountryID as nvarchar) + ',' , ',' + @CountryCode + ',' ) > 0  
    order by MetroArea.MetroAreaID
        ,MacroNeighborhood.MacroID 
        ,NeighborhoodID   
        
-- where conditions is applied for metro level . if metro input value =-1 i.e then dont apply metro level fiter  
-- if not equal to -1 then apply metro level fiter aand get only those many records.  
  
-- cuisine being independent of MRN its output value is calculated based on cuisine input variable  
if @CuisineIdList is not null and charindex('-1',@CuisineIdList) <> 0  
begin 

  	select @CuisineOutput = null

	select @CuisineOutput =(coalesce(@CuisineOutput + ',', '') + cast(macro.FoodTypeID as varchar(5))) from 
	FoodTypes micro
	INNER JOIN	FoodTypeSearchMap cm
	ON			cm.FoodTypeID = micro.FoodTypeID		
	INNER JOIN	FoodType macro
	ON			macro.FoodTypeID = cm.SearchFoodTypeID 
	inner join		dbo.DBUserDistinctLanguageVW db 
	on				db.languageid = macro.LanguageID
	group by macro.FoodTypeID


end     
else  
      set @CuisineOutput = @CuisineIdList -- cuisine output = null or equal to cuisine list if cuisine list is not equal to -1  
  
if @RegionIdList is null   
      set @RegionOutput = null -- if no region output is required  
  
if @NbHoodIdList is null   
      set @NbHoodOutput = null -- if no neighbouhood output is required  
end   
else  
begin  
-- id metro input value is null  
      set @MetroOutput = null  
      set @RegionOutput = null  
      set @NbHoodOutput = null  
      set @CuisineOutput = null  
end  
  
  
select  substring (@MetroOutput , charindex(',',@MetroOutput) + 1, len (@MetroOutput)) as MetroId,  
substring (@RegionOutput , charindex('#',@RegionOutput) + 1, len (@RegionOutput)) as RegionId ,  
substring (@NbHoodOutput , charindex('#',@NbHoodOutput) + 1, len (@NbHoodOutput)) as NeighborhoodId    ,  
@CuisineOutput as CuisineId  


go

grant execute on [TopTen_GetRuleSetValueForAll] to ExecuteOnlyRole
go


