USE gabby
GO

ALTER VIEW lit.illuminate_test_events AS

WITH clean_data AS (
  SELECT student_number
        ,date_administered
        ,about_the_text
        ,beyond_the_text
        ,within_the_text
        ,accuracy
        ,fluency
        ,reading_rate_wpm
        ,CASE WHEN instructional_level_tested != '' THEN instructional_level_tested END AS instructional_level_tested
        ,CASE WHEN rate_proficiency != '' THEN rate_proficiency END AS rate_proficiency
        ,CASE WHEN key_lever != '' THEN key_lever END AS key_lever
        ,CASE WHEN fiction_nonfiction != '' THEN fiction_nonfiction END AS fiction_nonfiction
        ,CASE WHEN test_administered_by != '' THEN test_administered_by END AS test_administered_by
        ,academic_year
        ,unique_id
        ,CASE WHEN test_round != '' THEN test_round END AS test_round
        ,CASE WHEN status != '' THEN status END AS status
        ,CASE WHEN achieved_independent_level != '' THEN achieved_independent_level END AS achieved_independent_level
  FROM gabby.lit.illuminate_test_events_archive
  
  UNION ALL

  SELECT local_student_id AS student_number        
        ,CONVERT(DATE,date_administered) AS date_administered
        ,CONVERT(FLOAT,about_the_text) AS about_the_text
        ,CONVERT(FLOAT,beyond_the_text) AS beyond_the_text
        ,CONVERT(FLOAT,within_the_text) AS within_the_text
        ,CONVERT(FLOAT,accuracy) AS accuracy
        ,CONVERT(FLOAT,fluency_score) AS fluency
        ,CONVERT(FLOAT,reading_rate_wpm) AS reading_rate_wpm
        
        ,reading_level AS instructional_level_tested
        ,CONVERT(NVARCHAR,rate_proficiency) AS rate_proficiency
        ,key_lever
        ,fiction_nonfiction
        ,test_administered_by
        ,academic_year        
        ,CONCAT('IL', repository_id, repository_row_id) AS unique_id        
        ,test_round
        ,CASE
          WHEN LTRIM(RTRIM([status])) LIKE '%Did Not Achieve%' THEN 'Did Not Achieve'
          WHEN LTRIM(RTRIM([status])) LIKE '%Achieved%' THEN 'Achieved'
          ELSE LTRIM(RTRIM([status]))
         END AS [status]
        ,CASE WHEN [status] LIKE '%Achieved%' THEN reading_level END AS achieved_independent_level
  FROM
      ( 
       SELECT 194 AS repository_id
             ,repo.[repository_row_id]
             ,s.local_student_id
             ,2017 AS academic_year
             ,'Q1' AS test_round
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
             ,repo.field_test_administered_by AS test_administered_by
             ,repo.field_comprehension AS within_the_text
             ,repo.field_writing_optional AS writing
       FROM [gabby].[illuminate_dna_repositories].[repository_194] repo
       JOIN gabby.illuminate_public.students s
         ON repo.student_id = s.student_id

       UNION ALL

       SELECT 195 AS repository_id
             ,repo.[repository_row_id]
             ,s.local_student_id
             ,2017 AS academic_year
             ,'Q2' AS test_round
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
             ,repo.field_test_administered_by AS test_administered_by
             ,repo.field_within_the_text AS within_the_text
             ,repo.field_writing_optional AS writing
       FROM [gabby].[illuminate_dna_repositories].[repository_195] repo
       JOIN gabby.illuminate_public.students s
         ON repo.student_id = s.student_id

       UNION ALL

       SELECT 196 AS repository_id
             ,repo.[repository_row_id]
             ,s.local_student_id
             ,2017 AS academic_year
             ,'Q3' AS test_round
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
             ,repo.field_test_administered_by AS test_administered_by
             ,repo.field_within_the_text AS within_the_text
             ,repo.field_writing_optional AS writing
       FROM [gabby].[illuminate_dna_repositories].[repository_196] repo
       JOIN gabby.illuminate_public.students s
         ON repo.student_id = s.student_id

       UNION ALL

       SELECT 193 AS repository_id
             ,repo.[repository_row_id]
             ,s.local_student_id
             ,2017 AS academic_year
             ,'Q4' AS test_round
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
             ,repo.field_test_administered_by AS test_administered_by
             ,repo.field_within_the_text AS within_the_text
             ,repo.field_writing_optional AS writing
       FROM [gabby].[illuminate_dna_repositories].[repository_193] repo
       JOIN gabby.illuminate_public.students s
         ON repo.student_id = s.student_id
      ) sub
  WHERE CONCAT(repository_id, '_', repository_row_id) IN (SELECT CONCAT(repository_id, '_', repository_row_id) FROM gabby.illuminate_dna_repositories.repository_row_ids)
 )

SELECT cd.unique_id
      ,cd.student_number
      ,cd.academic_year
      ,cd.test_round
      ,cd.date_administered
      ,cd.status
      ,cd.instructional_level_tested
      ,cd.achieved_independent_level
      ,cd.about_the_text
      ,cd.beyond_the_text
      ,cd.within_the_text      
      ,cd.accuracy
      ,cd.fluency
      ,cd.reading_rate_wpm
      ,cd.rate_proficiency
      ,cd.key_lever
      ,cd.fiction_nonfiction
      ,cd.test_administered_by      
      ,CASE
        WHEN test_round = 'BOY' THEN 1
        WHEN test_round = 'MOY' THEN 2
        WHEN test_round = 'EOY' THEN 3
        WHEN test_round = 'DR' THEN 1
        WHEN test_round = 'Q1' THEN 2
        WHEN test_round = 'Q2' THEN 3
        WHEN test_round = 'Q3' THEN 4
        WHEN test_round = 'Q4' THEN 5
       END AS round_num
      ,CASE 
        WHEN cd.about_the_text IS NULL AND cd.beyond_the_text IS NULL AND cd.within_the_text IS NULL THEN NULL
        ELSE ISNULL(cd.within_the_text,0) + ISNULL(cd.about_the_text,0) + ISNULL(cd.beyond_the_text,0) 
       END AS comp_overall
      
      ,achv.GLEQ
      ,achv.fp_lvl_num AS indep_lvl_num
      ,instr.fp_lvl_num AS instr_lvl_num
FROM clean_data cd
LEFT OUTER JOIN gabby.lit.gleq achv
  ON cd.achieved_independent_level = achv.read_lvl
LEFT OUTER JOIN gabby.lit.gleq instr
  ON cd.instructional_level_tested = instr.read_lvl