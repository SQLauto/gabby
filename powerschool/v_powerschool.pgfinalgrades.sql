USE [gabby];
GO

CREATE OR ALTER VIEW powerschool.pgfinalgrades AS

SELECT 'kippcamden' AS [db_name]
      ,NULL AS [citizenship]
      ,[comment_value]
      ,[dcid]
      ,[enddate]
      ,[finalgrade_type]
      ,[finalgradename]
      ,[finalgradename_clean]
      ,[grade]
      ,[gradebooktype]
      ,[id]
      ,[lastgradeupdate]
      ,[overridefg]
      ,[percent]
      ,[points]
      ,[pointspossible]
      ,[sectionid]
      ,[startdate]
      ,[studentid]
      ,[varcredit]
FROM kippcamden.powerschool.pgfinalgrades
UNION ALL
SELECT 'kippmiami' AS [db_name]
      ,NULL AS [citizenship]
      ,[comment_value]
      ,[dcid]
      ,[enddate]
      ,[finalgrade_type]
      ,[finalgradename]
      ,[finalgradename_clean]
      ,[grade]
      ,[gradebooktype]
      ,[id]
      ,[lastgradeupdate]
      ,[overridefg]
      ,[percent]
      ,[points]
      ,[pointspossible]
      ,[sectionid]
      ,[startdate]
      ,[studentid]
      ,[varcredit]
FROM kippmiami.powerschool.pgfinalgrades
UNION ALL
SELECT 'kippnewark' AS [db_name]
      ,NULL AS [citizenship]
      ,[comment_value]
      ,[dcid]
      ,[enddate]
      ,[finalgrade_type]
      ,[finalgradename]
      ,[finalgradename_clean]
      ,[grade]
      ,[gradebooktype]
      ,[id]
      ,[lastgradeupdate]
      ,[overridefg]
      ,[percent]
      ,[points]
      ,[pointspossible]
      ,[sectionid]
      ,[startdate]
      ,[studentid]
      ,[varcredit]
FROM kippnewark.powerschool.pgfinalgrades;