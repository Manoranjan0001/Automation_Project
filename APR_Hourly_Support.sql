

drop table if exists #camp_raw
DROP TABLE IF EXISTS #camp_RAW1
drop table if exists #Camp_Output
drop table if exists #CAMP_PIVOT
DROP TABLE IF EXISTS #CAMP_RAW2
DROP TABLE IF EXISTS Dashboard..CAMP_APR_Hourly_Support_Final
DROP TABLE IF EXISTS #Roster
DROP TABLE IF EXISTS #CSC_HOURLY_FINAL_OUTPUT
DROP TABLE IF EXISTS #CAMP_HOURLY_FINAL_OUTPUT
DROP TABLE IF EXISTS Dashboard..Final_APR_Hourly

Declare @Startdate date = '2023-09-01'
Declare @Enddate  date = '2023-09-30'

select  rs.[Date],rs.[Site], rs.[Employee ID],h.[CSC ID],rs.[Name],rs.[Team Leader],rs.[Profile],rs.LOB,rs.[Status],rs.[Exit Date],rs.[Shift]
INto #Roster
from Dashboard..ROSTER RS

left join Dashboard..Auto_Headcount$ h on CONCAT(h.[Date],h.[EMP ID]) 
  = CONCAT(RS.[Date],rs.[Employee Id]) 
 where rs.[Date] between @Startdate and @Enddate

  
