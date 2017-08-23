USE gabby
GO

ALTER VIEW powerschool.final_grades_wide AS

WITH grades_unpivot AS (
  SELECT student_number
        ,studentid
        ,academic_year
        ,CONVERT(VARCHAR,term_name) AS term_name
        ,reporting_term
        ,is_curterm
        ,course_number
        ,course_name
        ,credittype
        ,credit_hours
        ,excludefromgpa
        ,sectionid
        ,teacher_name
        ,y1_grade_letter
        ,y1_grade_percent
        ,e1_grade_percent
        ,e2_grade_percent
        ,need_90
        ,need_80
        ,need_70
        ,need_65
        ,CONCAT(reporting_term,'_',field) AS pivot_field
        ,CASE WHEN value = '' THEN NULL ELSE value END AS value
  FROM
      (
       SELECT fg.student_number      
             ,fg.studentid
             ,fg.academic_year      
             ,fg.term_name                  
             ,fg.course_number                                       
             ,fg.course_name
             ,fg.credittype
             ,fg.credit_hours
             ,fg.reporting_term                                      
             ,fg.sectionid                              
             ,fg.teacher_name
             ,fg.is_curterm
             ,fg.excludefromgpa
                          
             ,fg.e1_adjusted AS e1_grade_percent /* using only F* adjusted, when applicable */
             ,fg.e2_adjusted AS e2_grade_percent /* using only F* adjusted, when applicable */             
             ,fg.y1_grade_percent_adjusted AS y1_grade_percent /* using only F* adjusted, when applicable */             
             ,fg.y1_grade_letter AS y1_grade_letter
             
             /* empty strings preserve term_name structure when there aren't any grades */
             ,ISNULL(CONVERT(VARCHAR(64),fg.term_grade_letter),'') AS term_grade_letter
             ,ISNULL(CONVERT(VARCHAR(64),fg.term_grade_percent),'') AS term_grade_percent
             ,ISNULL(CONVERT(VARCHAR(64),fg.term_grade_letter_adjusted),'') AS term_grade_letter_adjusted
             ,ISNULL(CONVERT(VARCHAR(64),fg.term_grade_percent_adjusted),'') AS term_grade_percent_adjusted                          

             ,ISNULL(CONVERT(VARCHAR(64),fg.need_90),'') AS need_90
             ,ISNULL(CONVERT(VARCHAR(64),fg.need_80),'') AS need_80
             ,ISNULL(CONVERT(VARCHAR(64),fg.need_70),'') AS need_70
             ,ISNULL(CONVERT(VARCHAR(64),fg.need_65),'') AS need_65
       FROM gabby.powerschool.final_grades_static fg 
       WHERE fg.academic_year >= gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1

       UNION ALL

       SELECT fg.student_number      
             ,fg.studentid
             ,fg.academic_year      
             ,fg.term_name
             ,fg.course_number                                       
             ,fg.course_name
             ,fg.credittype
             ,fg.credit_hours
             ,'CUR' AS reporting_term
             ,fg.sectionid                              
             ,fg.teacher_name
             ,fg.is_curterm
             ,fg.excludefromgpa
             
             ,fg.e1_adjusted AS e1_grade_percent /* using only F* adjusted, when applicable */
             ,fg.e2_adjusted AS e2_grade_percent /* using only F* adjusted, when applicable */             
             ,fg.y1_grade_percent_adjusted AS y1_grade_percent /* using only F* adjusted, when applicable */             
             ,fg.y1_grade_letter AS y1_grade_letter
             
             /* empty strings preserve term_name structure when there aren't any grades */
             ,ISNULL(CONVERT(VARCHAR(64),fg.term_grade_letter),'') AS term_grade_letter
             ,ISNULL(CONVERT(VARCHAR(64),fg.term_grade_percent),'') AS term_grade_percent
             ,ISNULL(CONVERT(VARCHAR(64),fg.term_grade_letter_adjusted),'') AS term_grade_letter_adjusted
             ,ISNULL(CONVERT(VARCHAR(64),fg.term_grade_percent_adjusted),'') AS term_grade_percent_adjusted                          

             ,ISNULL(CONVERT(VARCHAR(64),fg.need_90),'') AS need_90
             ,ISNULL(CONVERT(VARCHAR(64),fg.need_80),'') AS need_80
             ,ISNULL(CONVERT(VARCHAR(64),fg.need_70),'') AS need_70
             ,ISNULL(CONVERT(VARCHAR(64),fg.need_65),'') AS need_65
       FROM gabby.powerschool.final_grades_static fg 
       WHERE fg.academic_year >= gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1
      ) sub
  UNPIVOT(
    value
    FOR field IN (term_grade_letter
                 ,term_grade_percent
                 ,term_grade_letter_adjusted
                 ,term_grade_percent_adjusted)                 
   ) u
 )

