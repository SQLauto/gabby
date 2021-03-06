USE gabby
GO

CREATE OR ALTER VIEW nwea.best_baseline AS

WITH subj AS (
  SELECT 'Mathematics' AS measurementscale UNION
  SELECT 'Reading'  UNION
  SELECT 'Language Usage' UNION
  SELECT 'Science - General Science'
 )
  
SELECT r.student_number
      ,r.academic_year
      
      ,subj.measurementscale 
      
      ,CASE
        WHEN map_fall.test_ritscore > map_spr.test_ritscore THEN map_fall.test_id
        WHEN map_spr.test_ritscore IS NULL THEN map_fall.test_id
        ELSE map_spr.test_id
       END AS test_id
      ,CASE
        WHEN map_fall.test_ritscore > map_spr.test_ritscore THEN map_fall.term_name
        WHEN map_spr.test_ritscore IS NULL THEN map_fall.term_name
        ELSE map_spr.term_name
       END AS term_name
      ,CASE
        WHEN map_fall.test_ritscore > map_spr.test_ritscore THEN map_fall.test_ritscore
        WHEN map_spr.test_ritscore IS NULL THEN map_fall.test_ritscore
        ELSE map_spr.test_ritscore
       END AS test_ritscore
      ,CASE 
        WHEN map_fall.test_ritscore > map_spr.test_ritscore THEN map_fall.percentile_2015_norms
        WHEN map_spr.test_ritscore IS NULL THEN map_fall.percentile_2015_norms
        ELSE map_spr.percentile_2015_norms
       END AS testpercentile
      ,CASE 
        WHEN map_fall.test_ritscore > map_spr.test_ritscore THEN map_fall.fall_to_spring_projected_growth
        WHEN map_spr.test_ritscore IS NULL THEN map_fall.fall_to_spring_projected_growth
        ELSE map_spr.fall_to_spring_projected_growth
       END AS typical_growth_fallorspring_to_spring
      ,CASE 
        WHEN map_fall.test_ritscore > map_spr.test_ritscore THEN map_fall.ritto_reading_score
        WHEN map_spr.test_ritscore IS NULL THEN map_fall.ritto_reading_score
        ELSE map_spr.ritto_reading_score
       END AS lexile_score
FROM gabby.powerschool.cohort_identifiers_static r
CROSS JOIN subj
LEFT JOIN gabby.nwea.assessment_result_identifiers map_fall /* CURRENT YEAR FALL */
  ON r.student_number = map_fall.student_id
 AND r.academic_year = map_fall.academic_year 
 AND subj.measurementscale = map_fall.measurement_scale
 AND map_fall.rn_term_subj = 1 
 AND map_fall.term = 'Fall'
LEFT JOIN gabby.nwea.assessment_result_identifiers map_spr /* PREVIOUS YEAR SPRING */
  ON r.student_number = map_spr.student_id
 AND r.academic_year = map_spr.test_year 
 AND subj.measurementscale = map_spr.measurement_scale
 AND map_spr.rn_term_subj = 1
 AND map_spr.term = 'Spring'
WHERE r.schoolid != 999999
  AND r.rn_year = 1