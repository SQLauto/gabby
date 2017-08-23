USE gabby
GO

ALTER VIEW extracts.deanslist_student_misc AS

WITH ug_school AS (
  SELECT student_number
        ,schoolid        
  FROM gabby.powerschool.cohort_identifiers_static
  WHERE schoolid != 999999
    AND rn_undergrad = 1
 )

,enroll_dates AS (
  SELECT student_number
        ,schoolid
        ,MIN(entrydate) AS school_entrydate
        ,MAX(exitdate) AS school_exitdate
  FROM gabby.powerschool.cohort_identifiers_static s  
  GROUP BY student_number, schoolid
 )

SELECT co.student_number
      ,co.state_studentnumber AS SID
      ,co.team
      ,co.dob
      ,co.home_phone
      ,co.mother AS parent1_name
      ,co.father AS parent2_name
      ,co.guardianemail
      ,co.academic_year      
      ,co.mother_cell AS parent1_cell      
      ,co.father_cell AS parent2_cell
      ,co.advisor_name
      ,co.advisor_phone AS advisor_cell
      ,co.advisor_email
      ,co.lunch_balance            
      ,CASE
        WHEN co.enroll_status = -1 THEN 'Pre-Registered'
        WHEN co.enroll_status = 0 THEN 'Enrolled'
        WHEN co.enroll_status = 1 THEN 'Inactive'
        WHEN co.enroll_status = 2 THEN 'Transferred Out'
        WHEN co.enroll_status = 3 THEN 'Graduated'
       END AS enroll_status
      ,CONCAT(co.street, ', ', co.city, ', ', co.state, ' ', co.zip) AS home_address
      
      ,ed.school_entrydate
      ,ed.school_exitdate
      
      ,nav.counselor_name AS ktc_counselor_name
      
      ,adp.personal_contact_personal_mobile AS ktc_counselor_phone
      
      ,ad.mail AS ktc_counselor_email
      
      ,cat.H_Y1 AS HWQ_Y1
      
      ,gpa.GPA_Y1      
FROM gabby.powerschool.cohort_identifiers_static co
JOIN ug_school ug
  ON co.student_number = ug.student_number
LEFT OUTER JOIN enroll_dates ed
  ON co.student_number = ed.student_number
 AND CASE WHEN co.schoolid = 999999 THEN ug.schoolid ELSE co.schoolid END = ed.schoolid
LEFT OUTER JOIN gabby.naviance.students nav 
  ON co.student_number = nav.hs_student_id
LEFT OUTER JOIN gabby.adp.staff_roster adp 
  ON nav.counselor_name = CONCAT(adp.preferred_first, ' ', adp.preferred_last)
 AND adp.rn_curr = 1
LEFT OUTER JOIN gabby.adsi.user_attributes ad
  ON adp.associate_id = ad.idautopersonalternateid
LEFT OUTER JOIN gabby.powerschool.category_grades_wide cat
  ON co.student_number = cat.student_number
 AND co.academic_year = cat.academic_year
 AND cat.is_curterm = 1
 AND cat.course_number = 'ALL'
LEFT OUTER JOIN gabby.powerschool.gpa_detail gpa
  ON co.student_number = gpa.student_number
 AND co.academic_year = gpa.academic_year
 AND gpa.is_curterm = 1
WHERE co.academic_year >= gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1
  AND co.rn_year = 1