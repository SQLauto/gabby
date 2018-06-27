USE [gabby];
GO

CREATE OR ALTER VIEW powerschool.schools AS

SELECT 'kippcamden' AS [db_name]
      ,[abbreviation]
      ,[activecrslist]
      ,[address]
      ,[alternate_school_number]
      ,[countyname]
      ,[countynbr]
      ,[dcid]
      ,[dfltnextschool]
      ,[district_number]
      ,[fee_exemption_status]
      ,[high_grade]
      ,[hist_high_grade]
      ,[hist_low_grade]
      ,[id]
      ,[issummerschool]
      ,[low_grade]
      ,[name]
      ,[principal]
      ,[principalemail]
      ,[principalphone]
      ,[schedulewhichschool]
      ,[school_number]
      ,[schooladdress]
      ,[schoolcity]
      ,[schoolfax]
      ,[schoolgroup]
      ,[schoolinfo_guid]
      ,[schoolphone]
      ,[schoolstate]
      ,[schoolzip]
      ,[sortorder]
      ,[state_excludefromreporting]
      ,[tchrlogentrto]
      ,[view_in_portal]
FROM kippcamden.powerschool.schools
UNION ALL
SELECT 'kippmiami' AS [db_name]
      ,[abbreviation]
      ,[activecrslist]
      ,[address]
      ,[alternate_school_number]
      ,[countyname]
      ,[countynbr]
      ,[dcid]
      ,[dfltnextschool]
      ,[district_number]
      ,[fee_exemption_status]
      ,[high_grade]
      ,[hist_high_grade]
      ,[hist_low_grade]
      ,[id]
      ,[issummerschool]
      ,[low_grade]
      ,[name]
      ,[principal]
      ,[principalemail]
      ,[principalphone]
      ,[schedulewhichschool]
      ,[school_number]
      ,[schooladdress]
      ,[schoolcity]
      ,[schoolfax]
      ,[schoolgroup]
      ,[schoolinfo_guid]
      ,[schoolphone]
      ,[schoolstate]
      ,[schoolzip]
      ,[sortorder]
      ,[state_excludefromreporting]
      ,[tchrlogentrto]
      ,[view_in_portal]
FROM kippmiami.powerschool.schools
UNION ALL
SELECT 'kippnewark' AS [db_name]
      ,[abbreviation]
      ,[activecrslist]
      ,[address]
      ,[alternate_school_number]
      ,[countyname]
      ,[countynbr]
      ,[dcid]
      ,[dfltnextschool]
      ,[district_number]
      ,[fee_exemption_status]
      ,[high_grade]
      ,[hist_high_grade]
      ,[hist_low_grade]
      ,[id]
      ,[issummerschool]
      ,[low_grade]
      ,[name]
      ,[principal]
      ,[principalemail]
      ,[principalphone]
      ,[schedulewhichschool]
      ,[school_number]
      ,[schooladdress]
      ,[schoolcity]
      ,[schoolfax]
      ,[schoolgroup]
      ,[schoolinfo_guid]
      ,[schoolphone]
      ,[schoolstate]
      ,[schoolzip]
      ,[sortorder]
      ,[state_excludefromreporting]
      ,[tchrlogentrto]
      ,[view_in_portal]
FROM kippnewark.powerschool.schools;