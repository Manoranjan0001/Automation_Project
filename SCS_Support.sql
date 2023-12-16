
/*SELECT * FROM CSC_AgentPerformance

UPDATE CSC_AgentPerformance 
SET [Aux Time] = '00:00:00'
WHERE [Aux Time] = 'NULL';

/*UPDATE CSC_AgentPerformance 
SET [Staffed Time] = '00:00:00'
WHERE [Staffed Time] = '-';*/

UPDATE CSC_AgentPerformance
SET [Aux Busy Time] = '00:00:00'
WHERE [Aux Busy Time] = '-';*/

WITH CTE1 AS (
SELECT 
	LEFT(CS.[Agent],CHARINDEX('(',CS.Agent)-1) CSC_ID,
 
		CONVERT(DATE,LEFT (CS.Interval,10)) AS Date,
		
		RS.Shift
		,CONCAT(SUBSTRING( cs.Interval, 12,5), ':00') AS [StartTime Support]



		,convert(datetime,CONCAT(convert(date,(LEFT (cs.Interval,10))),' ',SUBSTRING(CS.Interval,12,5)))[Start_DataTime],
		 CONVERT(TIME, DATEADD(SECOND, DATEDIFF(SECOND, CS.[Aux Time], CS.[Staffed Time]) + DATEDIFF(SECOND, '00:00:00', CS.[Aux Busy Time]), '00:00:00')) NetLogin,
		CS.[Agent]
      ,CS.[Profile]
      ,CS.[Site]
      ,[Interval]
      ,[Aux Busy Time]
      ,[Aux Time]
      ,[Staffed Time]
  FROM [Dashboard].[dbo].[CSC_AgentPerformance] CS
  LEFT JOIN Dashboard.dbo.ROSTER RS
  ON CONCAT(CONVERT(DATE,RS.Date),RS.[CSC ID]) = CONCAT(
		CONVERT(DATE,LEFT (CS.Interval,10)),LEFT(CS.[Agent],CHARINDEX('(',CS.Agent)-1))
		where cs.[Site] in ('BBI','VTZ')
		 

) ,CTE2 AS( 
SELECT convert(datetime,CONCAT(CONVERT(DATE,LEFT (CTE1.Interval,10)),' ',LEFT(CONVERT(time,MP.[Shift Start Time] ),5))) [Support_IN-Time]
		,convert(datetime,CONCAT(CONVERT(DATE,LEFT (CTE1.Interval,10)),' ',LEFT(CONVERT(time,MP.[Shift End Time] ),5))) +1 [Support_Out-Time] ,CTE1.* FROM CTE1
LEFT JOIN [Dashboard].[dbo].[Map1] MP
	ON
	CONCAT(MP.Site,MP.SHIFT) = CONCAT(CTE1.Site,CTE1.SHIFT)
	),  CTE3 AS (
				select cte2.Date,cte2.CSC_ID,cte2.Shift,cte2.[Support_IN-Time]  [Support_IN-Time],cte2.[Support_Out-Time] [Support_Out-Time],

		
		case
		
		when  convert(float,cte2.Start_DataTime)>= convert(float,cte2.[Support_IN-Time]) then CONVERT(TIME, DATEADD(SECOND, SUM(DATEDIFF(SECOND, '00:00:00', CTE2.[Staffed Time])), '00:00:00'))
		WHEN CONVERT(float,cte2.Start_DataTime)<= convert(float,cte2.[Support_Out-Time])
		then CONVERT(TIME, DATEADD(SECOND, SUM(DATEDIFF(SECOND, '00:00:00', CTE2.[Staffed Time])), '00:00:00'))
		else '00:00:00'
		end Stafftime

	from cte2
	WHERE   CSC_ID='poushali'
	group by cte2.Date,cte2.CSC_ID,cte2.Shift,cte2.[Support_IN-Time],cte2.[Support_Out-Time],cte2.Start_DataTime
)
	SELECT CTE3.Date,CTE3.CSC_ID,CTE3.Shift,CTE3.[Support_IN-Time],CTE3.[Support_Out-Time],CONVERT(TIME, DATEADD(SECOND, SUM(DATEDIFF(SECOND, '00:00:00', CTE3.Stafftime )), '00:00:00')) Stafftime
 FROM CTE3
	GROUP BY CTE3.Date,CTE3.CSC_ID,CTE3.Shift,CTE3.[Support_IN-Time],CTE3.[Support_Out-Time]