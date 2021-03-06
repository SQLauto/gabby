USE gabby
GO

CREATE OR ALTER VIEW extracts.gsheets_map_goal_sheets AS

SELECT student_number      
      ,lastfirst      
      ,region
      ,school_name
      ,grade_level
      ,team
      ,advisor_name

      ,mathematics_pctl_baseline
      ,mathematics_rit_50pctl
      ,mathematics_rit_75pctl
      ,mathematics_rit_baseline
      ,mathematics_rit_keepup
      ,reading_pctl_baseline
      ,reading_rit_50pctl
      ,reading_rit_75pctl
      ,reading_rit_baseline
      ,reading_rit_keepup
FROM
    (
     SELECT student_number           
           ,lastfirst
           ,region
           ,school_name
           ,grade_level
           ,team
           ,advisor_name
           ,value
           ,CONCAT(LOWER(measurementscale), '_', field) AS pivot_field
     FROM
         (
          SELECT bb.student_number                
                ,bb.measurementscale
                ,CONVERT(FLOAT,bb.test_ritscore) AS rit_baseline
                ,CONVERT(FLOAT,bb.testpercentile) AS pctl_baseline
      
                ,co.lastfirst      
                ,co.region
                ,co.school_name
                ,co.grade_level
                ,co.team
                ,co.advisor_name

                ,CONVERT(FLOAT,ku.testritscore) AS rit_keepup

                ,CONVERT(FLOAT,gl.testritscore) AS rit_50pctl

                ,CONVERT(FLOAT,tq.testritscore) AS rit_75pctl
          FROM gabby.nwea.best_baseline bb
          JOIN gabby.powerschool.cohort_identifiers_static co
            ON bb.student_number = co.student_number
           AND bb.academic_year = co.academic_year
           AND co.rn_year = 1
           AND co.school_level IN ('ES', 'MS')
          LEFT JOIN gabby.nwea.percentile_norms_dense ku
            ON co.grade_level = ku.grade_level
           AND bb.measurementscale = ku.measurementscale
           AND bb.testpercentile = ku.testpercentile
           AND ku.term = 'Spring'
          LEFT JOIN gabby.nwea.percentile_norms_dense gl
            ON co.grade_level = gl.grade_level
           AND bb.measurementscale = gl.measurementscale
           AND gl.testpercentile = 50
           AND gl.term = 'Spring'
          LEFT JOIN gabby.nwea.percentile_norms_dense tq
            ON co.grade_level = tq.grade_level
           AND bb.measurementscale = tq.measurementscale
           AND tq.testpercentile = 75
           AND tq.term = 'Spring'
          WHERE bb.academic_year = gabby.utilities.GLOBAL_ACADEMIC_YEAR()
            AND bb.measurementscale IN ('Mathematics', 'Reading')
         ) sub
     UNPIVOT(
       value
       FOR field IN (rit_baseline
                    ,pctl_baseline
                    ,rit_keepup
                    ,rit_50pctl
                    ,rit_75pctl)
      ) u
    ) sub
PIVOT(
  MAX(value)
  FOR pivot_field IN (mathematics_pctl_baseline
                     ,mathematics_rit_50pctl
                     ,mathematics_rit_75pctl
                     ,mathematics_rit_baseline
                     ,mathematics_rit_keepup
                     ,reading_pctl_baseline
                     ,reading_rit_50pctl
                     ,reading_rit_75pctl
                     ,reading_rit_baseline
                     ,reading_rit_keepup)
 ) p