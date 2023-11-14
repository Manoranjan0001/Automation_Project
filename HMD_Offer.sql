

		insert into [Dashboard].dbo.HMD_Offer_Response (Week ,Employee_Name,Emp_Id ,Status,Supervisor_I,Supervisor_II ,[Working Designation] ,
			AON , Bucket ,Working_LoB ,LOB ,Skill_Lob,AC3_Non_AC3 ,is_ac3_flag,Contact_type ,
			Site ,LogIn_Name,routing_skill_cs_hierarchy2_name ,routing_skill_ops_hierarchy_name ,routing_skill_name ,
			to_skill_name ,activity_date,Direction , agent_sic1_name ,agent_sic2_name ,agent_sic3_name,
			agent_sic4_name ,rap_repeat_comm_id ,comm_id ,hmd_poll_yes ,hmd_total_responses ,total_contacts_hmd ,
			handled_contacts ,transferred_contacts )


SELECT 
  concat(
    'Week_', 
    DATEPART(WEEK, activity_date)
  ) as Week, 
  HD.[Employee Name], 
  HD.[Emp ID], 
  HD.Status, 
  HD.[Supervisor I], 
  HD.[Supervisor II], 
  HD.[Working Designation], 
  HD.AON, 
  HD.Bucket, 
  HD.[Working LOB], 
  HD.LOB, 
	case concat(
    INTE.agent_site_group, '_', Rs.Skill_LOB
  ) when 'MLR_' then hd.[Working LOB] when 'BBI_' then hd.[Working LOB] when 'VTZ_' then hd.[Working LOB] when 'AMD_' then hd.[Working LOB] else concat(
   INTE.agent_site_group, '_', Rs.Skill_LOB
  ) end SKILL_LOB, 
  case HD.[Go LCM Department] when 'SDS,WFM,Inc' then 'AC3' when 'Consumer,Inc' then 'AC3' when 'SDS,Inc' then 'AC3' when 'AC3' then 'AC3' when '-' then '-' else 'Non_AC3' end [AC3_Non AC3], 
  is_ac3_flag, 
  contact_type, 
  agent_site_group, 
  login_name, 
  inte.routing_skill_cs_hierarchy2_name, 
  routing_skill_ops_hierarchy_name, 
  routing_skill_name, 
  to_skill_name, 
  convert(date,activity_date) Date, 
  direction, 
  agent_sic1_name, 
  agent_sic2_name, 
  agent_sic3_name, 
  agent_sic4_name, 
  rap_repeat_comm_id, 
  comm_id, 
  hmd_poll_yes, 
  hmd_total_responses, 
  total_contacts_hmd, 
  handled_contacts, 
  transferred_contacts 
FROM 
  [Dashboard].[dbo].[OLE DB Destination] INTE 
  LEFT JOIN [Dashboard].[dbo].[Auto_Headcount$] HD ON CONCAT(
    CONVERT(DATE, hd.Date), 
    [CSC ID]
  ) = CONCAT(
    CONVERT(DATE, inte.activity_date), 
    login_name
  ) 
  left join [SQLTestDBs].[dbo].[routing_skill$] Rs on 
    rs.Conso
   = concat(
    INTE.routing_skill_cs_hierarchy2_name, 
    INTE.contact_type,inte.agent_site_group
  ) 
where 
  agent_site_group in ('AMD','BBI','VTZ','MLR')
