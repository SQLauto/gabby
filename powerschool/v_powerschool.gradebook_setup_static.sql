USE [gabby];
GO

CREATE OR ALTER VIEW powerschool.gradebook_setup_static AS

SELECT 'kippcamden' AS [db_name]
      ,[sectionsdcid]
      ,[psm_sectionid]
      ,[finalgradesetupid]
      ,[finalgradesetuptype]
      ,[fg_reportingtermid]
      ,[reportingterm_name]
      ,[startdate]
      ,[enddate]
      ,[gradingformulaid]
      ,[gradingformulaweightingtype]
      ,[weighting]
      ,[assignmentcategoryid]
      ,[category_name]
      ,[category_abbreviation]
      ,[defaultscoretype]
      ,[includeinfinalgrades]
FROM kippcamden.powerschool.gradebook_setup_static
UNION ALL
SELECT 'kippmiami' AS [db_name]
      ,[sectionsdcid]
      ,[psm_sectionid]
      ,[finalgradesetupid]
      ,[finalgradesetuptype]
      ,[fg_reportingtermid]
      ,[reportingterm_name]
      ,[startdate]
      ,[enddate]
      ,[gradingformulaid]
      ,[gradingformulaweightingtype]
      ,[weighting]
      ,[assignmentcategoryid]
      ,[category_name]
      ,[category_abbreviation]
      ,[defaultscoretype]
      ,[includeinfinalgrades]
FROM kippmiami.powerschool.gradebook_setup_static
UNION ALL
SELECT 'kippnewark' AS [db_name]
      ,[sectionsdcid]
      ,[psm_sectionid]
      ,[finalgradesetupid]
      ,[finalgradesetuptype]
      ,[fg_reportingtermid]
      ,[reportingterm_name]
      ,[startdate]
      ,[enddate]
      ,[gradingformulaid]
      ,[gradingformulaweightingtype]
      ,[weighting]
      ,[assignmentcategoryid]
      ,[category_name]
      ,[category_abbreviation]
      ,[defaultscoretype]
      ,[includeinfinalgrades]
FROM kippnewark.powerschool.gradebook_setup_static;