SELECT 
		LEFT(CM.[Agent],CHARINDEX('@',CM.Agent)-1) CSC_ID,
		LEFT (CM.[Period],10) AS Date,

		rs.Shift,
		--CONCAT(LEFT (CM.Period,10),' ',LEFT(CONVERT(time,MP.[Shift Start Time] ),5)) [Support_IN-Time]
		--,CONCAT(LEFT (CM.Period,10),' ',LEFT(CONVERT(time,MP.[Shift End Time] ),5)) [Support_Out-Time],
		CONCAT(SUBSTRING(CM.[Period],12,5),':00') [StartTime Support],

		CONCAT(LEFT (CM.[Period],10),' ',SUBSTRING(CM.Period,12,5))[Start_DataTime],
						
		--CONVERT(TIME,DATEDIFF(SECOND, '00:00:00', CM.[Staffed Time]), '00:00:00')),
		CM.[Staffed Time],
	--select top 1 * from Dashboard..APR_Hourly_Camp

		
	--	CASE WHEN CONVERT(NVARCHAR(MAX),CM.Aux_Time) > CONVERT(NVARCHAR(MAX),CM.Staffed_Time ) THEN ((CONVERT(NVARCHAR(MAX),CM.Staffed_Time) -CONVERT(NVARCHAR(MAX),CM.Aux_Time )) + CONVERT(NVARCHAR(MAX),CM.Aux_Busy_Time))
		--ELSE ((CONVERT(NVARCHAR(MAX),CM.Staffed_Time) -CONVERT(NVARCHAR(MAX),CM.Aux_Time )) + CONVERT(NVARCHAR(MAX),CM.Aux_Busy_Time))

		--END AS Netlogin,
		--SUM(DATEDIFF(SECOND, '00:00:00', CM.Aux_Time) + DATEDIFF(SECOND, '00:00:00', CM.Staffed_Time)) AS TotalDurationInSeconds
		
		CASE 
			 WHEN CM.[aux time] > CM.[staffed time] THEN 
				  convert(TIME,DATEADD(SECOND, DATEDIFF(SECOND, CM.[staffed time], CM.[aux time]) + DATEDIFF(SECOND, '00:00:00', CM.[aux busy time]), '00:00:00'))
			   ELSE 
				  CONVERT(TIME, DATEADD(SECOND, DATEDIFF(SECOND, CM.[aux time], CM.[staffed time]) + DATEDIFF(SECOND, '00:00:00', CM.[aux busy time]), '00:00:00'))
				END Netlogin,


		
		CASE  WHEN CM.Site = 'NO_SITE' THEN RS.Site
		ELSE CM.Site
		END [Actual Site],
		CM.[Site]
      ,[Agent],
		MP.[Shift Category]
	  into #camp_raw
  FROM [Dashboard].[dbo].[APR_Hourly_Camp] CM



  LEFT JOIN #Roster RS
   


  ON concat(convert(DATE,RS.[Date] ),rs.[CSC ID]) = CONCAT(LEFT (CM.Period,10),LEFT(CM.[Agent],CHARINDEX('@',CM.Agent)-1)
		 )

		LEFT JOIN [Dashboard].[dbo].[Map1] MP
		ON CONCAT(MP.Site,MP.SHIFT) = CONCAT(CM.Site,RS.SHIFT)

	
		drop table if exists #camp_RAW1
		
		
	SELECT cr.*,CONCAT([DATE],' ',LEFT(CONVERT(time,MP.[Shift Start Time] ),5)) [Support_IN-Time]
		,CONCAT([DATE],' ',LEFT(CONVERT(time,MP.[Shift End Time] ),5)) [Support_Out-Time]
		into #camp_RAW1
	FROM #camp_raw cr

	
	LEFT JOIN [Dashboard].[dbo].[Map1] MP
	ON
	CONCAT(MP.Site,MP.SHIFT) = CONCAT(cr.[Actual Site],cr.SHIFT)
	 where cr.[Date] between @Startdate and @Enddate
	
	--DECLARE VTZ_TIME  = '7:00:00'
	--DECLARE IN_TIME  = '1:00:00'

	SELECT  CASE 
				WHEN [Shift] = 'WO' OR [Shift]='Leave' THEN CONVERT(DATE,DATEADD(DAY,-1,[Date]))
				WHEN [Actual Site] = 'VTZ' AND [Shift Category] = 'Odd' AND [StartTime Support] <= '07:00:00' THEN CONVERT(DATE,DATEADD(DAY,-1,[Date]))
				WHEN [Shift Category] = 'Even' AND [StartTime Support] <= '01:00:00' THEN CONVERT(DATE,DATEADD(DAY,-1,[Date]))
				WHEN [Shift Category] = 'Odd' AND [StartTime Support] <= '01:00:00' THEN CONVERT(DATE,DATEADD(DAY,-1,[Date]))
				ELSE [Date]
				END DATE1
	,* 
	INTO #CAMP_RAW2
	FROM #camp_RAW1 CR1

	ORDER BY DATE1

	SELECT CONVERT(DATE,DATE1) [Date],CR2.CSC_ID,CONVERT(TIME, DATEADD(SECOND, SUM(DATEDIFF(SECOND, '00:00:00', [Staffed Time])), '00:00:00')) Stafftime,
					CONVERT(TIME, DATEADD(SECOND, SUM(DATEDIFF(SECOND, '00:00:00', Netlogin)), '00:00:00')) Netlogin

	INTO #CAMP_HOURLY_FINAL_OUTPUT

	FROM #CAMP_RAW2 CR2


	GROUP BY DATE1,CR2.CSC_ID

	ORDER BY DATE1

	--select * from dashboard..map1 where shift in ('1900-0000','1600-1900/0000-0600','0200-0700')

	--update  dashboard..map1  SET [Shift Category] = 'Odd' where shift in ('1900-0000','1600-1900/0000-0600','0200-0700')

	
	----------------------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  CSC APR HOURLY CALCULATION  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<----------------------------
	----------------------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  CSC APR HOURLY CALCULATION  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<----------------------------
	----------------------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  CSC APR HOURLY CALCULATION  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<----------------------------

;



drop table if exists  #Csc_Raw
drop table if exists #CSC_Output
drop table if exists Dashboard..CSC_APR_Hourly_Support_Final
DROP TABLE IF EXISTS #Roster1
DROP TABLE IF EXISTS #Csc_Raw1

select  rs.[Date],rs.[Site], rs.[Employee ID],h.[CSC ID],rs.[Name],rs.[Team Leader],rs.[Profile],rs.LOB,rs.[Status],rs.[Exit Date],rs.[Shift]
INto #Roster1
from Dashboard..ROSTER RS
left join Dashboard..Auto_Headcount$ h on CONCAT(h.[Date],h.[EMP ID]) 
  = CONCAT(RS.[Date],rs.[Employee Id]) 
  	 where rs.[Date] between @Startdate and @Enddate

update [Dashboard].[dbo].APR_Hourly_CSC set [Aux Time] = '00:00:00'  where [Aux Time]  IS NULL


