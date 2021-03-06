USE gabby
GO

CREATE OR ALTER VIEW tableau.school_tactical_dashboard AS

WITH roster AS (
  SELECT co.student_number
        ,co.studentid
        ,co.academic_year
        ,co.yearid
        ,co.region
        ,CONVERT(VARCHAR(5),co.school_level) AS school_level
        ,CONVERT(VARCHAR(25),co.reporting_schoolid) AS reporting_schoolid
        ,CONVERT(VARCHAR(5),co.grade_level) AS grade_level
        ,co.iep_status
        ,co.lunchstatus
        ,co.exitdate
        ,co.enroll_status
        ,co.db_name
  FROM gabby.powerschool.cohort_identifiers_static co
  WHERE co.reporting_schoolid NOT IN (999999, 5173)
    AND co.rn_year = 1
 )

,demographics AS (
  SELECT u.academic_year
        ,u.region
        ,u.school_level
        ,u.reporting_schoolid
        ,u.grade_level
        
        ,u.field
        ,u.value
  FROM
      (
       SELECT sub.academic_year
             ,ISNULL(sub.region, 'All') AS region
             ,ISNULL(sub.school_level, 'All') AS school_level
             ,ISNULL(sub.reporting_schoolid, 'All') AS reporting_schoolid
             ,ISNULL(sub.grade_level, 'All') AS grade_level

             ,AVG(CAST(sub.is_fr_lunch AS FLOAT)) AS pct_fr_lunch
             ,SUM(CAST(sub.is_attrition_week AS FLOAT)) AS n_attrition_week
       FROM
           (
            SELECT r.academic_year
                  ,r.region
                  ,r.school_level
                  ,r.reporting_schoolid
                  ,r.grade_level
                  ,CASE WHEN r.lunchstatus IN ('F', 'R') THEN 1.0 ELSE 0.0 END AS is_fr_lunch
                  ,CASE WHEN r.exitdate BETWEEN DATEADD(DAY, 1 - (DATEPART(WEEKDAY, SYSDATETIME())), CAST(SYSDATETIME() AS DATE)) /* week start date */
                                            AND DATEADD(DAY, 7 - (DATEPART(WEEKDAY, SYSDATETIME())), CAST(SYSDATETIME() AS DATE)) /* week end date */
                                                  THEN 1.0 ELSE 0.0 END AS is_attrition_week
            FROM roster r
           ) sub
       GROUP BY sub.academic_year
               ,sub.school_level
               ,ROLLUP(sub.region, sub.reporting_schoolid)
               ,CUBE(sub.grade_level)
      ) sub
  UNPIVOT(
    value
    FOR field IN (pct_fr_lunch, n_attrition_week)
   ) u
 )

,modules AS (  
  SELECT u.academic_year
        ,u.region
        ,u.school_level
        ,u.reporting_schoolid
        ,u.grade_level
        ,u.subject_area
        ,u.module_number
      
        ,u.field
        ,u.value
  FROM
      (
       SELECT sub.academic_year
             ,sub.subject_area
             ,sub.module_number

             ,ISNULL(sub.region, 'All') AS region
             ,ISNULL(sub.school_level, 'All') AS school_level
             ,ISNULL(sub.reporting_schoolid, 'All') AS reporting_schoolid
             ,ISNULL(sub.grade_level, 'All') AS grade_level
      
             ,AVG(sub.is_target) AS pct_target
             ,AVG(sub.is_approaching) AS pct_approaching
             ,AVG(sub.is_below) AS pct_below
             ,AVG(sub.is_target_iep) AS pct_target_iep
             ,AVG(sub.is_approaching_iep) AS pct_approaching_iep
             ,AVG(sub.is_below_iep) AS pct_below_iep
       FROM
           (
            SELECT r.student_number
                  ,r.academic_year
                  ,r.region
                  ,r.school_level
                  ,r.reporting_schoolid
                  ,r.grade_level

                  ,a.subject_area
                  ,a.module_number
                  ,CASE 
                    WHEN a.performance_band_number IS NULL THEN NULL
                    WHEN a.performance_band_number >= 4 THEN 1.0 
                    ELSE 0.0 
                   END AS is_target
                  ,CASE 
                    WHEN a.performance_band_number IS NULL THEN NULL
                    WHEN a.performance_band_number = 3 THEN 1.0 
                    ELSE 0.0 
                   END AS is_approaching
                  ,CASE 
                    WHEN a.performance_band_number IS NULL THEN NULL
                    WHEN a.performance_band_number <= 2 THEN 1.0 
                    ELSE 0.0 
                   END AS is_below
           
                  ,CASE 
                    WHEN r.iep_status = 'No IEP' THEN NULL
                    WHEN a.performance_band_number IS NULL THEN NULL
                    WHEN a.performance_band_number >= 4 THEN 1.0 
                    ELSE 0.0 
                   END AS is_target_iep
                  ,CASE 
                    WHEN r.iep_status = 'No IEP' THEN NULL
                    WHEN a.performance_band_number IS NULL THEN NULL
                    WHEN a.performance_band_number = 3 THEN 1.0 
                    ELSE 0.0 
                   END AS is_approaching_iep
                  ,CASE 
                    WHEN r.iep_status = 'No IEP' THEN NULL
                    WHEN a.performance_band_number IS NULL THEN NULL
                    WHEN a.performance_band_number <= 2 THEN 1.0 
                    ELSE 0.0 
                   END AS is_below_iep
            FROM roster r
            JOIN gabby.illuminate_dna_assessments.agg_student_responses_all a
              ON r.student_number = a.local_student_id
             AND r.academic_year = a.academic_year
             AND a.response_type = 'O'
             AND a.is_replacement = 0
             AND a.module_type IN ('QA', 'CRQ')
             AND a.module_number IS NOT NULL
           ) sub
       GROUP BY sub.academic_year
               ,sub.subject_area
               ,sub.module_number
               ,sub.school_level
               ,ROLLUP(sub.region, sub.reporting_schoolid)
               ,CUBE(sub.grade_level)
      ) sub
  UNPIVOT (
    value
    FOR field IN (sub.pct_target
                 ,sub.pct_approaching
                 ,sub.pct_below
                 ,sub.pct_target_iep
                 ,sub.pct_approaching_iep
                 ,sub.pct_below_iep) 
   ) u
 )

