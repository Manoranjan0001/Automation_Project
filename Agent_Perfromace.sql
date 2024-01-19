
Declare @Startdate date = '2023-09-01'
Declare @Enddate date = '2023-09-30'


DROP TABLE IF EXISTS #Roster
DROP TABLE IF EXISTS #Agent_Support1
DROP TABLE IF EXISTS #Downtime
DROP TABLE IF EXISTS #Agent_Support2

------->>>>>>>>>>>>>>>>>> Downtime
SELECT [Date],[CSC ID],	CONVERT(TIME, DATEADD(SECOND, SUM(DATEDIFF(SECOND, '00:00:00', [Conducted Time])), '00:00:00')) [Conducted Time]
INTO #Downtime
FROM Dashboard..Downtime GROUP BY [Date], [CSC ID]

----->>>>>> Roster
select  rs.[Date],rs.[Site], rs.[Employee ID],h.[CSC ID],rs.[Name],rs.[Team Leader],rs.[Profile],rs.LOB,rs.[Status],rs.[Exit Date],rs.[Shift]
INto #Roster
from Dashboard..ROSTER RS

left join Dashboard..Auto_Headcount$ h on CONCAT(h.[Date],h.[EMP ID]) 
  = CONCAT(RS.[Date],rs.[Employee Id]) 
  where RS.[Date] BETWEEN @Startdate AND @Enddate
  ;

  select 
    HD.SITE, 
    CONVERT(DATE, HD.DATE) DATE, 
    HD.[CSC ID], 
    HD.[EMP ID], 
    HD.[Employee Name], 
    HD.[Supervisor I], 
    HD.[Supervisor II], 
    HD.[Quality Name], 
    HD.LOB, 
    HD.[Working LOB], 
    HD.[Designation], 
    convert(date, HD.[Graduation Date]) [Graduation Date], 
    HD.AON, 
    HD.Bucket, 
    HD.[Batch ID], 
    HD.Status, 
    HD.[Exit Date], 
	 CASE 
        WHEN hd.[Go LCM Department] LIKE '%inc%' THEN 'AC3'
        WHEN hd.[Go LCM Department] = 'AC3' THEN 'AC3'
        ELSE 'Non_AC3'
    END AS AC3_Non_AC3,
    RS.Shift, 
    concat(
      left(
        datename(mm, HD.Date), 
        3
      ), 
      '_', 
      right(
        datename(yy, HD.Date), 
        2
      )
    ) Month, 
    CONCAT(
      'Week_', 
      DATEPART(WEEK, HD.Date)
    ) Week, 
    CASE WHEN HD.[Working LOB] LIKE '%MU%' THEN 'MessageUs' ELSE 'Phone' end Channel, 
    
    case rs.shift when 'WO' then '-' when 'ABSC' then '-' when 'Leave' then '-' when 'Inactive' then '-' when 'Deroster' then '-' when 'Moved-out' then '-' when 'Training' then '-' else concat(
      CONVERT(DATE, rs.date), 
      ' ', 
      left(rs.shift, 2), 
      ':', 
      right(rs.shift, 2)
    ) end as Shift_LoginTime, 
    case rs.shift when 'WO' then '-' when 'ABSC' then '-' when 'Leave' then '-' when 'Inactive' then '-' when 'Deroster' then '-' when 'Moved-out' then '-' when 'Training' then '-' else concat(
      convert(date, rs.date), 
      ' ', 
      left(
        reverse(
          left(
            reverse(rs.shift), 
            4
          )
        ), 
        2
      ), 
      ':', 
      reverse(
        left(
          reverse(rs.shift), 
          2
        )
      )
    ) end Shift_LogoutTime, 


	left(concat(convert(date,hd.Date),' ',convert(time,mp.[Shift Start Time])),19) as [Shift Start Time],
	left(concat(convert(date,hd.Date),' ',convert(time,mp.[Shift End Time])),19) as [Shift End Time],
	LEFT(LN.[Actual Login Time] ,19) [CSC_LoginTime]
	,LEFT(LG.[Actual Logout Time],19) [CSC_LogoutTime]
		,case rs.shift when 'Training' then 0 when 'Deroster' then 0 when 'ABSC' then 0 when 'Inactive' then 0 when 'Moved_Out' then 0 when '-' then 0 else 1 end Headcount, 
    case rs.shift when 'Training' then 0 when 'Deroster' then 0 when 'ABSC' then 0 when 'Inactive' then 0 when 'Moved_Out' then 0 when '-' then 0 when 'Leave' then 0 when 'Wo' then 0 else 1 end [Schedule Count], 
    case rs.shift when 'WO' then 1 else 0 end [WO Count], 
    case rs.shift when 'Leave' then 1 else 0 end [Leave Count],

	dw.[Conducted Time],
	AF.Contacts_Handled,af.Contacts_Handled_Incoming,af.Contacts_Resolved,af.Contacts_Handled_Outbound,af.Missed_Contacts,
	AF.Available_Idle_Time,AF.Available_Busy_Time,AF.After_Contact_Work_Time,AF.Break_Time,AF.Break2_Time,AF.Break3_Time,AF.Concurrent_Handle_Time,AF.Hold_Time,
	AF.Lunch_Time,AF.Meeting_Time,AF.Outage_Time,AF.Outbound_Handle_Time,AF.Personal_Time,AF.Talk_Time,AF.Training_Time,AF.Ring_Time,AF.Handel_Time,
	MP.[HC Count],MP.[Schedule Count] [Schedule_Count]
	



    into #Agent_Support1
  from 
    [Dashboard].[dbo].[Auto_Headcount$] HD 

	--SELECT ROW_NUMBER () OVER (PARTITION BY SITE,SHIFT ORDER BY SITE )[ROW] ,* FROM Map1 ORDER BY ROW DESC

    LEFT JOIN #Roster RS ON CONCAT(
      CONVERT(DATE, HD.DATE), 
      HD.[EMP ID]
    ) = CONCAT(
      CONVERT(DATE, RS.DATE), 
      RS.[Employee ID]
    ) 

    left join [Dashboard].[dbo].[Downtime] Dw on concat(Dw.date, Dw.[empid]) = CONCAT(
      CONVERT(DATE, HD.DATE), 
      HD.[emp ID]
    ) 
 
	LEFT JOIN [Dashboard].dbo.Map1 MP
	ON concat(MP.Site,MP.Shift) = concat(hd.Site,rs.shift)

	LEFT JOIN [Dashboard].[dbo].[agent_login] LN
	ON  CONCAT(LN.DATESHIFT,LN.[CSC ID]) = CONCAT(CONVERT(DATE,HD.Date ),HD.[CSC ID])

	LEFT JOIN [Dashboard].[dbo].[agent_Logout] LG
	ON CONCAT(LG.DATESHIFT,LG.[CSC ID]) = CONCAT(CONVERT(DATE,HD.Date ),HD.[CSC ID])

	LEFT JOIN Dashboard.DBO.Agent_Profile_Final AF
	ON CONCAT(CONVERT(DATE,HD.[Date]),HD.[CSC ID])=CONCAT(AF.[Date],AF.[CSC ID]) 
	
  WHERE 
    HD.Site IN ('AMD', 'BBI', 'VTZ', 'MLR') and hd.[Working LOB] <> 'BBI_Smartbiz' AND
	
	   HD.[Date] BETWEEN @Startdate AND @Enddate

	select a1.[Site],a1.[DATE],a1.[CSC ID],a1.[EMP ID],a1.[Employee Name],a1.[Supervisor I],a1.[Supervisor II],a1.[Quality Name],a1.LOB,a1.[Working LOB],a1.Designation
	,a1.[Graduation Date],a1.AON,a1.Bucket,a1.[Batch ID],a1.[Status],a1.[Exit Date],a1.[Shift],a1.AC3_Non_AC3,A1.[Month],A1.[Week],A1.Channel,A1.Shift_LoginTime,A1.Shift_LogoutTime
	,A1.[Shift Start Time],A1.[Shift End Time],A1.CSC_LoginTime,A1.CSC_LogoutTime,[Schedule Count],[HC Count] as [Headcount],
		CASE 
    WHEN TRY_CONVERT(DATETIME, A1.CSC_LoginTime) IS NULL THEN 0
    -- WHEN ISDATE(A1.Shift_LoginTime) = 0 OR ISDATE(A1.CSC_LoginTime) = 0 THEN 0  -- Check if the dates are not valid
    WHEN A1.[Schedule Count] = 1 AND DATEDIFF(MINUTE, TRY_CONVERT(DATETIME, A1.CSC_LoginTime), TRY_CONVERT(DATETIME, A1.Shift_LoginTime)) BETWEEN - 5 AND 5 THEN 1
	--WHEN DATEDIFF(MINUTE, TRY_CONVERT(DATETIME, A1.CSC_LoginTime), TRY_CONVERT(DATETIME, A1.Shift_LoginTime)) >=5 THEN 0
	
    ELSE 0