SELECT 
	LEFT(CS.[Agent],CHARINDEX('(',CS.Agent)-1) CSC_ID,
 
		CONVERT(DATE,LEFT (CS.Interval,10)) AS Date,
		
		RS.Shift
		,CONCAT(SUBSTRING( cs.Interval, 12,5), ':00') AS [StartTime Support]
		, convert(datetime,CONCAT(CONVERT(DATE,LEFT (cs.Interval,10)),' ',LEFT(CONVERT(time,MP.[Shift Start Time] ),5))) [Support_IN-Time]
		,convert(datetime,CONCAT(CONVERT(DATE,LEFT (cs.Interval,10)),' ',LEFT(CONVERT(time,MP.[Shift End Time] ),5))) +1 [Support_Out-Time]


		,convert(datetime,CONCAT(convert(date,(LEFT (cs.Interval,10))),' ',SUBSTRING(CS.Interval,12,5)))[Start_DataTime],
		
		 CONVERT(TIME, DATEADD(SECOND, DATEDIFF(SECOND, CS.[Aux Time], CS.[Staffed Time]) + DATEDIFF(SECOND, '00:00:00', CS.[Aux Busy Time]), '00:00:00')) NetLogin,
		CS.[Agent]
      ,CS.[Profile]
      ,CS.[Site]
      ,[Interval]
      ,[Aux Busy Time]
      ,[Aux Time]
      ,[Staffed Time],
	  mp.[Shift Category]
	  
	  into #Csc_Raw
  FROM [Dashboard].[dbo].APR_Hourly_CSC CS
  LEFT JOIN #Roster1 RS
  ON CONCAT(CONVERT(DATE,RS.Date),RS.[CSC ID]) = CONCAT(
		CONVERT(DATE,LEFT (CS.Interval,10)),LEFT(CS.[Agent],CHARINDEX('(',CS.Agent)-1))
		LEFT JOIN [Dashboard].[dbo].[Map1] MP
	ON
	CONCAT(MP.Site,MP.SHIFT) = CONCAT(cs.Site,rs.SHIFT)
		where cs.[Site] in ('BBI','VTZ')
		  
		SELECT CASE 
				WHEN [Shift] = 'WO' OR [Shift]='Leave' THEN CONVERT(DATE,DATEADD(DAY,-1,[Date]))
				WHEN [Site] = 'VTZ' AND [Shift Category] = 'Odd' AND [StartTime Support] <= '07:00:00' THEN CONVERT(DATE,DATEADD(DAY,-1,[Date]))
				WHEN [Shift Category] = 'Even' AND [StartTime Support] <= '01:00:00' THEN CONVERT(DATE,DATEADD(DAY,-1,[Date]))
				WHEN [Shift Category] = 'Odd' AND [StartTime Support] <= '01:00:00' THEN CONVERT(DATE,DATEADD(DAY,-1,[Date]))
				ELSE [Date]
				END DATE1
		,*
		INTO #Csc_Raw1
		from #Csc_Raw 
		  	 where [Date] between @Startdate and @Enddate


		SELECT CONVERT(DATE,DATE1)[Date],CSC_ID,CONVERT(TIME, DATEADD(SECOND, SUM(DATEDIFF(SECOND, '00:00:00', [Staffed Time])), '00:00:00')) Stafftime,
							CONVERT(TIME, DATEADD(SECOND, SUM(DATEDIFF(SECOND, '00:00:00', NetLogin)), '00:00:00')) NetLogin
		
		INTO #CSC_HOURLY_FINAL_OUTPUT

		FROM #Csc_Raw1
		GROUP BY DATE1,CSC_ID

SELECT *
INTO Dashboard..Final_APR_Hourly
FROM #CAMP_HOURLY_FINAL_OUTPUT

UNION

-- Select rows from #CSC_HOURLY_FINAL_OUTPUT that are not in #CAMP_HOURLY_FINAL_OUTPUT
SELECT *

FROM #CSC_HOURLY_FINAL_OUTPUT
WHERE CONCAT([Date],CSC_ID) NOT IN (SELECT CONCAT([Date],CSC_ID) FROM #CAMP_HOURLY_FINAL_OUTPUT);