,parcc AS (
  SELECT u.academic_year
        ,u.region
        ,u.school_level
        ,u.reporting_schoolid
        ,u.grade_level
        ,u.subject
      
        ,u.field
        ,u.value
  FROM
      (
       SELECT sub.academic_year
             ,sub.subject

             ,ISNULL(sub.region, 'All') AS region
             ,ISNULL(sub.school_level, 'All') AS school_level
             ,ISNULL(sub.reporting_schoolid, 'All') AS reporting_schoolid
             ,ISNULL(sub.grade_level, 'All') AS grade_level
      
             ,AVG(sub.is_target) AS pct_target
             ,AVG(sub.is_approaching) AS pct_approaching
             ,AVG(sub.is_below) AS pct_below
             ,AVG(sub.is_target_iep) AS pct_target_iep
             ,AVG(sub.is_approaching_iep) AS pct_approaching_iep
             ,AVG(sub.is_below_iep) AS pct_below_iep
       FROM
           (
            SELECT r.student_number
                  ,r.academic_year
                  ,r.region
                  ,r.school_level
                  ,r.reporting_schoolid
                  ,r.grade_level

                  ,p.subject
                  ,CASE WHEN p.test_performance_level >= 4 THEN 1.0 ELSE 0.0 END AS is_target
                  ,CASE WHEN p.test_performance_level = 3 THEN 1.0 ELSE 0.0 END AS is_approaching
                  ,CASE WHEN p.test_performance_level <= 2 THEN 1.0 ELSE 0.0 END AS is_below

                  ,CASE 
                    WHEN r.iep_status = 'No IEP' THEN NULL
                    WHEN p.test_performance_level >= 4 THEN 1.0 
                    ELSE 0.0 
                   END AS is_target_iep
                  ,CASE 
                    WHEN r.iep_status = 'No IEP' THEN NULL
                    WHEN p.test_performance_level = 3 THEN 1.0 
                    ELSE 0.0 
                   END AS is_approaching_iep
                  ,CASE 
                    WHEN r.iep_status = 'No IEP' THEN NULL
                    WHEN p.test_performance_level <= 2 THEN 1.0 
                    ELSE 0.0 
                   END AS is_below_iep
            FROM roster r
            JOIN gabby.parcc.summative_record_file_clean p
              ON r.student_number = p.local_student_identifier
             AND r.academic_year = p.academic_year
           ) sub
       GROUP BY sub.academic_year
               ,sub.subject
               ,sub.school_level
               ,ROLLUP(sub.region, sub.reporting_schoolid)
               ,CUBE(sub.grade_level)
      ) sub
  UNPIVOT (
    value
    FOR field IN (sub.pct_target
                 ,sub.pct_approaching
                 ,sub.pct_below
                 ,sub.pct_target_iep
                 ,sub.pct_approaching_iep
                 ,sub.pct_below_iep) 
   ) u
 )

