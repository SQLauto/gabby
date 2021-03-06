USE gabby
GO

CREATE OR ALTER VIEW whetstone.users_clean AS

SELECT u.[_id] AS user_id
      ,u.[accounting_id]
      ,u.[internal_id]
      ,u.[email] AS user_email
      ,JSON_VALUE(u.[additional_emails],'$[0]') AS additional_email_1
      ,u.[name] AS user_name
      ,u.[inactive]      
      ,JSON_VALUE(u.[default_information],'$.course.name') AS default_course_name
      ,JSON_VALUE(u.[default_information],'$.gradeLevel.name') AS default_gradelevel_name
      ,JSON_VALUE(u.[default_information],'$.period') AS default_period
      ,JSON_VALUE(u.[default_information],'$.school.name') AS default_school_name      
      ,JSON_VALUE(u.[coach],'$.name') AS coach_name      
      ,u.[past_user_types]
      ,u.[past_default_informations]
      ,u.[highest_role_cached]
      ,u.[lowest_role_cached]      
      ,u.[created]
      ,u.[last_activity]
      ,u.[localkey]
      ,u.[default_information] AS default_information_json
      ,u.[coach] AS coach_json
      ,u.[additional_emails] AS additional_emails_json
FROM [gabby].[whetstone].[users] u