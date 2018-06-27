USE [gabby];
GO

CREATE OR ALTER VIEW powerschool.assignmentsection AS

SELECT 'kippcamden' AS [db_name]
      ,[assignmentid]
      ,[assignmentsectionid]
      ,[description]
      ,[duedate]
      ,[extracreditpoints]
      ,[iscountedinfinalgrade]
      ,[isscorespublish]
      ,[isscoringneeded]
      ,[maxretakeallowed]
      ,[name]
      ,[publishdaysbeforedue]
      ,[publisheddate]
      ,[publishonspecificdate]
      ,[publishoption]
      ,[scoreentrypoints]
      ,[scoretype]
      ,[sectionsdcid]
      ,[totalpointvalue]
      ,[weight]
FROM kippcamden.powerschool.assignmentsection
UNION ALL
SELECT 'kippmiami' AS [db_name]
      ,[assignmentid]
      ,[assignmentsectionid]
      ,[description]
      ,[duedate]
      ,[extracreditpoints]
      ,[iscountedinfinalgrade]
      ,[isscorespublish]
      ,[isscoringneeded]
      ,[maxretakeallowed]
      ,[name]
      ,[publishdaysbeforedue]
      ,[publisheddate]
      ,[publishonspecificdate]
      ,[publishoption]
      ,[scoreentrypoints]
      ,[scoretype]
      ,[sectionsdcid]
      ,[totalpointvalue]
      ,[weight]
FROM kippmiami.powerschool.assignmentsection
UNION ALL
SELECT 'kippnewark' AS [db_name]
      ,[assignmentid]
      ,[assignmentsectionid]
      ,[description]
      ,[duedate]
      ,[extracreditpoints]
      ,[iscountedinfinalgrade]
      ,[isscorespublish]
      ,[isscoringneeded]
      ,[maxretakeallowed]
      ,[name]
      ,[publishdaysbeforedue]
      ,[publisheddate]
      ,[publishonspecificdate]
      ,[publishoption]
      ,[scoreentrypoints]
      ,[scoretype]
      ,[sectionsdcid]
      ,[totalpointvalue]
      ,[weight]
FROM kippnewark.powerschool.assignmentsection;