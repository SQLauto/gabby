USE gabby
GO

ALTER VIEW parcc.summative_record_file_clean AS

SELECT state_abbreviation
      ,testing_district_code
      ,testing_school_code
      ,responsible_district_code
      ,responsible_school_code
      ,state_student_identifier
      ,local_student_identifier
      ,parccstudent_identifier
      ,last_or_surname
      ,first_name
      ,middle_name
      ,birthdate
      ,sex
      ,grade_level_when_assessed
      ,hispanic_or_latino_ethnicity
      ,american_indian_or_alaska_native
      ,asian
      ,black_or_african_american
      ,native_hawaiian_or_other_pacific_islander
      ,white
      ,two_or_more_races
      ,english_learner_el
      ,title_iiilimited_english_proficient_participation_status
      ,giftedand_talented
      ,migrant_status
      ,economic_disadvantage_status
      ,student_with_disabilities
      ,primary_disability_type
      ,state_field_1
      ,state_field_2
      ,state_field_3
      ,state_field_4
      ,state_field_5
      ,state_field_6
      ,state_field_7
      ,state_field_8
      ,state_field_9
      ,state_field_10
      ,class_name
      ,test_administrator
      ,staff_member_identifier
      ,test_code
      ,retest
      ,elaccommodation
      ,frequent_breaks
      ,separate_alternate_location
      ,small_testing_group
      ,specialized_equipment_or_furniture
      ,specified_area_or_setting
      ,time_of_day
      ,answer_masking
      ,assistive_technology_screen_reader
      ,closed_captioning_for_elal
      ,student_reads_assessment_aloud_to_themselves
      ,human_signer_for_test_directions
      ,calculation_device_and_mathematics_tools
      ,elalconstructed_response
      ,elalselected_response_or_technology_enhanced_items
      ,mathematics_response
      ,monitor_test_response
      ,word_prediction
      ,administration_directions_clarifiedin_students_native_language
      ,administration_directions_read_aloudin_students_native_language
      ,mathematics_response_el
      ,wordto_word_dictionary_english_native_language
      ,emergency_accommodation
      ,extended_time
      ,student_test_uuid
      ,paper_form_id
      ,online_form_id
      ,test_status
      ,total_test_items
      ,test_attemptedness_flag
      ,total_test_items_attempted
      ,paper_attempt_create_date
      ,paper_section_1_total_test_items
      ,paper_section_1_numberof_attempted_items
      ,paper_section_2_total_test_items
      ,paper_section_2_numberof_attempted_items
      ,paper_section_3_total_test_items
      ,paper_section_3_numberof_attempted_items
      ,paper_section_4_total_test_items
      ,paper_section_4_numberof_attempted_items
      ,student_unit_1_test_uuid
      ,unit_1_form_id
      ,unit_1_total_test_items
      ,unit_1_numberof_attempted_items
      ,student_unit_2_test_uuid
      ,unit_2_form_id
      ,unit_2_total_test_items
      ,unit_2_number_of_attempted_items
      ,student_unit_3_test_uuid
      ,unit_3_form_id
      ,unit_3_total_test_items
      ,unit_3_number_of_attempted_items
      ,student_unit_4_test_uuid
      ,unit_4_form_id
      ,unit_4_total_test_items
      ,unit_4_numberof_attempted_items
      ,not_tested_code
      ,not_tested_reason
      ,void_score_code
      ,void_score_reason
      ,ship_report_district_code
      ,ship_report_school_code
      ,summative_flag
      ,multiple_test_registration
      ,attempt_create_date
      ,unit_1_online_test_start_date_time
      ,unit_1_online_test_end_date_time
      ,unit_2_online_test_start_date_time
      ,unit_2_online_test_end_date_time
      ,unit_3_online_test_start_date_time
      ,unit_3_online_test_end_date_time
      ,unit_4_online_test_start_date_time
      ,unit_4_online_test_end_date_time
      ,assessment_year
      ,assessment_grade
      ,subject
      ,federal_race_ethnicity
      ,period
      ,testing_organizational_type
      ,testing_district_name
      ,testing_school_name
      ,responsible_organization_code_type
      ,responsible_organizational_type
      ,responsible_district_name
      ,responsible_school_name
      ,test_scale_score
      ,test_csemprobable_range
      ,test_performance_level
      ,test_reading_scale_score
      ,test_reading_csem
      ,test_writing_scale_score
      ,test_writing_csem
      ,subclaim_1_category
      ,subclaim_2_category
      ,subclaim_3_category
      ,subclaim_4_category
      ,subclaim_5_category
      ,test_score_complete
      ,word_prediction_for_elal
      ,NULL AS record_type
      ,NULL AS assessment_accommodation_english_learner
      ,NULL AS assessment_accommodation_504
      ,NULL AS assessment_accommodation_individualized_educational_plan
      ,text_to_speech
      ,NULL AS text_to_speech_for_mathematics
      ,NULL AS text_to_speech_for_elal
      ,human_reader_or_human_signer
      ,NULL AS human_reader_or_human_signer_for_mathematics
      ,NULL AS human_reader_or_human_signer_for_elal
      ,NULL AS pba_form_id
      ,NULL AS pba_not_tested_reason
      ,NULL AS pba_student_test_uuid
      ,NULL AS pba_test_attemptedness_flag
      ,NULL AS pba_testing_district_identifier
      ,NULL AS pba_testing_district_name
      ,NULL AS pba_testing_school_institution_identifier
      ,NULL AS pba_testing_school_institution_name
      ,NULL AS pba_total_test_items
      ,NULL AS pba_total_test_items_attempted
      ,NULL AS pba_unit_1_number_of_attempted_items
      ,NULL AS pba_unit_1_total_number_of_items
      ,NULL AS pba_unit_2_number_of_attempted_items
      ,NULL AS pba_unit_2_total_number_of_items
      ,NULL AS pba_unit_3_number_of_attempted_items
      ,NULL AS pba_unit_3_total_number_of_items
