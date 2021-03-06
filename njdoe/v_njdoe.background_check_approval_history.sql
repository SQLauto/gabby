USE gabby
GO

CREATE OR ALTER VIEW njdoe.background_check_approval_history AS

SELECT bg.df_employee_number
      ,bg.approval_history AS approval_history_json
      
      ,ah.approvaldate
      ,ah.countycode
      ,ah.districtcode
      ,ah.schoolcode
      ,CASE WHEN ah.contractorcode = '' THEN NULL ELSE ah.contractorcode END AS contractorcode
      ,ah.jobposition
      ,CONVERT(BIGINT,CONVERT(FLOAT,CASE WHEN ah.pcn != '' THEN ah.pcn END)) AS pcn
      ,CASE WHEN ah.transferind = '' THEN NULL ELSE ah.transferind END AS transferind
FROM gabby.njdoe.background_check_clean bg
CROSS APPLY OPENJSON(bg.approval_history, '$')
  WITH (
    approvaldate DATETIME2,
    countycode VARCHAR(5),
    districtcode VARCHAR(5),
    schoolcode VARCHAR(5),
    contractorcode VARCHAR(5),
    jobposition VARCHAR(125),
    pcn VARCHAR(25),
    transferind DATETIME2
   ) AS ah
WHERE bg.approval_history != '[]'