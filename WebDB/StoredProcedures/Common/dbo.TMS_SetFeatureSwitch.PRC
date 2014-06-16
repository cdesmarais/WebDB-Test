IF EXISTS ( SELECT * 
        FROM DBO.SYSOBJECTS 
        WHERE ID = OBJECT_ID(N'[dbo].[TMS_SetFeatureSwitch]') 
        AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
    DROP PROCEDURE [dbo].[TMS_SetFeatureSwitch]
GO


CREATE PROCEDURE [dbo].[TMS_SetFeatureSwitch]
(
	@EmailSwitchId INT,	
	@SwitchMode VARCHAR(50)
)
AS
    declare @ValueLookupId int = 92
	    
    if @SwitchMode in ('off', 'shadow', 'full')
    begin
        DELETE FROM ValueLookupIDList
        WHERE LookupID = @ValueLookupId AND ValueID IN (@EmailSwitchId, @EmailSwitchId+1000);
    
	    if(@SwitchMode in ('shadow', 'full'))
        begin
            INSERT INTO ValueLookupIDList(LookupID, ValueID)
            VALUES (@ValueLookupId, @EmailSwitchId);

            if(@SwitchMode = 'shadow')
            begin
                INSERT INTO ValueLookupIDList(LookupID, ValueID)
                VALUES (@ValueLookupId, @EmailSwitchId+1000);
            end
        end
    end

    select case
            when idcount = 2 then 'shadow'
            when idcount = 1 then 'full'
            else 'off' end as FeatureSwitchMode
    from
         (select count(*) as idcount from ValueLookupIDList where LookupId = @ValueLookupId and valueid in (@EmailSwitchId, @EmailSwitchId+1000)) a
  
GO

GRANT EXECUTE ON [TMS_SetFeatureSwitch] TO ExecuteOnlyRole

GO
