
---*** Create HMD_Offer_Response Raw dump Every day***----
Create Table[Dashboard].dbo.HMD_Offer_Response (Week Nvarchar(max),Employee_Name nvarchar(max),Emp_Id nvarchar(max),Status Nvarchar(max),Supervisor_I nvarchar(max),Supervisor_II nvarchar(max),[Working Designation] nvarchar(max),
		AON nvarchar(30), Bucket nvarchar(max),Working_LoB nvarchar(max),LOB nvarchar(max),Skill_Lob nvarchar(max),AC3_Non_AC3 nvarchar(max),is_ac3_flag nvarchar(max),Contact_type nvarchar(max),
			Site nvarchar(max),LogIn_Name nvarchar(max),routing_skill_cs_hierarchy2_name nvarchar(max),routing_skill_ops_hierarchy_name nvarchar(max),routing_skill_name nvarchar(max),
			to_skill_name nvarchar(max),activity_date nvarchar(max),Direction nvarchar(max), agent_sic1_name nvarchar(max),agent_sic2_name nvarchar(max),agent_sic3_name nvarchar(max),
			agent_sic4_name nvarchar(max),rap_repeat_comm_id nvarchar(max),comm_id nvarchar(max),hmd_poll_yes int,hmd_total_responses int,total_contacts_hmd int,
			handled_contacts int,transferred_contacts int);