,student_attendance AS (
  SELECT r.student_number
        ,r.academic_year
        ,r.region
        ,r.school_level
        ,r.reporting_schoolid
        ,r.grade_level
        ,r.iep_status
        ,r.enroll_status
      
        ,SUM(CAST(ada.membershipvalue AS FLOAT)) AS n_membership
        ,SUM(CAST(ada.attendancevalue AS FLOAT)) AS n_present
        ,SUM(CASE 
              WHEN ada.calendardate BETWEEN DATEADD(DAY, 1 - (DATEPART(WEEKDAY, SYSDATETIME())), CAST(SYSDATETIME() AS DATE)) /* week start date */
                                        AND DATEADD(DAY, 7 - (DATEPART(WEEKDAY, SYSDATETIME())), CAST(SYSDATETIME() AS DATE)) /* week end date */
                                              THEN CAST(ada.membershipvalue AS FLOAT)
             END) AS n_membership_week
        ,SUM(CASE 
              WHEN ada.calendardate BETWEEN DATEADD(DAY, 1 - (DATEPART(WEEKDAY, SYSDATETIME())), CAST(SYSDATETIME() AS DATE)) /* week start date */
                                        AND DATEADD(DAY, 7 - (DATEPART(WEEKDAY, SYSDATETIME())), CAST(SYSDATETIME() AS DATE)) /* week end date */
                                              THEN CAST(ada.attendancevalue AS FLOAT)
             END) AS n_present_week


        ,SUM(CAST(CASE WHEN att.att_code IN ('T', 'T10') THEN 1 ELSE 0 END AS FLOAT)) AS n_tardy
        ,CAST(CASE WHEN SUM(CASE WHEN att.att_code = 'ISS' THEN 1 END) > 0 THEN 1 ELSE 0 END AS FLOAT) AS is_iss
        ,CAST(CASE WHEN SUM(CASE WHEN att.att_code = 'OSS' THEN 1 END) > 0 THEN 1 ELSE 0 END AS FLOAT) AS is_oss
        ,SUM(CASE 
              WHEN ada.calendardate BETWEEN DATEADD(DAY, 1 - (DATEPART(WEEKDAY, SYSDATETIME())), CAST(SYSDATETIME() AS DATE)) /* week start date */
                                        AND DATEADD(DAY, 7 - (DATEPART(WEEKDAY, SYSDATETIME())), CAST(SYSDATETIME() AS DATE)) /* week end date */
                                              THEN CAST(CASE WHEN att.att_code IN ('T', 'T10') THEN 1 ELSE 0 END AS FLOAT)
             END) AS n_tardy_week
        ,SUM(CASE 
              WHEN ada.calendardate BETWEEN DATEADD(DAY, 1 - (DATEPART(WEEKDAY, SYSDATETIME())), CAST(SYSDATETIME() AS DATE)) /* week start date */
                                        AND DATEADD(DAY, 7 - (DATEPART(WEEKDAY, SYSDATETIME())), CAST(SYSDATETIME() AS DATE)) /* week end date */
                                              THEN CAST(CASE WHEN att.att_code = 'ISS' THEN 1 ELSE 0 END AS FLOAT)
             END) AS is_iss_week
        ,SUM(CASE 
              WHEN ada.calendardate BETWEEN DATEADD(DAY, 1 - (DATEPART(WEEKDAY, SYSDATETIME())), CAST(SYSDATETIME() AS DATE)) /* week start date */
                                        AND DATEADD(DAY, 7 - (DATEPART(WEEKDAY, SYSDATETIME())), CAST(SYSDATETIME() AS DATE)) /* week end date */
                                              THEN CAST(CASE WHEN att.att_code = 'OSS' THEN 1 ELSE 0 END AS FLOAT)
             END) AS is_oss_week
        
        ,CAST(CASE 
               WHEN r.iep_status = 'No IEP' THEN NULL 
               WHEN SUM(CASE WHEN att.att_code = 'ISS' THEN 1 END) > 0 THEN 1 
               ELSE 0 
              END AS FLOAT) AS is_iss_iep
        ,CAST(CASE 
               WHEN r.iep_status = 'No IEP' THEN NULL 
               WHEN SUM(CASE WHEN att.att_code = 'OSS' THEN 1 END) > 0 THEN 1 
               ELSE 0 
              END AS FLOAT) AS is_oss_iep
  FROM roster r
  JOIN gabby.powerschool.ps_adaadm_daily_ctod ada
    ON r.studentid = ada.studentid
   AND r.yearid = ada.yearid
   AND r.db_name = ada.db_name
   AND ada.membershipvalue > 0
   AND ada.calendardate < CAST(SYSDATETIME() AS DATE)
  LEFT JOIN gabby.powerschool.ps_attendance_daily att
    ON r.studentid = att.studentid
   AND r.db_name = att.db_name
   AND ada.calendardate = att.att_date 
  GROUP BY r.student_number
          ,r.academic_year
          ,r.region
          ,r.school_level
          ,r.reporting_schoolid
          ,r.grade_level
          ,r.iep_status
          ,r.enroll_status
 )

