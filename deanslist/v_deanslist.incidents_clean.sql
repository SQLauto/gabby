USE gabby
GO

CREATE OR ALTER VIEW deanslist.incidents_clean AS

SELECT DISTINCT 
       CONVERT(INT,[incident_id]) AS [incident_id]
      ,CONVERT(INT,[school_id]) AS [school_id]
      ,CONVERT(INT,[student_id]) AS [student_id]
      ,CONVERT(INT,[student_school_id]) AS [student_school_id]
      ,CONVERT(INT,[infraction_type_id]) AS [infraction_type_id]
      ,CONVERT(INT,[location_id]) AS [location_id]
      ,CONVERT(VARCHAR(125),location) AS location
      ,CONVERT(INT,[category_id]) AS [category_id]
      ,CONVERT(VARCHAR(125),category) AS category
      ,CONVERT(INT,[status_id]) AS [status_id]
      ,CONVERT(VARCHAR(25),status) AS status
      ,CONVERT(VARCHAR(125),infraction) AS infraction
      ,CONVERT(VARCHAR(8000),reported_details) AS reported_details
      ,CONVERT(VARCHAR(8000),admin_summary) AS admin_summary
      ,CONVERT(VARCHAR(2000),context) AS context
      ,CONVERT(VARCHAR(500),addl_reqs) AS addl_reqs
      ,CONVERT(VARCHAR(2000),family_meeting_notes) AS family_meeting_notes
      ,CONVERT(INT,[create_by]) AS [create_by]
      ,CONVERT(VARCHAR(25),create_first) AS create_first
      ,CONVERT(VARCHAR(25),create_middle) AS create_middle
      ,CONVERT(VARCHAR(25),create_last) AS create_last
      ,CONVERT(VARCHAR(25),create_title) AS create_title
      ,CONVERT(INT,[update_by]) AS [update_by]
      ,CONVERT(VARCHAR(25),update_first) AS update_first
      ,CONVERT(VARCHAR(25),update_middle) AS update_middle
      ,CONVERT(VARCHAR(25),update_last) AS update_last      
      ,CONVERT(VARCHAR(25),update_title) AS update_title
      ,[is_referral]
      ,[is_active]      
      ,[send_alert]
      ,[hearing_flag]      
      ,CONVERT(INT,[return_period]) AS [return_period]      
      ,CONVERT(DATE,JSON_VALUE([return_date], '$.date')) AS [return_date]      
      ,CONVERT(DATETIME2,JSON_VALUE([issue_ts], '$.date')) AS [issue_ts]
      ,CONVERT(DATETIME2,JSON_VALUE([update_ts], '$.date')) AS [update_ts]
      ,CONVERT(DATETIME2,JSON_VALUE([close_ts], '$.date')) AS [close_ts]
      ,CONVERT(DATETIME2,JSON_VALUE([review_ts], '$.date')) AS [review_ts]
      ,CONVERT(DATETIME2,JSON_VALUE([create_ts], '$.date')) AS [create_ts]
      ,CONVERT(DATETIME2,JSON_VALUE([dl_lastupdate], '$.date')) AS [dl_lastupdate]
      ,reporting_incident_id
      
      ,gabby.utilities.DATE_TO_SY(CONVERT(DATETIME2,JSON_VALUE([create_ts], '$.date'))) AS create_academic_year
FROM [gabby].[deanslist].[incidents]