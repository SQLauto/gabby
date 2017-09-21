USE gabby
GO

CREATE OR ALTER VIEW tableau.attendance_dashboard AS

SELECT sub.academic_year
      ,sub.schoolid
      ,sub.studentid
      ,sub.student_number
      ,sub.lastfirst
      ,sub.grade_level
      ,sub.school_level
      ,sub.team
      ,sub.enroll_status
      ,sub.iep_status
      ,sub.gender
      ,sub.ethnicity
      ,sub.section_number
      ,sub.teacher_name
      ,sub.calendardate
      ,sub.membershipvalue
      ,sub.is_present
      ,sub.is_absent
      ,sub.att_code
      ,sub.is_tardy
      ,sub.suspension_all
      ,sub.n_A
      ,sub.n_AD
      ,sub.n_AE
      ,sub.n_A_E
      ,sub.n_CR
      ,sub.n_CS
      ,sub.n_D
      ,sub.n_E
      ,sub.n_EA
      ,sub.n_ET
      ,sub.n_EV
      ,sub.n_ISS
      ,sub.n_NM
      ,sub.n_OS
      ,sub.n_OSS
      ,sub.n_OSSP
      ,sub.n_PLE
      ,sub.n_Q
      ,sub.n_S
      ,sub.n_SE
      ,sub.n_T
      ,sub.n_T10
      ,sub.n_TE
      ,sub.n_TLE
      ,sub.n_U
      ,sub.n_X
      ,sub.term
      ,MAX(CASE WHEN sub.att_code IN ('OS', 'OSS', 'OSSP') THEN 1 ELSE 0 END)
         OVER(PARTITION BY sub.student_number, sub.academic_year
              ORDER BY sub.calendardate) AS is_oss_running
      ,MAX(CASE WHEN sub.att_code IN ('S', 'ISS') THEN 1 ELSE 0 END) 
         OVER(PARTITION BY sub.student_number, sub.academic_year
              ORDER BY sub.calendardate) AS is_iss_running
      ,MAX(CASE WHEN sub.att_code IN ('OS', 'OSS', 'OSSP', 'S', 'ISS') THEN 1 ELSE 0 END) 
         OVER(PARTITION BY sub.student_number, sub.academic_year
              ORDER BY sub.calendardate) AS is_suspended_running
