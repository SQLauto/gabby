USE gabby
GO

--ALTER VIEW tableau.promo_tracker AS 

WITH roster AS (
  SELECT co.studentid
        ,co.student_number
        ,co.lastfirst      
        ,co.academic_year
        ,co.schoolid
        ,co.reporting_schoolid
        ,co.grade_level
        ,co.cohort
        ,co.team
        ,co.advisor_name   
        ,co.iep_status
        ,co.enroll_status

        ,CONVERT(NVARCHAR,dt.alt_name) AS term
        ,CONVERT(NVARCHAR,dt.time_per_name) AS reporting_term
        ,CONVERT(DATE,dt.start_date) AS term_start_date
        ,CONVERT(DATE,dt.end_date) AS term_end_date
  FROM gabby.powerschool.cohort_identifiers_static co
  JOIN gabby.reporting.reporting_terms dt
    ON co.academic_year = dt.academic_year
   AND co.schoolid = dt.schoolid
   AND dt.identifier = 'RT'
   AND dt.alt_name != 'Summer School'
  WHERE co.academic_year >= (gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1)
    AND co.schoolid != 999999
    AND co.rn_year = 1    
  
  UNION ALL

  SELECT co.studentid
        ,co.student_number
        ,co.lastfirst      
        ,co.academic_year
        ,co.schoolid
        ,co.reporting_schoolid
        ,co.grade_level
        ,co.cohort
        ,co.team
        ,co.advisor_name           
        ,co.iep_status
        ,co.enroll_status

        ,'Y1' AS term
        ,CONVERT(NVARCHAR,dt.time_per_name) AS reporting_term
        ,CONVERT(DATE,dt.start_date) AS term_start_date
        ,CONVERT(DATE,dt.end_date) AS term_end_date
  FROM gabby.powerschool.cohort_identifiers_static co
  JOIN gabby.reporting.reporting_terms dt
    ON co.academic_year = dt.academic_year   
   AND dt.identifier = 'SY'   
  WHERE co.academic_year >= (gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1)
    AND co.schoolid != 999999
    AND co.rn_year = 1
 )

,contact AS (
  SELECT student_number
        ,'CONTACT' AS domain      
        ,LEFT(field, CHARINDEX('_',field) - 1) AS person
        ,RIGHT(field, LEN(field) - CHARINDEX('_',field)) AS type
        ,value      
  FROM
      (
       SELECT con.student_number      
             ,CONVERT(NVARCHAR,con.home_phone) AS home_phone
             ,CONVERT(NVARCHAR,con.guardianemail) AS home_email
             ,CONVERT(NVARCHAR,con.mother) AS parent1_name            
             ,CONVERT(NVARCHAR,con.father) AS parent2_name            
             ,CONVERT(NVARCHAR,con.doctor_name) AS doctor_name      
             ,CONVERT(NVARCHAR,con.doctor_phone) AS doctor_phone
             ,CONVERT(NVARCHAR,con.emerg_contact_1) AS emerg1_name      
             ,CONVERT(NVARCHAR,con.emerg_phone_1) AS emerg1_phone
             ,CONVERT(NVARCHAR,con.emerg_contact_2) AS emerg2_name      
             ,CONVERT(NVARCHAR,con.emerg_phone_2) AS emerg2_phone            
             ,CONVERT(NVARCHAR,'Home') AS home_name           

             ,CONVERT(NVARCHAR,scf.mother_home_phone) AS parent1_home      
             ,CONVERT(NVARCHAR,scf.motherdayphone) AS parent1_day
             ,CONVERT(NVARCHAR,scf.father_home_phone) AS parent2_home      
             ,CONVERT(NVARCHAR,scf.fatherdayphone) AS parent2_day
             ,CONVERT(NVARCHAR,scf.emerg_1_rel) AS emerg1_relation
             ,CONVERT(NVARCHAR,scf.emerg_2_rel) AS emerg2_relation
             ,CONVERT(NVARCHAR,scf.emerg_contact_3) AS emerg3_name
             ,CONVERT(NVARCHAR,scf.emerg_3_rel) AS emerg3_relation
             ,CONVERT(NVARCHAR,scf.emerg_3_phone) AS emerg3_phone
      
             ,CONVERT(NVARCHAR,suf.emerg_4_name) AS emerg4_name
             ,CONVERT(NVARCHAR,suf.emerg_4_rel) AS emerg4_relation
             ,CONVERT(NVARCHAR,suf.emerg_4_phone) AS emerg4_phone
             ,CONVERT(NVARCHAR,suf.emerg_5_name) AS emerg5_name
             ,CONVERT(NVARCHAR,suf.emerg_5_rel) AS emerg5_relation
             ,CONVERT(NVARCHAR,suf.emerg_5_phone) AS emerg5_phone
             ,CONVERT(NVARCHAR,suf.mother_cell) AS parent1_cell
             ,CONVERT(NVARCHAR,suf.father_cell) AS parent2_cell
             ,CONVERT(NVARCHAR,suf.release_1_name) AS release1_name
             ,CONVERT(NVARCHAR,suf.release_1_relation) AS release1_relation
             ,CONVERT(NVARCHAR,suf.release_1_phone) AS release1_phone           
             ,CONVERT(NVARCHAR,suf.release_2_name) AS release2_name
             ,CONVERT(NVARCHAR,suf.release_2_relation) AS release2_relation
             ,CONVERT(NVARCHAR,suf.release_2_phone) AS release2_phone           
             ,CONVERT(NVARCHAR,suf.release_3_name) AS release3_name
             ,CONVERT(NVARCHAR,suf.release_3_relation) AS release3_relation
             ,CONVERT(NVARCHAR,suf.release_3_phone) AS release3_phone           
             ,CONVERT(NVARCHAR,suf.release_4_name) AS release4_name
             ,CONVERT(NVARCHAR,suf.release_4_relation) AS release4_relation
             ,CONVERT(NVARCHAR,suf.release_4_phone) AS release4_phone           
             ,CONVERT(NVARCHAR,suf.release_5_name) AS release5_name
             ,CONVERT(NVARCHAR,suf.release_5_relation) AS release5_relation
             ,CONVERT(NVARCHAR,suf.release_5_phone) AS release5_phone                      

             ,CASE WHEN CONCAT(scf.mother_home_phone, suf.mother_cell, scf.motherdayphone)!= '' THEN CONVERT(NVARCHAR,'Mother') END AS parent1_relation
             ,CASE WHEN CONCAT(scf.father_home_phone, suf.father_cell, scf.fatherdayphone) != '' THEN CONVERT(NVARCHAR,'Father') END AS parent2_relation
             ,CASE WHEN CONCAT(con.doctor_name, con.doctor_phone) != '' THEN CONVERT(NVARCHAR,'Doctor') END AS doctor_relation
       FROM gabby.powerschool.students con      
       JOIN gabby.powerschool.studentcorefields scf
         ON con.dcid = scf.studentsdcid
       JOIN gabby.powerschool.u_studentsuserfields suf
         ON con.dcid = suf.studentsdcid    
      ) sub
  UNPIVOT(
    value
    FOR field IN (home_name
                 ,home_phone
                 ,home_email
                 ,parent1_name
                 ,parent1_relation
                 ,parent1_home
                 ,parent1_cell
                 ,parent1_day
                 ,parent2_name
                 ,parent2_relation
                 ,parent2_home
                 ,parent2_cell
                 ,parent2_day
                 ,doctor_name
                 ,doctor_phone
                 ,emerg1_name
                 ,emerg1_relation
                 ,emerg1_phone
                 ,emerg2_name
                 ,emerg2_relation
                 ,emerg2_phone
                 ,emerg3_name
                 ,emerg3_relation
                 ,emerg3_phone
                 ,emerg4_name
                 ,emerg4_relation
                 ,emerg4_phone
                 ,emerg5_name
                 ,emerg5_relation
                 ,emerg5_phone
                 ,release1_name
                 ,release1_relation
                 ,release1_phone
                 ,release2_name
                 ,release2_relation
                 ,release2_phone
                 ,release3_name
                 ,release3_relation
                 ,release3_phone
                 ,release4_name
                 ,release4_relation
                 ,release4_phone
                 ,release5_name
                 ,release5_relation
                 ,release5_phone)
   ) u
 )

