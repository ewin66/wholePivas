USE [0101]
GO
/****** Object:  StoredProcedure [dbo].[autoivorderByUDL]    Script Date: 2016/4/18 星期一 16:00:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER proc [dbo].[autoivorderByUDL]
(
  @LogId varchar(64), --OrderLog的唯一号
  @wardcode varchar(50),--病区编码
  @patCode varchar(50),--病人编码
  @dat varchar(50)
)
AS 
IF (SELECT [EndTime] FROM [V_Sync] WHERE [SynCode]='8') IS NOT NULL 
AND(SELECT COUNT(ID) FROM [PBatchTemp] WHERE DATEDIFF(MINUTE,[DT],GETDATE())<10 AND [ISend]=0)=0
BEGIN
	BEGIN TRY
	INSERT INTO [PBatchTemp]([logid],[DT],[ISend])
	VALUES(@LogId,GETDATE(),0)

	declare @BatchMark varchar(10)
    declare @PackName varchar(50)
    declare @NightTime int
    declare @NightIsPack bit
    declare @dt int
    declare @InfusionDT datetime
    declare @LabelNo varchar(50)
    declare @IVRecordID bigint
    declare @maxOrderID int
    declare @maxNextOrderID int     
    declare @OrderID smallint
    declare @row int
    declare @rows int
    declare @Strs varchar(32)
	declare @BitValue bit
	declare @TeamNo smallint
      
    SET @dt=DATEDIFF(DAY,GETDATE(),@dat)
	SET @BitValue=(CASE WHEN (SELECT TOP(1) [WithoutK] FROM [orderrule2])=1 THEN 0 ELSE 1 END)
	SET @TeamNo=(SELECT MAX([OrderID]) FROM [DOrder])

    SELECT @BatchMark=[BatchMark],
           @PackName=[PackName],
           @NightTime=[NightTime],
           @NightIsPack=[NightIsPack]
     FROM [OrderRule]

	IF @wardcode!=''
	BEGIN
	UPDATE [OrderLog] 
       SET [Docount]='开始重排'
     WHERE [LogID]=@LogId 

		PRINT '开始重排'+CONVERT(VARCHAR,CONVERT(TIME,GETDATE()))

		IF @patCode!=''
		BEGIN

		PRINT @patCode

		END
	END
	ELSE 
	BEGIN
	
	UPDATE [OrderLog] 
       SET [Docount]='开始生成瓶签'
     WHERE [LogID]=@LogId 

	 PRINT '开始生成瓶签'+CONVERT(VARCHAR,CONVERT(TIME,GETDATE()))

	IF OBJECT_ID('tempdb..#PreTemp') IS NOT NULL
	BEGIN DROP TABLE #PreTemp END     


	SELECT DISTINCT 
           [PrescriptionID],
           [DrugLGroupNo],
           p.[GroupNo],
           [OccDT],
           [FregCode], 
		   SUBSTRING([DrugLGroupNo],CHARINDEX('M',[DrugLGroupNo],LEN(u.[GroupNo])+10)+1,20) [FreqName],
           [PatientCode],
           [PatName],
           ISNULL(pt.[BedNo],p.[BedNo])[BedNo],
           ISNULL(pt.[WardCode],p.[WardCode])[WardCode],
           [WardName],
           pt.[Sex],
           pt.[Age],
           [JustOne],
           CASE WHEN DATEPART(HOUR,[OccDT])<@NightTime AND @NightIsPack=1 THEN 1 ELSE ([dbo].[GetIsPack]([PrescriptionID]))END [IsPack],
           [Remark1],
           [Remark2],
           [Remark3],
           [Remark4],
           [Remark5],
           [Remark6],
		   [DrugListID]
	  INTO  #PreTemp
      FROM [Prescription] p 
INNER JOIN [UseDrugList]  u 
        ON P.[GroupNo]=u.[GroupNo] 
       AND DATEDIFF(DAY,GETDATE(),[OccDT])=@dt
       AND p.[PStatus]=2 
       AND p.[PPause]=0    
	   AND NOT EXISTS (SELECT 'X' FROM [IVRecord] i WHERE i.[DrugLGroupNo]=u.[DrugLGroupNo])      
 LEFT JOIN [Patient] pt
        ON pt.[PatCode] =p.[PatientCode]                
 LEFT JOIN [DWard] dw
        ON dw.[WardCode]=p.[WardCode]


      INSERT INTO [IVRecord](
	              [PrescriptionID],
	              [DrugLGroupNo],
	              [GroupNo],
	              [InfusionDT],
	              [BatchSaved],
	              [IVStatus],
				  [IsBatch],
	              [FreqCode],
	              [FreqName],
	              [InsertDT],
	              [PatCode],
	              [PatName],
	              [BedNo],
	              [WardCode],
	              [WardName],
	              [Sex],
	              [IsSame],
	              [TeamNumber],
	              [IsPack],
	              [PackName],
	              [Batch],
	              [LabelNo],
	              [Age],
	              [BatchRule],
	              [JustOne],
	              [IsCommand],
	              [FreqNum],
				  [LabelOver],
	              [Remark1],
	              [Remark2],
	              [Remark3],
	              [Remark4],
	              [Remark5],
	              [Remark6])
  SELECT DISTINCT [PrescriptionID],
                  [DrugLGroupNo],
                  [GroupNo],
                  [OccDT],
	              0,
	              0,
				  0,
                  [FregCode], 
                  [FreqName],
                  GETDATE(),
                  [PatientCode],
                  [PatName],
                  [BedNo],
                  [WardCode],
                  [WardName],
                  [Sex],
                  1,
                  CASE WHEN [DrugListID]='K' THEN 0 ELSE replace([DrugListID],'#','') END [TeamNumber],
                  [IsPack], 		
                  CASE WHEN [IsPack]=1 THEN @PackName ELSE '' END [PackName],
                  [DrugListID],
                  null,
                  [age],
                  '初始:'+[DrugListID],
                  [JustOne],
                  0 [IsCommand], 
                  SUBSTRING([FreqName],LEN([FregCode])+1,2) [FreqNum],
				  0 [LabelOver],
                  [Remark1],
                  [Remark2],
                  '10' as [Remark3],
                  [Remark4],
                  [Remark5],
                  [Remark6]
             FROM #PreTemp  
      
       DROP TABLE #PreTemp

     INSERT INTO [IVRecordDetail]
				([IVRecordID]
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
				,[RecipeNo])
 SELECT DISTINCT [IVRecordID],
				 GETDATE(),
                 [DrugCode],
				 [DrugName],
				 [Spec],
				 [Dosage],
				 [DosageUnit],
				 CEILING([Quantity]),
				 -1,
				 [Remark7],
				 [Remark8],
				 [Remark9],
				 [Remark10],
				 [RecipeNo]
			FROM [PrescriptionDetail] pr 
	  INNER JOIN [IVRecord] iv 
              ON pr.[PrescriptionID]=iv.[PrescriptionID]
			 AND NOT EXISTS (SELECT 'X' FROM [IVRecordDetail] ivd WHERE iv.[IVRecordID]=ivd.[IVRecordID])
			 AND [PDStatus]=2
			 AND [IsBatch] =0
			 AND EXISTS(SELECT 'X' FROM [UseDrugList] UL WHERE pr.[RecipeNo]=ul.[RecipeID] OR EXISTS(SELECT 'X' FROM [OrderRule2] WHERE [IVDCreatByUseDrug]=0))

		DELETE FROM [IVRecordDetail] WHERE [IVRecordID] IN (SELECT MIN([IVRecordID]) FROM [IVRecord] WHERE DATEDIFF(DAY,[InfusionDT],GETDATE())<1 GROUP BY [DrugLGroupNo] HAVING COUNT(1)>1)
		DELETE FROM [IVRecordDetail] WHERE [IVRecodedDetaiID] IN (SELECT MIN([IVRecodedDetaiID]) FROM [IVRecordDetail] GROUP BY [IVRecordID],[RecipeNo] HAVING COUNT(1)>1)
		DELETE FROM [IVRecord] WHERE [IVRecordID] IN (SELECT MIN([IVRecordID]) FROM [IVRecord] WHERE DATEDIFF(DAY,[InfusionDT],GETDATE())<1 GROUP BY [DrugLGroupNo] HAVING COUNT(1)>1)
	     
		UPDATE [IVRecord]
		   SET [Remark2]=CASE WHEN(SELECT COUNT(1) FROM [IVRecordDetail] ivd WHERE ivd.[IVRecordID]=[IVRecord].[IVRecordID])=(SELECT COUNT(1) FROM [PrescriptionDetail] pd WHERE pd.[PrescriptionID]=[IVRecord].[PrescriptionID]) THEN '0' ELSE '-1' END
		 WHERE ISNULL([Remark2],'-1')='-1'

        UPDATE [IVRecord] 
           SET [Menstruum]= ISNULL((SELECT MAX(iv.[DrugCode]) FROM [IVRecordDetail] iv INNER JOIN [DDrug] d ON iv.[DrugCode]=d.[DrugCode] AND iv.[IVRecordID]=[IVRecord].[IVRecordID] AND d.[IsMenstruum]=1),
		                    ISNULL((SELECT MAX(iv.[DrugCode]) FROM [IVRecordDetail] iv INNER JOIN [DDrug] d ON iv.[DrugCode]=d.[DrugCode] AND iv.[IVRecordID]=[IVRecord].[IVRecordID] AND d.[withmenstruum]=1),(SELECT MAX([DrugCode]) FROM [IVRecordDetail] ivd WHERE ivd.[IVRecordID]=[IVRecord].[IVRecordID]))),
               [MarjorDrug]=ISNULL((SELECT MAX(iv.[DrugCode]) FROM [IVRecordDetail] iv INNER JOIN [DDrug] d ON iv.[DrugCode]=d.[DrugCode] AND iv.[IVRecordID]=[IVRecord].[IVRecordID] AND d.[AsMajorDrug]=0 AND d.[IsMenstruum]=0 AND d.[withmenstruum]=0),
							ISNULL((SELECT MAX(iv.[DrugCode]) FROM [IVRecordDetail] iv INNER JOIN [DDrug] d ON iv.[DrugCode]=d.[DrugCode] AND iv.[IVRecordID]=[IVRecord].[IVRecordID] AND d.[IsMenstruum]=0),(SELECT MAX([DrugCode]) FROM [IVRecordDetail] ivd WHERE ivd.[IVRecordID]=[IVRecord].[IVRecordID])))
         WHERE [LabelNo] IS NULL 
		    OR [Menstruum] IS NULL 
			OR [MarjorDrug] IS NULL

		UPDATE [OrderLog]
           SET [Docount]='开始生成瓶签号'
         WHERE [LogID]=@LogId  

		PRINT '开始生成瓶签号'+CONVERT(VARCHAR,CONVERT(TIME,GETDATE()))
		 
		IF OBJECT_ID('tempdb..#LabelNO') IS NOT NULL
	    BEGIN DROP TABLE #LabelNO END     

		SELECT [IVRecordID],
		       [LabelNo],
		       [InfusionDT]
		  INTO #LabelNO
		  FROM IVRecord
		 WHERE DATEDIFF(DAY,GETDATE(),[InfusionDT])=@dt

		WHILE(SELECT COUNT(1) FROM #LabelNO WHERE [LabelNo] IS NULL)>0
		BEGIN	
      
		SELECT @InfusionDT=MIN([InfusionDT]),
			   @IVRecordID=MIN([IVRecordID]) 
		  FROM #LabelNO 
		 WHERE [LabelNo] IS NULL 
         
		SELECT @LabelNo=MAX([LabelNo]) 
		  FROM #LabelNO 
      
		UPDATE #LabelNO 
		   SET [LabelNo]=CONVERT(BIGINT,ISNULL(@LabelNo,(CONVERT(varchar(32),@InfusionDT,112)+'100000')))+1+[IVRecordID]-@IVRecordID
		 WHERE [LabelNo] IS NULL 
         
		END

		UPDATE [IVRecord]
		   SET [LabelNo]=#LabelNO.[LabelNo]
		  FROM #LabelNO
		 WHERE #LabelNO.[IVRecordID]=[IVRecord].[IVRecordID]

		DROP TABLE #LabelNO 

	END

		UPDATE [OrderLog]
           SET [CopyOver]=1,
               [Docount]='开始排批次'
         WHERE [LogId]=@LogId

		PRINT '开始排批次'+CONVERT(VARCHAR,CONVERT(TIME,GETDATE()))

		UPDATE IVRecord
		   SET Batch=                         (SELECT TOP(1)DrugListID FROM UseDrugList UDL WHERE UDL.DrugLGroupNo=IVRecord.DrugLGroupNo AND UDL.DrugListID!=IVRecord.Batch)
		      ,BatchRule=BatchRule+';更新为:'+(SELECT TOP(1)DrugListID FROM UseDrugList UDL WHERE UDL.DrugLGroupNo=IVRecord.DrugLGroupNo AND UDL.DrugListID!=IVRecord.Batch)
		 WHERE EXISTS(SELECT 'X' FROM UseDrugList UDL WHERE UDL.DrugLGroupNo=IVRecord.DrugLGroupNo AND UDL.DrugListID!=IVRecord.Batch)
		   AND IVStatus=0

        UPDATE IVRecord
		   SET TeamNumber=(CASE WHEN Batch='K' THEN 0 ELSE REPLACE(Batch,'#','') END)
		 WHERE IVStatus=0

	  UPDATE [IVRecord] 
         SET [IsBatch]=1
	   WHERE [IsBatch]=0
	     AND DATEDIFF(DAY,GETDATE(),[InfusionDT])=@dt
	         

      UPDATE [OrderLog]
         SET [End]=1,
             [Docount]='结束' 
       WHERE [LogId]=@LogId

    END   TRY
    BEGIN CATCH
		print 'error:'
		print error_message() 

		UPDATE [OrderLog] 
		   SET [End]=1,
		       [Docount]='结束' 
		 WHERE [LogId]=@LogId
	END CATCH
	
	UPDATE [PBatchTemp]
	   SET [ISend]=1
	 WHERE [logid]=@LogId
	   AND DATEDIFF(MINUTE,[DT],GETDATE())<10 
	   AND [ISend]=0 

	PRINT '结束'+CONVERT(VARCHAR,CONVERT(TIME,GETDATE()))	  
	               
END

