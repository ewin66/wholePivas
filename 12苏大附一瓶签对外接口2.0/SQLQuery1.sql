/****** Script for SelectTopNRows command from SSMS  ******/
  select LabelNo,BatchSavedDT from IVRecord(nolock) iv 
  where IVRecordID in 
  (
	select ivd.IVRecordID from IVRecordDetail(nolock) ivd 
	where DrugCode in (select DrugCode from Drug_YTJ)
  ) 
  --已进入打印的下个流程的，不再发送给英特吉去打印
  and iv.IVStatus <=3
  --已因各种原因被取消的瓶签，不再发送给英特吉去打印
  and iv.LabelOver >= 0 
  and DATEDIFF(DD,InfusionDT,GETDATE()) < 2
  and not exists
  (
	select LabelNo,BatchSavedDT from IVRecordToYTJ ivi 
	where ivi.labelno = iv.labelno 
	and ISNULL(ivi.BatchSavedDT,1)=ISNULL(iv.BatchSavedDT,1) 	
  )

go
 select * from IVRecord where LabelNo = 20180310101714
 or LabelNo = 20180310102034
  or LabelNo = 20180310102034
   or LabelNo = 20180310102034