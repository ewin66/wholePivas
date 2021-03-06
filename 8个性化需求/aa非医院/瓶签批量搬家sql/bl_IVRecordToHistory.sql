USE [Pivas2013]
GO
/****** Object:  StoredProcedure [dbo].[bl_IVRecordToHistory]    Script Date: 02/13/2014 14:59:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--出仓核对
ALTER procedure [dbo].[bl_IVRecordToHistory] 
as 
begin 
 
 DECLARE @IVRecordID  varchar(32)
 select top 1 @IVRecordID =IVRecordID from dbo.IVRecord where infusiondt<getdate()-4 order by IVRecordID desc
  
 --明细表  
  INSERT INTO 
  [IVRecordDetailHistory]
   (
      [IVRecodedDetaiID]
      ,[IVRecordID]
      ,[InceptDT]
      ,[DrugCode]
      ,[DrugName]
      ,[Spec]
      ,[Dosage]
      ,[DosageUnit]
      ,[DgNo]
      ,[ReturnFromHis]
      ,[Remark7]
      ,[Remark8]
      ,[Remark9]
      ,[Remark10]
    )
   (select 
      [IVRecodedDetaiID]
      ,[IVRecordID]
      ,[InceptDT]
      ,[DrugCode]
      ,[DrugName]
      ,[Spec]
      ,[Dosage]
      ,[DosageUnit]
      ,[DgNo]
      ,[ReturnFromHis]
      ,[Remark7]
      ,[Remark8]
      ,[Remark9]
      ,[Remark10]
   FROM 
     [dbo].[IVRecordDetail]
  where IVRecordID <=@IVRecordID
  )
   delete from [IVRecordDetail] where IVRecordID <=@IVRecordID 
   
  
 --主表 
 INSERT INTO 
    [IVRecordHistory]
 (
      [IVRecordID]
      ,[PrescriptionID]
      ,[DrugLGroupNo]
      ,[GroupNo]
      ,[Batch]
      ,[BatchRule]
      ,[LabelNo]
      ,[InfusionDT]
      ,[BatchSaved]
      ,[IVStatus]
      ,[FreqCode]
      ,[FreqName]
      ,[BatchSavedDT]
      ,[InsertDT]
      ,[PrintDT]
      ,[PrinterID]
      ,[PrinterName]
      ,[PatCode]
      ,[PatName]
      ,[BedNo]
      ,[WardCode]
      ,[WardName]
      ,[Sex]
      ,[Age]
      ,[IsSame]
      ,[JustOne]
      ,[IsCommand]
      ,[TeamNumber]
      ,[IsPack]
      ,[IsBatch]
      ,[PackName]
      ,[Remark1]
      ,[Remark2]
      ,[Remark3]
      ,[Remark4]
      ,[Remark5]
      ,[Remark6]
      ,[FreqNum]
      ,[LabelOver]
      ,[WardRetreat]
      ,[WardRID]
      ,[WardRtime]
      ,[PackID]
      ,[PackTime]
      ,[MarjorDrug]
      ,[Menstruum]
      ,[LabelOverID]
      ,[LabelOverTime]
      )
      (
SELECT  [IVRecordID]
      ,[PrescriptionID]
      ,[DrugLGroupNo]
      ,[GroupNo]
      ,[Batch]
      ,[BatchRule]
      ,[LabelNo]
      ,[InfusionDT]
      ,[BatchSaved]
      ,[IVStatus]
      ,[FreqCode]
      ,[FreqName]
      ,[BatchSavedDT]
      ,[InsertDT]
      ,[PrintDT]
      ,[PrinterID]
      ,[PrinterName]
      ,[PatCode]
      ,[PatName]
      ,[BedNo]
      ,[WardCode]
      ,[WardName]
      ,[Sex]
      ,[Age]
      ,[IsSame]
      ,[JustOne]
      ,[IsCommand]
      ,[TeamNumber]
      ,[IsPack]
      ,[IsBatch]
      ,[PackName]
      ,[Remark1]
      ,[Remark2]
      ,[Remark3]
      ,[Remark4]
      ,[Remark5]
      ,[Remark6]
      ,[FreqNum]
      ,[LabelOver]
      ,[WardRetreat]
      ,[WardRID]
      ,[WardRtime]
      ,[PackID]
      ,[PackTime]
      ,[MarjorDrug]
      ,[Menstruum]
      ,[LabelOverID]
      ,[LabelOverTime]
  FROM 
     [dbo].[IVRecord]
  where IVRecordID <=@IVRecordID 
  )
 
  delete from [IVRecord] where IVRecordID <=@IVRecordID 

end