,student_attendance_rollup AS (
  SELECT u.academic_year
        ,u.region
        ,u.school_level
        ,u.reporting_schoolid
        ,u.grade_level

        ,u.field
        ,u.value
  FROM
      (
       SELECT sub.academic_year
             ,ISNULL(sub.region, 'All') AS region        
             ,ISNULL(sub.school_level, 'All') AS school_level
             ,ISNULL(sub.reporting_schoolid, 'All') AS reporting_schoolid
             ,ISNULL(sub.grade_level, 'All') AS grade_level
            
             ,SUM(sub.n_present) / SUM(sub.n_membership) AS pct_ada             
             ,(SUM(sub.n_present) - SUM(sub.n_tardy)) / SUM(sub.n_membership) AS pct_ontime             
             ,AVG(sub.is_iss) AS pct_iss
             ,AVG(sub.is_oss) AS pct_oss
             ,AVG(sub.is_iss_iep) AS pct_iss_iep
             ,AVG(sub.is_oss_iep) AS pct_oss_iep

             ,SUM(sub.n_present_week) / SUM(sub.n_membership_week) AS pct_ada_week
             ,(SUM(sub.n_present_week) - SUM(sub.n_tardy_week)) / SUM(sub.n_membership_week) AS pct_ontime_week
             ,CAST(COUNT(DISTINCT CASE WHEN sub.is_iss_week >= 1 THEN sub.student_number END) AS FLOAT) AS n_iss_week
             ,CAST(COUNT(DISTINCT CASE WHEN sub.is_oss_week >= 1 THEN sub.student_number END) AS FLOAT) AS n_oss_week
       FROM student_attendance sub
       GROUP BY sub.academic_year
               ,sub.school_level
               ,ROLLUP(sub.region, sub.reporting_schoolid)
               ,CUBE(sub.grade_level)
      ) sub
  UNPIVOT(
    value 
    FOR field IN (sub.pct_ada
                 ,sub.pct_ontime
                 ,sub.pct_iss
                 ,sub.pct_oss
                 ,sub.pct_iss_iep
                 ,sub.pct_oss_iep                 
                 ,sub.pct_ada_week
                 ,sub.pct_ontime_week
                 ,sub.n_iss_week
                 ,sub.n_oss_week)
   ) u
)

,chronic_absentee AS (
  SELECT sub.academic_year
        ,ISNULL(sub.region, 'All') AS region        
        ,ISNULL(sub.school_level, 'All') AS school_level
        ,ISNULL(sub.reporting_schoolid, 'All') AS reporting_schoolid
        ,ISNULL(sub.grade_level, 'All') AS grade_level

        ,'pct_chronic_absentee' AS field
        ,AVG(sub.is_chronic_absentee) AS value
  FROM
      (
       SELECT sa.student_number
             ,sa.academic_year
             ,sa.region
             ,sa.school_level
             ,sa.reporting_schoolid
             ,sa.grade_level
      
             ,CAST(CASE WHEN (sa.n_present / sa.n_membership) < 0.895 THEN 1 ELSE 0 END AS FLOAT) AS is_chronic_absentee
       FROM student_attendance sa
       WHERE sa.enroll_status = 0
      ) sub
  GROUP BY sub.academic_year
          ,sub.school_level
          ,ROLLUP(sub.region, sub.reporting_schoolid)
          ,CUBE(sub.grade_level)
 )

