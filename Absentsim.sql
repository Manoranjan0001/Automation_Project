
DROP TABLE IF EXISTS #Absent_Raw
SELECT	
	--ROW_NUMBER() over ( partition by a.Site order by a.site) [Sr No],

		[EMP ID],DATE as [Date]	,[CSC ID]
		   ,[Employee Name]
      ,[Supervisor I]
      ,[Supervisor II],
	  Designation
      
      ,[Working LOB]
      ,[Graduation Date]
      ,[AON]
      ,[Bucket]
      
      ,[Status]
	  Site
      ,[Shift]
      ,[Schedule Count]
      ,[Staff Time (Shift Wise)]
      ,[Net Login (Shift Wise)],
     
	 case when 
	-- a.[Staff Time (Shift Wise)] = '-' THEN 'Yes' or 
	 --a.[Staff Time (Shift Wise)] = 'N/A' then 'Yes' or
	 a.[Staff Time (Shift Wise)] is null then 'Yes'
	 
	 ELSE 'No' END [Absent],
	 	 case when 
	-- a.[Staff Time (Shift Wise)] = '-' THEN 'Yes' or 
	 --a.[Staff Time (Shift Wise)] = 'N/A' then 'Yes' or
	 a.[Staff Time (Shift Wise)] is null then 1
	 
	 ELSE 0 END [Absent Count]
	 
	 INTO #Absent_Raw
  FROM [Dashboard].[dbo].[Final_IN_Agent_Performance] A
  where a.Designation = 'CSA' and [Schedule Count] >= 1 and Bucket <> 'Training'
  order by a.[EMP ID],a.Date

drop table if exists #Absent1
    SELECT *,
        CASE
            WHEN [Staff Time (Shift Wise)] IS NULL THEN ROW_NUMBER() OVER (PARTITION BY [EMP ID], [Absent Count] ORDER BY [EMP ID])
            ELSE 0
        END AS [Consiq Absent]
		 into #Absent1
    FROM #Absent_Raw
	ORDER BY [EMP ID],Date
	;

--	SELECT *,CASE WHEN LAG([Staff Time (Shift Wise)]) OVER(ORDER BY [EMP ID],DATE) IS  NULL AND lag(Absent) over(order by [emp id],date) = 'No' then 1
--	WHEN [Staff Time (Shift Wise)] IS NULL THEN lag([Consiq Absent])over(order by [EMP ID],DATE) +1 END [Consiq Absent2]
--	FROM #Absent1
--DROP TABLE IF EXISTS #Absent2;

SELECT
    a1.*,
    CASE
        WHEN i.Instance IS NULL THEN a1.[Consiq Absent]
        ELSE i.Instance
    END AS [Consiq_Absent1]
INTO #Absent2
   
FROM  #Absent1 a1
   
LEFT JOIN
    Dashboard..Instance i ON i.Absent_count = a1.[Consiq Absent]
	ORDER BY [EMP ID],Date
	
DROP TABLE IF EXISTS #Absent3

;


WITH INSTANCE  AS (
SELECT * , CASE WHEN [Staff Time (Shift Wise)] IS NULL THEN 
	FIRST_VALUE([Consiq_Absent1]) OVER(PARTITION BY [EMP ID] ORDER BY [Consiq_Absent1] DESC )
	ELSE 0 END Instance
	--,LAST_VALUE([Consiq_Absent1]) OVER (PARTITION BY [EMP ID] ORDER BY [Consiq_Absent1] DESC
	----RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT FALLOWING )
	--AS Instance2
	
FROM #Absent2
)
SELECT * ,CASE WHEN Consiq_Absent1 = Instance THEN Instance ELSE 0 END Instance1
INTO #Absent3
FROM INSTANCE

SELECT * , CASE WHEN [Staff Time (Shift Wise)] IS NULL
	AND [EMP ID] <> LEAD([EMP ID]) OVER(ORDER BY [EMP ID]) THEN 1
		ELSE Instance1 END Instance3

FROM #Absent3

	ORDER BY [EMP ID],Date

