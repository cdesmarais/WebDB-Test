if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_propercase]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_propercase]
GO



CREATE Procedure dbo.Sp_propercase @in nvarchar(255) output
as

BEGIN
declare @in_pos    tinyint
       ,@inter     nvarchar(255)
       ,@inter_pos tinyint

select  @in_pos     = 0
       ,@in         = lower(@in)
select  @inter      = @in
select  @inter_pos  = patindex('%[0-9A-Za-z]%',@inter)
while   @inter_pos  > 0
  begin
    select @in_pos = @in_pos + @inter_pos
    select @in = stuff(@in,@in_pos,1,upper(substring(@in,@in_pos,1))),@inter = substring(@inter,@inter_pos + 1,datalength(@inter) - @inter_pos)
    select @inter_pos = patindex('%[^0-9A-Za-z]%',@inter)
      if @inter_pos > 0
        begin
          select @in_pos    = @in_pos + @inter_pos
          select @inter     = substring(@inter,@inter_pos + 1,datalength(@inter) - @inter_pos)
          select @inter_pos = patindex('%[0-9A-Za-z]%',@inter)
        end
  end
END 




GO

GRANT EXECUTE ON [sp_propercase] TO ExecuteOnlyRole

GO
