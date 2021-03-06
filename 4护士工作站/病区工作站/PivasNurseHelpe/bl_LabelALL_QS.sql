USE [Pivas20140818]
GO
/****** Object:  StoredProcedure [dbo].[bl_LabelALL_QS]    Script Date: 07/24/2014 17:23:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--病区签收
--工作者工号，labelno，病区，病区组,扫描位置,扫描物类型(瓶签,总瓶签)
ALTER procedure [dbo].[bl_LabelALL_QS](@Lid varchar(32) ,@labelNos varchar(32),@Location varchar(32),@Type smallint)
as 
begin 
  --DECLARE @RecordStat int
  if (SELECT count([LabelNo]) FROM [dbo].[IVRecord_Print]where [DrugQRCode]=@labelNos or [OrderQRCode]=@labelNos)=0
	return -1
  else
  begin
    update IVRecord set IVStatus = 15 
		where 
    LabelNo in ((SELECT LabelNo FROM IVRecord iv 
      left join patient pt on iv.PatCode=pt.PatCode
    left join PivasNurseFormSet on PivasNurseFormSet.WardCode=pt.WardCode
 where (( Batch like '%#' and IVStatus>= LabelPack)or (Batch like '%K' and IVStatus>=LabelPackAir)) and pt.WardCode=@Location))
 
    and LabelOver=0 and WardRetreat!='1' and WardRetreat!='2' and labelNo in (SELECT [LabelNo] FROM [dbo].[IVRecord_Print]where [DrugQRCode]=@labelNos or [OrderQRCode]=@labelNos)
    insert into IVRecord_QS(IVrecordID,QSDT,ScanCount,pcode,Location,[Type])
    SELECT a.[LabelNo],GETDATE(),(SELECT COUNT(1) from IVRecord_QS where IVrecordID = a.[LabelNo] and Invalid is null),@Lid,@Location,@Type FROM [dbo].[IVRecord_Print]a inner join IVRecord b on a.LabelNo=b.LabelNo and IVStatus>=3 and LabelOver=0 and WardRetreat!='1' and WardRetreat!='2' where [DrugQRCode]=@labelNos or [OrderQRCode]=@labelNos 
    return 1
  end
 end


