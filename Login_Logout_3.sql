
drop table if exists  [Dashboard].[dbo].agent_login
drop table if exists [Dashboard].[dbo].agent_Logout


DROP TABLE IF EXISTS #Roster

select  rs.[Date],rs.[Site], rs.[Employee ID],h.[CSC ID],rs.[Name],rs.[Team Leader],rs.[Profile],rs.LOB,rs.[Status],rs.[Exit Date],rs.[Shift]
INto #Roster
from Dashboard..ROSTER RS
left join Dashboard..Auto_Headcount$ h on CONCAT(h.[Date],h.[EMP ID]) 
  = CONCAT(RS.[Date],rs.[Employee Id]) 
  ;
WITH cte1 AS (
    SELECT
        convert(date,lg.[Online Date]) AS Date,
        rs.[Shift] AS Shift,
        left([Agent Login (ID)], charindex('(', [Agent Login (ID)]) - 1) AS [CSC ID],
        concat(convert(date,lg.[Online Date]), ' ', convert(time,lg.[Online Time])) AS [Date+Login Time],
        concat(convert(date,lg.[Offline Date]), ' ', convert(time,lg.[Offline Time])) AS [Date + Logout Time],
        concat(convert(date,lg.[Online Date]), ' ', convert(time,mp.[Shift Start Time])) AS [Hoop Login Time],
        concat(convert(date,lg.[Online Date]), ' ', convert(time,mp.[Shift End Time])) AS [Hoop Logout Time],
        mp.[Shift Category],
        lg.[Agent Login (ID)],
        lg.[Agent Name (First Last)],
        lg.[Team],
        lg.[Profile],
        lg.[Site],
        [Agent Owner],
        convert(date,lg.[Online Date]) AS [Online Date],
        convert(time,lg.[Online Time]) AS [Online Time],
        convert(date,lg.[Offline Date]) AS [Offline Date],
        convert(time,lg.[Offline Time]) AS [Offline Time],
        convert(time,lg.[Online Duration]) AS [Online Duration]
    FROM [Dashboard].[dbo].[Login_Logout] lg
    LEFT JOIN #Roster rs ON concat(convert(date,lg.[Online Date]), left([Agent Login (ID)], charindex('(', [Agent Login (ID)]) - 1)) = concat(convert(date,rs.date), rs.[csc id])
    LEFT JOIN [Dashboard].[dbo].Map1 mp ON concat(mp.Site, mp.shift) = concat(RS.Site, rs.Shift)
),
cte2 AS (
    SELECT
        CASE 
            WHEN [Date+Login Time] >= [Hoop Login Time] THEN [Date+Login Time]
            ELSE '-'
        END AS [Actual Login Time],
        CASE 
            WHEN [Date + Logout Time] <= [Hoop Logout Time] THEN [Date + Logout Time]
            ELSE '-'
        END AS [Actual Logout Time],
        
        *
    FROM cte1
),
cte3 AS (
	SELECT
		case	
			when cte2.[Actual Login Time] = '-' then 'Invalid'
			else 'Valid'
		end [Login Valid/Invalid],
		case 
			when cte2.[Actual Login Time] = '-' then '-'
			else cte2.Shift
		end as [Actual Shift],
		cte2.*
	FROM
		cte2
)
,
	cte4 as(
SELECT 
	
		case 
			when cte3.[Actual Shift] = '-' then '-'
			else concat(cte3.Date,' ',convert(time,mp.[Shift Start Time])) end [Hoop Login Time1],

		case 
			when cte3.[Actual Shift] = '-' then '-'
			else  concat(cte3.Date,' ',convert(time,mp.[Shift End Time])) end [Hoop Logout Time1],



	
    CASE 
        WHEN CTE3.[Actual Shift] = '-' THEN CONVERT(NVARCHAR(MAX),DATEADD(DAY,-1,CTE3.Date))
        WHEN CTE3.[Shift Category] = 'General' AND CTE3.[Actual Login Time] = '-' THEN CONVERT(NVARCHAR(MAX), DATEADD(DAY, -1, CTE3.Date))
        WHEN CTE3.[Shift] = CTE3.[Actual Login Time] THEN CTE3.DATE
		
        ELSE LEFT(CTE3.[Actual Login Time], 10)
    END AS DATESHIFT,cte3.*
    -- Include other columns as needed
FROM 
    cte3

	left join Dashboard.dbo.Map1 mp
	on concat(mp.site,mp.shift) = concat(cte3.site,cte3.[Actual Shift])


	),
		CTE5 AS(
		select	
			
        CASE when [Hoop Login Time1] = '-' then '-'
            WHEN [Date+Login Time] >= [Hoop Login Time1] THEN [Date+Login Time]
            ELSE '-'
        END AS [Actual Login Time1],
        CASE 
				when [Date + Logout Time] = '-' THEN '-'
            WHEN [Date + Logout Time] <= [Hoop Logout Time1] THEN [Date + Logout Time]
            ELSE [Date + Logout Time]
        END AS [Actual Logout Time1]

		,* from cte4
		),CTE6 AS (
		SELECT 
			CASE 
				WHEN CTE5.[Actual Login Time1] = '-' THEN 'Invalid'
					ELSE 'Valid'
				END 
					[Login Valid/Invalid1]
			,* FROM CTE5)
	SELECT 
    CTE6.DATESHIFT,
    CTE6.[CSC ID],
    MIN(CTE6.[Actual Login Time1]) AS [Actual Login Time]
	into [Dashboard].[dbo].agent_login
