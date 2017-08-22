USE gabby
GO

ALTER VIEW powerschool.course_section_scaffold AS 

WITH course_scaffold AS (
  SELECT studentid
        ,student_number
        ,yearid
        ,term_name
        ,course_number
        ,excludefromgpa
        ,CASE 
          WHEN CONVERT(DATE,GETDATE()) BETWEEN term_start_date AND term_end_date THEN 1
          WHEN term_end_date <= CONVERT(DATE,GETDATE()) AND term_start_date = MAX(CONVERT(DATE,term_start_date)) OVER(PARTITION BY studentid, yearid, course_number) THEN 1
          ELSE 0
         END AS is_curterm
  FROM
      (
       SELECT DISTINCT 
              co.studentid
             ,co.student_number
             ,co.yearid      
      
             ,terms.alt_name AS term_name        
             ,CONVERT(DATE,terms.start_date) AS term_start_date
             ,CONVERT(DATE,terms.end_date) AS term_end_date
                            
             ,enr.course_number
             ,enr.excludefromgpa
       FROM gabby.powerschool.cohort_identifiers_static co  
       JOIN gabby.reporting.reporting_terms terms
         ON co.schoolid = terms.schoolid   
        AND co.academic_year = terms.academic_year
        AND terms.identifier = 'RT'
        AND terms.alt_name != 'Summer School'
       JOIN gabby.powerschool.course_enrollments_static enr
         ON co.studentid = enr.studentid
        AND co.yearid = enr.yearid
        --AND enr.course_enroll_status = 0
        --AND enr.section_enroll_status = 0
        AND enr.dateenrolled <= CONVERT(DATE,GETDATE())
       WHERE co.rn_year = 1
      ) sub
 )

,section_scaffold AS (
  SELECT cc.studentid            
        ,cc.course_number            
        ,LEFT(ABS(cc.termid), 2) AS yearid      
        ,ABS(cc.sectionid) AS abs_sectionid
      
        ,CASE WHEN terms.alt_name = 'Summer School' THEN 'Q1' ELSE terms.alt_name END AS term_name

        ,ROW_NUMBER() OVER(
           PARTITION BY cc.studyear, cc.course_number, CASE WHEN terms.alt_name = 'Summer School' THEN 'Q1' ELSE terms.alt_name END
             ORDER BY cc.dateleft DESC, cc.sectionid DESC) AS rn_term
  FROM gabby.powerschool.cc
  JOIN gabby.reporting.reporting_terms terms
    ON cc.schoolid = terms.schoolid      
   AND RIGHT(cc.studyear, 2) = terms.yearid   
   AND cc.dateenrolled BETWEEN CONVERT(DATE,terms.start_date) AND CONVERT(DATE,terms.end_date)
   AND terms.identifier = 'RT'
  WHERE cc.dateenrolled <= CONVERT(DATE,GETDATE())
 )

SELECT cs.studentid
      ,cs.student_number
      ,cs.yearid
      ,cs.term_name
      ,cs.is_curterm
      ,cs.course_number      
      ,cs.excludefromgpa

      ,COALESCE(ss.abs_sectionid
               ,LAG(ss.abs_sectionid, 1) OVER(PARTITION BY cs.studentid, cs.yearid, cs.course_number ORDER BY cs.term_name)
               ,LAG(ss.abs_sectionid, 2) OVER(PARTITION BY cs.studentid, cs.yearid, cs.course_number ORDER BY cs.term_name)
               ,LAG(ss.abs_sectionid, 3) OVER(PARTITION BY cs.studentid, cs.yearid, cs.course_number ORDER BY cs.term_name)) AS sectionid
FROM course_scaffold cs
LEFT OUTER JOIN section_scaffold ss
  ON cs.studentid = ss.studentid
 AND cs.yearid = ss.yearid
 AND cs.term_name = ss.term_name
 AND cs.course_number = ss.course_number
 AND ss.rn_term = 1