,grades AS (
  /* term grades */
  SELECT gr.student_number
        ,gr.academic_year            
        ,gr.reporting_term        
        ,gr.credittype
        ,gr.course_name
        ,gr.term_grade_percent_adjusted
        ,'GRADES' AS domain
        ,'TERM' AS subdomain
        ,'Term' AS finalgradename
  FROM gabby.powerschool.final_grades_static gr
  WHERE gr.academic_year >= (gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1)
    AND gr.excludefromgpa = 0

  UNION ALL

  SELECT gr.student_number        
        ,gr.academic_year      
        ,'Y1' AS reporting_term        
        ,gr.credittype
        ,gr.course_name
        ,gr.y1_grade_percent_adjusted AS term_grade_percent_adjusted
        ,'GRADES' AS domain
        ,'TERM' AS subdomain
        ,'Y1' AS finalgradename
  FROM gabby.powerschool.final_grades_static gr
  WHERE gr.academic_year >= (gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1)
    AND gr.is_curterm = 1
    AND gr.excludefromgpa = 0

  UNION ALL
  
  /* category grades */
  SELECT gr.student_number        
        ,gr.academic_year            
        ,'Y1' AS reporting_term        
        ,gr.credittype
        ,gr.course_name
        ,ROUND(AVG(gr.grade_category_pct), 0) AS term_grade_percent_adjusted
        ,'GRADES' AS domain
        ,'CATEGORY' AS subdomain
        ,gr.grade_category AS finalgradename
  FROM gabby.powerschool.category_grades_static gr
  WHERE gr.academic_year >= (gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1)    
  GROUP BY gr.student_number
          ,gr.academic_year
          ,gr.grade_category
          ,gr.credittype
          ,gr.course_name
 )