FROM 
    CTE6
WHERE 
    CTE6.[Login Valid/Invalid1] = 'Valid'
GROUP BY 
    CTE6.DATESHIFT, CTE6.[CSC ID], CTE6.[Agent Login (ID)], CTE6.[Online Date]
ORDER BY 
    CTE6.[Agent Login (ID)], CTE6.[Online Date];


	----------------------->>>>>>>>>>>>>>>>>>>>>>>>>>>>> LOG Out Time
--WITH cte1 AS (
--    SELECT
--        convert(date,lg.[Online Date]) AS Date,
--        rs.[Shift] AS Shift,
--        left([Agent Login (ID)], charindex('(', [Agent Login (ID)]) - 1) AS [CSC ID],
--        concat(convert(date,lg.[Online Date]), ' ', convert(time,lg.[Online Time])) AS [Date+Login Time],
--        concat(convert(date,lg.[Offline Date]), ' ', convert(time,lg.[Offline Time])) AS [Date + Logout Time],
--        concat(convert(date,lg.[Online Date]), ' ', convert(time,mp.[Shift Start Time])) AS [Hoop Login Time],
--        concat(convert(date,lg.[Online Date]), ' ', convert(time,mp.[Shift End Time])) AS [Hoop Logout Time],
--        mp.[Shift Category],
--        lg.[Agent Login (ID)],
--        lg.[Agent Name (First Last)],
--        lg.[Team],
--        lg.[Profile],
--        lg.[Site],
--        [Agent Owner],
--        convert(date,lg.[Online Date]) AS [Online Date],
--        convert(time,lg.[Online Time]) AS [Online Time],
--        convert(date,lg.[Offline Date]) AS [Offline Date],
--        convert(time,lg.[Offline Time]) AS [Offline Time],
--        convert(time,lg.[Online Duration]) AS [Online Duration]
--    FROM [Dashboard].[dbo].[Login_Logout] lg
--    LEFT JOIN #Roster rs ON concat(convert(date,lg.[Online Date]), left([Agent Login (ID)], charindex('(', [Agent Login (ID)]) - 1)) = concat(convert(date,rs.date), rs.[csc id])
--    LEFT JOIN [Dashboard].[dbo].Map1 mp ON concat(mp.Site, mp.shift) = concat(RS.Site, rs.Shift)
--),
--cte2 AS (
--    SELECT
--        CASE 
--            WHEN [Date+Login Time] >= [Hoop Login Time] THEN [Date+Login Time]
--            ELSE '-'
--        END AS [Actual Login Time],
--        CASE 
--            WHEN [Date + Logout Time] <= [Hoop Logout Time] THEN [Date + Logout Time]
--            ELSE '-'
--        END AS [Actual Logout Time],
        
--        *
--    FROM cte1
--),
--cte3 AS (
--	SELECT
--		case	
--			when cte2.[Actual Login Time] = '-' then 'Invalid'
--			else 'Valid'
--		end [Login Valid/Invalid],
--		case 
--			when cte2.[Actual Login Time] = '-' then '-'
--			else cte2.Shift
--		end as [Actual Shift],
--		cte2.*
--	FROM
--		cte2
--)
--,
--	cte4 as(
--SELECT 
	
--		case 
--			when cte3.[Actual Shift] = '-' then '-'
--			else concat(cte3.Date,' ',convert(time,mp.[Shift Start Time])) end [Hoop Login Time1],

--		case 
--			when cte3.[Actual Shift] = '-' then '-'
--			else  concat(cte3.Date,' ',convert(time,mp.[Shift End Time])) end [Hoop Logout Time1],



	
--    CASE 
--        WHEN CTE3.[Actual Shift] = '-' THEN CONVERT(NVARCHAR(MAX),DATEADD(DAY,-1,CTE3.Date))
--        WHEN CTE3.[Shift Category] = 'General' AND CTE3.[Actual Login Time] = '-' THEN CONVERT(NVARCHAR(MAX), DATEADD(DAY, -1, CTE3.Date))
--        WHEN CTE3.[Shift] = CTE3.[Actual Login Time] THEN CTE3.DATE
		
--        ELSE LEFT(CTE3.[Actual Login Time], 10)
--    END AS DATESHIFT,cte3.*
--    -- Include other columns as needed
--FROM 
--    cte3

--	left join Dashboard.dbo.Map1 mp
--	on concat(mp.site,mp.shift) = concat(cte3.site,cte3.[Actual Shift])


--	),
--		CTE5 AS(
--		select	
			
--        CASE when [Hoop Login Time1] = '-' then '-'
--            WHEN [Date+Login Time] >= [Hoop Login Time1] THEN [Date+Login Time]
--            ELSE '-'
--        END AS [Actual Login Time1],
--        CASE 
--				when [Date + Logout Time] = '-' THEN '-'
--            WHEN [Date + Logout Time] <= [Hoop Logout Time1] THEN [Date + Logout Time]
--            ELSE [Date + Logout Time]
--        END AS [Actual Logout Time1]

--		,* from cte4
--		),CTE6 AS (
--		SELECT 
--			CASE 
--				WHEN CTE5.[Actual Login Time1] = '-' THEN 'Invalid'
--					ELSE 'Valid'
--				END 
--					[Login Valid/Invalid1]
--			,* FROM CTE5)
--	SELECT 
--    CTE6.DATESHIFT,
--    CTE6.[CSC ID],
--    MAX(CTE6.[Actual Logout Time1]) AS [Actual Logout Time]
--	into [Dashboard].[dbo].agent_Logout

