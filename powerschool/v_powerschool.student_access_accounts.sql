USE gabby
GO

CREATE OR ALTER VIEW powerschool.student_access_accounts AS 

WITH clean_names AS (
  SELECT CONVERT(INT,s.student_number) AS student_number
        ,CONVERT(INT,s.schoolid) AS schoolid
        ,CONVERT(INT,s.grade_level) AS grade_level
        ,CONVERT(VARCHAR(125),s.first_name) AS first_name
        ,CONVERT(VARCHAR(125),s.last_name) AS last_name
        ,CONVERT(INT,s.enroll_status) AS enroll_status
        ,LEFT(LOWER(s.first_name),1) AS first_init
        ,CONVERT(VARCHAR,DATEPART(MONTH,s.dob)) COLLATE Latin1_General_BIN AS dob_month
        ,CONVERT(VARCHAR,RIGHT(DATEPART(DAY,s.dob),2)) COLLATE Latin1_General_BIN AS dob_day
        ,CONVERT(VARCHAR,RIGHT(DATEPART(YEAR,s.dob),2)) AS dob_year

        ,CONVERT(VARCHAR(25),sch.abbreviation) AS school_name

        ,gabby.utilities.STRIP_CHARACTERS(LOWER(s.first_name), '^A-Z') AS first_name_clean
        ,gabby.utilities.STRIP_CHARACTERS(LOWER(
           CASE
            WHEN s.last_name LIKE 'St %' OR s.last_name LIKE 'St. %' THEN s.last_name
            WHEN s.last_name LIKE '% II%' THEN LEFT(s.last_name,CHARINDEX(' I',s.last_name) - 1)
            WHEN CHARINDEX('-',s.last_name) + CHARINDEX(' ',s.last_name) = 0 THEN REPLACE(s.last_name, ' JR', '')
            WHEN CHARINDEX(' ',s.last_name) > 0 AND CHARINDEX('-',s.last_name) > 0 AND CHARINDEX(' ',s.last_name) < CHARINDEX('-',s.last_name) THEN LEFT(s.last_name,CHARINDEX(' ',s.last_name) - 1)
            WHEN CHARINDEX('-',s.last_name) > 0 AND CHARINDEX(' ',s.last_name) > 0 AND CHARINDEX('-',s.last_name) < CHARINDEX(' ',s.last_name) THEN LEFT(s.last_name,CHARINDEX('-',s.last_name) - 1)
            WHEN s.last_name NOT LIKE 'De %' AND CHARINDEX(' ',s.last_name) > 0 THEN LEFT(s.last_name,CHARINDEX(' ',s.last_name) - 1)
            WHEN CHARINDEX('-',s.last_name) > 0 THEN LEFT(s.last_name,CHARINDEX('-',s.last_name) - 1)
            ELSE REPLACE(s.last_name, ' JR', '')
           END), '^A-Z') AS last_name_clean
  FROM gabby.powerschool.students s
  JOIN gabby.powerschool.schools sch
    ON s.schoolid = sch.school_number
   AND s.db_name = sch.db_name
  WHERE s.enroll_status != -1
    AND s.dob IS NOT NULL
 )

SELECT student_number
      ,schoolid
      ,enroll_status
      ,base_username
      ,alt_username
      ,uses_alt
      ,base_dupe_audit
      ,alt_dupe_audit
      ,CONVERT(VARCHAR(125),CASE
                             WHEN alt_dupe_audit > 1 THEN first_init + last_name_clean + dob_month + dob_day
                             WHEN uses_alt = 1 THEN alt_username
                             ELSE base_username
                            END) AS student_web_id
      ,CONVERT(VARCHAR(125),CASE
                             WHEN student_number IN (SELECT student_numbers_variation_1 FROM gabby.extracts.student_account_override) THEN first_name_clean + dob_month /* manual override of passwords */
                             WHEN student_number IN (SELECT student_numbers_variation_2 FROM gabby.extracts.student_account_override) THEN CONCAT(first_name_clean, student_number) /* manual override of passwords */
                             WHEN grade_level >= 2 THEN last_name_clean + dob_year
                             ELSE LOWER(school_name) + '1'
                            END) AS student_web_password
FROM
    (
     SELECT student_number
           ,schoolid
           ,school_name
           ,grade_level
           ,enroll_status
           ,first_name_clean
           ,first_init
           ,last_name_clean
           ,dob_month
           ,dob_day
           ,dob_year
           ,base_username
           ,alt_username
           ,base_dupe_audit
           ,CASE
             WHEN base_dupe_audit > 1 THEN 1
             WHEN LEN(base_username) > 16 THEN 1
             ELSE 0
            END AS uses_alt
           
           ,ROW_NUMBER() OVER(
             PARTITION BY CASE WHEN base_dupe_audit > 1 THEN alt_username ELSE base_username END
               ORDER BY student_number) AS alt_dupe_audit
     FROM
         (
          SELECT student_number
                ,schoolid
                ,school_name
                ,grade_level
                ,enroll_status
                ,first_name_clean
                ,first_init
                ,last_name_clean
                ,dob_month
                ,dob_day
                ,dob_year
                ,last_name_clean + dob_month + dob_day AS base_username
                ,first_name_clean + dob_month + dob_day AS alt_username
                
                ,ROW_NUMBER() OVER(
                   PARTITION BY last_name_clean + dob_month + dob_day
                     ORDER BY student_number) AS base_dupe_audit
          FROM clean_names
         ) sub
    ) sub