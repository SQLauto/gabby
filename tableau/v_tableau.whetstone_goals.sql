USE gabby
GO

CREATE OR ALTER VIEW tableau.whetstone_goals AS

SELECT CONVERT(VARCHAR(25),wa.[_id]) AS assignment_id
      ,wa.[name] AS assignment_name
      ,CONVERT(VARCHAR(5),wa.[type]) AS assignment_type
      ,wa.[date] AS assignment_date
      ,CONVERT(INT,wa.[status]) AS assignment_status
      ,wa.[exclude_from_bank]
      ,wa.[mastered_date]
      ,CONVERT(VARCHAR(25),JSON_VALUE(wa.[user], '$._id')) AS user_id      
      ,CONVERT(VARCHAR(125),JSON_VALUE(wa.[user], '$.email')) AS user_email
      ,CONVERT(VARCHAR(125),JSON_VALUE(wa.[user], '$.name')) AS user_name      
      ,CONVERT(VARCHAR(25),JSON_VALUE(wa.[creator], '$._id')) AS creator_id      
      ,CONVERT(VARCHAR(125),JSON_VALUE(wa.[creator], '$.email')) AS creator_email
      ,CONVERT(VARCHAR(125),JSON_VALUE(wa.[creator], '$.name')) AS creator_name  

      ,wu.default_school_name AS user_default_school_name
      ,wu.default_course_name AS user_default_course_name
      ,wu.default_gradelevel_name AS user_default_gradelevel_name

      ,wt.tag_name
FROM [gabby].[whetstone].[assignments] wa
LEFT JOIN gabby.whetstone.users_clean wu
  ON CONVERT(VARCHAR(25),JSON_VALUE(wa.[user], '$._id')) = wu.user_id
LEFT JOIN gabby.whetstone.assignment_tags wt
  ON wa._id = wt.assignment_id
WHERE wa.[type] = 'goal'