--FROM 
--    CTE6

--GROUP BY 
--    CTE6.DATESHIFT, CTE6.[CSC ID], CTE6.[Agent Login (ID)], CTE6.[Online Date]
--ORDER BY 
--    CTE6.[Agent Login (ID)], CTE6.[Online Date];
;




DROP TABLE IF EXISTS #logout5
DROP TABLE IF EXISTS #logout6
DROP TABLE IF EXISTS #logout4
DROP TABLE IF EXISTS #logout3
DROP TABLE IF EXISTS #logout2
DROP TABLE IF EXISTS #logout1




    SELECT
        convert(date,lg.[Online Date]) AS Date,
        rs.[Shift] AS Shift,
        left([Agent Login (ID)], charindex('(', [Agent Login (ID)]) - 1) AS [CSC ID],
        concat(convert(date,lg.[Online Date]), ' ', convert(time,lg.[Online Time])) AS [Date+Login Time],
        concat(convert(date,lg.[Offline Date]), ' ', convert(time,lg.[Offline Time])) AS [Date + Logout Time],
        concat(convert(date,lg.[Online Date]), ' ', convert(time,mp.[Shift Start Time])) AS [Hoop Login Time],
        concat(convert(date,lg.[Online Date]), ' ', convert(time,mp.[Shift End Time])) AS [Hoop Logout Time],
        mp.[Shift Category],
        lg.[Agent Login (ID)],
        lg.[Agent Name (First Last)],
        lg.[Team],
        lg.[Profile],
        lg.[Site],
        [Agent Owner],
        convert(date,lg.[Online Date]) AS [Online Date],
        convert(time,lg.[Online Time]) AS [Online Time],
        convert(date,lg.[Offline Date]) AS [Offline Date],
        convert(time,lg.[Offline Time]) AS [Offline Time],
        convert(time,lg.[Online Duration]) AS [Online Duration]
		INTO #logout1
    FROM [Dashboard].[dbo].[Login_Logout] lg
    LEFT JOIN #Roster rs ON concat(convert(date,lg.[Online Date]), left([Agent Login (ID)], charindex('(', [Agent Login (ID)]) - 1)) = concat(convert(date,rs.date), rs.[csc id])
    LEFT JOIN [Dashboard].[dbo].Map1 mp ON concat(mp.Site, mp.shift) = concat(RS.Site, rs.Shift)