,staff_attrition AS (
  SELECT u.academic_year
        ,u.region
        ,u.school_level
        ,u.reporting_schoolid
        ,u.grade_level
      
        ,u.field
        ,u.value
  FROM
      (
       SELECT sub.academic_year
             ,ISNULL(sub.region, 'All') AS region        
             ,ISNULL(sub.school_level, 'All') AS school_level
             ,ISNULL(sub.reporting_schoolid, 'All') AS reporting_schoolid
             ,'All' AS grade_level

             ,AVG(sub.is_attrition) AS pct_attrition
             ,AVG(sub.is_attrition_resignation) AS pct_attrition_resignation
             ,AVG(sub.is_attrition_termination) AS pct_attrition_termination
       FROM
           (
            SELECT a.df_employee_number
                  ,a.academic_year
                  ,CASE
                    WHEN a.legal_entity_name = 'TEAM Academy Charter Schools' THEN 'TEAM'
                    WHEN a.legal_entity_name = 'KIPP Cooper Norcross Academy' THEN 'KCNA'
                    WHEN a.legal_entity_name = 'KIPP Miami' THEN 'KMS'
                   END AS region      
                  ,a.primary_site_school_level COLLATE Latin1_General_BIN AS school_level
                  ,CAST(a.primary_site_reporting_schoolid AS VARCHAR(25)) AS reporting_schoolid
                  ,NULL AS grade_level
                  ,CAST(a.is_attrition AS FLOAT) AS is_attrition
                  ,CAST(CASE WHEN a.status_reason = 'Resignation' THEN 1.0 ELSE 0.0 END AS FLOAT) AS is_attrition_resignation
                  ,CAST(CASE WHEN a.status_reason = 'Termination' THEN 1.0 ELSE 0.0 END AS FLOAT) AS is_attrition_termination
            FROM gabby.tableau.compliance_staff_attrition a
            WHERE a.is_denominator = 1
              AND a.primary_site_reporting_schoolid != 0
              AND a.legal_entity_name != 'KIPP New Jersey'
              AND a.academic_year = 2002
           ) sub
       GROUP BY sub.academic_year
               ,sub.school_level
               ,ROLLUP(sub.region, sub.reporting_schoolid)
      ) sub
  UNPIVOT(
    value
    FOR field IN (sub.pct_attrition
                 ,sub.pct_attrition_resignation
                 ,sub.pct_attrition_termination)
   ) u
 )

,student_attrition AS (
  SELECT sub.academic_year
        ,ISNULL(sub.region, 'All') AS region
        ,ISNULL(sub.school_level, 'All') AS school_level
        ,ISNULL(sub.reporting_schoolid, 'All') AS reporting_schoolid
        ,ISNULL(sub.grade_level, 'All') AS grade_level
      
        ,'pct_attrition' AS field
        ,AVG(sub.is_attrition) AS value
  FROM
      (
       SELECT y1.student_number      
             ,y1.academic_year
             ,y1.region
             ,CONVERT(VARCHAR(5),y1.school_level) AS school_level
             ,CONVERT(VARCHAR(25),y1.reporting_schoolid) AS reporting_schoolid
             ,CONVERT(VARCHAR(5),y1.grade_level) AS grade_level

             ,CASE
               /* graduates != attrition */
               WHEN y1.exitcode = 'G1' THEN 0.0
               /* handles re-enrollments during the year */
               WHEN s.exitdate >= y1.exitdate AND s.exitdate >= CONVERT(DATE,SYSDATETIME()) THEN 0.0
               /* was not enrolled on 10/1 next year */
               WHEN y1.academic_year < gabby.utilities.GLOBAL_ACADEMIC_YEAR() AND y1.exitdate <= SYSDATETIME() AND y2.entrydate IS NULL THEN 1.0
               /* left after 10/1 this year */
               WHEN y1.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR() AND s.exitdate <= SYSDATETIME() THEN 1.0
               ELSE 0.0
              END AS is_attrition
       FROM gabby.powerschool.cohort_identifiers_static y1
       LEFT JOIN gabby.powerschool.students s
         ON y1.student_number = s.student_number
        AND y1.db_name = s.db_name
       LEFT JOIN gabby.powerschool.cohort_identifiers_static y2
         ON y1.student_number = y2.student_number
        AND y1.db_name = y2.db_name
        AND y1.academic_year = (y2.academic_year - 1)
        AND DATEFROMPARTS(y2.academic_year, 10, 01) BETWEEN y2.entrydate AND y2.exitdate
       WHERE DATEFROMPARTS(y1.academic_year, 10, 01) BETWEEN y1.entrydate AND y1.exitdate
      ) sub
  GROUP BY sub.academic_year
          ,sub.school_level
          ,ROLLUP(sub.region, sub.reporting_schoolid)
          ,CUBE(sub.grade_level)
 )

,gpa AS (
  SELECT u.academic_year
        ,u.region
        ,u.school_level
        ,u.reporting_schoolid
        ,u.grade_level
      
        ,u.field
        ,u.value
  FROM
      (
       SELECT sub.academic_year
             ,ISNULL(sub.region, 'All') AS region        
             ,ISNULL(sub.school_level, 'All') AS school_level
             ,ISNULL(sub.reporting_schoolid, 'All') AS reporting_schoolid
             ,ISNULL(sub.grade_level, 'All') AS grade_level

             ,AVG(sub.gpa_ge_3) AS pct_gpa_ge_3
             ,AVG(sub.gpa_ge_2) AS pct_gpa_ge_2
       FROM
           (
            SELECT r.student_number
                  ,r.academic_year
                  ,r.region
                  ,r.school_level
                  ,r.reporting_schoolid
                  ,r.grade_level
      
                  ,CASE WHEN gpa.gpa_y1 >= 3.0 THEN 1.0 ELSE 0.0 END AS gpa_ge_3
                  ,CASE WHEN gpa.gpa_y1 >= 2.0 THEN 1.0 ELSE 0.0 END AS gpa_ge_2
            FROM roster r
            JOIN gabby.powerschool.gpa_detail gpa
              ON r.student_number = gpa.student_number
             AND r.academic_year = gpa.academic_year
             AND r.reporting_schoolid = gpa.schoolid
             AND gpa.is_curterm = 1
           ) sub
       GROUP BY sub.academic_year
               ,sub.school_level
               ,ROLLUP(sub.region, sub.reporting_schoolid)
               ,CUBE(sub.grade_level)
      ) sub
  UNPIVOT(
    value
    FOR field IN (sub.pct_gpa_ge_3
                 ,sub.pct_gpa_ge_2)
   ) u
 )

