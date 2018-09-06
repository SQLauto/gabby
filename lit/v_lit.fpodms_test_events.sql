USE gabby
GO

CREATE OR ALTER VIEW lit.fpodms_test_events AS 

WITH clean_data AS (
  SELECT sub.unique_id
        ,sub.student_identifier
        ,sub.year_of_assessment
        ,sub.academic_year
        ,sub.assessment_date
        ,sub.genre
        ,sub.data_type
        ,sub.class_name
        ,sub.benchmark_level
        ,sub.title
        ,sub.accuracy_percent
        ,sub.comprehension_within
        ,sub.comprehension_beyond
        ,sub.comprehension_about
        ,sub.comprehension_additional
        ,sub.comprehension_total
        ,sub.comprehension_maximum
        ,sub.comprehension_label
        ,sub.fluency
        ,sub.wpm_rate
        ,sub.writing
        ,sub.self_corrections
        ,sub.text_level
        ,sub.status        
        ,sub.schoolid
        ,sub.test_administered_by
        ,sub.testid
        ,sub.is_fp
        ,CASE WHEN sub.benchmark_level IN ('Instructional', 'Hard') THEN sub.text_level END AS dna_lvl
        ,CASE WHEN sub.benchmark_level IN ('Instructional', 'Hard') THEN sub.text_level END AS instruct_lvl
        ,CASE WHEN sub.benchmark_level = 'Independent' THEN sub.text_level END AS indep_lvl
  FROM
      (
       SELECT CONCAT('FPBAS', LEFT(fp.year_of_assessment, 4), fp._line) AS unique_id
             ,fp.student_identifier
             ,fp.year_of_assessment
             ,CONVERT(INT,LEFT(fp.year_of_assessment, 4)) AS academic_year      
             ,CONVERT(DATE,fp.assessment_date) AS assessment_date
             ,fp.genre
             ,fp.data_type
             ,fp.class_name
             ,fp.benchmark_level
             ,fp.title            
             ,fp.accuracy_ AS accuracy_percent
             ,fp.comprehension_within
             ,fp.comprehension_beyond
             ,fp.comprehension_about
             ,fp.comprehension_additional
             ,fp.comprehension_total
             ,fp.comprehension_maximum
             ,fp.comprehension_label
             ,fp.fluency
             ,fp.wpm_rate
             ,fp.writing
             ,fp.self_corrections /* how should this be parsed? */
             ,CASE 
               WHEN fp.text_level = 'false' THEN 'F'
               WHEN fp.text_level = 'true' THEN 'T'
               ELSE CONVERT(VARCHAR(5),fp.text_level)
              END AS text_level
             ,CASE
               WHEN fp.benchmark_level = 'Independent' THEN 'Achieved'
               WHEN fp.benchmark_level IN ('Instructional', 'Hard') THEN 'Did Not Achieve'
              END AS status           
             ,CASE
               WHEN fp.school_name = 'BOLD Academy' THEN 73258
               WHEN fp.school_name = 'KIPP Sunrise Academy' THEN 30200801
               WHEN fp.school_name = 'Lanning Sq Middle' THEN 179902
               WHEN fp.school_name = 'Lanning Sq Primary' THEN 179901
               WHEN fp.school_name = 'Life Academy' THEN 73257
               WHEN fp.school_name = 'Rise Academy' THEN 73252
               WHEN fp.school_name = 'Seek Academy' THEN 73256
               WHEN fp.school_name = 'SPARK Academy' THEN 73254
               WHEN fp.school_name = 'TEAM Academy' THEN 133570965
               WHEN fp.school_name = 'THRIVE Academy' THEN 73255
               WHEN fp.school_name = 'Whittier Middle' THEN 179903
              END AS schoolid

             ,c.teacher_first_name + ', ' + c.teacher_last_name AS test_administered_by
      
             ,3273 AS testid
             ,1 AS is_fp
       FROM gabby.fpodms.bas_assessments fp
       JOIN gabby.fpodms.bas_classes c
         ON fp.school_name = c.school_name
        AND fp.year_of_assessment = c.school_year
        AND fp.class_name = c.name
        AND c.student_count > 0
      ) sub
 )

SELECT cd.unique_id
      ,cd.student_identifier
      ,cd.year_of_assessment
      ,cd.academic_year
      ,cd.assessment_date
      ,cd.genre
      ,cd.data_type
      ,cd.class_name
      ,cd.benchmark_level
      ,cd.title
      ,cd.accuracy_percent
      ,cd.comprehension_within
      ,cd.comprehension_beyond
      ,cd.comprehension_about
      ,cd.comprehension_additional
      ,cd.comprehension_total
      ,cd.comprehension_maximum
      ,cd.comprehension_label
      ,cd.fluency
      ,cd.wpm_rate
      ,cd.writing
      ,cd.self_corrections
      ,cd.text_level
      ,cd.status
      ,cd.schoolid
      ,cd.test_administered_by
      ,cd.testid
      ,cd.is_fp
      ,cd.dna_lvl
      ,cd.instruct_lvl
      ,cd.indep_lvl

      ,rt.alt_name AS test_round
      ,CONVERT(INT,RIGHT(rt.time_per_name, 1)) AS round_num

      ,gleq.fp_lvl_num AS lvl_num
      ,gleq.gleq AS gleq      
      ,gleq.lvl_num AS gleq_lvl_num
      ,CASE WHEN cd.benchmark_level IN ('Instructional', 'Hard') THEN gleq.fp_lvl_num END AS dna_lvl_num
      ,CASE WHEN cd.benchmark_level IN ('Instructional', 'Hard') THEN gleq.fp_lvl_num END AS instruct_lvl_num      
      ,CASE WHEN cd.benchmark_level = 'Independent' THEN gleq.fp_lvl_num END AS indep_lvl_num      

      --,NULL AS fp_keylever /* comprehension label? */
FROM clean_data cd
LEFT JOIN gabby.reporting.reporting_terms rt
  ON cd.schoolid = rt.schoolid
 AND cd.assessment_date BETWEEN rt.start_date AND rt.end_date
 AND rt.identifier = 'LIT'
LEFT JOIN gabby.lit.gleq
  ON cd.text_level = gleq.read_lvl