,attendance AS (
  SELECT studentid
        ,academic_year
        ,reporting_term
        ,UPPER(LEFT(field, CHARINDEX('_', field) - 1)) AS att_code
        ,value AS att_counts
        ,'ATTENDANCE' AS domain
        ,CASE
          WHEN field = 'presentpct_term' THEN 'ABSENT'
          WHEN field = 'ontimepct_term' THEN 'TARDY'
          WHEN field IN ('attpts_term', 'attptspct_term') THEN 'PROMO'
          WHEN field LIKE 'A%' THEN 'ABSENT'
          WHEN field LIKE 'T%' THEN 'TARDY'
          WHEN field LIKE '%SS%' THEN 'SUSPENSION'
         END AS subdomain        
  FROM 
      (
       SELECT att.studentid
             ,att.academic_year
             ,att.reporting_term           
             ,att.a_count_term
             ,att.ad_count_term
             ,att.ae_count_term
             ,att.iss_count_term
             ,att.oss_count_term
             ,att.t_count_term
             ,att.t10_count_term
             ,att.abs_unexcused_count_term
             ,att.tdy_all_count_term
             ,att.abs_unexcused_count_term + ROUND((att.TDY_all_count_term / 3), 1, 1) AS attpts_term
             ,ROUND(
                ((att.mem_count_term - att.abs_unexcused_count_term) 
                 / CASE WHEN att.mem_count_term = 0 THEN NULL ELSE att.mem_count_term END) 
                 * 100, 0) AS presentpct_term
             ,ROUND(
                ((att.mem_count_term - att.abs_unexcused_count_term - att.TDY_all_count_term) 
                 / CASE WHEN (att.mem_count_term - att.abs_unexcused_count_term) = 0 THEN NULL ELSE (att.mem_count_term - att.abs_unexcused_count_term) END)
                 * 100, 0) AS ontimepct_term             
             ,ROUND(
                ((att.mem_count_term - (att.abs_unexcused_count_term + ROUND((att.TDY_all_count_term / 3), 1, 1))) 
                 / CASE WHEN att.mem_count_term = 0 THEN NULL ELSE att.mem_count_term END) 
                 * 100, 0) AS attptspct_term
       FROM gabby.powerschool.attendance_counts_static att
       WHERE att.academic_year >= (gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1)
         AND att.mem_count_term > 0
         AND att.mem_count_term != att.abs_unexcused_count_term

       UNION ALL

       SELECT att.studentid
             ,att.academic_year
             ,'SY1' AS reporting_term
             ,att.a_count_y1
             ,att.ad_count_y1
             ,att.ae_count_y1
             ,att.iss_count_y1
             ,att.oss_count_y1
             ,att.t_count_y1
             ,att.t10_count_y1      
             ,att.abs_unexcused_count_y1
             ,att.tdy_all_count_y1
             ,att.abs_unexcused_count_y1 + ROUND((att.TDY_all_count_y1 / 3), 1, 1) AS attpts_y1             
             ,ROUND(
                ((att.MEM_count_y1 - (att.abs_unexcused_count_y1 + ROUND((att.TDY_all_count_y1 / 3), 1, 1))) 
                 / CASE WHEN att.MEM_count_y1 = 0 THEN NULL ELSE att.MEM_count_y1 END) 
                 * 100, 0) AS attptspct_y1
             ,ROUND(
                ((att.MEM_count_y1 - att.abs_unexcused_count_y1) 
                 / CASE WHEN att.MEM_count_y1 = 0 THEN NULL ELSE att.MEM_count_y1 END) 
                 * 100, 0) AS presentpct_y1
             ,ROUND(
                ((att.MEM_count_y1 - att.abs_unexcused_count_y1 - att.TDY_all_count_y1) 
                 / CASE WHEN (att.MEM_count_y1 - att.abs_unexcused_count_y1) = 0 THEN NULL ELSE (att.mem_count_y1 - att.abs_unexcused_count_y1) END) 
                 * 100, 0) AS ontimepct_y1             
       FROM gabby.powerschool.attendance_counts_static att 
       WHERE att.academic_year >= (gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1)
         AND att.mem_count_y1 > 0
         AND att.mem_count_y1 != att.abs_unexcused_count_y1
         AND att.is_curterm = 1
      ) sub
  UNPIVOT(
    value
    FOR field IN (a_count_term       
                 ,ad_count_term
                 ,ae_count_term
                 ,abs_unexcused_count_term
                 ,t_count_term
                 ,t10_count_term    
                 ,tdy_all_count_term
                 ,iss_count_term
                 ,oss_count_term
                 ,presentpct_term
                 ,ontimepct_term
                 ,attpts_term
                 ,attptspct_term)
   ) u
 )

,modules AS (
  SELECT a.subject_area
        ,a.title
        ,a.academic_year
        ,a.local_student_id AS student_number
        ,a.assessment_id
        ,a.scope        
        ,a.date_taken AS measure_date
        ,CASE 
          WHEN a.subject_area = 'Writing' THEN a.standard_description
          ELSE a.standard_code 
         END AS standards
        ,CASE
          WHEN a.subject_area = 'Writing' THEN a.points
          ELSE a.percent_correct        
         END AS percent_correct
        ,CASE
          WHEN a.performance_band_number = 5 THEN 'Above'
          WHEN a.performance_band_number = 4 THEN 'Target'
          WHEN a.performance_band_number = 3 THEN 'Near'
          WHEN a.performance_band_number = 2 THEN 'Below'
          WHEN a.performance_band_number = 1 THEN 'Far Below'
         END AS proficiency_label
        ,'MODULES' AS domain
        ,CASE
          WHEN a.subject_area = 'Writing' THEN 'WRITING RUBRIC'
          WHEN a.response_type = 'O' THEN 'OVERALL' 
          WHEN a.response_type = 'S' THEN 'STANDARDS' 
         END AS subdomain        
  FROM gabby.illuminate_dna_assessments.agg_student_responses_all a  
  WHERE a.subject_area IN ('Text Study','Mathematics','Writing')
    AND a.scope IN ('CMA - End-of-Module','CMA - Mid-Module','CMA - Checkpoint 1','CMA - Checkpoint 2','Process Piece')
    AND a.academic_year >= (gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1)
    AND a.response_type IN ('O','S')
 )

,gpa AS (
  SELECT student_number        
        ,academic_year      
        ,reporting_term
        ,schoolid
        ,gpa_y1 AS gpa
        ,'GPA' AS domain
        ,'GPA Y1 - TERM' AS subdomain
  FROM gabby.powerschool.gpa_detail
  WHERE academic_year >= (gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1)

  UNION ALL

  SELECT student_number        
        ,academic_year      
        ,'Y1' AS reporting_term
        ,schoolid
        ,gpa_y1 AS GPA
        ,'GPA' AS domain
        ,'GPA Y1' AS subdomain
  FROM gabby.powerschool.gpa_detail
  WHERE academic_year >= (gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1)
    AND is_curterm = 1

  UNION ALL

  SELECT s.student_number
        ,gabby.utilities.GLOBAL_ACADEMIC_YEAR()  AS academic_year
        ,'Y1' AS reporting_Term
        ,gpa.schoolid           
        ,gpa.cumulative_Y1_gpa AS gpa
        ,'GPA' AS domain
        ,'GPA CUMULATIVE' AS subdomain
  FROM gabby.powerschool.gpa_cumulative gpa
  JOIN gabby.powerschool.students s
    ON gpa.studentid = s.id

  UNION ALL

  SELECT s.student_number        
        ,gabby.utilities.GLOBAL_ACADEMIC_YEAR()  AS academic_year
        ,'Y1' AS reporting_Term
        ,gpa.schoolid           
        ,gpa.earned_credits_cum AS gpa
        ,'GPA' AS domain
        ,'CREDITS EARNED' AS subdomain
  FROM gabby.powerschool.gpa_cumulative gpa
  JOIN gabby.powerschool.students s
    ON gpa.studentid = s.id
  WHERE gpa.schoolid = 73253
 )

