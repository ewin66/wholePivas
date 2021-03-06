USE [Pivas20140818]
GO
/****** Object:  StoredProcedure [dbo].[bl_Label_QS]    Script Date: 07/24/2014 17:33:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--病区签收
--工作者工号，labelno，病区，病区组,扫描位置,扫描物类型(瓶签,总瓶签)
ALTER procedure [dbo].[bl_Label_QS](@date datetime,@Lid varchar(32) ,@labelNo varchar(32),@Location varchar(32),@Type smallint)
as 
begin 
  --DECLARE @RecordStat int
  if (select COUNT(1) from IVRecord where DATEDIFF(DAY,@date,InfusionDT)=0 and labelNo = @labelNo and LabelOver=0 and WardRetreat!='1' and WardRetreat!='2')=100
	return -1
  else if (SELECT COUNT(*) FROM IVRecord iv 
  left join patient pt on iv.PatCode=pt.PatCode
  left join PivasNurseFormSet on PivasNurseFormSet.WardCode=pt.WardCode
  where labelNo = @labelNo and (( Batch like '%#' and IVStatus>= LabelPack)or (Batch like '%K' and IVStatus>=LabelPackAir)) and pt.WardCode=@Location)!=0
 
  begin
    update IVRecord set IVStatus = 15 where labelNo = @labelNo
    insert into IVRecord_QS(IVrecordID,QSDT,ScanCount,pcode,Location,[Type]) 
    values(@labelNo,getdate(),(SELECT COUNT(1) from IVRecord_QS where IVrecordID = @labelNo and Invalid is null),@Lid,@Location,@Type)
    return 1
  end
  else
  return 0
 end