,staff_attendance AS (
  SELECT u.academic_year
        ,u.region
        ,u.school_level
        ,u.reporting_schoolid
        ,u.grade_level
        
        ,u.field
        ,u.value
  FROM
      (
       SELECT sub.academic_year
             ,ISNULL(sub.region, 'All') AS region        
             ,ISNULL(sub.primary_site_school_level, 'All') AS school_level
             ,ISNULL(sub.reporting_schoolid, 'All') AS reporting_schoolid
             ,'All' AS grade_level
      
             ,AVG(sub.present_lt_90) AS pct_present_lt_90
             ,AVG(sub.present_ge_90_lt_95) AS pct_present_ge_90_lt_95
             ,AVG(sub.ontime_lt_90) AS pct_ontime_lt_90
             ,AVG(sub.ontime_ge_90_lt_95) AS pct_ontime_ge_90_lt_95
       FROM
           (
            SELECT df_employee_number
                  ,academic_year
                  ,CASE 
                    WHEN legal_entity_name = 'TEAM Academy Charter Schools' THEN 'TEAM'
                    WHEN legal_entity_name = 'KIPP Cooper Norcross Academy' THEN 'TEAM'
                    WHEN legal_entity_name = 'KIPP Miami' THEN 'KMS'
                    ELSE ''
                   END AS region
                  ,primary_site_school_level
                  ,CAST(schoolid AS VARCHAR(25)) AS reporting_schoolid
                  ,NULL AS grade_level

                  ,SUM(1) AS membershipvalue
                  ,SUM(CASE WHEN absent IS NULL OR absent = 'excused' THEN 1.0 ELSE 0.0 END) AS is_present
                  ,SUM(CASE WHEN late IS NULL OR late = 'excused' THEN 1.0 ELSE 0.0 END) AS is_ontime
                  ,SUM(CASE WHEN absent IS NULL OR absent = 'excused' THEN 1.0 ELSE 0.0 END) / SUM(1) AS pct_present
                  ,SUM(CASE WHEN late IS NULL OR late = 'excused' THEN 1.0 ELSE 0.0 END) / SUM(1) AS pct_ontime
           
                  ,CASE WHEN SUM(CASE WHEN absent IS NULL OR absent = 'excused' THEN 1.0 ELSE 0.0 END) / SUM(1) < 0.895 THEN 1.0 ELSE 0.0 END AS present_lt_90
                  ,CASE WHEN SUM(CASE WHEN absent IS NULL OR absent = 'excused' THEN 1.0 ELSE 0.0 END) / SUM(1) BETWEEN 0.895 AND 0.944 THEN 1.0 ELSE 0.0 END AS present_ge_90_lt_95
                  ,CASE WHEN SUM(CASE WHEN late IS NULL OR late = 'excused' THEN 1.0 ELSE 0.0 END) / SUM(1) < 0.895 THEN 1.0 ELSE 0.0 END AS ontime_lt_90
                  ,CASE WHEN SUM(CASE WHEN late IS NULL OR late = 'excused' THEN 1.0 ELSE 0.0 END) / SUM(1) BETWEEN 0.895 AND 0.944 THEN 1.0 ELSE 0.0 END AS ontime_ge_90_lt_95           
            FROM gabby.tableau.staff_tracker
            GROUP BY df_employee_number
                    ,academic_year
                    ,legal_entity_name
                    ,primary_site_school_level
                    ,schoolid
           ) sub
       GROUP BY sub.academic_year
               ,sub.primary_site_school_level
               ,ROLLUP(sub.region, sub.reporting_schoolid)
      ) sub
  UNPIVOT(
    value
    FOR field IN (sub.pct_present_lt_90
                 ,sub.pct_present_ge_90_lt_95
                 ,sub.pct_ontime_lt_90
                 ,sub.pct_ontime_ge_90_lt_95)
   ) u
 )

