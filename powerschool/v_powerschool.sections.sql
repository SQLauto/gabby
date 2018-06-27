USE [gabby];
GO

CREATE OR ALTER VIEW powerschool.sections AS

SELECT 'kippcamden' AS [db_name]
      ,[att_mode_code]
      ,[attendance_type_code]
      ,[bitmap]
      ,[buildid]
      ,[campusid]
      ,[course_number]
      ,[course_number_clean]
      ,[dcid]
      ,[dependent_secs]
      ,[distuniqueid]
      ,[exclude_ada]
      ,[exclude_state_rpt_yn]
      ,[excludefromclassrank]
      ,[excludefromgpa]
      ,[excludefromhonorroll]
      ,[excludefromstoredgrades]
      ,[expression]
      ,[grade_level]
      ,[gradebooktype]
      ,[gradescaleid]
      ,[id]
      ,[log]
      ,[maxcut]
      ,[maxenrollment]
      ,[no_of_students]
      ,[noofterms]
      ,[parent_section_id]
      ,[pgversion]
      ,[programid]
      ,[room]
      ,[rostermodser]
      ,[schedulesectionid]
      ,[schoolid]
      ,[section_number]
      ,[section_type]
      ,[sectioninfo_guid]
      ,[sortorder]
      ,[teacher]
      ,[teacherdescr]
      ,[termid]
      ,[trackteacheratt]
      ,[wheretaught]
      ,[wheretaughtdistrict]
      ,[yearid]
FROM kippcamden.powerschool.sections
UNION ALL
SELECT 'kippmiami' AS [db_name]
      ,[att_mode_code]
      ,[attendance_type_code]
      ,[bitmap]
      ,[buildid]
      ,[campusid]
      ,[course_number]
      ,[course_number_clean]
      ,[dcid]
      ,[dependent_secs]
      ,[distuniqueid]
      ,[exclude_ada]
      ,[exclude_state_rpt_yn]
      ,[excludefromclassrank]
      ,[excludefromgpa]
      ,[excludefromhonorroll]
      ,[excludefromstoredgrades]
      ,[expression]
      ,[grade_level]
      ,[gradebooktype]
      ,[gradescaleid]
      ,[id]
      ,[log]
      ,[maxcut]
      ,[maxenrollment]
      ,[no_of_students]
      ,[noofterms]
      ,[parent_section_id]
      ,[pgversion]
      ,[programid]
      ,[room]
      ,[rostermodser]
      ,[schedulesectionid]
      ,[schoolid]
      ,[section_number]
      ,[section_type]
      ,[sectioninfo_guid]
      ,[sortorder]
      ,[teacher]
      ,[teacherdescr]
      ,[termid]
      ,[trackteacheratt]
      ,[wheretaught]
      ,[wheretaughtdistrict]
      ,[yearid]
FROM kippmiami.powerschool.sections
UNION ALL
SELECT 'kippnewark' AS [db_name]
      ,[att_mode_code]
      ,[attendance_type_code]
      ,[bitmap]
      ,[buildid]
      ,[campusid]
      ,[course_number]
      ,[course_number_clean]
      ,[dcid]
      ,[dependent_secs]
      ,[distuniqueid]
      ,[exclude_ada]
      ,[exclude_state_rpt_yn]
      ,[excludefromclassrank]
      ,[excludefromgpa]
      ,[excludefromhonorroll]
      ,[excludefromstoredgrades]
      ,[expression]
      ,[grade_level]
      ,[gradebooktype]
      ,[gradescaleid]
      ,[id]
      ,[log]
      ,[maxcut]
      ,[maxenrollment]
      ,[no_of_students]
      ,[noofterms]
      ,[parent_section_id]
      ,[pgversion]
      ,[programid]
      ,[room]
      ,[rostermodser]
      ,[schedulesectionid]
      ,[schoolid]
      ,[section_number]
      ,[section_type]
      ,[sectioninfo_guid]
      ,[sortorder]
      ,[teacher]
      ,[teacherdescr]
      ,[termid]
      ,[trackteacheratt]
      ,[wheretaught]
      ,[wheretaughtdistrict]
      ,[yearid]
FROM kippnewark.powerschool.sections;