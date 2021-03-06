CREATE OR ALTER VIEW powerschool.team_roster AS

SELECT studentid
      ,student_number
      ,academic_year
      ,team
      ,1 AS rn_year
FROM
    (
     SELECT enr.studentid
           ,enr.student_number                      
           ,enr.academic_year                       
           ,CONVERT(VARCHAR(25),CASE
             WHEN gabby.utilities.STRIP_CHARACTERS(enr.section_number,'0-9') = '' COLLATE Latin1_General_BIN THEN enr.teacher_name
             ELSE gabby.utilities.STRIP_CHARACTERS(enr.section_number,'0-9')
            END) AS team

           ,CONVERT(INT,ROW_NUMBER() OVER(
                          PARTITION BY enr.student_number, enr.academic_year
                            ORDER BY enr.dateleft DESC, enr.dateenrolled DESC)) AS rn_year
     FROM powerschool.course_enrollments_static enr           
     WHERE enr.course_number = 'HR'
       AND enr.sectionid > 0
    ) sub
WHERE rn_year = 1