END AS [Login Adhered],

	CASE 
    WHEN TRY_CONVERT(DATETIME, A1.CSC_LogoutTime) IS NULL THEN 0
    -- WHEN ISDATE(A1.Shift_LoginTime) = 0 OR ISDATE(A1.CSC_LoginTime) = 0 THEN 0  -- Check if the dates are not valid
    WHEN A1.[Schedule Count] = 1 AND DATEDIFF(MINUTE, TRY_CONVERT(DATETIME, A1.CSC_LogoutTime), TRY_CONVERT(DATETIME, A1.Shift_LogoutTime)) <=5 THEN 1

	
    ELSE 0
END AS [Logout Adhered],
		
		CASE WHEN a1.[Shift] = 'WO' THEN 1
		ELSE 0 END [WO Count],

		CASE WHEN A1.[Shift] = 'Leave' THEN 1
		ELSE 0 END [Leave Count],
		FH.Stafftime [Staff Time (Shift Wise)],FH.Netlogin [Net Login (Shift Wise)],CONVERT(TIME,CONVERT(DATETIME,FH.Stafftime)-CONVERT(DATETIME,FH.Netlogin)) AS [Aux Time (Shift Wise)],
		DW.[Conducted Time] AS [Downtime (Shift Wise)]

		,Contacts_Handled   [Contacts Handled]
		,Contacts_Handled_Incoming	[Contacts Handled Incoming]
		, CASE WHEN Channel = 'MessageUs' THEN Contacts_Handled_Incoming
		END [MessageUs Contact Incoming]

		,CASE WHEN Channel = 'Phone' THEN Contacts_Handled_Incoming
		END [Phone Contact Incoming]
		,Contacts_Handled_Outbound [ Contacts Handled Outbound]
		,Contacts_Resolved [Contacts Resolved]
		,Missed_Contacts [Missed Contacts]

		,CASE WHEN Channel = 'MessageUs' THEN Concurrent_Handle_Time
		END [MessageUs Concurrent Handle Time],
		Available_Idle_Time [Available Idle Time]
		,Available_Busy_Time [Available Busy Time],
		After_Contact_Work_Time [After Contact Work Time]
		,Break_Time [Break Time]
		,Break2_Time [Break2 Time]
		,Break3_Time [Break3 Time]
		,Concurrent_Handle_Time [Concurrent Handle Time]
		,Hold_Time [Hold Time]
		,Lunch_Time [Lunch Time]
		,Meeting_Time [Meeting Time]
		,Outage_Time [Outage Time]
		,Outbound_Handle_Time [Outbound Handle Time]
		,Personal_Time [Personal Time]
		,Talk_Time [Talk Time]
		,Training_Time [Training Time]
		,Ring_Time [Ring Time]
		,Handel_Time [Handle Time]

		INTO #Agent_Support2

	from #Agent_Support1 a1
	LEFT JOIN Dashboard..[Final_APR_Hourly] FH ON CONCAT(CONVERT(DATE,FH.[Date]),CSC_ID) = CONCAT(CONVERT(DATE,A1.[Date]),A1.[CSC ID])

	LEFT JOIN #Downtime DW ON CONCAT(CONVERT(DATE,DW.[Date]),DW.[CSC ID])  = CONCAT(CONVERT(DATE,A1.[Date]),A1.[CSC ID])

	