,lit AS (
  /* STEP/F&P */
  SELECT student_number        
        ,academic_year        
        ,test_round      
        ,read_lvl
        ,lvl_num       
        ,'LIT' AS domain
        ,'ACHIEVED' AS subdomain 
  FROM gabby.lit.achieved_by_round_static
  WHERE read_lvl IS NOT NULL
    AND goal_lvl IS NOT NULL
    AND start_date <= CONVERT(DATE,GETDATE())
  UNION ALL
  SELECT student_number        
        ,academic_year        
        ,test_round      
        ,goal_lvl
        ,goal_num
        ,'LIT' AS domain
        ,'GOAL' AS subdomain
  FROM gabby.lit.achieved_by_round_static
  WHERE read_lvl IS NOT NULL
    AND goal_lvl IS NOT NULL
    AND start_date <= CONVERT(DATE,GETDATE())
  
  UNION ALL

  /* Lexile */
  SELECT student_id        
        ,academic_year        
        ,term AS test_round        
        ,CONCAT(ritto_reading_score,'L') AS read_lvl
        ,CASE
          WHEN ritto_reading_score = 0 THEN -1
          WHEN ritto_reading_score BETWEEN 0 AND 100 THEN 1
          WHEN ritto_reading_score BETWEEN 100 AND 200 THEN 5
          WHEN ritto_reading_score BETWEEN 200 AND 300 THEN 10
          WHEN ritto_reading_score BETWEEN 300 AND 400 THEN 14
          WHEN ritto_reading_score BETWEEN 400 AND 500 THEN 17
          WHEN ritto_reading_score BETWEEN 500 AND 600 THEN 20
          WHEN ritto_reading_score BETWEEN 600 AND 700 THEN 22
          WHEN ritto_reading_score BETWEEN 700 AND 800 THEN 25
          WHEN ritto_reading_score BETWEEN 800 AND 900 THEN 27
          WHEN ritto_reading_score BETWEEN 900 AND 1000 THEN 28
          WHEN ritto_reading_score BETWEEN 1000 AND 1100 THEN 29
          WHEN ritto_reading_score BETWEEN 1100 AND 1200 THEN 30
          WHEN ritto_reading_score >= 1200 THEN 31
         END AS lvl_num        
        ,'LIT' AS domain
        ,'ACHIEVED' AS subdomain
  FROM gabby.nwea.assessment_result_identifiers_static
  WHERE measurement_scale = 'Reading'
    AND school_name = 'Newark Collegiate Academy'
    AND rn_term_subj = 1
  UNION ALL
  SELECT map.student_id        
        ,map.academic_year        
        ,map.term AS test_round        
        ,CASE
          WHEN s.grade_level = 9 THEN '900L'
          WHEN s.grade_level = 10 THEN '1000L'
          WHEN s.grade_level = 11 THEN '1100L'
          WHEN s.grade_level = 12 THEN '1200L'
         END AS goal_lvl
        ,CASE
          WHEN s.grade_level = 9 THEN 28
          WHEN s.grade_level = 10 THEN 29
          WHEN s.grade_level = 11 THEN 30
          WHEN s.grade_level = 12 THEN 31
         END AS goal_num
        ,'LIT' AS domain
        ,'GOAL' AS subdomain
  FROM gabby.nwea.assessment_result_identifiers_static map
  JOIN gabby.powerschool.students s
    ON map.student_id = s.student_number
   AND s.schoolid = 73253
  WHERE map.measurement_scale = 'Reading'    
    AND map.rn_term_subj = 1
 )

,map AS (
  SELECT student_id AS student_number        
        ,academic_year
        ,test_year
        ,term
        ,measurement_scale
        ,test_ritscore
        ,percentile_2015_norms AS testpercentile
        ,'MAP' AS domain
        ,NULL AS subdomain                        
  FROM gabby.nwea.assessment_result_identifiers_static
  WHERE rn_term_subj = 1
 )

