-----------------------------------------------------------------------------------------------------------------
-----------------------------------------Task 2 --------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
----drop procedure 
IF OBJECT_ID ( 'ANALYSE', 'P' ) IS NOT NULL
    DROP PROCEDURE ANALYSE;
GO
----create procedure 
CREATE PROCEDURE ANALYSE
   @p_DatabaseName nvarchar(max),
   @p_SchemaName nvarchar(max),
	@p_TableName nvarchar(max)
AS

declare @sql varchar(max),
     	@tblname sysname,
		@tblsch sysname,
		@tblclmn sysname,
		@count_rows int

--- ---create table @t2 with  count of DISTINCT values in the current column	
declare @t2 table ( tablename sysname, colname sysname, [cnt_rows] bigint, [cnt_distinct] bigint, [cnt_null] bigint, 
					[max_val] varchar(max),[min_val] varchar(max), sum_upp int, sum_lower int, most_used varchar(max), most_used_cnt int, non_pr int)
DECLARE vendor_cursor CURSOR FOR 
select TABLE_SCHEMA,TABLE_NAME, COLUMN_NAME from [INFORMATION_SCHEMA].[COLUMNS] 
OPEN vendor_cursor

FETCH NEXT FROM vendor_cursor 
INTO @tblsch, @tblname, @tblclmn

WHILE @@FETCH_STATUS = 0
BEGIN

set @sql ='		
	with 
	row_cnt as (select '''+@tblname +''' as tablename, '''+ @tblclmn +''' as colname, count(*) as row_cnt from '+@tblsch +'.'+@tblname +'),		
	dist_cnt as (select '''+@tblname +''' as tablename,'''+ @tblclmn +''' as colname, count(*) as dist_cnt from (select distinct '+ @tblclmn +' from '+@tblsch +'.'+@tblname +' ) as w),
	null_cnt as (select '''+@tblname +''' as tablename, '''+ @tblclmn +''' as colname, count(*) as null_cnt from '+@tblsch +'.'+@tblname +' where '+ @tblclmn +' is NULL),	
	min_val as (select '''+@tblname +''' as tablename, '''+ @tblclmn +''' as colname, min('+ @tblclmn +') as min_val from '+@tblsch +'.'+@tblname +'),
	max_val as (select '''+@tblname +''' as tablename, '''+ @tblclmn +''' as colname, max('+ @tblclmn +') as max_val from '+@tblsch +'.'+@tblname +'),
	sum_upp as (select '''+@tblname +''' as tablename, '''+ @tblclmn +''' as colname, sum(equal) as sum_upp  from 
		(SELECT '+ @tblclmn +', UPPER('+ @tblclmn +') as upp,
				CASE
				WHEN cast('+ @tblclmn +' as varbinary(120)) = cast(upper('+ @tblclmn +') as varbinary(120)) THEN 1
				else 0
				END as equal
		FROM '+@tblsch +'.'+@tblname +'
		WHERE '+ @tblclmn +' LIKE ''%[A-Z]%'' COLLATE Latin1_General_100_BIN2) as e	),
	sum_lower as (select '''+@tblname +''' as tablename, '''+ @tblclmn +''' as colname, sum(equal) as sum_lower from 
		(SELECT '+ @tblclmn +', LOWER('+ @tblclmn +') as low,
				CASE
				WHEN cast('+ @tblclmn +' as varbinary(120)) = cast(lower('+ @tblclmn +') as varbinary(120)) THEN 1
				else 0
				END as equal
		FROM '+@tblsch +'.'+@tblname +'
		WHERE '+ @tblclmn +' LIKE ''%[a-z]%'' COLLATE Latin1_General_100_BIN2
		) as e),
	most_used as (select '''+@tblname +''' as tablename, '''+ @tblclmn +''' as colname, r.'+ @tblclmn +' as most_used, cnt_used as most_used_cnt  
			from (
		  SELECT d.'+ @tblclmn +', cnt_used,ROW_NUMBER() OVER (ORDER BY cnt_used desc) row_num				
		  FROM  (select  '+ @tblclmn +', count(*) as cnt_used 
				from  '+@tblsch +'.'+@tblname +'
				group by '+ @tblclmn +'	
				HAVING count(*) >1) as d) as r
			where row_num= 1),		
	non_pr as (
	select '''+@tblname +''' as tablename, '''+ @tblclmn +''' as colname,
		 CASE
		 WHEN (	SELECT DATA_TYPE FROM [INFORMATION_SCHEMA].[COLUMNS] 
				WHERE TABLE_SCHEMA ='''+@tblsch +'''
				and TABLE_NAME ='''+@tblname +'''
				AND COLUMN_NAME='''+ @tblclmn +''') NOT LIKE ''%char%'' THEN NULL
		ELSE (SELECT count(*) as non_pr from '+@tblsch +'.'+@tblname +'
		where ascii('+ @tblclmn +') <32 or UNICODE(right('+ @tblclmn +',1)) <32
		) 
		END	AS 	non_pr
		)
select '''+@tblname +''' as tablename,'''+ @tblclmn +''' as colname,
		row_cnt, 
		dist_cnt.dist_cnt,
		null_cnt.null_cnt,		
		min_val.min_val,
		max_val.max_val,
		sum_upp.sum_upp, 
		sum_lower.sum_lower,
		most_used.most_used,
		most_used.most_used_cnt,
		non_pr.non_pr
