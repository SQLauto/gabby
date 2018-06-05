USE gabby
GO

CREATE OR ALTER VIEW surveys.exit_survey_detail AS

SELECT df.df_employee_number
      ,df.adp_associate_id AS associate_id
      ,df.termination_date
      ,df.status_reason AS termination_reason_description
      ,df.primary_job AS job_title_description
      ,df.birth_date
      ,df.primary_ethnicity AS eeo_ethnic_description
      ,df.primary_on_site_department AS subject_dept_custom
      ,df.payclass + ' - ' + df.job_family AS benefits_eligibility_class_description
      ,df.is_manager AS is_management
      ,df.gender
      ,df.original_hire_date AS hire_date
      ,df.status AS position_status      
      ,df.address
      ,df.city AS primary_address_city
      ,df.state AS primary_address_state_territory_code
      ,df.postal_code AS primary_address_zip_postal_code
      ,df.primary_site AS location
      ,df.manager_name AS manager
      ,MONTH(df.original_hire_date) AS hire_month
      ,COALESCE(YEAR(df.termination_date), YEAR(GETDATE())) - YEAR(df.original_hire_date) + 1 AS years_at_kipp
      ,gabby.utilities.DATE_TO_SY(df.termination_date) AS termination_academic_year
	
      ,es.timestamp AS exit_survey_date
      ,es.q_1 AS exit_survey_title
      ,es.q_2 AS exit_survey_location
      ,es.q_3 AS nps
      ,es.q_4 AS nps_explanation
      ,es.q_5	AS voluntary_termination
      ,es.q_6 AS exit_survey_reason_for_leaving
      ,es.q_7 AS next_role
      ,es.q_8 AS next_title
      ,es.q_9 AS expectation_alignment
      ,es.q_10 AS open_comment
      ,es.q_11 AS anonymous
      ,es.q_12 AS consider_kipp_in_future
      ,es.q_13 AS what_does_kipp_do_well
      ,es.q_14 AS how_can_kipp_improve
      ,es.q_15 AS rating_career_growth
      ,es.q_16 AS rating_schedule_flexibility
      ,es.q_17 AS rating_compensation_benefits
      ,es.q_18 AS rating_school_culture
      ,es.q_19 AS rating_immediate_principal_supervisor
      ,es.q_20 AS rating_kid_focus
      ,es.q_21 AS rating_impact
      ,es.q_22 AS rating_improvement
      ,es.q_23 AS rating_freedom
      ,es.q_24 AS rating_fun
      ,es.q_25 AS rating_teamwork        
FROM gabby.surveys.exit_survey es
LEFT JOIN gabby.dayforce.staff_roster df
  ON es.df_id = df.df_employee_number