,lit AS (
  SELECT u.academic_year
        ,u.reporting_term
        ,u.region
        ,u.school_level
        ,u.reporting_schoolid
        ,u.grade_level
        ,u.field
        ,u.value      
  FROM
      (
       SELECT sub.academic_year
             ,sub.reporting_term
             ,ISNULL(sub.region, 'All') AS region        
             ,ISNULL(sub.school_level, 'All') AS school_level
             ,ISNULL(sub.reporting_schoolid, 'All') AS reporting_schoolid
             ,ISNULL(sub.grade_level, 'All') AS grade_level
      
             ,AVG(sub.is_on_gradelevel) AS pct_on_gradelevel
             ,AVG(sub.moved_reading_level) AS pct_moved_reading_level
       FROM
           (
            SELECT r.student_number      
                  ,r.academic_year      
                  ,r.region
                  ,r.school_level
                  ,r.reporting_schoolid
                  ,r.grade_level      
      
                  ,achv.reporting_term                        
      
                  ,CONVERT(FLOAT,achv.met_goal) AS is_on_gradelevel
                  ,CASE WHEN achv.reporting_term = 'LIT1' THEN NULL ELSE CONVERT(FLOAT,achv.moved_levels) END AS moved_reading_level
            FROM roster r
            JOIN gabby.lit.achieved_by_round_static achv
              ON r.student_number = achv.student_number
             AND r.academic_year = achv.academic_year 
             AND achv.achv_unique_id LIKE 'FPBAS%'
             AND achv.start_date <= SYSDATETIME()
           ) sub
       GROUP BY sub.academic_year
               ,sub.reporting_term
               ,sub.school_level
               ,ROLLUP(sub.region, sub.reporting_schoolid)
               ,CUBE(sub.grade_level)
      ) sub
  UNPIVOT(
    value
    FOR field IN (sub.pct_on_gradelevel
                 ,sub.pct_moved_reading_level)
   ) u
 )

,so_survey AS (
  SELECT academic_year
        ,reporting_term
        ,ISNULL(subject_legal_entity_name, 'All') AS region        
        ,ISNULL(subject_primary_site_school_level, 'All') AS school_level
        ,ISNULL(subject_primary_site_schoolid, 'All') AS reporting_schoolid
        ,'All' AS grade_level      
      
        ,'avg_survey_weighted_response_value' AS field
        ,AVG(avg_survey_weighted_response_value) AS value
  FROM
      (
       SELECT academic_year
             ,reporting_term
             ,subject_legal_entity_name COLLATE Latin1_General_BIN AS subject_legal_entity_name
             ,subject_primary_site_school_level
             ,CONVERT(VARCHAR,subject_primary_site_schoolid) AS subject_primary_site_schoolid            
             ,subject_username

             ,SUM(total_weighted_response_value) / SUM(total_response_weight) AS avg_survey_weighted_response_value
       FROM gabby.surveys.self_and_others_survey_rollup
       WHERE subject_primary_site_school_level IS NOT NULL
       GROUP BY academic_year
               ,reporting_term
               ,subject_legal_entity_name
               ,subject_primary_site_school_level
               ,subject_primary_site_schoolid
               ,subject_username
      ) sub
  GROUP BY academic_year
          ,reporting_term
          ,subject_primary_site_school_level
          ,ROLLUP(subject_legal_entity_name, subject_primary_site_schoolid)
 )

,manager_survey AS (
  SELECT academic_year
        ,reporting_term
        ,ISNULL(subject_legal_entity_name, 'All') AS region        
        ,ISNULL(subject_primary_site_school_level, 'All') AS school_level
        ,ISNULL(subject_primary_site_schoolid, 'All') AS reporting_schoolid
        ,'All' AS grade_level      
      
        ,'avg_survey_response_value' AS field
        ,AVG(sub.avg_survey_response_value) AS value
  FROM
      (
       SELECT academic_year
             ,reporting_term
             ,subject_legal_entity_name COLLATE Latin1_General_BIN AS subject_legal_entity_name
             ,subject_primary_site_school_level
             ,CONVERT(VARCHAR,subject_primary_site_schoolid) AS subject_primary_site_schoolid            
             ,subject_username

             ,AVG(avg_response_value) AS avg_survey_response_value
       FROM gabby.surveys.manager_survey_rollup
       WHERE subject_primary_site_school_level IS NOT NULL
       GROUP BY academic_year
               ,reporting_term
               ,subject_legal_entity_name
               ,subject_primary_site_school_level
               ,subject_primary_site_schoolid
               ,subject_username
      ) sub
  GROUP BY academic_year
          ,reporting_term
          ,subject_primary_site_school_level
          ,ROLLUP(subject_legal_entity_name, subject_primary_site_schoolid)
 )

