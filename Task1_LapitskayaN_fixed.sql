------------------------------------task 1--------------------------------
---Given a JSON string
DECLARE @inputString VARCHAR(MAX) = '[{"employee_id": "5181816516151", "department_id": "1", "class": "src\bin\comp\json"}, 
		{"employee_id": "925155", "department_id": "1", "class": "src\bin\comp\json"}, 
		{"employee_id": "815153", "department_id": "2", "class": "src\bin\comp\json"}, 
		{"employee_id": "967", "department_id": "", "class": "src\bin\comp\json"}]';

---Task: parse given JSON string to be able to get the following output in table format
SELECT
	--- Extract employee_id from a string (start at 'start_empl_id' position, extract 'len_empl_id' characters)
	SUBSTRING(q.value,q.start_empl_id, q.len_empl_id) AS employee_id,
	--- Extract department_id from a string (start at 'start_dep_id' position, extract 'len_dep_id' characters)
	--- as department_id INT, then if len_dep_id can be equal to zero 0, than use IIF - to change it for NULL
	IIF(q.len_dep_id>0,SUBSTRING(q.value,q.start_dep_id, q.len_dep_id),NULL) AS department_id
FROM 
	(
		SELECT 
			---use CHARINDEX to find the number of index where are 'employee_id' and 'department_id' are ended
			---lenght empl_id=end_empl_id-start_empl_id
			---lenght dep_id=end_dep_id-start_dep_id
			w.start_empl_id,
			CHARINDEX('"', w.value, w.start_empl_id) as end_empl_id,
			CHARINDEX('"', w.value, w.start_empl_id)- w.start_empl_id AS len_empl_id,
			w.start_dep_id,
			CHARINDEX('"', w.value, w.start_dep_id) as end_dep_id,
			CHARINDEX('"', w.value, w.start_dep_id)-w.start_dep_id AS len_dep_id,	
			w.value
		FROM
			(
				---use STRING_SPLIT to our string variable to split it into rows of substrings				
				SELECT  	
					---use CHARINDEX to find the number of index where are 'employee_id' and 'department_id' are place (started) 
					---len('"employee_id": "') - its lenght of "employee_id": "
					CHARINDEX('"employee_id": "', t.value)+len('"employee_id": "') AS start_empl_id,		
					CHARINDEX('"department_id": "', t.value)+len('"department_id": "')  AS start_dep_id, 		
					value  
				FROM STRING_SPLIT(@inputString,'{') as t
			) as w
	)  as q
	where q.len_empl_id>=0 and q.end_dep_id>=0
	


------------------------ Task 1 using CTE--------------------------


