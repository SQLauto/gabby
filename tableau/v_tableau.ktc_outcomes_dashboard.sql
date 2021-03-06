USE gabby
GO

CREATE OR ALTER VIEW tableau.ktc_outcomes_dashboard AS

WITH matric_app AS (
  SELECT c.id AS contact_id

        ,acc.type AS matriculation_account_type

        ,ROW_NUMBER() OVER(
           PARTITION BY c.id
             ORDER BY enr.start_date_c) AS rn
  FROM gabby.alumni.contact c
  JOIN gabby.alumni.application_c app
    ON c.id = app.applicant_c
   AND app.is_deleted = 0
   AND app.transfer_application_c = 0
   AND app.matriculation_decision_c = 'Matriculated (Intent to Enroll)'
  JOIN gabby.alumni.account acc
    ON app.school_c = acc.id
   AND acc.is_deleted = 0
  JOIN gabby.alumni.enrollment_c enr
    ON app.applicant_c = enr.student_c
   AND app.school_c = enr.school_c
   AND c.kipp_hs_class_c = YEAR(enr.start_date_c)
   AND enr.is_deleted = 0
  WHERE c.is_deleted = 0
 )

SELECT c.id AS contact_id
      ,c.name
      ,c.kipp_hs_class_c
      ,c.kipp_ms_graduate_c
      ,c.kipp_hs_graduate_c
      ,c.expected_hs_graduation_c
      ,c.actual_hs_graduation_date_c
      ,c.expected_college_graduation_c
      ,c.actual_college_graduation_date_c
      ,c.current_kipp_student_c
      ,c.highest_act_score_c

      ,rt.name AS record_type_name

      ,u.name AS user_name

      ,ei.ugrad_school_name
      ,ei.ugrad_pursuing_degree_type
      ,ei.ugrad_status
      ,ei.ugrad_start_date
      ,ei.ugrad_actual_end_date
      ,ei.ugrad_anticipated_graduation
      ,ei.ecc_school_name
      ,ei.ecc_pursuing_degree_type
      ,ei.ecc_status
      ,ei.ecc_start_date
      ,ei.ecc_actual_end_date
      ,ei.ecc_anticipated_graduation
      ,ei.ecc_adjusted_6_year_minority_graduation_rate
      ,ei.ecc_account_type
      ,ei.hs_school_name
      ,ei.hs_pursuing_degree_type
      ,ei.hs_status
      ,ei.hs_start_date
      ,ei.hs_actual_end_date
      ,ei.hs_anticipated_graduation

      ,a.matriculation_account_type
FROM gabby.alumni.contact c
JOIN gabby.alumni.record_type rt
  ON c.record_type_id = rt.id
JOIN gabby.alumni.[user] u
  ON c.owner_id = u.id
LEFT JOIN gabby.alumni.enrollment_identifiers ei
  ON c.id = ei.student_c
LEFT JOIN matric_app a
  ON c.id = a.contact_id
 AND a.rn = 1
WHERE c.is_deleted = 0