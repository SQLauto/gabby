USE gabby
GO

ALTER VIEW extracts.gsheets_staff_roster AS

SELECT adp.associate_id
      ,adp.preferred_first AS preferred_first_name
      ,adp.preferred_last AS preferred_last_name
      ,CONCAT(adp.preferred_last, ', ', adp.preferred_first) AS preferred_lastfirst
      ,adp.location_description AS location
      ,adp.home_department_description AS department
      ,adp.job_title_description AS job_title 
      ,adp.reports_to_name AS reports_to
       
      ,dir.mail AS email_addr 
FROM gabby.adp.staff_roster adp
LEFT OUTER JOIN gabby.adsi.user_attributes dir
  ON adp.associate_id = dir.idautopersonalternateid
WHERE position_status != 'Terminated' 
  AND rn_curr = 1 