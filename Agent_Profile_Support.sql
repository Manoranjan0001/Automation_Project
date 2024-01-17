


DROP TABLE IF EXISTS #csc_Agent_support
DROP TABLE IF EXISTS #csc_Agent_support2
DROP TABLE IF EXISTS #CSC_Agent_Profile_Support_Final
DROP TABLE IF EXISTS [Dashboard]..Agent_Profile_Final



update [Dashboard].[dbo].[CSC_Agent_Profile]   set [Talk_Time] = TRY_CONVERT(time,[Talk_Time])
update [Dashboard].[dbo].[CSC_Agent_Profile]   set Available_Idle_Time = TRY_CONVERT(time,Available_Idle_Time)




SELECT  CONVERT(DATE,LEFT(Interval,10)) [Date],
	LEFT ( [Agent],CHARINDEX('(',[Agent])-1) [CSC ID],
		[Agent]
      ,[Profile]
      ,[Site]
      ,[Interval]
      ,[After_Contact_Work_Time]
      ,[Aux_Busy_Time]
      ,[Aux_Time]
      ,[Available_Busy_Time]
      ,[Available_Idle_Time]
      ,[Break_Time]
      ,[Break2_Time]
      ,[Break3_Time]
      ,[Concurrent_Handle_Time]
      ,[Contacts_Handled]
      ,[Contacts_Handled_Incoming]
      ,[Contacts_Resolved]
      ,[Hold_Contacts]
      ,[Hold_Time]
      ,[Lunch_Time]
      ,[Meeting_Time]
      ,[Missed_Contacts]
      ,[Outage_Time]
      ,[Outbound_Handle_Time]
      ,[Personal_Time]
      ,[Ring_Time]
      ,[Staffed_Time]
      ,[Talk_Time]
      ,[Training_Time]
	  into #csc_Agent_support
	  
  FROM [Dashboard].[dbo].[CSC_Agent_Profile] 
  WHERE Contacts_Handled > 0 AND [Site] IN ('BBI','VTZ')
  SELECT CA.[Date],CA.[CSC ID], SUM(CA.Contacts_Handled) Contacts_Handled ,SUM(CA.Contacts_Handled_Incoming)Contacts_Handled_Incoming,SUM(CA.Contacts_Resolved )Contacts_Resolved,
		SUM(CA.Contacts_Handled)-SUM(CA.Contacts_Handled_Incoming) Contacts_Handled_Outbound,SUM(CA.Missed_Contacts) AS Missed_Contacts,
		CONVERT(TIME, DATEADD(SECOND, SUM(DATEDIFF(SECOND, '00:00:00',CA.Staffed_Time )), '00:00:00')) Staffed_Time,
		CONVERT(TIME,DATEADD(SECOND,SUM(DATEDIFF(SECOND,'00:00:00',CA.Aux_Time)),'00:00:00')) Aux_Time,
		CONVERT(TIME,DATEADD(SECOND,SUM(DATEDIFF(SECOND,'00:00:00',CA.Available_Idle_Time)),'00:00:00')) Available_Idle_Time,


		CONVERT(TIME,DATEADD(SECOND,SUM(DATEDIFF(SECOND,'00:00:00',CA.After_Contact_Work_Time)),'00:00:00')) After_Contact_Work_Time,
		CONVERT(TIME,DATEADD(SECOND,SUM(DATEDIFF(SECOND,'00:00:00',CA.Break_Time)),'00:00:00')) Break_Time,
		CONVERT(TIME,DATEADD(SECOND,SUM(DATEDIFF(SECOND,'00:00:00',CA.Break2_Time)),'00:00:00')) Break2_Time,
		CONVERT(TIME,DATEADD(SECOND,SUM(DATEDIFF(SECOND,'00:00:00',CA.Break3_Time)),'00:00:00')) Break3_Time,
		CONVERT(TIME,DATEADD(SECOND,SUM(DATEDIFF(SECOND,'00:00:00',CA.Concurrent_Handle_Time)),'00:00:00')) Concurrent_Handle_Time,
		CONVERT(TIME,DATEADD(SECOND,SUM(DATEDIFF(SECOND,'00:00:00',CA.Hold_Time)),'00:00:00')) Hold_Time,
		CONVERT(TIME,DATEADD(SECOND,SUM(DATEDIFF(SECOND,'00:00:00',CA.Lunch_Time)),'00:00:00')) Lunch_Time,
		CONVERT(TIME,DATEADD(SECOND,SUM(DATEDIFF(SECOND,'00:00:00',CA.Meeting_Time)),'00:00:00')) Meeting_Time,
		CONVERT(TIME,DATEADD(SECOND,SUM(DATEDIFF(SECOND,'00:00:00',CA.Outage_Time)),'00:00:00')) Outage_Time,
		CONVERT(TIME,DATEADD(SECOND,SUM(DATEDIFF(SECOND,'00:00:00',CA.Outbound_Handle_Time)),'00:00:00')) Outbound_Handle_Time,
		CONVERT(TIME,DATEADD(SECOND,SUM(DATEDIFF(SECOND,'00:00:00',CA.Personal_Time)),'00:00:00')) Personal_Time,
		CONVERT(TIME,DATEADD(SECOND,SUM(DATEDIFF(SECOND,'00:00:00',CA.Talk_Time)),'00:00:00')) Talk_Time,
		CONVERT(TIME,DATEADD(SECOND,SUM(DATEDIFF(SECOND,'00:00:00',CA.Training_Time)),'00:00:00')) Training_Time,
		CONVERT(TIME,DATEADD(SECOND,SUM(DATEDIFF(SECOND,'00:00:00',CA.Ring_Time)),'00:00:00')) Ring_Time,
		CONVERT(TIME,DATEADD(SECOND,SUM(DATEDIFF(SECOND,'00:00:00',CA.[Available_Busy_Time])),'00:00:00')) [Available_Busy_Time]

		
		
           
		
	INTO [Dashboard]..#csc_Agent_support2
  FROM #csc_Agent_support CA
  GROUP BY Date,[CSC ID]
  
  SELECT *,
   CONVERT(
            TIME,
                DATEADD(
                    SECOND,
                    CAST(
                        (
                            DATEPART(HOUR, CA1.Concurrent_Handle_Time) * 3600
                        ) + (
                            DATEPART(MINUTE, CA1.Concurrent_Handle_Time) * 60
                        ) + DATEPART(SECOND, CA1.Concurrent_Handle_Time)
                        AS FLOAT  -- Explicitly convert to a numeric type
                    ) / CA1.Contacts_Handled,
                    0
                ),
                108  -- Style code for HH:MI:SS
            )
  AS Handel_Time
	
	INTO #CSC_Agent_Profile_Support_Final
	FROM #csc_Agent_support2 CA1




  ;

  
 DROP TABLE IF EXISTS #CAMP_Agent_Profile
 DROP TABLE IF EXISTS #CAMP_Agent_Profile2
 DROP TABLE IF EXISTS #CAMP_Agent_Profile_Support_Final