;
    SELECT
        CASE 
            WHEN [Date+Login Time] >= [Hoop Login Time] THEN [Date+Login Time]
            ELSE '-'
        END AS [Actual Login Time],
        CASE 
            WHEN [Date + Logout Time] <= [Hoop Logout Time] THEN [Date + Logout Time]
            ELSE '-'
        END AS [Actual Logout Time],
        
        *
		INTO #logout2
    FROM #logout1
	;
	SELECT
		case	
			when [Actual Login Time] = '-' then 'Invalid'
			else 'Valid'
		end [Login Valid/Invalid],
		case 
			when [Actual Login Time] = '-' then '-'
			else Shift
		end as [Actual Shift],
		*
		INTO #logout3
	FROM
		#logout2


SELECT 
	
		case 
			when L3.[Actual Shift] = '-' then '-'
			else concat(L3.Date,' ',convert(time,mp.[Shift Start Time])) end [Hoop Login Time1],

		case 
			when L3.[Actual Shift] = '-' then '-'
			else  concat(Date,' ',convert(time,mp.[Shift End Time])) end [Hoop Logout Time1],


		
	
    CASE 
        WHEN L3.[Actual Shift] = '-' THEN CONVERT(NVARCHAR(MAX),DATEADD(DAY,-1,L3.Date))
        WHEN L3.[Shift Category] = 'General' AND L3.[Actual Login Time] = '-' THEN CONVERT(NVARCHAR(MAX), DATEADD(DAY, -1, L3.Date))
        WHEN L3.[Shift] = L3.[Actual Login Time] THEN L3.DATE
		
        ELSE LEFT(L3.[Actual Login Time], 10)
    END AS DATESHIFT,L3.*
    -- Include other columns as needed
	INTO #logout4
FROM 
    #logout3 L3
	

	left join Dashboard.dbo.Map1 mp
	on concat(mp.site,mp.shift) = concat(L3.site,L3.[Actual Shift])


		select	
			
        CASE when [Hoop Login Time1] = '-' then '-'
            WHEN [Date+Login Time] >= [Hoop Login Time1] THEN [Date+Login Time]
            ELSE '-'
        END AS [Actual Login Time1],
        CASE 
				when [Date + Logout Time] = '-' THEN '-'
            WHEN [Date + Logout Time] <= [Hoop Logout Time1] THEN [Date + Logout Time]
            ELSE [Date + Logout Time]
        END AS [Actual Logout Time1]

		,*
		INTO #logout5
		from #logout4

		SELECT 
			CASE 
				WHEN [Actual Login Time1] = '-' THEN 'Invalid'
					ELSE 'Valid'
				END 
					[Login Valid/Invalid1]
			,* 
			INTO #logout6
			FROM #logout5
	SELECT 
    DATESHIFT,
    [CSC ID],
    MAX([Actual Logout Time1]) AS [Actual Logout Time]
	into [Dashboard].[dbo].agent_Logout

FROM 
    #logout6
	--where [csc id] = 'abhisekp'
GROUP BY 
    DATESHIFT, [CSC ID]
ORDER BY 
     DATESHIFT
	 