SELECT d.academic_year
      ,d.region
      ,d.school_level
      ,d.reporting_schoolid
      ,d.grade_level
      ,NULL AS subject_area
      ,'Y1' AS term_name
      
      ,'Student Enrollment' AS domain
      ,'Demographics' AS subdomain
      ,d.field
      ,d.value      
FROM demographics d

UNION ALL

SELECT m.academic_year
      ,m.region
      ,m.school_level
      ,m.reporting_schoolid
      ,m.grade_level
      ,m.subject_area
      ,m.module_number AS term_name
      
      ,'Assessments' AS domain
      ,'Internal Assessments' AS subdomain
      ,m.field
      ,m.value      
FROM modules m

UNION ALL

SELECT p.academic_year
      ,p.region
      ,p.school_level
      ,p.reporting_schoolid
      ,p.grade_level
      ,p.subject COLLATE Latin1_General_BIN AS subject_area
      ,'Y1' AS term_name
      
      ,'Assessments' AS domain
      ,'PARCC' AS subdomain
      ,p.field
      ,p.value      
FROM parcc p

UNION ALL

SELECT a.academic_year
      ,a.region
      ,a.school_level
      ,a.reporting_schoolid
      ,a.grade_level
      ,NULL AS subject_area
      ,'Y1' AS term_name
      
      ,CASE 
        WHEN a.field IN ('pct_iss', 'pct_oss', 'pct_iss_iep', 'pct_oss_iep') THEN 'Student Culture'
        ELSE 'Student Attendance'
       END AS domain
      ,NULL AS subdomain
      ,a.field
      ,a.value      
FROM student_attendance_rollup a

UNION ALL

SELECT a.academic_year
      ,a.region
      ,a.school_level
      ,a.reporting_schoolid
      ,a.grade_level
      ,NULL AS subject_area
      ,'Y1' AS term_name
      
      ,'Student Attendance' AS domain
      ,NULL AS subdomain
      ,a.field
      ,a.value      
FROM chronic_absentee a

UNION ALL

SELECT sa.academic_year
      ,sa.region
      ,sa.school_level
      ,sa.reporting_schoolid
      ,sa.grade_level
      ,NULL AS subject_area
      ,'Y1' AS term_name
      
      ,'Staff Attrition' AS domain
      ,NULL AS subdomain
      ,sa.field
      ,sa.value      
FROM staff_attrition sa

UNION ALL

SELECT sta.academic_year
      ,sta.region
      ,sta.school_level
      ,sta.reporting_schoolid
      ,sta.grade_level
      ,NULL AS subject_area
      ,'Y1' AS term_name
      
      ,'Student Attrition' AS domain
      ,NULL AS subdomain
      ,sta.field
      ,sta.value      
FROM student_attrition sta

UNION ALL

SELECT gpa.academic_year
      ,gpa.region
      ,gpa.school_level
      ,gpa.reporting_schoolid
      ,gpa.grade_level
      ,NULL AS subject_area
      ,'Y1' AS term_name

      ,'Grades' AS domain
      ,'GPA' AS subdomain
      ,gpa.field
      ,gpa.value      
FROM gpa

UNION ALL

SELECT sta.academic_year
      ,sta.region
      ,sta.school_level
      ,sta.reporting_schoolid
      ,sta.grade_level
      ,NULL AS subject_area
      ,'Y1' AS term_name

      ,'Staff Attendance' AS domain
      ,NULL AS subdomain
      ,sta.field
      ,sta.value
FROM staff_attendance sta

UNION ALL

SELECT lit.academic_year      
      ,lit.region
      ,lit.school_level
      ,lit.reporting_schoolid
      ,lit.grade_level
      ,NULL AS subject_area
      ,lit.reporting_term AS term_name

      ,'Literacy' AS domain
      ,NULL AS subdomain
      ,lit.field
      ,lit.value
FROM lit

UNION ALL

SELECT sos.academic_year      
      ,sos.region
      ,sos.school_level
      ,sos.reporting_schoolid
      ,sos.grade_level
      ,NULL AS subject_area
      ,sos.reporting_term AS term_name

      ,'Surveys' AS domain
      ,'Self & Others' AS subdomain
      ,sos.field
      ,sos.value
FROM so_survey sos

UNION ALL

SELECT mgr.academic_year      
      ,mgr.region
      ,mgr.school_level
      ,mgr.reporting_schoolid
      ,mgr.grade_level
      ,NULL AS subject_area
      ,mgr.reporting_term AS term_name

      ,'Surveys' AS domain
      ,'Manager' AS subdomain
      ,mgr.field
      ,mgr.value
FROM manager_survey mgr