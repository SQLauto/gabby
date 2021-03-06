USE gabby
GO

CREATE OR ALTER VIEW lit.illuminate_test_events_current AS

SELECT CONVERT(INT,s.local_student_id) AS local_student_id
      ,sub.date_administered
      ,sub.about_the_text
      ,sub.beyond_the_text
      ,sub.within_the_text
      ,sub.accuracy
      ,sub.fluency
      ,sub.reading_rate_wpm
      ,sub.instructional_level_tested
      ,sub.rate_proficiency
      ,sub.key_lever
      ,sub.fiction_nonfiction
      ,NULL AS test_administered_by
      ,sub.academic_year        
      ,sub.unique_id
      ,sub.test_round
      ,sub.status
      ,sub.achieved_independent_level
FROM
    (
     SELECT student_id 
           ,academic_year        
           ,test_round
           ,CONVERT(DATE,date_administered) AS date_administered
           ,CONVERT(FLOAT,about_the_text) AS about_the_text
           ,CONVERT(FLOAT,beyond_the_text) AS beyond_the_text
           ,CONVERT(FLOAT,within_the_text) AS within_the_text
           ,CONVERT(FLOAT,accuracy) AS accuracy
           ,CONVERT(FLOAT,fluency_score) AS fluency
           ,CONVERT(FLOAT,reading_rate_wpm) AS reading_rate_wpm        
           ,CONVERT(VARCHAR(5),reading_level) AS instructional_level_tested
           ,CONVERT(VARCHAR(25),rate_proficiency) AS rate_proficiency
           ,CONVERT(VARCHAR(25),key_lever) AS key_lever
           ,CONVERT(VARCHAR(5),fiction_nonfiction) AS fiction_nonfiction
           --,CONVERT(VARCHAR(125),test_administered_by) AS test_administered_by             
           ,CONCAT('IL', repository_id, repository_row_id) AS unique_id                     
           ,CASE
             WHEN LTRIM(RTRIM([status])) LIKE '%Did Not Achieve%' THEN 'Did Not Achieve'
             WHEN LTRIM(RTRIM([status])) LIKE '%Achieved%' THEN 'Achieved'
             ELSE CONVERT(VARCHAR(25),LTRIM(RTRIM([status])))
            END AS [status]
           ,CASE WHEN [status] LIKE '%Achieved%' THEN CONVERT(VARCHAR(5),reading_level) END AS achieved_independent_level
     FROM
         ( 
          SELECT 194 AS repository_id                  
                ,2017 AS academic_year
                ,'Q1' AS test_round
                ,repo.repository_row_id
                ,repo.student_id
                ,repo.field_about_the_text AS about_the_text
                ,repo.field_accuracy AS accuracy
                ,repo.field_beyond_the_text AS beyond_the_text
                ,repo.field_comprehension_1 AS comprehension
                ,repo.field_date_administered AS date_administered
                ,repo.field_fictionnonfiction AS fiction_nonfiction
                ,repo.field_fluency_score AS fluency_score
                ,repo.field_key_lever AS key_lever
                ,repo.field_rate_proficiency AS rate_proficiency
                ,repo.field_reading_level AS reading_level
                ,repo.field_words_per_minute AS reading_rate_wpm
                ,repo.field_status AS status
                --,repo.field_test_administered_by AS test_administered_by
                ,repo.field_comprehension AS within_the_text
                ,repo.field_writing_optional AS writing
          FROM [gabby].[illuminate_dna_repositories].[repository_194] repo       

          UNION ALL

          SELECT 195 AS repository_id                  
                ,2017 AS academic_year
                ,'Q2' AS test_round
                ,repo.repository_row_id
                ,repo.student_id
                ,repo.field_about_the_text AS about_the_text
                ,repo.field_accuracy AS accuracy
                ,repo.field_beyond_the_text AS beyond_the_text
                ,repo.field_comprehension_1 AS comprehension
                ,repo.field_date_administered AS date_administered
                ,repo.field_fictionnonfiction AS fiction_nonfiction
                ,repo.field_fluency_score AS fluency_score
                ,repo.field_key_lever AS key_lever
                ,repo.field_rate_proficiency AS rate_proficiency
                ,repo.field_reading_level AS reading_level
                ,repo.field_words_per_minute AS reading_rate_wpm
                ,repo.field_status AS status
                --,repo.field_test_administered_by AS test_administered_by
                ,repo.field_within_the_text AS within_the_text
                ,repo.field_writing_optional AS writing
          FROM [gabby].[illuminate_dna_repositories].[repository_195] repo       

          UNION ALL

          SELECT 196 AS repository_id                  
                ,2017 AS academic_year
                ,'Q3' AS test_round
                ,repo.repository_row_id
                ,repo.student_id
                ,repo.field_about_the_text AS about_the_text
                ,repo.field_accuracy AS accuracy
                ,repo.field_beyond_the_text AS beyond_the_text
                ,repo.field_comprehension_2 AS comprehension
                ,repo.field_date_administered AS date_administered
                ,repo.field_fictionnonfiction AS fiction_nonfiction
                ,repo.field_fluency_score AS fluency_score
                ,repo.field_key_lever AS key_lever
                ,repo.field_rate_proficiency AS rate_proficiency
                ,repo.field_reading_level AS reading_level
                ,repo.field_words_per_minute AS reading_rate_wpm
                ,repo.field_status AS status
                --,repo.field_test_administered_by AS test_administered_by
                ,repo.field_within_the_text AS within_the_text
                ,repo.field_writing_optional AS writing
          FROM [gabby].[illuminate_dna_repositories].[repository_196] repo       

          UNION ALL

          SELECT 193 AS repository_id                  
                ,2017 AS academic_year
                ,'Q4' AS test_round                  
                ,repo.repository_row_id
                ,repo.student_id
                ,repo.field_about_the_text AS about_the_text
                ,repo.field_accuracy AS accuracy
                ,repo.field_beyond_the_text AS beyond_the_text
                ,repo.field_comprehension_1 AS comprehension
                ,repo.field_date_administered_1 AS date_administered
                ,repo.field_fictionnonfiction AS fiction_nonfiction
                ,repo.field_fluency_score AS fluency_score
                ,repo.field_key_lever AS key_lever
                ,repo.field_rate_proficiency AS rate_proficiency
                ,repo.field_reading_level AS reading_level
                ,repo.field_words_per_minute AS reading_rate_wpm
                ,repo.field_status AS status
                --,repo.field_test_administered_by AS test_administered_by
                ,repo.field_within_the_text AS within_the_text
                ,repo.field_writing_optional AS writing
          FROM [gabby].[illuminate_dna_repositories].[repository_193] repo       
         ) sub
     WHERE CONCAT(repository_id, '_', repository_row_id) IN (SELECT CONCAT(repository_id, '_', repository_row_id) FROM gabby.illuminate_dna_repositories.repository_row_ids)
    ) sub
JOIN gabby.illuminate_public.students s
  ON sub.student_id = s.student_id