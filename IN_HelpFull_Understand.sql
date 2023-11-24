with Helpful_CTE as(
  Select 
    concat(
      left(
        datename(mm, activity_date), 
        3
      ), 
      ' ', 
      right(
        datename(yy, activity_date), 
        2
      )
    ) Month, 
    concat(
      'Week_', 
      datepart(week, activity_date)
    ) WeeK, 
    convert(date, activity_date) Date, 
    case concat(
      agent_site_group, Skill1.Skill_LOB
    ) when 'VTZ' THEN HEAD.[Working LOB] WHEN 'MLR' THEN HEAD.[Working LOB] WHEN 'BBI' THEN HEAD.[Working LOB] WHEN 'CYB' THEN HEAD.[Working LOB] WHEN 'AMD' THEN HEAD.[Working LOB] ELSE HEAD.[Working LOB] END [to_skill_name_Skill LOB], 
    CASE CONCAT(
      INTE.agent_site_group, '_', SKILL1.Skill_LOB
    ) WHEN 'VTZ_' THEN HEAD.[Working LOB] WHEN 'MLR_' THEN HEAD.[Working LOB] WHEN 'BBI_' THEN HEAD.[Working LOB] WHEN 'CYB_' THEN HEAD.[Working LOB] WHEN 'AMD_' THEN HEAD.[Working LOB] ELSE HEAD.[Working LOB] END routing_skill_name_Skill_LOB, 
    case concat(
      INTE.agent_site_group, '_', Rs.Skill_LOB
    ) when 'MLR_' then HEAD.[Working LOB] when 'BBI_' then HEAD.[Working LOB] when 'VTZ_' then HEAD.[Working LOB] when 'AMD_' then HEAD.[Working LOB] else concat(
      INTE.agent_site_group, '_', Rs.Skill_LOB
    ) end SKILL_LOB, 
    head.[Emp ID], 
    head.[Employee Name], 
    head.[Supervisor I], 
    head.[Supervisor II], 
    head.LOB, 
    head.[Working LOB], 
    head.Bucket, 
    head.[Working Designation]as[Designation], 
    head.AON, 
    head.Batch, 
    case head.[Go LCM Department] when 'SDS,WFM,Inc' then 'AC3' when 'Consumer,Inc' then 'AC3' when 'SDS,Inc' then 'AC3' when 'AC3' then 'AC3' when '-' then '-' else 'Non_AC3' end [AC3_Non AC3], 
    INTE.marketplace_name, 
    contact_type, 
    agent_site_group, 
    login_name, 
    routing_skill_amzn_hierarchy_name, 
    routing_skill_cs_hierarchy1_name, 
    inte.routing_skill_cs_hierarchy2_name routing_skill_ops_hierarchy_name, 
    routing_skill_name, 
    direction, 
    activity_date, 
    agent_sic1_name, 
    agent_sic2_name, 
    agent_sic3_name, 
    agent_sic4_name, 
    comm_id, 
    understandability_12345count, 
    understandability_45count, 
    ccx_45count, 
    ccx_12345count 
  from 
    [Dashboard].[dbo].[OLE DB Destination] as inte 
    left join [Dashboard].[dbo].[Auto_Headcount$] head on concat(
      head.[CSC ID], 
      convert(date, head.Date)
    ) = concat(
      inte.login_name, 
      convert(date, inte.activity_date)
    ) 
    left join [SQLTestDBs].[dbo].[Skill_Alignment$] Skill1 on skill1.Skill_Name = inte.routing_skill_name 
    left join [SQLTestDBs].[dbo].[routing_skill$] Rs on concat(rs.Conso, rs.site) = concat(
      INTE.routing_skill_cs_hierarchy2_name, 
      INTE.contact_type, inte.agent_site_group
    ) 
  WHERE 
    agent_site_group IN ('AMD', 'BBI', 'MLR', 'VTZ') 
    AND (
      understandability_12345count + understandability_45count + ccx_45count + ccx_12345count
    ) >= 1
) 
select 
  case when SKILL_LOB = [Working LOB] then 'Dedicated' else 'Cross' end Category, 
  * 
from 
  Helpful_CTE 
order by 
  Date