FROM
    (
     SELECT co.academic_year
           ,co.reporting_schoolid AS schoolid
           ,co.studentid
           ,co.student_number
           ,CONVERT(NVARCHAR(256),co.lastfirst) AS lastfirst
           ,co.grade_level
           ,co.school_level
           ,CONVERT(NVARCHAR(32),co.team) AS team
           ,co.enroll_status
           ,CONVERT(NVARCHAR(64),co.iep_status) AS iep_status
           ,co.gender
           ,CONVERT(NVARCHAR(16),co.ethnicity) AS ethnicity            

           ,CONVERT(NVARCHAR(64),enr.section_number) AS section_number
           ,CONVERT(NVARCHAR(256),enr.teacher_name) AS teacher_name

           ,mem.calendardate
           ,mem.membershipvalue
           ,mem.attendancevalue AS is_present
           ,ABS(mem.attendancevalue - 1) AS is_absent

           ,CONVERT(NVARCHAR(16),att.att_code) AS att_code
           ,CASE WHEN att.att_code IN ('T','T10','ET','TE') THEN 1 ELSE 0 END AS is_tardy
           ,CASE WHEN att.att_code IN ('OSS','ISS') THEN 1 ELSE 0 END AS suspension_all
           ,CASE WHEN att.att_code = 'A' THEN 1 ELSE 0 END AS n_A
           ,CASE WHEN att.att_code = 'AD' THEN 1 ELSE 0 END AS n_AD
           ,CASE WHEN att.att_code = 'AE' THEN 1 ELSE 0 END AS n_AE
           ,CASE WHEN att.att_code = 'A-E' THEN 1 ELSE 0 END AS n_A_E
           ,CASE WHEN att.att_code = 'CR' THEN 1 ELSE 0 END AS n_CR
           ,CASE WHEN att.att_code = 'CS' THEN 1 ELSE 0 END AS n_CS
           ,CASE WHEN att.att_code = 'D' THEN 1 ELSE 0 END AS n_D
           ,CASE WHEN att.att_code = 'E' THEN 1 ELSE 0 END AS n_E
           ,CASE WHEN att.att_code = 'EA' THEN 1 ELSE 0 END AS n_EA
           ,CASE WHEN att.att_code = 'ET' THEN 1 ELSE 0 END AS n_ET
           ,CASE WHEN att.att_code = 'EV' THEN 1 ELSE 0 END AS n_EV
           ,CASE WHEN att.att_code = 'ISS' THEN 1 ELSE 0 END AS n_ISS
           ,CASE WHEN att.att_code = 'NM' THEN 1 ELSE 0 END AS n_NM
           ,CASE WHEN att.att_code = 'OS' THEN 1 ELSE 0 END AS n_OS
           ,CASE WHEN att.att_code = 'OSS' THEN 1 ELSE 0 END AS n_OSS
           ,CASE WHEN att.att_code = 'OSSP' THEN 1 ELSE 0 END AS n_OSSP
           ,CASE WHEN att.att_code = 'PLE' THEN 1 ELSE 0 END AS n_PLE
           ,CASE WHEN att.att_code = 'Q' THEN 1 ELSE 0 END AS n_Q
           ,CASE WHEN att.att_code = 'S' THEN 1 ELSE 0 END AS n_S
           ,CASE WHEN att.att_code = 'SE' THEN 1 ELSE 0 END AS n_SE
           ,CASE WHEN att.att_code = 'T' THEN 1 ELSE 0 END AS n_T
           ,CASE WHEN att.att_code = 'T10' THEN 1 ELSE 0 END AS n_T10
           ,CASE WHEN att.att_code = 'TE' THEN 1 ELSE 0 END AS n_TE
           ,CASE WHEN att.att_code = 'TLE' THEN 1 ELSE 0 END AS n_TLE
           ,CASE WHEN att.att_code = 'U' THEN 1 ELSE 0 END AS n_U
           ,CASE WHEN att.att_code = 'X' THEN 1 ELSE 0 END AS n_X

           ,CONVERT(NVARCHAR(32),dt.alt_name) AS term     
     FROM gabby.powerschool.cohort_identifiers_static co
     LEFT OUTER JOIN gabby.powerschool.course_enrollments_static enr
       ON co.studentid = enr.studentid
      AND co.academic_year = enr.academic_year 
      AND CONVERT(NVARCHAR(16),enr.course_number) = 'HR' 
      AND enr.rn_course_yr = 1
     JOIN gabby.powerschool.ps_adaadm_daily_ctod_static mem
       ON co.studentid = mem.studentid
      AND co.schoolid = mem.schoolid
      AND mem.calendardate BETWEEN co.entrydate AND co.exitdate
      AND mem.calendardate <= CONVERT(DATE,GETDATE()) 
      AND mem.membershipvalue > 0
      AND mem.attendancevalue IS NOT NULL
     LEFT OUTER JOIN gabby.powerschool.ps_attendance_daily_static att
       ON co.studentid = att.studentid
      AND mem.calendardate = att.att_date
     LEFT OUTER JOIN gabby.reporting.reporting_terms dt 
       ON co.schoolid = dt.schoolid
      AND co.academic_year = dt.academic_year
      AND mem.calendardate BETWEEN CONVERT(DATE,dt.start_date) AND CONVERT(DATE,dt.end_date)
      AND CONVERT(NVARCHAR(16),dt.identifier) = 'RT'
     WHERE co.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
    ) sub

UNION ALL

SELECT academic_year
      ,schoolid
      ,studentid
      ,student_number
      ,lastfirst
      ,grade_level
      ,school_level
      ,team
      ,enroll_status
      ,iep_status
      ,gender
      ,ethnicity
      ,section_number
      ,teacher_name
      ,calendardate
      ,membershipvalue
      ,is_present
      ,is_absent
      ,att_code
      ,is_tardy
      ,suspension_all
      ,n_A
      ,n_AD
      ,n_AE
      ,n_A_E
      ,n_CR
      ,n_CS
      ,n_D
      ,n_E
      ,n_EA
      ,n_ET
      ,n_EV
      ,n_ISS
      ,n_NM
      ,n_OS
      ,n_OSS
      ,n_OSSP
      ,n_PLE
      ,n_Q
      ,n_S
      ,n_SE
      ,n_T
      ,n_T10
      ,n_TE
      ,n_TLE
      ,n_U
      ,n_X
      ,term
      ,is_oss_running
      ,is_iss_running
      ,is_suspended_running
FROM gabby.tableau.attendance_dashboard_archive