WITH 
	PARSED_DATA AS 
	(
	SELECT	
		SUBSTRING(q.value,q.start_empl_id, q.len_empl_id) AS employee_id,	
		IIF(q.len_dep_id>0,SUBSTRING(q.value,q.start_dep_id, q.len_dep_id),NULL) AS department_id
	FROM 
		(
			SELECT 			
				w.start_empl_id,
				CHARINDEX('"', w.value, w.start_empl_id) as end_empl_id,
				CHARINDEX('"', w.value, w.start_empl_id)- w.start_empl_id AS len_empl_id,
				w.start_dep_id,
				CHARINDEX('"', w.value, w.start_dep_id) as end_dep_id,
				CHARINDEX('"', w.value, w.start_dep_id)-w.start_dep_id AS len_dep_id,	
				w.value
			FROM
				(							
					SELECT  						
						CHARINDEX('"employee_id": "', t.value)+len('"employee_id": "') AS start_empl_id,		
						CHARINDEX('"department_id": "', t.value)+len('"department_id": "')  AS start_dep_id, 		
						value  
					FROM STRING_SPLIT('[{"employee_id": "5181816516151", "department_id": "1", "class": "src\bin\comp\json"}, 
		{"employee_id": "925155", "department_id": "1", "class": "src\bin\comp\json"}, 
		{"employee_id": "815153", "department_id": "2", "class": "src\bin\comp\json"}, 
		{"employee_id": "967", "department_id": "", "class": "src\bin\comp\json"}]','{') as t
				) as w
		)  as q
		where q.len_empl_id>=0 and q.end_dep_id>=0	 
		)
SELECT
	employee_id,
	department_id
from PARSED_DATA;




------------------------ Task 1 using recursive parsing of a string--------------------------


WITH
	json_string AS
	(
		SELECT '[{"employee_id": "5181816516151", "department_id": "1", "class": "src\bin\comp\json"}, {"employee_id": "925155", "department_id": "1", "class": "src\bin\comp\json"}, {"employee_id": "815153", "department_id": "2", "class": "src\bin\comp\json"}, {"employee_id": "967", "department_id": "", "class": "src\bin\comp\json"}]'  AS string
	),
	some_transformations (string_new, sbstr_json, employee_id, department_id) as 
	(	SELECT 
			CAST(STUFF(string,1,LEN(SUBSTRING(string, CHARINDEX('{',string),CHARINDEX('}',string)))+1,'') as nvarchar(MAX)) as string_new,
			CAST(SUBSTRING(string, CHARINDEX('{',string),CHARINDEX('}',string)) as nvarchar(MAX)) as sbstring_json,
			---employee_id
			CAST(NULLIF(SUBSTRING(SUBSTRING(string, CHARINDEX('{',string),CHARINDEX('}',string)),
						CHARINDEX(':',SUBSTRING(string, CHARINDEX('{',string),CHARINDEX('}',string))) +3,
						CHARINDEX(',',SUBSTRING(string, CHARINDEX('{',string),CHARINDEX('}',string))) -CHARINDEX(':',SUBSTRING(string, CHARINDEX('{',string),CHARINDEX('}',string)))-4),'')
			as BIGINT) as employee_id,
			---department_id
			CAST(NULLIF(SUBSTRING(SUBSTRING(string, CHARINDEX('{',string),CHARINDEX('}',string)),
						CHARINDEX(':',SUBSTRING(string, CHARINDEX('{',string),CHARINDEX('}',string)),
						CHARINDEX(',',SUBSTRING(string, CHARINDEX('{',string),CHARINDEX('}',string))))+3,
						CHARINDEX(',',SUBSTRING(string, CHARINDEX('{',string),CHARINDEX('}',string)),
						CHARINDEX(',',SUBSTRING(string, CHARINDEX('{',string),CHARINDEX('}',string)))+1)
						-CHARINDEX(':',SUBSTRING(string, CHARINDEX('{',string),CHARINDEX('}',string)),
						CHARINDEX(',',SUBSTRING(string, CHARINDEX('{',string),CHARINDEX('}',string))))-4),'')
			as INT) as department_id
		FROM json_string
		union all
		SELECT 
			CAST(STUFF(string_new,1,LEN(substring(string_new, CHARINDEX('{',string_new),CHARINDEX('}',string_new)))+1,'') as nvarchar(MAX)) as string_new_upd ,
			CAST(SUBstring(string_new, CHARINDEX('{',string_new),CHARINDEX('}',string_new)) as nvarchar(MAX)) as sbstring_new_json,
			---employee_id
			CAST(NULLIF(SUBstring(SUBstring(string_new, CHARINDEX('{',string_new),CHARINDEX('}',string_new)),
						CHARINDEX(':',SUBstring(string_new, CHARINDEX('{',string_new),CHARINDEX('}',string_new))) +3,
						CHARINDEX(',',SUBstring(string_new, CHARINDEX('{',string_new),CHARINDEX('}',string_new))) 
						-CHARINDEX(':',SUBstring(string_new, CHARINDEX('{',string_new),CHARINDEX('}',string_new)))-4),'')
			as BIGINT) as employee_id,
			---department_id
			CAST(NULLIF(SUBstring(SUBstring(string_new, CHARINDEX('{',string_new),CHARINDEX('}',string_new)),
						CHARINDEX(':',SUBstring(string_new, CHARINDEX('{',string_new),CHARINDEX('}',string_new)),
						CHARINDEX(',',SUBstring(string_new, CHARINDEX('{',string_new),CHARINDEX('}',string_new))))+3,
						CHARINDEX(',',SUBstring(string_new, CHARINDEX('{',string_new),CHARINDEX('}',string_new)),
						CHARINDEX(',',SUBstring(string_new, CHARINDEX('{',string_new),CHARINDEX('}',string_new)))+1)
						-CHARINDEX(':',SUBstring(string_new, CHARINDEX('{',string_new),CHARINDEX('}',string_new)),
						CHARINDEX(',',SUBstring(string_new, CHARINDEX('{',string_new),CHARINDEX('}',string_new))))-4),'')
			as INT) as department_id
		FROM some_transformations
		where string_new >''
	)
SELECT
	employee_id,
	department_id
FROM some_transformations;