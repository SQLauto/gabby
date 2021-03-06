USE gabby
GO

CREATE OR ALTER VIEW surveys.self_and_others_survey_detail AS

SELECT so.survey_type
      ,so.response_id
      ,so.academic_year
      ,so.reporting_term
      ,so.term_name
      ,so.time_started
      ,so.date_submitted      
      ,so.respondent_name
      ,so.respondent_email_address
      ,so.question_code
      ,so.response
      ,so.subject_associate_id
      ,so.is_manager
      ,so.n_managers
      ,so.n_peers
      ,so.n_total           
      ,so.question_text
      ,so.open_ended
      ,so.response_value
      ,so.response_weight
      ,(so.response_value * so.response_weight) AS response_value_weighted

      ,COALESCE(dfdf.df_employee_number, dfadp.df_employee_number) AS subject_employee_number
      ,COALESCE(CONCAT(dfdf.preferred_first_name, ' ', dfdf.preferred_last_name) 
               ,CONCAT(dfadp.preferred_first_name, ' ', dfadp.preferred_last_name)) AS subject_name
      ,COALESCE(dfdf.legal_entity_name, dfadp.legal_entity_name) AS subject_legal_entity_name
      ,CONVERT(VARCHAR,COALESCE(dfdf.primary_site, dfadp.primary_site)) AS subject_location
      ,COALESCE(dfdf.primary_site_schoolid, dfadp.primary_site_schoolid) AS subject_primary_site_schoolid
      ,COALESCE(dfdf.primary_site_school_level, dfadp.primary_site_school_level) AS subject_primary_site_school_level
      ,COALESCE(dfdf.manager_df_employee_number, dfadp.manager_df_employee_number) AS subject_manager_id      

      ,COALESCE(addf.samaccountname, adadp.samaccountname) AS subject_username

      ,COALESCE(mgrdf.displayname, mgradp.displayname) AS subject_manager_name
      ,COALESCE(mgrdf.samaccountname, mgradp.samaccountname) AS subject_manager_username

      ,NULL AS avg_response_value_location
FROM gabby.surveys.self_and_others_survey_long_static so     
LEFT JOIN gabby.dayforce.staff_roster dfadp
  ON so.subject_associate_id = dfadp.adp_associate_id
LEFT JOIN gabby.adsi.user_attributes_static adadp
  ON dfadp.adp_associate_id = adadp.idautopersonalternateid
LEFT JOIN gabby.adsi.user_attributes_static mgradp
  ON dfadp.manager_adp_associate_id = mgradp.idautopersonalternateid
LEFT JOIN gabby.dayforce.staff_roster dfdf
  ON so.subject_associate_id = CONVERT(VARCHAR,dfdf.df_employee_number)     
LEFT JOIN gabby.adsi.user_attributes_static addf
  ON CONVERT(VARCHAR,dfdf.df_employee_number) = addf.employeenumber     
LEFT JOIN gabby.adsi.user_attributes_static mgrdf
  ON CONVERT(VARCHAR,dfdf.manager_df_employee_number) = mgrdf.employeenumber