,standardized_tests AS (
  /* PARCC */
  SELECT local_student_identifier AS student_number        
        ,LEFT(assessment_year, 4) AS academic_year
        ,NULL AS test_date
        ,'PARCC' AS test_name
        ,subject                 
        ,test_scale_score
        ,test_performance_level
        ,CASE
          WHEN test_performance_level = 5 THEN 'Exceeded'
          WHEN test_performance_level = 4 THEN 'Met'
          WHEN test_performance_level = 3 THEN 'Approached'
          WHEN test_performance_level = 2 THEN 'Partially Met'
          WHEN test_performance_level = 1 THEN 'Did Not Meet'
         END AS performance_level_label       
  FROM gabby.parcc.summative_record_file_clean

  UNION ALL

  /* NJASK & HSPA */
  SELECT local_student_id AS student_number        
        ,academic_year
        ,NULL AS test_date
        ,test_type
        ,subject      
        ,scaled_score      
        ,CASE
          WHEN performance_level = 'Advanced Proficient' THEN 5
          WHEN performance_level = 'Proficient' THEN 4
          WHEN performance_level = 'Partially Proficient' THEN 1
         END AS performance_level
        ,performance_level AS performance_level_label
  FROM gabby.njsmart.all_state_assessments

  UNION ALL

  /* ACT */
  SELECT student_number        
        ,academic_year
        ,test_date
        ,test_name
        ,subject
        ,scale_score
        ,NULL AS performance_level
        ,NULL AS performance_level_label
  FROM
      (
       SELECT student_number             
             ,academic_year
             ,test_date
             ,test_type AS test_name
             ,CONVERT(INT,composite) AS composite
             ,CONVERT(INT,english) AS english
             ,CONVERT(INT,math) AS math
             ,CONVERT(INT,reading) AS reading
             ,CONVERT(INT,science) AS science             
       FROM gabby.naviance.act_scores_clean
      ) sub
  UNPIVOT(
    scale_score
    FOR subject IN (composite
                   ,english
                   ,math
                   ,reading
                   ,science)
   ) u

  UNION ALL

  /* ACT Prep */
  SELECT student_number        
        ,academic_year
        ,administered_at AS test_date
        ,'ACT Prep' AS test_name
        ,CASE WHEN subject_area = 'Mathematics' THEN 'Math' ELSE subject_area END AS subject
        ,scale_score
        ,overall_performance_band AS performance_level
        ,NULL AS performance_level_label
  FROM gabby.act.test_prep_scores 
  WHERE rn_dupe = 1

  UNION ALL
  
  /* SAT */
  SELECT student_number
        ,academic_year
        ,test_date      
        ,'SAT' AS test_name
        ,subject
        ,scale_score
        ,NULL AS performance_level
        ,NULL AS performance_level_label
  FROM gabby.naviance.sat_scores_clean
  UNPIVOT(
    scale_score
    FOR subject IN (all_tests_total
                   ,math
                   ,verbal
                   ,writing)
   ) u

  UNION ALL

  /* SAT II */
  SELECT hs_student_id AS student_number
        ,gabby.utilities.DATE_TO_SY(CONVERT(DATE,CASE 
                                                  WHEN test_date = '0000-00-00' THEN NULL 
                                                  ELSE REPLACE(test_date,'-00','-01') 
                                                 END)) AS academic_year
        ,CONVERT(DATE,CASE 
                       WHEN test_date = '0000-00-00' THEN NULL 
                       ELSE REPLACE(test_date,'-00','-01') 
                      END) AS test_date
        ,'SAT II' AS test_name      
        ,test_name AS subject
        ,score AS scale_score
        ,NULL AS performance_level
        ,NULL AS performance_level_label
  FROM gabby.naviance.sat_2_scores

  UNION ALL  

  /* AP */
  SELECT hs_student_id AS student_number        
        ,gabby.utilities.DATE_TO_SY(CONVERT(DATE,CASE 
                                                  WHEN test_date = '0000-00-00' THEN NULL 
                                                  ELSE REPLACE(test_date,'-00','-01') 
                                                 END)) AS academic_year
        ,CONVERT(DATE,CASE 
                       WHEN test_date = '0000-00-00' THEN NULL 
                       ELSE REPLACE(test_date,'-00','-01') 
                      END) AS test_date     
        ,'AP' AS test_name      
        ,test_name AS subject
        ,score AS scale_score
        ,NULL AS performance_level
        ,NULL AS performance_level_label
  FROM gabby.naviance.ap_scores 

  UNION ALL

  /* EXPLORE */
  SELECT hs_student_id
        ,gabby.utilities.DATE_TO_SY(CONVERT(DATE,CASE 
                                                  WHEN test_date = '0000-00-00' THEN NULL 
                                                  ELSE REPLACE(test_date,'-00','-01') 
                                                 END)) AS academic_year
        ,CONVERT(DATE,CASE 
                       WHEN test_date = '0000-00-00' THEN NULL 
                       ELSE REPLACE(test_date,'-00','-01') 
                      END) AS test_date     
        ,'EXPLORE' AS test_name
        ,subject
        ,scale_score
        ,NULL AS performance_level
        ,NULL AS performance_level_label
  FROM gabby.naviance.explore_scores
  UNPIVOT(
    scale_score
    FOR subject IN (english	
                   ,math
                   ,reading
                   ,science
                   ,composite)
   ) u

  UNION ALL

  SELECT hs_student_id AS student_number
        ,gabby.utilities.DATE_TO_SY(CONVERT(DATE,CASE 
                                                  WHEN test_date = '0000-00-00' THEN NULL 
                                                  ELSE REPLACE(test_date,'-00','-01') 
                                                 END)) AS academic_year
        ,CONVERT(DATE,CASE 
                       WHEN test_date = '0000-00-00' THEN NULL 
                       ELSE REPLACE(test_date,'-00','-01') 
                      END) AS test_date 
        ,'PSAT' AS test_name
        ,subject
        ,scale_score
        ,NULL AS performance_level
        ,NULL AS performance_level_label
  FROM gabby.naviance.psat_scores
  UNPIVOT(
    scale_score
    FOR subject IN (critical_reading
                   ,math
                   ,writing
                   ,total)
   ) u
 )

,collegeapps AS (
  SELECT app.hs_student_id AS student_number
        ,app.collegename              
        ,app.level       
        ,CASE WHEN app.result_code IN ('unknown') OR app.result_code IS NULL THEN app.stage ELSE app.result_code END AS result_code
        ,CONCAT('Type:', CHAR(9), REPLACE(app.inst_control,'p','P'), CHAR(10)
               ,'Attending:', CHAR(9), app.attending, CHAR(10)               
               ,app.comments) AS value
        
        ,ROW_NUMBER() OVER(                                
           PARTITION BY app.hs_student_id
             ORDER BY CASE
                       WHEN a.competitiveness_ranking_c = 'Most Competitive+' THEN 7
                       WHEN a.competitiveness_ranking_c = 'Most Competitive' THEN 6
                       WHEN a.competitiveness_ranking_c = 'Highly Competitive' THEN 5
                       WHEN a.competitiveness_ranking_c = 'Very Competitive' THEN 4
                       WHEN a.competitiveness_ranking_c = 'Noncompetitive' THEN 1
                       WHEN a.competitiveness_ranking_c = 'Competitive' THEN 3
                       WHEN a.competitiveness_ranking_c = 'Less Competitive' THEN 2
                      END DESC) AS competitiveness_ranking 
  FROM gabby.naviance.college_applications app
  LEFT OUTER JOIN gabby.alumni.account a 
    ON app.ceeb_code = CONVERT(NVARCHAR,a.ceeb_code_c)
   AND a.record_type_id = '01280000000BQEkAAO'
   AND a.competitiveness_ranking_c IS NOT NULL
 )