SELECT	convert(DATE,LEFT([Period],10)) [Date],
		LEFT( [Agent],CHARINDEX('@',[Agent])-1) [CSC ID],
	[Site]
      ,[Agent]
      ,[Routing_Profile]
      ,[Period]
      ,[After_Contact_Work_Time]
      ,[Aux_Time]
      ,[Available_Busy_Time]
      ,[Available_Idle_Time]
      ,[Break_Time]
      ,[Break2_Time]
      ,[Break3_Time]
      ,[Total_Concurrent_Handle_Time]
      ,[Contacts_Handled]
      ,[Contacts_Handled_Incoming]
      ,[Contacts_Resolved]
      ,[Hold_Time]
      ,[Lunch_Time]
      ,[Meeting_Time]
      ,[Missed_Contacts]
      ,[Outage_Time]
      ,[Outbound_Handle_Time]
      ,[Personal_Time]
      ,[Ring_Time]
      ,[Staffed_Time]
      ,[Talk_Time]
      ,[Training_Time]
      ,[Aux_Busy_Time]
	  INTO #CAMP_Agent_Profile
  FROM [Dashboard].[dbo].[Camp_Agent_Profile]

  SELECT [Date],[CSC ID],SUM(Contacts_Handled) AS Contacts_Handled, SUM(Contacts_Handled_Incoming) AS Contacts_Handled_Incoming,SUM(Contacts_Resolved) Contacts_Resolved,
  SUM(CP.Contacts_Handled)-SUM(CP.Contacts_Handled_Incoming) Contacts_Handled_Outbound,SUM(Missed_Contacts) AS Missed_Contacts

	,CONVERT(TIME, DATEADD(SECOND, SUM(DATEDIFF(SECOND, '00:00:00',CP.Staffed_Time )), '00:00:00')) Staffed_Time
	,CONVERT(TIME, DATEADD(SECOND, SUM(DATEDIFF(SECOND, '00:00:00',CP.Aux_Time )), '00:00:00')) Aux_Time
	,CONVERT(TIME, DATEADD(SECOND, SUM(DATEDIFF(SECOND, '00:00:00',CP.Available_Idle_Time )), '00:00:00')) Available_Idle_Time
	,CONVERT(TIME, DATEADD(SECOND, SUM(DATEDIFF(SECOND, '00:00:00',CP.After_Contact_Work_Time )), '00:00:00')) After_Contact_Work_Time
	,CONVERT(TIME, DATEADD(SECOND, SUM(DATEDIFF(SECOND, '00:00:00',CP.Break_Time )), '00:00:00')) Break_Time
	,CONVERT(TIME, DATEADD(SECOND, SUM(DATEDIFF(SECOND, '00:00:00',CP.Break2_Time )), '00:00:00')) Break2_Time
	,CONVERT(TIME, DATEADD(SECOND, SUM(DATEDIFF(SECOND, '00:00:00',CP.Break3_Time )), '00:00:00')) Break3_Time
	,CONVERT(TIME, DATEADD(SECOND, SUM(DATEDIFF(SECOND, '00:00:00',(CAST(CP.Talk_Time AS DATETIME)+CAST(CP.Hold_Time AS DATETIME)+CAST(CP.After_Contact_Work_Time AS DATETIME)) )), '00:00:00')) [Concurrent_Handle_Time]
	,CONVERT(TIME, DATEADD(SECOND, SUM(DATEDIFF(SECOND, '00:00:00',CP.Hold_Time )), '00:00:00')) Hold_Time
	,CONVERT(TIME, DATEADD(SECOND, SUM(DATEDIFF(SECOND, '00:00:00',CP.Lunch_Time )), '00:00:00')) Lunch_Time
	,CONVERT(TIME, DATEADD(SECOND, SUM(DATEDIFF(SECOND, '00:00:00',CP.Meeting_Time )), '00:00:00')) Meeting_Time
	,CONVERT(TIME, DATEADD(SECOND, SUM(DATEDIFF(SECOND, '00:00:00',CP.Outage_Time )), '00:00:00')) Outage_Time
	,CONVERT(TIME, DATEADD(SECOND, SUM(DATEDIFF(SECOND, '00:00:00',CP.Outbound_Handle_Time )), '00:00:00')) Outbound_Handle_Time
	,CONVERT(TIME, DATEADD(SECOND, SUM(DATEDIFF(SECOND, '00:00:00',CP.Personal_Time )), '00:00:00')) Personal_Time
	,CONVERT(TIME, DATEADD(SECOND, SUM(DATEDIFF(SECOND, '00:00:00',CP.Talk_Time )), '00:00:00')) Talk_Time
	,CONVERT(TIME, DATEADD(SECOND, SUM(DATEDIFF(SECOND, '00:00:00',CP.Training_Time )), '00:00:00')) Training_Time
	,CONVERT(TIME, DATEADD(SECOND, SUM(DATEDIFF(SECOND, '00:00:00',CP.Ring_Time )), '00:00:00')) Ring_Time
	,CONVERT(TIME, DATEADD(SECOND, SUM(DATEDIFF(SECOND, '00:00:00',CP.Available_Busy_Time )), '00:00:00')) Available_Busy_Time



	INTO #CAMP_Agent_Profile2

  FROM #CAMP_Agent_Profile CP
  GROUP BY [Date],[CSC ID]
  ORDER BY Date
 SELECT
    *,
    CASE
        WHEN CP1.Contacts_Handled <> 0 THEN
            CONVERT(
                TIME,
                DATEADD(
                    SECOND,
                    CAST(
                        (
                            DATEPART(HOUR, CP1.Concurrent_Handle_Time) * 3600
                        ) + (
                            DATEPART(MINUTE, CP1.Concurrent_Handle_Time) * 60
                        ) + DATEPART(SECOND, CP1.Concurrent_Handle_Time)
                        AS FLOAT  -- Explicitly convert to a numeric type
                    ) / CP1.Contacts_Handled,
                    0
                ),
                108  -- Style code for HH:MI:SS
            )
        ELSE
            NULL
    END AS Handel_Time

	INTO #CAMP_Agent_Profile_Support_Final