SELECT student_number
      ,studentid
      ,academic_year
      ,reporting_term
      ,term_name
      ,is_curterm
      ,credittype
      ,course_number
      ,sectionid
      ,course_name
      ,teacher_name
      ,credit_hours
      ,excludefromgpa
      ,y1_grade_letter
      ,y1_grade_percent
      ,need_90
      ,need_80
      ,need_70
      ,need_65

      ,MAX(e1_grade_percent) OVER(PARTITION BY student_number, academic_year, course_name ORDER BY term_name ASC) AS e1_grade_percent
      ,MAX(e2_grade_percent) OVER(PARTITION BY student_number, academic_year, course_name ORDER BY term_name ASC) AS e2_grade_percent
      ,MAX(RT1_term_grade_letter) OVER(PARTITION BY student_number, academic_year, course_name ORDER BY term_name ASC) AS RT1_term_grade_letter
      ,MAX(RT1_term_grade_letter_adjusted) OVER(PARTITION BY student_number, academic_year, course_name ORDER BY term_name ASC) AS RT1_term_grade_letter_adjusted
      ,MAX(RT1_term_grade_percent) OVER(PARTITION BY student_number, academic_year, course_name ORDER BY term_name ASC) AS RT1_term_grade_percent
      ,MAX(RT1_term_grade_percent_adjusted) OVER(PARTITION BY student_number, academic_year, course_name ORDER BY term_name ASC) AS RT1_term_grade_percent_adjusted      
      
      ,MAX(RT2_term_grade_letter) OVER(PARTITION BY student_number, academic_year, course_name ORDER BY term_name ASC) AS RT2_term_grade_letter
      ,MAX(RT2_term_grade_letter_adjusted) OVER(PARTITION BY student_number, academic_year, course_name ORDER BY term_name ASC) AS RT2_term_grade_letter_adjusted
      ,MAX(RT2_term_grade_percent) OVER(PARTITION BY student_number, academic_year, course_name ORDER BY term_name ASC) AS RT2_term_grade_percent
      ,MAX(RT2_term_grade_percent_adjusted) OVER(PARTITION BY student_number, academic_year, course_name ORDER BY term_name ASC) AS RT2_term_grade_percent_adjusted      
      
      ,MAX(RT3_term_grade_letter) OVER(PARTITION BY student_number, academic_year, course_name ORDER BY term_name ASC) AS RT3_term_grade_letter
      ,MAX(RT3_term_grade_letter_adjusted) OVER(PARTITION BY student_number, academic_year, course_name ORDER BY term_name ASC) AS RT3_term_grade_letter_adjusted
      ,MAX(RT3_term_grade_percent) OVER(PARTITION BY student_number, academic_year, course_name ORDER BY term_name ASC) AS RT3_term_grade_percent
      ,MAX(RT3_term_grade_percent_adjusted) OVER(PARTITION BY student_number, academic_year, course_name ORDER BY term_name ASC) AS RT3_term_grade_percent_adjusted      
      
      ,MAX(RT4_term_grade_letter) OVER(PARTITION BY student_number, academic_year, course_name ORDER BY term_name ASC) AS RT4_term_grade_letter
      ,MAX(RT4_term_grade_letter_adjusted) OVER(PARTITION BY student_number, academic_year, course_name ORDER BY term_name ASC) AS RT4_term_grade_letter_adjusted
      ,MAX(RT4_term_grade_percent) OVER(PARTITION BY student_number, academic_year, course_name ORDER BY term_name ASC) AS RT4_term_grade_percent
      ,MAX(RT4_term_grade_percent_adjusted) OVER(PARTITION BY student_number, academic_year, course_name ORDER BY term_name ASC) AS RT4_term_grade_percent_adjusted

      ,[CUR_term_grade_letter]
      ,[CUR_term_grade_letter_adjusted]
      ,[CUR_term_grade_percent]
      ,[CUR_term_grade_percent_adjusted]

      ,ROW_NUMBER() OVER(
         PARTITION BY student_number, academic_year, term_name, credittype
           ORDER BY course_number ASC) AS rn_credittype
FROM grades_unpivot gr
PIVOT(
  MAX(value)
  FOR pivot_field IN ([RT1_term_grade_letter]
                     ,[RT1_term_grade_letter_adjusted]
                     ,[RT1_term_grade_percent]
                     ,[RT1_term_grade_percent_adjusted]                     
                     ,[RT2_term_grade_letter]
                     ,[RT2_term_grade_letter_adjusted]
                     ,[RT2_term_grade_percent]
                     ,[RT2_term_grade_percent_adjusted]                     
                     ,[RT3_term_grade_letter]
                     ,[RT3_term_grade_letter_adjusted]
                     ,[RT3_term_grade_percent]
                     ,[RT3_term_grade_percent_adjusted]                     
                     ,[RT4_term_grade_letter]
                     ,[RT4_term_grade_letter_adjusted]
                     ,[RT4_term_grade_percent]
                     ,[RT4_term_grade_percent_adjusted]
                     ,[CUR_term_grade_letter]
                     ,[CUR_term_grade_letter_adjusted]
                     ,[CUR_term_grade_percent]
                     ,[CUR_term_grade_percent_adjusted])
 ) p