,promo_status AS (
  SELECT student_number
        ,academic_year
        ,'PROMO STATUS' AS domain
        ,field AS subdomain
        ,CASE WHEN field LIKE '%status%' THEN value ELSE NULL END AS text_value
        ,CASE WHEN field LIKE '%status%' THEN NULL ELSE CONVERT(FLOAT,value) END AS numeric_value
  FROM
      (
       SELECT student_number
             ,academic_year
             ,schoolid             

             /* overall */
             ,CONVERT(NVARCHAR,promo_status_overall) AS promo_status_overall             
             
             /* attendance */
             ,CONVERT(NVARCHAR,promo_status_attendance) AS promo_status_att
             ,CONVERT(NVARCHAR,att_pts) AS att_pts
             ,CONVERT(NVARCHAR,att_pts_pct) AS att_pts_pct
             ,CONVERT(NVARCHAR,days_to_90_pts) AS days_to_90
             ,CONVERT(NVARCHAR,days_to_90_abs_only) AS days_to_90_abs_only
             
             /* lit */
             ,CONVERT(NVARCHAR,promo_status_lit) AS lit_ARFR_status                   
             ,CONVERT(NVARCHAR,cur_read_lvl) AS read_lvl_status
             ,CONVERT(NVARCHAR,goal_lvl) AS goal_lvl_status      
             
             /* grades */
             ,CONVERT(NVARCHAR,promo_status_grades) AS promo_status_grades /* # failing */                          
             ,CONVERT(NVARCHAR,N_below_60) AS n_failing       
             ,CONVERT(NVARCHAR,gpa_y1) AS gpa_y1_promo                   

             /* credits */
             ,CONVERT(NVARCHAR,promo_status_credits) AS promo_status_credits
             ,CONVERT(NVARCHAR,credits_enrolled_y1) AS credits_enrolled
             ,CONVERT(NVARCHAR,projected_credits_earned_cum) AS projected_credits_earned
             ,CONVERT(NVARCHAR,earned_credits_cum) AS earned_credits_cum
             ,CONVERT(NVARCHAR,credits_needed) AS credits_needed
       FROM gabby.reporting.promotional_status
       WHERE academic_year >= (gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1)
         AND is_curterm = 1       
      ) sub
  UNPIVOT(
    value
    FOR field IN (days_to_90
                 ,days_to_90_abs_only
                 ,att_pts
                 ,att_pts_pct                 
                 ,n_failing
                 ,promo_status_overall
                 ,promo_status_grades
                 ,promo_status_att
                 ,read_lvl_status
                 ,goal_lvl_status          
                 ,lit_ARFR_status
                 ,promo_status_credits
                 ,credits_needed
                 ,credits_enrolled
                 ,projected_credits_earned
                 ,earned_credits_cum
                 ,gpa_y1_promo)
   ) u
 )

,blended AS (
  SELECT student_number
        ,academic_year        
        ,words AS progress
        ,words_goal AS goal
        ,stu_status_words AS goal_status
        ,CASE WHEN reporting_term = 'ARY' THEN 'Y1' ELSE REPLACE(reporting_term, 'AR', 'Q') END AS reporting_term
        ,'BLENDED LEARNING' AS domain
        ,'AR' AS subdomain      
  FROM gabby.renaissance.ar_progress_to_goals_static
  WHERE academic_year >= (gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1)
 )