FROM
    #CAMP_Agent_Profile2 CP1;

WITH CTE AS (
SELECT * FROM #CSC_Agent_Profile_Support_Final 
UNION
SELECT * FROM #CAMP_Agent_Profile_Support_Final
)
SELECT [Date],RIGHT([CSC ID],6)[EMP ID] ,[CSC ID],SUM(Contacts_Handled)Contacts_Handled,SUM(Contacts_Handled_Incoming) Contacts_Handled_Incoming,SUM(Contacts_Resolved) Contacts_Resolved,
	SUM(Missed_Contacts) Missed_Contacts,SUM(Contacts_Handled_Outbound) AS Contacts_Handled_Outbound
	,CONVERT(TIME, DATEADD(SECOND, SUM(DATEDIFF(SECOND, '00:00:00',Available_Idle_Time)), '00:00:00')) Available_Idle_Time
	,CONVERT(TIME, DATEADD(SECOND, SUM(DATEDIFF(SECOND, '00:00:00',After_Contact_Work_Time)), '00:00:00')) After_Contact_Work_Time
	,CONVERT(TIME, DATEADD(SECOND, SUM(DATEDIFF(SECOND, '00:00:00',Break_Time)), '00:00:00')) Break_Time
	,CONVERT(TIME, DATEADD(SECOND, SUM(DATEDIFF(SECOND, '00:00:00',Break2_Time)), '00:00:00')) Break2_Time
	,CONVERT(TIME, DATEADD(SECOND, SUM(DATEDIFF(SECOND, '00:00:00',Break3_Time)), '00:00:00')) Break3_Time
	,CONVERT(TIME, DATEADD(SECOND, SUM(DATEDIFF(SECOND, '00:00:00',Concurrent_Handle_Time)), '00:00:00')) Concurrent_Handle_Time
	,CONVERT(TIME, DATEADD(SECOND, SUM(DATEDIFF(SECOND, '00:00:00',Hold_Time)), '00:00:00')) Hold_Time
	,CONVERT(TIME, DATEADD(SECOND, SUM(DATEDIFF(SECOND, '00:00:00',Lunch_Time)), '00:00:00')) Lunch_Time
	,CONVERT(TIME, DATEADD(SECOND, SUM(DATEDIFF(SECOND, '00:00:00',Meeting_Time)), '00:00:00')) Meeting_Time
	,CONVERT(TIME, DATEADD(SECOND, SUM(DATEDIFF(SECOND, '00:00:00',Outage_Time)), '00:00:00')) Outage_Time
	,CONVERT(TIME, DATEADD(SECOND, SUM(DATEDIFF(SECOND, '00:00:00',Outbound_Handle_Time)), '00:00:00')) Outbound_Handle_Time
	,CONVERT(TIME, DATEADD(SECOND, SUM(DATEDIFF(SECOND, '00:00:00',Personal_Time)), '00:00:00')) Personal_Time
	,CONVERT(TIME, DATEADD(SECOND, SUM(DATEDIFF(SECOND, '00:00:00',Talk_Time)), '00:00:00')) Talk_Time
	,CONVERT(TIME, DATEADD(SECOND, SUM(DATEDIFF(SECOND, '00:00:00',Training_Time)), '00:00:00')) Training_Time
	,CONVERT(TIME, DATEADD(SECOND, SUM(DATEDIFF(SECOND, '00:00:00',Ring_Time)), '00:00:00')) Ring_Time
	,CONVERT(TIME, DATEADD(SECOND, SUM(DATEDIFF(SECOND, '00:00:00',Handel_Time)), '00:00:00')) Handel_Time
	,CONVERT(TIME, DATEADD(SECOND, SUM(DATEDIFF(SECOND, '00:00:00',Available_Busy_Time)), '00:00:00')) Available_Busy_Time



	INTO [Dashboard]..Agent_Profile_Final

	FROM CTE

GROUP BY [Date]
      ,[CSC ID]
     