FROM gabby.parcc.summative_record_file
WHERE assessment_year IN ('2015-2016','2016-2017')
  AND test_status = 'Attempt'
  AND summative_flag = 'Y'

UNION ALL

/* 2014-2015 report format */
SELECT state_abbreviation
      ,eoy_testing_district_identifier
      ,eoy_testing_school_institution_identifier
      ,responsible_district_identifier
      ,responsible_school_institution_identifier
      ,state_student_identifier
      ,local_student_identifier
      ,parcc_student_identifier
      ,last_name
      ,first_name
      ,middle_name
      ,birthdate
      ,sex
      ,grade_level_when_assessed
      ,hispanic_or_latino_ethnicity
      ,american_indian_or_alaska_native
      ,asian
      ,black_or_african_american
      ,native_hawaiian_or_other_pacific_islander
      ,white
      ,two_or_more_races
      ,english_learner
      ,title_iiilimited_english_proficient_participation_status
      ,gifted_and_talented
      ,migrant_status
      ,economic_disadvantage_status
      ,student_with_disabilities
      ,primary_disability_type
      ,optional_state_data_1
      ,optional_state_data_2
      ,NULL AS state_field_3
      ,NULL AS state_field_4
      ,NULL AS state_field_5
      ,NULL AS state_field_6
      ,NULL AS state_field_7
      ,NULL AS state_field_8
      ,NULL AS state_field_9
      ,NULL AS state_field_10
      ,NULL AS class_name
      ,NULL AS test_administrator
      ,staff_member_identifier
      ,test_code
      ,NULL AS retest
      ,NULL AS elaccommodation
      ,frequent_breaks
      ,separate_alternate_location
      ,small_testing_group
      ,NULL AS specialized_equipment_or_furniture
      ,specified_area_or_setting
      ,time_of_day
      ,answer_masking
      ,NULL AS assistive_technology_screen_reader
      ,NULL AS closed_captioning_for_elal
      ,NULL AS student_reads_assessment_aloud_to_themselves
      ,NULL AS human_signer_for_test_directions
      ,calculation_device_and_mathematics_tools
      ,elal_constructed_response
      ,elal_selected_response_or_technology_enhanced_items
      ,mathematics_response
      ,NULL AS monitor_test_response
      ,word_prediction
      ,administration_directions_clarified_in_students_native_language
      ,NULL AS administration_directions_read_aloudin_students_native_language
      ,NULL AS mathematics_response_el
      ,NULL AS wordto_word_dictionary_english_native_language
      ,NULL AS emergency_accommodation
      ,extended_time
      ,summative_score_record_uuid
      ,eoy_form_id
      ,eoy_form_id
      ,NULL AS test_status
      ,eoy_total_test_items
      ,eoy_test_attemptedness_flag
      ,eoy_total_test_items_attempted
      ,NULL AS paper_attempt_create_date
      ,NULL AS paper_section_1_total_test_items
      ,NULL AS paper_section_1_numberof_attempted_items
      ,NULL AS paper_section_2_total_test_items
      ,NULL AS paper_section_2_numberof_attempted_items
      ,NULL AS paper_section_3_total_test_items
      ,NULL AS paper_section_3_numberof_attempted_items
      ,NULL AS paper_section_4_total_test_items
      ,NULL AS paper_section_4_numberof_attempted_items
      ,NULL AS student_unit_1_test_uuid
      ,NULL AS unit_1_form_id
      ,eoy_unit_1_total_number_of_items
      ,eoy_unit_1_number_of_attempted_items
      ,NULL AS student_unit_2_test_uuid
      ,NULL AS unit_2_form_id
      ,eoy_unit_2_total_number_of_items
      ,eoy_unit_2_number_of_attempted_items
      ,NULL AS student_unit_3_test_uuid
      ,NULL AS unit_3_form_id
      ,eoy_unit_3_total_number_of_items
      ,eoy_unit_3_number_of_attempted_items
      ,NULL AS student_unit_4_test_uuid
      ,NULL AS unit_4_form_id
      ,NULL AS unit_4_total_test_items
      ,NULL AS unit_4_numberof_attempted_items
      ,NULL AS not_tested_code
      ,eoy_not_tested_reason
      ,NULL AS void_score_code
      ,NULL AS void_score_reason
      ,NULL AS ship_report_district_code
      ,NULL AS ship_report_school_code
      ,reported_summative_score_flag
      ,NULL AS multiple_test_registration
      ,NULL AS attempt_create_date
      ,NULL AS unit_1_online_test_start_date_time
      ,NULL AS unit_1_online_test_end_date_time
      ,NULL AS unit_2_online_test_start_date_time
      ,NULL AS unit_2_online_test_end_date_time
      ,NULL AS unit_3_online_test_start_date_time
      ,NULL AS unit_3_online_test_end_date_time
      ,NULL AS unit_4_online_test_start_date_time
      ,NULL AS unit_4_online_test_end_date_time
      ,assessment_year
      ,assessment_grade
      ,subject
      ,federal_race_ethnicity
      ,NULL AS period
      ,NULL AS testing_organizational_type
      ,eoy_testing_district_name
      ,eoy_testing_school_institution_name
      ,NULL AS responsible_organization_code_type
      ,NULL AS responsible_organizational_type
      ,responsible_district_name
      ,responsible_school_institution_name
      ,summative_scale_score
      ,summative_csem
      ,summative_performance_level
      ,summative_reading_scale_score
      ,summative_reading_csem
      ,summative_writing_scale_score
      ,summative_writing_csem
      ,subclaim_1_category
      ,subclaim_2_category
      ,subclaim_3_category
      ,subclaim_4_category
      ,subclaim_5_category
      ,NULL AS test_score_complete
      ,NULL AS word_prediction_for_elal
      ,record_type
      ,assessment_accommodation_english_learner
      ,assessment_accommodation_504
      ,assessment_accommodation_individualized_educational_plan
      ,NULL AS text_to_speech
      ,text_to_speech_for_mathematics
      ,text_to_speech_for_elal
      ,NULL AS human_reader_or_human_signer
      ,human_reader_or_human_signer_for_mathematics
      ,human_reader_or_human_signer_for_elal
      ,pba_form_id
      ,pba_not_tested_reason
      ,pba_student_test_uuid
      ,pba_test_attemptedness_flag
      ,pba_testing_district_identifier
      ,pba_testing_district_name
      ,pba_testing_school_institution_identifier
      ,pba_testing_school_institution_name
      ,pba_total_test_items
      ,pba_total_test_items_attempted
      ,pba_unit_1_number_of_attempted_items
      ,pba_unit_1_total_number_of_items
      ,pba_unit_2_number_of_attempted_items
      ,pba_unit_2_total_number_of_items
      ,pba_unit_3_number_of_attempted_items
      ,pba_unit_3_total_number_of_items
FROM gabby.parcc.summative_record_file
WHERE assessment_year = '2014-2015'
  AND record_type = 1 
  AND reported_summative_score_flag = 'Y'