from row_cnt
	left join dist_cnt
		on row_cnt.tablename=dist_cnt.tablename		
		and row_cnt.colname=dist_cnt.colname
	left join null_cnt  
		on row_cnt.tablename=null_cnt.tablename		
		and row_cnt.colname=null_cnt.colname		
	left join min_val 
		on row_cnt.tablename=min_val.tablename		
		and row_cnt.colname=min_val.colname
	left join max_val
		on row_cnt.tablename=max_val.tablename		
		and row_cnt.colname=max_val.colname
	left join sum_upp
		on row_cnt.tablename=sum_upp.tablename		
		and row_cnt.colname=sum_upp.colname
	left join sum_lower
		on row_cnt.tablename=sum_lower.tablename		
		and row_cnt.colname=sum_lower.colname
	left join most_used
		on row_cnt.tablename=most_used.tablename		
		and row_cnt.colname=most_used.colname	
	left join non_pr
		on row_cnt.tablename=non_pr.tablename		
		and row_cnt.colname=non_pr.colname'

print @sql
insert @t2(tablename ,colname ,[cnt_rows], [cnt_distinct], [cnt_null],[max_val], [min_val], [sum_upp], [sum_lower],
								  [most_used], [most_used_cnt],[non_pr]) 
exec (@sql) 

    FETCH NEXT FROM vendor_cursor 
    INTO @tblsch, @tblname,@tblclmn

END 
CLOSE vendor_cursor
DEALLOCATE vendor_cursor

--- table #t2 with DISTINCT values in the current column for every table 
--select * from @t2 order by 2 desc

--- output to the user if @p_TableName <> '%'
if @p_TableName <> '%'
begin
select TABLE_CATALOG as 'Database name',
	TABLE_SCHEMA as 'Schema Name',
	TABLE_NAME as 'Table Name',	
	b.cnt_rows as 'Table row count',
	COLUMN_NAME as 'Column name',
	CASE
	WHEN DATA_TYPE IN ('char', 'varchar', 'nvarchar')
		THEN DATA_TYPE + '(' + CAST(CHARACTER_MAXIMUM_LENGTH As VARCHAR) + ')'
	WHEN DATA_TYPE IN ('decimal')
		THEN DATA_TYPE + '(' + CAST(NUMERIC_PRECISION As VARCHAR) + ',' + CAST(NUMERIC_SCALE As VARCHAR) + ')'
	ELSE DATA_TYPE
	END  as 'Data type',
	b.cnt_distinct as 'Count of DISTINCT values',	
	b.cnt_null as 'Count of NULL values',	
	b.min_val as 'MAX value',
	b.max_val as 'MIN value',
	b.sum_upp as 'UPPERCASE strings',
	b.sum_lower as 'LOWERCASE strings',
	B.most_used as 'Most USED',
	ISNULL(CAST(CAST(b.most_used_cnt as decimal)*100/b.cnt_rows as decimal(10,2)),NULL) as '% rows with most used value',
	B.non_pr AS 'rows_non_print_characters'

  FROM [TRN].[INFORMATION_SCHEMA].[COLUMNS] as a
    join @t2 as b
  ON a.TABLE_NAME=b.tablename
  and a.COLUMN_NAME=b.colname

  where 
TABLE_CATALOG = @p_DatabaseName
and TABLE_SCHEMA =@p_SchemaName
and TABLE_NAME =@p_TableName
end

--- output to the user if @p_TableName = '%'
if @p_TableName = '%'
begin
select TABLE_CATALOG as 'Database name',
	TABLE_SCHEMA as 'Schema Name',
	TABLE_NAME as 'Table Name',	
	b.cnt_rows as 'Table row count',
	COLUMN_NAME as 'Column name',
	CASE
	WHEN DATA_TYPE IN ('char', 'varchar', 'nvarchar')
		THEN DATA_TYPE + '(' + CAST(CHARACTER_MAXIMUM_LENGTH As VARCHAR) + ')'
	WHEN DATA_TYPE IN ('decimal')
		THEN DATA_TYPE + '(' + CAST(NUMERIC_PRECISION As VARCHAR) + ',' + CAST(NUMERIC_SCALE As VARCHAR) + ')'
	ELSE DATA_TYPE
	END  as 'Data type',
	b.cnt_distinct as 'Count of DISTINCT values',
	b.cnt_null as 'Count of NULL values',
	b.min_val as 'MAX value',
	b.max_val as 'MIN value',
	b.sum_upp as 'UPPERCASE strings',
	b.sum_lower as 'LOWERCASE strings',
	B.most_used as 'Most USED',
	ISNULL(CAST(CAST(b.most_used_cnt as decimal)*100/b.cnt_rows as decimal(10,2)),NULL) as '% rows with most used value',
	B.non_pr AS 'rows_non_print_characters'

  FROM [TRN].[INFORMATION_SCHEMA].[COLUMNS] as a
    join @t2 as b
  ON a.TABLE_NAME=b.tablename
  and a.COLUMN_NAME=b.colname

  where 
TABLE_CATALOG = @p_DatabaseName
and TABLE_SCHEMA =@p_SchemaName
end

GO
----EXECUTE procedure 

EXECUTE [ANALYSE]
@p_DatabaseName = 'TRN', 
@p_SchemaName = N'hr',
--@p_TableName = N'employees' 
--@p_TableName = N'regions' 
--@p_TableName = N'countries' 
--@p_TableName = N'locations' 
--@p_TableName = N'jobs' 
--@p_TableName = N'departments' 
--@p_TableName = N'dependents' 
@p_TableName = N'%'

GO  

--select * from hr.employees
--select * from hr.regions
--select * from hr.departments
--select * from hr.dependents
--select * from hr.countries
--select* from hr.jobs
--select * from hr.locations

