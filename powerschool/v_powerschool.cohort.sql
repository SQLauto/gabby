USE gabby
GO

ALTER VIEW powerschool.cohort AS

SELECT studentid
      ,schoolid
      ,grade_level
      ,entrydate
      ,exitdate
      ,entrycode
      ,exitcode
      ,exitcomment
      ,lunchstatus
      ,yearid
      ,academic_year
      ,NULL AS cohort
      ,rn_year
      ,rn_school
      ,rn_undergrad
      ,rn_all
      ,year_in_school
      ,year_in_network                  
      ,MIN(prev_grade_level) OVER(PARTITION BY studentid, yearid ORDER BY yearid ASC) AS prev_grade_level
      ,CASE
        WHEN grade_level != 99 
         AND sub.grade_level <= MIN(prev_grade_level) OVER(PARTITION BY studentid, yearid ORDER BY yearid ASC) 
             THEN 1
        ELSE 0
       END AS is_retained_year
FROM
    (
     SELECT sub.studentid      
           ,sub.schoolid      
           ,sub.grade_level      
           ,sub.entrydate
           ,sub.exitdate
           ,sub.entrycode
           ,sub.exitcode      
           ,sub.exitcomment
           ,sub.lunchstatus      
           ,sub.yearid
           ,(sub.yearid + 1990) AS academic_year            
           ,LAG(grade_level, 1) OVER(PARTITION BY sub.studentid ORDER BY sub.yearid ASC) AS prev_grade_level

           ,ROW_NUMBER() OVER(
              PARTITION BY sub.studentid, sub.yearid
                ORDER BY sub.yearid DESC, sub.exitdate DESC) AS rn_year
           ,ROW_NUMBER() OVER(
              PARTITION BY sub.studentid, sub.schoolid
                ORDER BY sub.yearid DESC, sub.exitdate DESC) AS rn_school
           ,ROW_NUMBER() OVER(
              PARTITION BY sub.studentid, CASE WHEN sub.grade_level = 99 THEN 1 ELSE 0 END
                ORDER BY sub.yearid DESC, sub.exitdate DESC) AS rn_undergrad
           ,ROW_NUMBER() OVER(
              PARTITION BY sub.studentid
                ORDER BY sub.yearid DESC, sub.exitdate DESC) AS rn_all
           ,ROW_NUMBER() OVER(
              PARTITION BY sub.studentid, sub.schoolid
                ORDER BY sub.yearid ASC, sub.exitdate ASC) AS year_in_school
           ,ROW_NUMBER() OVER(
              PARTITION BY sub.studentid
                ORDER BY sub.yearid ASC, sub.exitdate ASC) AS year_in_network
     FROM
         (
          /* terminal (current & transfers) */
          SELECT s.id AS studentid
                ,s.grade_level
                ,s.schoolid
                ,s.entrydate
                ,s.exitdate
                ,s.entrycode
                ,s.exitcode
                ,s.exitcomment
                ,s.lunchstatus
                ,terms.yearid
          FROM gabby.powerschool.students s
          JOIN gabby.powerschool.terms terms
            ON s.schoolid = terms.schoolid 
           AND s.entrydate BETWEEN terms.firstday AND terms.lastday
           AND terms.portion = 1
          WHERE s.enroll_status IN (0, 2)            
            AND s.exitdate > s.entrydate
     
          UNION ALL

          /* terminal (grads) */
          SELECT s.id AS studentid
                ,s.grade_level
                ,s.schoolid           
                ,NULL AS entrydate
                ,NULL AS exitdate        
                ,NULL AS entrycode
                ,NULL AS exitcode
                ,NULL AS exitcomment
                ,NULL AS lunchstatus
                ,terms.yearid
          FROM gabby.powerschool.students s
          JOIN gabby.powerschool.terms terms
            ON s.schoolid = terms.schoolid
           AND s.entrydate <= terms.firstday
           AND terms.portion = 1
          WHERE s.enroll_status = 3                
            AND s.id NOT IN (171, 141, 45) /* 3 students back in the Dark Ages graduated 8th, didn't go to NCA in 9th, but came back and graduated from NCA with a different student record */

          UNION ALL

          /* re-enrollments */
          SELECT re.studentid
                ,re.grade_level
                ,re.schoolid
                ,re.entrydate
                ,re.exitdate 
                ,re.entrycode
                ,re.exitcode
                ,re.exitcomment           
                ,re.lunchstatus            
                ,terms.yearid
          FROM gabby.powerschool.reenrollments re       
          JOIN gabby.powerschool.terms terms
            ON re.schoolid = terms.schoolid       
           AND re.entrydate BETWEEN terms.firstday AND terms.lastday
           AND terms.portion = 1     
          WHERE re.schoolid != 12345 /* filter out summer school */
            AND re.exitdate > re.entrydate            
         ) sub
    ) sub