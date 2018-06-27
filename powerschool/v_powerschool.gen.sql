USE [gabby];
GO

CREATE OR ALTER VIEW powerschool.gen AS

SELECT 'kippcamden' AS [db_name]
      ,[cat]
      ,[cat_clean]
      ,[date_value]
      ,[dcid]
      ,[id]
      ,[log]
      ,[name]
      ,[powerlink]
      ,[powerlinkspan]
      ,[schoolid]
      ,[sortorder]
      ,[spedindicator]
      ,[time_1]
      ,[time_2]
      ,[value]
      ,[value_2]
      ,[value_x]
      ,[valueli]
      ,[valueli_2]
      ,[valueli_3]
      ,[valueli_4]
      ,[valuer]
      ,[valuer_2]
      ,[valuet]
      ,[valuet_2]
      ,[yearid]
FROM kippcamden.powerschool.gen
UNION ALL
SELECT 'kippmiami' AS [db_name]
      ,[cat]
      ,[cat_clean]
      ,[date_value]
      ,[dcid]
      ,[id]
      ,[log]
      ,[name]
      ,[powerlink]
      ,[powerlinkspan]
      ,[schoolid]
      ,[sortorder]
      ,[spedindicator]
      ,[time_1]
      ,[time_2]
      ,[value]
      ,[value_2]
      ,[value_x]
      ,[valueli]
      ,[valueli_2]
      ,[valueli_3]
      ,[valueli_4]
      ,[valuer]
      ,[valuer_2]
      ,[valuet]
      ,[valuet_2]
      ,[yearid]
FROM kippmiami.powerschool.gen
UNION ALL
SELECT 'kippnewark' AS [db_name]
      ,[cat]
      ,[cat_clean]
      ,[date_value]
      ,[dcid]
      ,[id]
      ,[log]
      ,[name]
      ,[powerlink]
      ,[powerlinkspan]
      ,[schoolid]
      ,[sortorder]
      ,[spedindicator]
      ,[time_1]
      ,[time_2]
      ,[value]
      ,[value_2]
      ,[value_x]
      ,[valueli]
      ,[valueli_2]
      ,[valueli_3]
      ,[valueli_4]
      ,[valuer]
      ,[valuer_2]
      ,[valuet]
      ,[valuet_2]
      ,[yearid]
FROM kippnewark.powerschool.gen;