/*
SELECT r.studentid
      ,r.student_number
      ,r.lastfirst
      ,r.academic_year
      ,r.reporting_schoolid AS schoolid
      ,r.grade_level
      ,r.cohort
      ,r.team
      ,r.advisor_name
      ,r.iep_status
      ,r.enroll_status
      ,r.term
      ,r.reporting_term      
      ,gr.domain
      ,gr.subdomain      
      ,gr.credittype AS subject
      ,gr.course_name
      ,gr.finalgradename AS measure_name
      ,gr.term_grade_percent_adjusted AS measure_value
      ,NULL AS measure_date
      ,NULL AS performance_level
      ,NULL AS performance_level_label
FROM roster r
LEFT OUTER JOIN grades gr
  ON r.student_number = gr.student_number
 AND r.academic_year = gr.academic_year
 AND r.reporting_term = gr.reporting_term

UNION ALL
--*/
/*
SELECT r.studentid
      ,r.student_number
      ,r.lastfirst
      ,r.academic_year
      ,r.reporting_schoolid AS schoolid
      ,r.grade_level
      ,r.cohort
      ,r.team
      ,r.advisor_name
      ,r.iep_status
      ,r.enroll_status
      ,r.term
      ,r.reporting_term      
      ,att.domain
      ,att.subdomain      
      ,NULL AS subject
      ,NULL AS course_name
      ,att.att_code AS measure_name
      ,att.att_counts AS measure_value
      ,NULL AS measure_date
      ,NULL AS performance_level
      ,NULL AS performance_level_label
FROM roster r
LEFT OUTER JOIN attendance att
  ON r.studentid = att.studentid
 AND r.academic_year = att.academic_year
 AND r.reporting_term = att.reporting_term

UNION ALL
--*/
/*
SELECT r.studentid
      ,r.student_number
      ,r.lastfirst
      ,r.academic_year
      ,r.reporting_schoolid AS schoolid
      ,r.grade_level
      ,r.cohort
      ,r.team
      ,r.advisor_name
      ,r.iep_status
      ,r.enroll_status
      ,cma.scope AS term
      ,r.reporting_term      
      ,cma.domain
      ,cma.subdomain      
      ,cma.subject_area AS subject
      ,cma.title AS course_name
      ,cma.standards AS measure_name
      ,cma.percent_correct AS measure_value
      ,cma.measure_date
      ,cma.assessment_id AS performance_level
      ,cma.proficiency_label AS performance_level_label
FROM roster r
LEFT OUTER JOIN modules cma
  ON r.student_number = cma.student_number
 AND r.academic_year = cma.academic_year
WHERE r.term = 'Y1' 

UNION ALL
--*/
/*
SELECT r.studentid
      ,r.student_number
      ,r.lastfirst
      ,gpa.academic_year AS year
      ,r.reporting_schoolid AS schoolid
      ,r.grade_level
      ,r.cohort
      ,r.team
      ,r.advisor_name
      ,r.iep_status
      ,r.enroll_status
      ,r.term
      ,r.reporting_term      
      ,gpa.domain
      ,gpa.subdomain      
      ,NULL AS subject
      ,NULL AS course_name
      ,NULL AS measure_name
      ,gpa.GPA AS measure_value
      ,NULL AS measure_date
      ,NULL AS performance_level
      ,NULL AS performance_level_label
FROM roster r
LEFT OUTER JOIN gpa
  ON r.student_number = gpa.student_number 
 AND r.schoolid = gpa.schoolid
 AND r.academic_year >= gpa.academic_year
 AND r.reporting_term = gpa.reporting_term

UNION ALL
--*/
--/*
SELECT r.studentid
      ,r.student_number
      ,r.lastfirst
      ,lit.academic_year AS year
      ,r.reporting_schoolid AS schoolid
      ,r.grade_level
      ,r.cohort
      ,r.team
      ,r.advisor_name
      ,r.iep_status
      ,r.enroll_status
      ,lit.test_round AS term
      ,r.reporting_term      
      ,lit.domain
      ,lit.subdomain      
      ,NULL AS subject
      ,NULL AS course_name
      ,lit.read_lvl AS measure_name
      ,lit.lvl_num AS measure_value
      ,NULL AS measure_date
      ,NULL AS performance_level
      ,NULL AS performance_level_label
FROM roster r
LEFT OUTER JOIN lit
  ON r.student_number = lit.student_number
 AND r.academic_year >= lit.academic_year
WHERE r.term = 'Y1'

--UNION ALL
--*/
--/*
--SELECT r.studentid
--      ,r.student_number
--      ,r.lastfirst
--      ,map.test_year AS year
--      ,r.reporting_schoolid AS schoolid
--      ,r.grade_level
--      ,r.cohort
--      ,r.team
--      ,r.advisor_name
--      ,r.iep_status
--      ,r.enroll_status
--      ,map.term
--      ,r.reporting_term      
--      ,map.domain
--      ,map.subdomain      
--      ,map.measurementscale AS subject
--      ,NULL AS course_name
--      ,CONVERT(VARCHAR,map.testritscore) AS measure_name
--      ,map.testpercentile AS measure_value
--      ,NULL AS measure_date
--      ,NULL AS performance_level
--      ,NULL AS performance_level_label
--FROM roster r
--LEFT OUTER JOIN map
--  ON r.student_number = map.student_number
-- AND r.academic_year >= map.academic_year
--WHERE r.reporting_term = 'Y1' 

--UNION ALL

--SELECT r.studentid
--      ,r.student_number
--      ,r.lastfirst
--      ,std.academic_year AS year
--      ,r.reporting_schoolid AS schoolid
--      ,r.grade_level
--      ,r.cohort
--      ,r.team
--      ,r.advisor_name
--      ,r.iep_status
--      ,r.enroll_status
--      ,r.term
--      ,r.reporting_term      
--      ,'STANDARDIZED TESTS' AS domain
--      ,std.test_name AS subdomain
--      ,std.subject AS subject
--      ,NULL AS course_name
--      ,CONVERT(VARCHAR,std.BINI_ID) AS measure_name
--      ,std.scale_score AS measure_value
--      ,std.test_date AS measure_date
--      ,std.performance_level
--      ,std.performance_level_label
--FROM roster r
--LEFT OUTER JOIN standardized_tests std
--  ON r.student_number = std.student_number
--WHERE r.reporting_term = 'Y1'

--UNION ALL

--SELECT r.studentid
--      ,r.student_number
--      ,r.lastfirst
--      ,r.academic_year
--      ,r.reporting_schoolid AS schoolid
--      ,r.grade_level
--      ,r.cohort
--      ,r.team
--      ,r.advisor_name
--      ,r.iep_status
--      ,r.enroll_status
--      ,r.term
--      ,r.reporting_term      
--      ,'COLLEGE APPS' AS domain
--      ,apps.level AS subdomain
--      ,apps.result_code AS subject
--      ,apps.collegename AS course_name
--      ,NULL AS measure_name
--      ,NULL AS measure_value
--      ,NULL AS measure_date
--      ,apps.competitiveness_index__c AS performance_level
--      ,apps.value AS performance_level_label
--FROM roster r
--LEFT OUTER JOIN collegeapps apps
--  ON r.student_number = apps.student_number
--WHERE r.reporting_term = 'Y1'

--UNION ALL

--SELECT r.studentid
--      ,r.student_number
--      ,r.lastfirst
--      ,r.academic_year
--      ,r.reporting_schoolid AS schoolid
--      ,r.grade_level
--      ,r.cohort
--      ,r.team
--      ,r.advisor_name
--      ,r.iep_status
--      ,r.enroll_status
--      ,r.term
--      ,r.reporting_term      
--      ,logs.domain
--      ,logs.logtype AS subdomain
--      ,NULL AS subject
--      ,NULL AS course_name
--      ,logs.subtype AS measure_name
--      ,logs.n_counts AS measure_value
--      ,NULL AS measure_date
--      ,NULL AS performance_level
--      ,NULL AS performance_level_label
--FROM roster r
--LEFT OUTER JOIN disc_logs logs
--  ON r.studentid = logs.studentid
-- AND r.academic_year = logs.academic_year
-- AND r.reporting_term = logs.reporting_term
--WHERE r.term != 'Y1'

--UNION ALL

--SELECT r.studentid
--      ,r.student_number
--      ,r.lastfirst
--      ,r.academic_year
--      ,r.reporting_schoolid AS schoolid
--      ,r.grade_level
--      ,r.cohort
--      ,r.team
--      ,r.advisor_name
--      ,r.iep_status
--      ,r.enroll_status
--      ,r.term
--      ,r.reporting_term      
--      ,daily.domain
--      ,daily.field AS subdomain
--      ,daily.time_of_day AS subject
--      ,NULL AS course_name
--      ,NULL AS measure_name
--      ,daily.n_counts AS measure_value
--      ,NULL AS measure_date
--      ,NULL AS performance_level
--      ,NULL AS performance_level_label
--FROM roster r
--LEFT OUTER JOIN daily_tracking daily
--  ON r.studentid = daily.studentid
-- AND r.academic_year = daily.academic_year
-- AND r.term = daily.term
--WHERE r.term != 'Y1'

--UNION ALL

--SELECT r.studentid
--      ,r.student_number
--      ,r.lastfirst
--      ,r.academic_year
--      ,r.reporting_schoolid AS schoolid
--      ,r.grade_level
--      ,r.cohort
--      ,r.team
--      ,r.advisor_name
--      ,r.iep_status
--      ,r.enroll_status
--      ,r.term
--      ,r.reporting_term      
--      ,promo.domain
--      ,promo.subdomain
--      ,NULL AS subject
--      ,NULL AS course_name
--      ,NULL AS measure_name
--      ,NULL AS measure_value
--      ,NULL AS measure_date
--      ,promo.numeric_value AS performance_level
--      ,promo.text_value AS performance_level_label
--FROM roster r
--LEFT OUTER JOIN promo_status promo
--  ON r.student_number = promo.student_number 
-- AND r.academic_year = promo.academic_year
--WHERE r.term = 'Y1'

--UNION ALL

--SELECT r.studentid
--      ,r.student_number
--      ,r.lastfirst
--      ,r.academic_year
--      ,r.reporting_schoolid AS schoolid
--      ,r.grade_level
--      ,r.cohort
--      ,r.team
--      ,r.advisor_name
--      ,r.iep_status
--      ,r.enroll_status
--      ,ss.term
--      ,r.reporting_term      
--      ,'SOCIAL SKILLS' AS domain
--      ,NULL AS subdomain
--      ,NULL AS subject
--      ,NULL AS course_name
--      ,ss.social_skill AS measure_name
--      ,CONVERT(FLOAT,ss.score) AS measure_value
--      ,NULL AS measure_date
--      ,NULL AS performance_level
--      ,NULL AS performance_level_label
--FROM roster r
--JOIN KIPP_NJ..REPORTING$social_skills#ES ss WITH(NOLOCK)
--  ON r.student_number = ss.student_number 
-- AND r.academic_year = ss.academic_year
-- AND r.term = ss.term
-- AND ISNUMERIC(ss.score) = 1
--WHERE r.term != 'Y1'
--  AND r.academic_year >= (gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1)

--UNION ALL

--SELECT r.studentid
--      ,r.student_number
--      ,r.lastfirst
--      ,r.academic_year
--      ,r.reporting_schoolid AS schoolid
--      ,r.grade_level
--      ,r.cohort
--      ,r.team
--      ,r.advisor_name
--      ,r.iep_status
--      ,r.enroll_status
--      ,r.term
--      ,r.reporting_term      
--      ,c.domain
--      ,c.type AS subdomain
--      ,c.person AS subject
--      ,NULL AS course_name
--      ,c.value AS measure_name
--      ,NULL AS measure_value
--      ,NULL AS measure_date
--      ,NULL AS performance_level
--      ,NULL AS performance_level_label
--FROM roster r
--LEFT OUTER JOIN contact c
--  ON r.STUDENTID = c.STUDENTID  
--WHERE r.term = 'Y1'

--UNION ALL

--SELECT r.studentid
--      ,r.student_number
--      ,r.lastfirst
--      ,r.academic_year
--      ,r.reporting_schoolid AS schoolid
--      ,r.grade_level
--      ,r.cohort
--      ,r.team
--      ,r.advisor_name
--      ,r.iep_status
--      ,r.enroll_status
--      ,CONVERT(VARCHAR,ww.listweek_num) AS term
--      ,r.reporting_term      
--      ,ww.domain
--      ,ww.subdomain
--      ,NULL AS subject
--      ,NULL AS course_name
--      ,ww.word AS measure_name
--      ,ww.score AS measure_value
--      ,NULL AS measure_date
--      ,NULL AS performance_level
--      ,NULL AS performance_level_label
--FROM roster r
--JOIN wordwork ww
--  ON r.student_number = ww.student_number
-- AND r.academic_year = ww.academic_year
--WHERE r.term = 'Y1'

--UNION ALL

--SELECT r.studentid
--      ,r.student_number
--      ,r.lastfirst
--      ,r.academic_year
--      ,r.reporting_schoolid AS schoolid
--      ,r.grade_level
--      ,r.cohort
--      ,r.team
--      ,r.advisor_name
--      ,r.iep_status
--      ,r.enroll_status
--      ,r.term
--      ,r.reporting_term      
--      ,b.domain
--      ,b.subdomain
--      ,NULL AS subject
--      ,NULL AS course_name
--      ,NULL AS measure_name
--      ,b.progress AS measure_value
--      ,NULL AS measure_date
--      ,b.goal AS performance_level
--      ,b.goal_status AS performance_level_label
--FROM roster r
--JOIN blended b
--  ON r.student_number = b.student_number
-- AND r.academic_year = b.academic_year
-- AND r.reporting_term = b.reporting_term

--/* blank row for default */
--UNION ALL

--SELECT DISTINCT 
--       NULL AS studentid
--      ,NULL AS student_number
--      ,' Choose a student...' AS lastfirst
--      ,year
--      ,reporting_schoolid AS schoolid
--      ,grade_level
--      ,NULL AS cohort
--      ,NULL AS team
--      ,advisor      
--      ,'No IEP' AS spedlep
--      ,0 AS enroll_status
--      ,NULL AS term
--      ,NULL AS reporting_term      
--      ,'CONTACT' AS domain
--      ,NULL AS subdomain
--      ,NULL AS subject
--      ,NULL AS course_name
--      ,NULL AS measure_name
--      ,NULL AS measure_value
--      ,NULL AS measure_date
--      ,NULL AS performance_level
--      ,NULL AS performance_level_label
--FROM KIPP_NJ..COHORT$identifiers_long#static WITH(NOLOCK)
--WHERE year >= (gabby.utilities.GLOBAL_ACADEMIC_YEAR() - 1)
--  AND schoolid != 999999