--	SELECT TRY_CONVERT(DATETIME, CSC_LoginTime), TRY_CONVERT(DATETIME, Shift_LoginTime),DATEDIFF(MINUTE(TRY_CONVERT(DATETIME, CSC_LoginTime), TRY_CONVERT(DATETIME, Shift_LoginTime)) FROM #Agent_Support1

--	SELECT 
--    TRY_CONVERT(DATETIME, CSC_LoginTime) AS CSC_LoginTime_Converted,
--    TRY_CONVERT(DATETIME, Shift_LoginTime) AS Shift_LoginTime_Converted,
--    DATEDIFF(MINUTE, TRY_CONVERT(DATETIME, CSC_LoginTime), TRY_CONVERT(DATETIME, Shift_LoginTime)) AS TimeDifference
--FROM 
--    #Agent_Support1;

DROP TABLE IF EXISTS #Agent_Support3
SELECT *,CASE WHEN [Status] = 'Inactive' THEN 0 
				WHEN [Staff Time (Shift Wise)]  IS NULL OR [Staff Time (Shift Wise)] = '00:00:00' THEN 0
				ELSE 1
				END [Present Count]
				, CONVERT(TIME, 
    DATEADD(SECOND, 
        DATEDIFF(SECOND, '00:00:00', ISNULL([Staff Time (Shift Wise)], '00:00:00')) + 
        DATEDIFF(SECOND, '00:00:00', ISNULL([Downtime (Shift Wise)], '00:00:00')), 
    '00:00:00')) AS [Staff Time + DT (Shift Wise)],

	CONVERT(TIME,DATEADD(SECOND,DATEDIFF(SECOND,'00:00:00',ISNULL([Net Login (Shift Wise)],'00:00:00'))+
			DATEDIFF(SECOND,'00:00:00',ISNULL([Downtime (Shift Wise)],'00:00:00')),'00:00:00')) [Net Login+DT (Shift Wise)]
	,CONVERT(TIME,DATEADD(SECOND,DATEDIFF(SECOND,'00:00:00',ISNULL([Break Time],'00:00:00'))+DATEDIFF(SECOND,'00:00:00',ISNULL([Break2 Time],'00:00:00'))+
	DATEDIFF(SECOND,'00:00:00',ISNULL([Break3 Time],'00:00:00'))+
	DATEDIFF(SECOND,'00:00:00', ISNULL([Personal Time],'00:00:00'))+
	DATEDIFF(SECOND,'00:00:00',ISNULL([Lunch Time],'00:00:00')),'00:00:00')) AS [Non.Prod_Aux]
	
	,CASE WHEN Channel = 'Phone'
	THEN CONVERT(TIME,DATEADD(SECOND,DATEDIFF(SECOND,'00:00:00',ISNULL([Talk Time],'00:00:00'))+DATEDIFF(SECOND,'00:00:00',ISNULL([Hold Time],'00:00:00'))+
			DATEDIFF(SECOND,'00:00:00',ISNULL([After Contact Work Time],'00:00:00')),'00:00:00'))
			ELSE '00:00:00'
			END [IB TTT]
			,
			CASE WHEN Bucket IN ('OJT','Training') THEN 'OJT'
			ELSE 'Production'
			END [Status_in_Floor]
			INTO #Agent_Support3
FROM  #Agent_Support2
	
	DROP TABLE IF EXISTS #Agent_Support4

	SELECT 
	CASE WHEN [Status] = 'Inactive' THEN 0 
	WHEN [Login Adhered]= 1 AND [Logout Adhered] = 1 THEN 1
	ELSE 0 END [Schedule Adhered],
		
		CASE 
			WHEN [Staff Time + DT (Shift Wise)]  >= '08:00:00' THEN 1
				WHEN [Staff Time + DT (Shift Wise)] >= '04:00:00' THEN 0.5
					ELSE 0	
					END [Mandays],

			CASE WHEN [Schedule Count] = 1 AND Status_in_Floor = 'Production'
					AND [Net Login (Shift Wise)] >= '08:00:00' THEN 1
					ELSE 0 END [Login HR Met/Not_Met]
		,
			CASE WHEN [Status] = 'Inactive' THEN 0 
					WHEN [Schedule Count] = 1 AND [Present Count] = 0 THEN 1
					ELSE 0
					END [Absent Count]
	,*
	INTO #Agent_Support4
	FROM #Agent_Support3

		DROP TABLE IF EXISTS #Final_IN_Agent_Performance
	SELECT
		CASE WHEN [Status] = 'Inactive' THEN 0 
			WHEN Mandays = 0.5 THEN 1
			ELSE 0 
			END [HD Count]
	, 
	CONVERT(TIME,DATEADD(MINUTE, DATEDIFF(MINUTE, '00:00', [Staff Time (Shift Wise)]) * [Mandays], '00:00')) AS [Prod. StaffTime]
	,CONVERT(TIME,DATEADD(MINUTE, DATEDIFF(MINUTE, '00:00', [Net Login (Shift Wise)] )* [Mandays], '00:00')) AS [Prod. NetLogin]
	,CONVERT(TIME,DATEADD(MINUTE, DATEDIFF(MINUTE, '00:00', [Aux Time (Shift Wise)] )* [Mandays], '00:00')) AS [Prod. AuxTime]
	
	
	,CONVERT(TIME,DATEADD(MINUTE,DATEDIFF(MINUTE,'00:00',[Available Idle Time]) * Mandays,'00:00')) AS [Prod. IdleTime]
	,CONVERT(TIME,DATEADD(MINUTE,DATEDIFF(MINUTE,'00:00',[Available Busy Time]) * Mandays,'00:00')) AS [Prod. BusyTime]
	,CONVERT(TIME,DATEADD(MINUTE,DATEDIFF(MINUTE,'00:00',[Downtime (Shift Wise)]) * Mandays,'00:00')) AS [Prod. Downtime]

	
	,*

		 INTO  #Final_IN_Agent_Performance

		FROM #Agent_Support4
		
		DROP TABLE IF EXISTS [Dashboard]..Final_IN_Agent_Performance

		SELECT [Site],[DATE],[CSC ID],[EMP ID],[Employee Name],[Supervisor I],[Supervisor II],[Quality Name],LOB,[Working LOB],Designation,
				[Graduation Date],AON,Bucket,[Batch ID],[Status],[Exit Date],[Shift],AC3_Non_AC3 AS [AC3 & Non_AC3],[Month],[Week],Channel,Shift_LoginTime,
				Shift_LogoutTime,[Shift Start Time],[Shift End Time],CSC_LoginTime,CSC_LogoutTime,[Login Adhered],[Logout Adhered],[Schedule Adhered],Headcount,
				[Schedule Count],[Present Count],[Absent Count],[WO Count],[Leave Count],[HD Count],[Staff Time (Shift Wise)],[Net Login (Shift Wise)],
				[Aux Time (Shift Wise)],[Downtime (Shift Wise)],[Staff Time + DT (Shift Wise)],[Net Login+DT (Shift Wise)],Mandays,[Contacts Handled],
				[Contacts Handled Incoming],[MessageUs Contact Incoming],[Phone Contact Incoming],[ Contacts Handled Outbound],[Contacts Resolved],
				[Missed Contacts],[MessageUs Concurrent Handle Time],[Available Idle Time],[Available Busy Time],[After Contact Work Time],[Break Time],[Break2 Time],[Break3 Time],
				[Concurrent Handle Time],[Hold Time],[Lunch Time],[Meeting Time],[Outage Time],[Outbound Handle Time],[Personal Time],[Talk Time],
				[Training Time],[Ring Time],[Handle Time],[Prod. StaffTime],[Prod. NetLogin],[Prod. AuxTime],[Non.Prod_Aux],[Prod. IdleTime],[Prod. BusyTime],
				[Prod. Downtime],[IB TTT],Status_in_Floor,[Login HR Met/Not_Met]

			INTO [Dashboard]..Final_IN_Agent_Performance
		FROM 	 #Final_IN_Agent_Performance
		ORDER BY DATE , SITE