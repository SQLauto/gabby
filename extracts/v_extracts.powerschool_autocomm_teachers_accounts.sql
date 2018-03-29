USE gabby
GO

CREATE OR ALTER VIEW extracts.powerschool_autocomm_teachers_accounts AS

SELECT sub.teachernumber
      ,sub.first_name
      ,sub.last_name
      ,CASE WHEN sub.status = 1 THEN sub.loginid END AS loginid
      ,CASE WHEN sub.status = 1 THEN sub.teacherloginid END AS teacherloginid
      ,sub.email_addr
      ,CONVERT(INT,COALESCE(t.schoolid, sub.homeschoolid, 0)) AS schoolid
      ,CONVERT(INT,COALESCE(t.homeschoolid, sub.homeschoolid, 0)) AS homeschoolid
      ,sub.status      
      ,CASE WHEN sub.status = 1 THEN 1 ELSE 0 END AS teacherldapenabled
      ,CASE WHEN sub.status = 1 THEN 1 ELSE 0 END AS adminldapenabled      
      ,CASE WHEN sub.status = 1 THEN 1 ELSE 0 END AS ptaccess            
FROM
    (
     SELECT COALESCE(psid.ps_teachernumber, df.adp_associate_id) AS teachernumber
           ,df.preferred_first_name AS first_name
           ,df.preferred_last_name AS last_name
           ,df.primary_site_schoolid AS homeschoolid
           
           ,LOWER(dir.samaccountname) AS loginid
           ,LOWER(dir.samaccountname) AS teacherloginid
           ,LOWER(dir.mail) AS email_addr
           
           ,CASE
             WHEN psid.is_master = 0 THEN 2
             WHEN df.termination_date < GETDATE() THEN 2
             WHEN df.primary_job = 'Intern' THEN 2
             WHEN df.status IN ('ACTIVE','INACTIVE') OR df.termination_date >= CONVERT(DATE,GETDATE()) THEN 1
             ELSE 2
            END AS status
     FROM gabby.dayforce.staff_roster df
     LEFT JOIN gabby.adsi.user_attributes_static dir
       ON df.adp_associate_id = dir.idautopersonalternateid
      AND dir.is_active = 1
     LEFT JOIN gabby.people.id_crosswalk_powerschool psid
       ON df.adp_associate_id = psid.adp_associate_id
     WHERE df.primary_on_site_department != 'Data'
    ) sub
LEFT JOIN gabby.powerschool.teachers t
  ON sub.teachernumber = t.teachernumber