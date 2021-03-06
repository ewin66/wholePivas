USE [0101]
GO
/****** Object:  StoredProcedure [dbo].[bl_fetchdrugList6]    Script Date: 2016/4/18 星期一 16:31:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[bl_fetchdrugList6]
AS
BEGIN
if ISNULL((select ISend from PBatchTemp where ID=(select MAX(ID) from PBatchTemp)),1)=1
begin

   delete from dbo.UseDrugListTemp 
         where OccDT < GETDATE()-1

   update UseDrugList
      set DrugListID=udlt.DrugListID
	 from UseDrugListTemp udlt
	where UseDrugList.GroupNo    =udlt.GroupNo
	  and UseDrugList.RecipeID   =udlt.RecipeID
	  and UseDrugList.Schedule   =udlt.Schedule  
	  and UseDrugList.DrugListID!=udlt.DrugListID

   update UseDrugListTemp
      set Schedule=ISNULL(remark2,OccDT)
    where Schedule is null

   delete from dbo.UseDrugListTemp  
         where exists (select 'X' from UseDrugList ul 
                                 where ul.GroupNo=UseDrugListTemp.GroupNo 
                                   and ul.RecipeID=UseDrugListTemp.RecipeID
                                   and DATEDIFF(DAY,ul.OccDT,UseDrugListTemp.OccDT)=0 
                                   and ul.Schedule=UseDrugListTemp.Schedule)
   
   delete from dbo.UseDrugListTemp  
         where exists(select 'X' from IVRecord iv 
                           inner join DFreq df 
                                   on iv.FreqCode=df.FreqCode 
                                  and df.IntervalDay>24 
                                  and iv.GroupNo=UseDrugListTemp.GroupNo
                                where DATEDIFF(DAY,InfusionDT,OccDT)<(IntervalDay/24))
                   
   delete from dbo.UseDrugList  
         where OccDT < GETDATE()-2
   --and exists (select 'X' from Prescription p where p.GroupNo=UseDrugList.GroupNo and PStatus!=2) 
   
   print '删除冗余药单'

    insert into dbo.UseDrugList 
               (DrugLGroupNo,GroupNo,RecipeID,DrugListID,Schedule,DrugCode,Spec,DrugName,Quantity,QuantityUnit,OccDT,InsertDT)
        (select distinct    
                case when lt.remark2 is null 
				     then p.FregCode 
					 else pd.GroupNo+CONVERT(varchar,OccDT,111)+'M'+fr.FreqSubCode end,
                pd.GroupNo,
                pd.RecipeNo,
                DrugListID,
                Schedule,
                pd.DrugCode,
                pd.Spec,
                pd.DrugName,
                pd.Quantity,
                lt.remark2,
                case when lt.remark2 is null 
				     then OccDT 
					 else CONVERT(datetime,CONVERT(DATE,OccDT))+CONVERT(time,ISNULL(fr.MedicineTime,'')) end OccDt,
                getdate() 
           from UseDrugListTemp lt 
     inner join PrescriptionDetail pd
             on lt.RecipeID=pd.RecipeNo 
            and DATEDIFF(DAY,OccDT,GETDATE())<1 
     inner join Prescription p
             on p.PrescriptionID=pd.PrescriptionID 
     inner join dbo.FreqRule fr 
             on p.FregCode=fr.FreqCode 
        )
   
   
	 
   update UseDrugList
      set OccDT=isnull((select max(OccDT) from UseDrugListTemp ut where ut.GroupNo=UseDrugList.GroupNo and ut.RecipeID=UseDrugList.RecipeID and ut.Schedule=UseDrugList.Schedule and DATEDIFF(day,UseDrugList.OccDT,ut.OccDT)=0),OccDT)  
    where OccDT=CONVERT(date,OccDT) 
	  and QuantityUnit is not null
     
   print '插入新药单'

   if object_id('tempdb..#UDLTemp') is not null
     begin drop table #UDLTemp end   

   SELECT UseDrugID,
	      GroupNo,
	      occdt,
	      FreqSubCode,
	      lno 
	 INTO #UDLTemp
     FROM [dbo].[V_UseDrugList]
	

   
   DELETE FROM #UDLTemp
         WHERE EXISTS(SELECT 'X' 
		                FROM ( 
                      SELECT GroupNo,
	                         occdt 
	                    FROM [V_UseDrugList] 
                    GROUP BY GroupNo,
                             RecipeID,
		                     occdt,
		                     FreqSubCode 
                      HAVING COUNT(1)>1) HC
					   WHERE HC.GroupNo=#UDLTemp.GroupNo
					     AND HC.occdt  =#UDLTemp.occdt
						)
  
  UPDATE UseDrugList
     SET DrugLGroupNo=UDLT.GroupNo+CONVERT(varchar,UDLT.OccDT,111)+'M'+UDLT.FreqSubCode,
	     QuantityUnit=UDLT.lno
	FROM #UDLTemp UDLT
   WHERE UDLT.UseDrugID=UseDrugList.UseDrugID
     AND DATEDIFF(DAY,UseDrugList.OccDT,GETDATE())<1
     AND QuantityUnit IS NULL
	 
	
   if object_id('tempdb..#UDLTemp') is not null
     begin drop table #UDLTemp end 	 

   print '批量更新药单唯一号'
  
   while(select COUNT(1) from dbo.UseDrugList where DATEDIFF(DAY,OccDT,GETDATE())<1 and QuantityUnit is null)>0
   begin
   update dbo.UseDrugList
      set DrugLGroupNo=GroupNo+
	                   CONVERT(varchar,OccDT,111)+'M'+
					   DrugLGroupNo+
					   CONVERT(varchar,(select isnull(max(convert(int,QuantityUnit)),0)+1 
					                      from UseDrugList udl 
										 where udl.GroupNo=UseDrugList.GroupNo 
										   and udl.RecipeID=UseDrugList.RecipeID 
										   and DATEDIFF(DAY,UseDrugList.OccDT,udl.OccDT)=0)),
          QuantityUnit=(select isnull(max(convert(int,QuantityUnit)),0)+1 
		                  from UseDrugList udl 
						 where udl.GroupNo=UseDrugList.GroupNo 
						   and udl.RecipeID=UseDrugList.RecipeID 
						   and DATEDIFF(DAY,UseDrugList.OccDT,udl.OccDT)=0)
    where UseDrugID in (select MIN(UseDrugID) 
	                      from UseDrugList 
						 where DATEDIFF(DAY,OccDT,GETDATE())<1 
						   and QuantityUnit is null 
					  group by GroupNo,RecipeID)
   end

   update UseDrugList
      set OccDT=(select min(OccDT) from UseDrugList e where e.DrugLGroupNo=UseDrugList.DrugLGroupNo)
    where DrugLGroupNo in (select DrugLGroupNo from UseDrugList group by DrugLGroupNo having COUNT(distinct OccDT)>1) 


   print '循环更新药单唯一号'

   delete from dbo.UseDrugList 
         where EXISTS(SELECT 'X' FROM Prescription p 
		                   inner join DFreq df 
						           on p.FregCode=df.FreqCode 
								  and p.GroupNo =UseDrugList.GroupNo 
								  and DATEDIFF(DAY,OccDT,GETDATE())<1 
								  and convert(int,QuantityUnit)>TimesOfDay)
   
   delete from dbo.UseDrugList 
         where UseDrugID in(select MIN(UseDrugID) 
		                      from dbo.UseDrugList 
		                     where OccDT>GETDATE()-1 
						  group by DrugLGroupNo,RecipeID 
						    having COUNT(1)>1)
   
   print '删除问题药单'
   --exec dbo.bl_synHisDrugStor 

END 
END



