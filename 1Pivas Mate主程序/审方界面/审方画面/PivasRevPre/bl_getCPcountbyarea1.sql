USE [Pivas20141019]
GO
/****** Object:  StoredProcedure [dbo].[bl_getCPcountbyarea]    Script Date: 11/03/2014 14:56:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










ALTER PROCEDURE [dbo].[bl_getCPcountbyarea]
@DT datetime,
@Per varchar(16),--1：人工未审 p；全部
@Empty bit,       --显示空数据病区 1、显示；0、不显示
@Open bit,       --显示未开放病区 1、显示；0、不显示  
@WardAreaName varchar(16)--显示当前病区组的病区
AS
BEGIN
  DECLARE @OrderLabelCountByArea TABLE (
    WardCode varchar(50),
    WardName varchar(50),
    UnCheckCount int,
    TotalCount int,
    IsOpen bit)
    
      DECLARE @OrderLabelCountByArea1 TABLE (
    WardCode varchar(50),
    WardName varchar(50),
    UnCheckCount int,
    TotalCount int,
    IsOpen bit)
    
  --IF @Per<>'1'
  IF @Per='1,3'
  BEGIN
		  IF @Open=1
		  BEGIN
			  INSERT @OrderLabelCountByArea
			  SELECT 
				D.WardCode,
				D.WardSimName,    
				SUM(case when P.PStatus=1 or P.PStatus = 3 then 1 else 0 end) AS UnCheckCount,
				SUM(Case when DATEDIFF(DD, P.InceptDT, @DT) =0 then 1 else 0 end) AS TotalCount,
				--COUNT(DISTINCT P.PrescriptionID) AS TotalCount,
				IsOpen
			  FROM DWard D --INNER JOIN Patient Pa ON D.WardCode = Pa.WardCode    
					INNER JOIN Prescription P ON D.WardCode = P.WardCode--Pa.PatCode=P.PatientCode  
					INNER JOIN Patient Pa ON Pa.PatCode = P.PatientCode
			  WHERE
				P.PStatus in(1, 2, 3 )    
				AND DATEDIFF(DD, P.InceptDT, @DT) >=0 AND Pa.PatStatus = 1
			  GROUP BY D.WardCode, D.WardSimName ,IsOpen
			  
			  IF @Empty=1
			  BEGIN
				  INSERT @OrderLabelCountByArea
				  SELECT WardCode, WardSimName, 0 ,0 ,IsOpen
				  FROM DWard 
				  WHERE WardCode NOT IN (SELECT WardCode FROM @OrderLabelCountByArea)
			  END
		  END
		  
		  ELSE
		  BEGIN
			  INSERT @OrderLabelCountByArea
			  SELECT 
				D.WardCode,
				D.WardSimName,    
				SUM(case when P.PStatus=1 or P.PStatus = 3 then 1 else 0 end) AS UnCheckCount,
				SUM(Case when DATEDIFF(DD, P.InceptDT, @DT) =0 then 1 else 0 end) AS TotalCount,
				--COUNT(DISTINCT P.PrescriptionID) AS TotalCount,
				IsOpen
			  FROM DWard D --INNER JOIN Patient Pa ON D.WardCode = Pa.WardCode    
					INNER JOIN Prescription P ON D.WardCode = P.WardCode--Pa.PatCode=P.PatientCode  
					INNER JOIN Patient Pa ON Pa.PatCode = P.PatientCode 
			  WHERE
				D.IsOpen <> 0 
				AND P.PStatus in(1, 2, 3 )    
				AND DATEDIFF(DD, P.InceptDT, @DT) >=0 AND Pa.PatStatus = 1
			  GROUP BY D.WardCode, D.WardSimName ,IsOpen
			  
			  IF @Empty=1
			  BEGIN
				  INSERT @OrderLabelCountByArea
				  SELECT WardCode, WardSimName, 0 ,0 ,IsOpen
				  FROM DWard 
				  WHERE IsOpen <> 0 AND WardCode NOT IN (SELECT WardCode FROM @OrderLabelCountByArea)
			  END
		  END
    
		  INSERT @OrderLabelCountByArea
		  SELECT '', '<全部>', ISNULL(SUM(UnCheckCount),0),ISNULL(SUM(TotalCount),0),1 FROM @OrderLabelCountByArea
		 if @WardAreaName =''
		  SELECT O.* ,WardSeqNo,WardArea,WardSeqNo,D.WardSimName,D.Spellcode FROM @OrderLabelCountByArea O LEFT OUTER JOIN DWard D ON O.WardCode = D.WardCode
		  ORDER BY D.WardSeqNo,IsOpen desc
		  else
		  begin
		
		  
		  INSERT @OrderLabelCountByArea1 
		  SELECT O.* FROM @OrderLabelCountByArea O LEFT OUTER JOIN DWard D ON O.WardCode = D.WardCode
	      WHERE WardArea=@WardAreaName
		  ORDER BY D.WardSeqNo,IsOpen desc
		  INSERT @OrderLabelCountByArea1
		  SELECT '', '<全部>', ISNULL(SUM(UnCheckCount),0),ISNULL(SUM(TotalCount),0),1 FROM @OrderLabelCountByArea1
		  
		  SELECT O.* ,WardSeqNo,WardArea,WardSeqNo,D.WardSimName,D.Spellcode FROM @OrderLabelCountByArea1 O LEFT OUTER JOIN DWard D ON O.WardCode = D.WardCode
		  ORDER BY D.WardSeqNo,IsOpen desc
		  end
  END
  ELSE IF @per='1'
  BEGIN
    IF @Open=1
		  BEGIN
			  INSERT @OrderLabelCountByArea
			  SELECT 
				D.WardCode,
				D.WardSimName,    
				SUM(case when P.PStatus=1 then 1 else 0 end) AS UnCheckCount,
				SUM(Case when DATEDIFF(DD, P.InceptDT, @DT) =0 then 1 else 0 end) AS TotalCount,
				--COUNT(DISTINCT P.PrescriptionID) AS TotalCount,
				IsOpen
			  FROM DWard D --INNER JOIN Patient Pa ON D.WardCode = Pa.WardCode    
					INNER JOIN Prescription P ON D.WardCode = P.WardCode--Pa.PatCode=P.PatientCode  
					INNER JOIN Patient Pa ON Pa.PatCode = P.PatientCode
			  WHERE
				P.PStatus in(1, 2, 3 )    
				AND DATEDIFF(DD, P.InceptDT, @DT) >=0 AND Pa.PatStatus = 1
			  GROUP BY D.WardCode, D.WardSimName ,IsOpen
			  
			  IF @Empty=1
			  BEGIN
				  INSERT @OrderLabelCountByArea
				  SELECT WardCode, WardSimName, 0 ,0 ,IsOpen
				  FROM DWard 
				  WHERE WardCode NOT IN (SELECT WardCode FROM @OrderLabelCountByArea)
			  END
		  END
		  
		  ELSE
		  BEGIN
			  INSERT @OrderLabelCountByArea
			  SELECT 
				D.WardCode,
				D.WardSimName,    
				SUM(case when P.PStatus=1 then 1 else 0 end) AS UnCheckCount,
				SUM(Case when DATEDIFF(DD, P.InceptDT, @DT) =0 then 1 else 0 end) AS TotalCount,
				--COUNT(DISTINCT P.PrescriptionID) AS TotalCount,
				IsOpen
			  FROM DWard D --INNER JOIN Patient Pa ON D.WardCode = Pa.WardCode    
					INNER JOIN Prescription P ON D.WardCode = P.WardCode--Pa.PatCode=P.PatientCode  
					INNER JOIN Patient Pa ON Pa.PatCode = P.PatientCode
			  WHERE
				D.IsOpen <> 0 
				AND P.PStatus in(1, 2, 3 )    
				AND DATEDIFF(DD, P.InceptDT, @DT) >=0 AND Pa.PatStatus = 1
			  GROUP BY D.WardCode, D.WardSimName ,IsOpen
			  
			  IF @Empty=1
			  BEGIN
				  INSERT @OrderLabelCountByArea
				  SELECT WardCode, WardSimName, 0 ,0 ,IsOpen
				  FROM DWard 
				  WHERE IsOpen <> 0 AND WardCode NOT IN (SELECT WardCode FROM @OrderLabelCountByArea)
			  END
		  END

		  INSERT @OrderLabelCountByArea
		  SELECT '', '<全部>', ISNULL(SUM(UnCheckCount),0),ISNULL(SUM(TotalCount),0),1 FROM @OrderLabelCountByArea
		 if @WardAreaName =''
		  SELECT O.* ,WardSeqNo,WardArea,WardSeqNo,D.WardSimName,D.Spellcode FROM @OrderLabelCountByArea O LEFT OUTER JOIN DWard D ON O.WardCode = D.WardCode
		  ORDER BY D.WardSeqNo,IsOpen desc
		  else
		  begin
		
		  
		  INSERT @OrderLabelCountByArea1 
		  SELECT O.* FROM @OrderLabelCountByArea O LEFT OUTER JOIN DWard D ON O.WardCode = D.WardCode
	      WHERE WardArea=@WardAreaName
		  ORDER BY D.WardSeqNo,IsOpen desc
		  INSERT @OrderLabelCountByArea1
		  SELECT '', '<全部>', ISNULL(SUM(UnCheckCount),0),ISNULL(SUM(TotalCount),0),1 FROM @OrderLabelCountByArea1
		  
		  SELECT O.* ,WardSeqNo,WardArea,WardSeqNo,D.WardSimName,D.Spellcode FROM @OrderLabelCountByArea1 O LEFT OUTER JOIN DWard D ON O.WardCode = D.WardCode
		  ORDER BY D.WardSeqNo,IsOpen desc
		  end
		  
  END
  ELSE IF @Per='2,3'
    BEGIN
		  IF @Open=1
		  BEGIN
			  INSERT @OrderLabelCountByArea
			  SELECT 
				D.WardCode,
				D.WardSimName,    
				SUM(case when P.PStatus> 1 then 1 else 0 end) AS UnCheckCount,
				SUM(Case when DATEDIFF(DD, P.InceptDT, @DT) =0 then 1 else 0 end) AS TotalCount,
				--COUNT(DISTINCT P.PrescriptionID) AS TotalCount,
				IsOpen
			  FROM DWard D --INNER JOIN Patient Pa ON D.WardCode = Pa.WardCode    
					INNER JOIN Prescription P ON D.WardCode = P.WardCode--Pa.PatCode=P.PatientCode  
					INNER JOIN Patient Pa ON Pa.PatCode = P.PatientCode
			  WHERE
				P.PStatus in(1, 2, 3 )    
				AND DATEDIFF(DD, P.InceptDT, @DT)=0 AND Pa.PatStatus = 1
			  GROUP BY D.WardCode, D.WardSimName ,IsOpen
			  
			  IF @Empty=1
			  BEGIN
				  INSERT @OrderLabelCountByArea
				  SELECT WardCode, WardSimName, 0 ,0 ,IsOpen
				  FROM DWard 
				  WHERE WardCode NOT IN (SELECT WardCode FROM @OrderLabelCountByArea)
			  END
		  END
		  
     ELSE
	 BEGIN
			  INSERT @OrderLabelCountByArea
			  SELECT 
				D.WardCode,
				D.WardSimName,    
				SUM(case when P.PStatus>1 then 1 else 0 end) AS UnCheckCount,
				SUM(Case when DATEDIFF(DD, P.InceptDT, @DT) =0 then 1 else 0 end) AS TotalCount,
				--COUNT(DISTINCT P.PrescriptionID) AS TotalCount,
				IsOpen
			  FROM DWard D --INNER JOIN Patient Pa ON D.WardCode = Pa.WardCode    
					INNER JOIN Prescription P ON D.WardCode = P.WardCode--Pa.PatCode=P.PatientCode  
					INNER JOIN Patient Pa ON Pa.PatCode = P.PatientCode 
			  WHERE
				D.IsOpen <> 0 
				AND P.PStatus in(1, 2, 3 )    
				AND DATEDIFF(DD, P.InceptDT, @DT)=0 AND Pa.PatStatus = 1
			  GROUP BY D.WardCode, D.WardSimName ,IsOpen
			  
			  IF @Empty=1
			  BEGIN
				  INSERT @OrderLabelCountByArea
				  SELECT WardCode, WardSimName, 0 ,0 ,IsOpen
				  FROM DWard 
				  WHERE IsOpen <> 0 AND WardCode NOT IN (SELECT WardCode FROM @OrderLabelCountByArea)
			  END
		  END
  		  INSERT @OrderLabelCountByArea
		  SELECT '', '<全部>', ISNULL(SUM(UnCheckCount),0),ISNULL(SUM(TotalCount),0),1 FROM @OrderLabelCountByArea
		 if @WardAreaName =''
		  SELECT O.* ,WardSeqNo,WardArea,WardSeqNo,D.WardSimName,D.Spellcode FROM @OrderLabelCountByArea O LEFT OUTER JOIN DWard D ON O.WardCode = D.WardCode
		  ORDER BY D.WardSeqNo,IsOpen desc
		  else
		  begin
		
		  
		  INSERT @OrderLabelCountByArea1 
		  SELECT O.* FROM @OrderLabelCountByArea O LEFT OUTER JOIN DWard D ON O.WardCode = D.WardCode
	      WHERE WardArea=@WardAreaName
		  ORDER BY D.WardSeqNo,IsOpen desc
		  INSERT @OrderLabelCountByArea1
		  SELECT '', '<全部>', ISNULL(SUM(UnCheckCount),0),ISNULL(SUM(TotalCount),0),1 FROM @OrderLabelCountByArea1
		  
		  SELECT O.* ,WardSeqNo,WardArea,WardSeqNo,D.WardSimName,D.Spellcode FROM @OrderLabelCountByArea1 O LEFT OUTER JOIN DWard D ON O.WardCode = D.WardCode
		  ORDER BY D.WardSeqNo,IsOpen desc
		  end  
  END
  ELSE IF @Per='3'
  BEGIN
    IF @Open=1
		  BEGIN
			  INSERT @OrderLabelCountByArea
			  SELECT 
				D.WardCode,
				D.WardSimName,    
				SUM(case when P.PStatus=3 then 1 else 0 end) AS UnCheckCount,
				SUM(Case when DATEDIFF(DD, P.InceptDT, @DT) =0 then 1 else 0 end) AS TotalCount,
				--COUNT(DISTINCT P.PrescriptionID) AS TotalCount,
				IsOpen
			  FROM DWard D --INNER JOIN Patient Pa ON D.WardCode = Pa.WardCode    
					INNER JOIN Prescription P ON D.WardCode = P.WardCode--Pa.PatCode=P.PatientCode  
					INNER JOIN Patient Pa ON Pa.PatCode = P.PatientCode
			  WHERE
				P.PStatus IN (1,2,3)    
				AND DATEDIFF(DD, P.InceptDT, @DT)=0 AND Pa.PatStatus = 1
			  GROUP BY D.WardCode, D.WardSimName ,IsOpen
			  
			  IF @Empty=1
			  BEGIN
				  INSERT @OrderLabelCountByArea
				  SELECT WardCode, WardSimName, 0 ,0 ,IsOpen
				  FROM DWard 
				  WHERE WardCode NOT IN (SELECT WardCode FROM @OrderLabelCountByArea)
			  END
		  END
		  
		  ELSE
		  BEGIN
			  INSERT @OrderLabelCountByArea
			  SELECT 
				D.WardCode,
				D.WardSimName,    
				SUM(case when P.PStatus=3  then 1 else 0 end) AS UnCheckCount,
				SUM(Case when DATEDIFF(DD, P.InceptDT, @DT) =0 then 1 else 0 end) AS TotalCount,
				--COUNT(DISTINCT P.PrescriptionID) AS TotalCount,
				IsOpen
			  FROM DWard D --INNER JOIN Patient Pa ON D.WardCode = Pa.WardCode    
					INNER JOIN Prescription P ON D.WardCode = P.WardCode--Pa.PatCode=P.PatientCode  
					INNER JOIN Patient Pa ON Pa.PatCode = P.PatientCode 
			  WHERE
				D.IsOpen <> 0 
				AND P.PStatus in(1, 2, 3 )    
				AND DATEDIFF(DD, P.InceptDT, @DT)=0 AND Pa.PatStatus = 1
			  GROUP BY D.WardCode, D.WardSimName ,IsOpen
			  
			  IF @Empty=1
			  BEGIN
				  INSERT @OrderLabelCountByArea
				  SELECT WardCode, WardSimName, 0 ,0 ,IsOpen
				  FROM DWard 
				  WHERE IsOpen <> 0 AND WardCode NOT IN (SELECT WardCode FROM @OrderLabelCountByArea)
			  END
		  END
     
		  INSERT @OrderLabelCountByArea
		  SELECT '', '<全部>', ISNULL(SUM(UnCheckCount),0),ISNULL(SUM(TotalCount),0),1 FROM @OrderLabelCountByArea
	 
	 if @WardAreaName =''
		  SELECT O.* ,WardSeqNo,WardArea,WardSeqNo,D.WardSimName,D.Spellcode FROM @OrderLabelCountByArea O LEFT OUTER JOIN DWard D ON O.WardCode = D.WardCode
		  ORDER BY D.WardSeqNo,IsOpen desc
		  else
		  begin
		
		  
		  INSERT @OrderLabelCountByArea1 
		  SELECT O.* FROM @OrderLabelCountByArea O LEFT OUTER JOIN DWard D ON O.WardCode = D.WardCode
	      WHERE WardArea=@WardAreaName
		  ORDER BY D.WardSeqNo,IsOpen desc
		  INSERT @OrderLabelCountByArea1
		  SELECT '', '<全部>', ISNULL(SUM(UnCheckCount),0),ISNULL(SUM(TotalCount),0),1 FROM @OrderLabelCountByArea1
		  
		  SELECT O.* ,WardSeqNo,WardArea,WardSeqNo,D.WardSimName,D.Spellcode FROM @OrderLabelCountByArea1 O LEFT OUTER JOIN DWard D ON O.WardCode = D.WardCode
		  ORDER BY D.WardSeqNo,IsOpen desc
		  end
		 
  END
END










