USE gabby
GO

CREATE OR ALTER VIEW illuminate_dna_assessments.assessment_responses_long AS

WITH asmts AS (
  SELECT a.student_id
        ,a.assessment_id
        ,a.title
        ,a.academic_year    
        ,a.administered_at
        ,a.scope
        ,a.subject_area
        ,a.module_type
        ,a.module_number
        ,a.performance_band_set_id
        ,a.is_replacement
        ,a.grade_level_id
        ,a.is_normed_scope

        ,sa.student_assessment_id
        ,sa.date_taken
  FROM gabby.illuminate_dna_assessments.student_assessment_scaffold a
  --LEFT JOIN gabby.illuminate_dna_assessments.students_assessments sa
  LEFT JOIN illuminate_dna_assessments.students_assessments_workaround sa
    ON a.student_id = sa.student_id
   AND a.assessment_id = sa.assessment_id
 )

SELECT a.student_id
      ,a.assessment_id
      ,a.title
      ,a.academic_year    
      ,a.administered_at
      ,a.scope
      ,a.subject_area
      ,a.module_type
      ,a.module_number
      ,a.performance_band_set_id
      ,a.grade_level_id
      ,a.is_replacement
      ,a.is_normed_scope
      ,a.date_taken

      ,'O' AS response_type

      ,asr.points
      ,asr.points_possible                     
      ,asr.percent_correct             
        
      ,-1 AS standard_id
      ,'Overall' AS standard_code
      ,'Overall' AS standard_description
      ,NULL AS domain_description
FROM asmts a  
LEFT JOIN gabby.illuminate_dna_assessments.agg_student_responses asr
  ON a.student_assessment_id = asr.student_assessment_id
 AND asr.points_possible > 0  

UNION ALL

SELECT a.student_id
      ,a.assessment_id
      ,a.title
      ,a.academic_year    
      ,a.administered_at
      ,a.scope
      ,a.subject_area
      ,a.module_type
      ,a.module_number
      ,astd.performance_band_set_id
      ,a.grade_level_id
      ,a.is_replacement
      ,a.is_normed_scope
      ,a.date_taken

      ,'S' AS response_type

      ,asrs.points
      ,asrs.points_possible        
      ,asrs.percent_correct             
      ,asrs.standard_id

      ,CONVERT(VARCHAR(125),std.custom_code) AS standard_code
      ,CONVERT(VARCHAR(2000),std.description) AS standard_description

      ,dom.domain_description
FROM asmts a  
JOIN gabby.illuminate_dna_assessments.agg_student_responses_standard asrs
  ON a.student_assessment_id = asrs.student_assessment_id
 AND asrs.points_possible > 0  
JOIN gabby.illuminate_dna_assessments.assessment_standards astd
  ON asrs.assessment_id = astd.assessment_id
 AND asrs.standard_id = astd.standard_id
LEFT JOIN gabby.illuminate_standards.standards std
  ON asrs.standard_id = std.standard_id   
LEFT JOIN gabby.illuminate_standards.standards_domain_static dom
  ON asrs.standard_id = dom.standard_id
 AND dom.domain_level = 1
 AND dom.domain_label NOT IN ('', 'Standard')
  
UNION ALL

SELECT a.student_id
      ,a.assessment_id
      ,a.title
      ,a.academic_year    
      ,a.administered_at
      ,a.scope
      ,a.subject_area
      ,a.module_type
      ,a.module_number
      ,arg.performance_band_set_id
      ,a.grade_level_id
      ,a.is_replacement
      ,a.is_normed_scope
      ,a.date_taken

      ,'G' AS response_type
                          
      ,asrg.points
      ,asrg.points_possible        
      ,asrg.percent_correct             
      ,asrg.reporting_group_id AS standard_id

      ,NULL AS standard_code
      ,rg.label AS standard_description
      ,NULL AS domain_description
FROM asmts a  
JOIN gabby.illuminate_dna_assessments.agg_student_responses_group asrg
  ON a.student_assessment_id = asrg.student_assessment_id      
 AND asrg.points_possible > 0       
JOIN gabby.illuminate_dna_assessments.assessments_reporting_groups arg
  ON asrg.assessment_id = arg.assessment_id
 AND asrg.reporting_group_id = arg.reporting_group_id
JOIN gabby.illuminate_dna_assessments.reporting_groups rg
  ON asrg.reporting_group_id = rg.reporting_group_id