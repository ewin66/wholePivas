 select ivd.DrugCode DrugCode,ivd.DrugName DrugName,ivd.Spec DrugUnit,ivd.DgNo DrugAMT,
 ivd.Dosage DosageAMT,ivd.DosageUnit DosageUnit,dd.AsMajorDrug IsMajorDrug,dd.IsMenstruum  IsMenstruum,
 CASE WHEN 0 < CHARINDEX('嘱托', ivd.DrugName) THEN 1 ELSE 0 END  IsSelf,case ivd.DosageUnit when 'ml' 
 then ivd.Dosage when 'l' then (1000*ivd.Dosage) else isnull(dd.Capacity,0)*ivd.DgNo end Capacity,
 (SELECT TOP 1 aa from (SELECT LabelNo,aa=stuff((select ','+DrugPlusConditionName FROM [dbo].[V_DrugAC] dd 
 WHERE dd.LabelNo = d.LabelNo FOR XML PATH('')),1,1,'') from [dbo].[V_DrugAC] d)a where iv.LabelNo = a.LabelNo) 
 DrugRemark1,'' DrugRemark2,'' DrugRemark3,'' DrugRemark4 from IVRecord iv left join IVRecordDetail ivd on 
 iv.IVRecordID = ivd.IVRecordID left join DDrug dd on ivd.DrugCode = dd.DrugCode 
 where iv.LabelNo in
 (
	select cast(iv.GroupNo as decimal(18,0)) RecipeID,cast(iv.GroupNo as decimal(18,0)) GroupNo,
	cast(p.CaseID as decimal(18,0)) ZYNo,CASE WHEN '1'=iv.Remark4 THEN 1 ELSE 0 END IsTemporary,
	CASE p.DrugType WHEN 2 THEN '抗' WHEN 3 THEN '化' WHEN 4 THEN '营' ELSE '普' END PresType,
	(SELECT DEmployeeName FROM dbo.DEmployee WHERE (DEmployeeCode = P.DrawerCode)) NurseName,
	de.DEmployeeName DoctorName,iv.Batch BatchNo,iv.InfusionDT LabelDate,iv.InfusionDT UseTime,iv.WardCode WardNo,
	iv.WardName WardName,iv.BedNo BedNo,PatientCode PatientCode,PatName PatientName,iv.labelno LabelNO, 
	iv.Sex PatientSex,iv.Age PatientAge,ABS(iv.IsPack - 1) Iscompound,RTRIM(p.UsageName) UsageRoute,
	iv.FreqCode FregCode,FreqNum LabelIndex,p.DrugCount DrugNum,'' presremark2,'' presremark3,
	(SELECT TimesOfDay FROM dbo.DFreq AS df WHERE (FreqCode = p.FregCode)) LabelTotal,
	ISNULL(p.Remark1, '') presremark1,
	ISNULL(
	(
		select DEmployeeCode from DEmployee where DEmployeeID=
		(SELECT max(cp.CheckDCode) FROM CPRecord cp where cp.PrescriptionID=iv.PrescriptionID)
	),'') ExminePerson 
	from IVRecord iv left join Prescription p on iv.GroupNo = p.GroupNo left join DEmployee de on p.DoctorCode = de.DEmployeeCode 
	--where iv.LabelNo = '20171209100002'
	--where p.DrugType = 3
	where de.DEmployeeName = '王建平'
	and PatName= '金仁宝'
 )