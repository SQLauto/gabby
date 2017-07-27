USE gabby
GO

ALTER VIEW easyiep.njsmart_powerschool AS

SELECT [student_number]
      ,[state_studentnumber]
      ,[first_name]
      ,[last_name]
      ,[dob]
      ,[nj_se_referraldate]
      ,[nj_se_parentalconsentdate]
      ,[nj_se_eligibilityddate]
      ,[nj_se_initialiepmeetingdate]
      ,[nj_se_parental_consentobtained]
      ,[nj_se_consenttoimplementdate]
      ,[nj_se_lastiepmeetingdate]
      ,RIGHT('0' + CONVERT(VARCHAR,[special_education]), 2) AS [special_education]
      ,CASE 
        WHEN special_education = 1 THEN 'AI'
        WHEN special_education = 2 THEN 'AUT'
        WHEN special_education = 3 THEN 'CMI'
        WHEN special_education = 4 THEN 'CMO'
        WHEN special_education = 5 THEN 'CSE'
        WHEN special_education = 6 THEN 'CI'
        WHEN special_education = 7 THEN 'ED'
        WHEN special_education = 8 THEN 'MD'
        WHEN special_education = 9 THEN 'DB'
        WHEN special_education = 10 THEN 'OI'
        WHEN special_education = 11 THEN 'OHI'
        WHEN special_education = 12 THEN 'PSD'
        WHEN special_education = 13 THEN 'SM'
        WHEN special_education = 14 THEN 'SLD'
        WHEN special_education = 15 THEN 'TBI'
        WHEN special_education = 16 THEN 'VI'
        WHEN special_education = 17 THEN 'ESLS'
        WHEN special_education = 99 THEN '99'
        WHEN special_education = 0 THEN '00'
       END AS special_education_code
      ,[nj_se_reevaluationdate]
      ,[nj_se_delayreason]
      ,[nj_se_placement]
      ,[nj_timeinregularprogram]
      ,[ti_serv_counseling]
      ,[ti_serv_occup]
      ,[ti_serv_physical]
      ,[ti_serv_speech]
      ,[ti_serv_other]
      ,CASE 
        WHEN PATINDEX('%_[0-9]%',_file) = 0 THEN gabby.utilities.GLOBAL_ACADEMIC_YEAR()
        ELSE SUBSTRING(_file, PATINDEX('%_[0-9]%',_file) + 1, 4)
       END AS academic_year
      ,CASE
        WHEN [special_education] = 17 THEN 'SPED SPEECH'
        WHEN [special_education] IN (0,99) THEN NULL
        WHEN special_education IS NULL THEN NULL
        ELSE 'SPED'
       END AS spedlep
FROM [gabby].[easyiep].[njsmart_powerschool_kcna]

UNION ALL

SELECT [student_number]
      ,[state_studentnumber]
      ,[first_name]
      ,[last_name]
      ,[dob]
      ,[nj_se_referraldate]
      ,[nj_se_parentalconsentdate]
      ,[nj_se_eligibilityddate]
      ,[nj_se_initialiepmeetingdate]
      ,[nj_se_parental_consentobtained]
      ,[nj_se_consenttoimplementdate]
      ,[nj_se_lastiepmeetingdate]
      ,RIGHT('0' + CONVERT(VARCHAR,[special_education]), 2) AS [special_education]
      ,CASE 
        WHEN special_education = '1' THEN 'AI'
        WHEN special_education = '2' THEN 'AUT'
        WHEN special_education = '3' THEN 'CMI'
        WHEN special_education = '4' THEN 'CMO'
        WHEN special_education = '5' THEN 'CSE'
        WHEN special_education = '6' THEN 'CI'
        WHEN special_education = '7' THEN 'ED'
        WHEN special_education = '8' THEN 'MD'
        WHEN special_education = '9' THEN 'DB'
        WHEN special_education = '10' THEN 'OI'
        WHEN special_education = '11' THEN 'OHI'
        WHEN special_education = '12' THEN 'PSD'
        WHEN special_education = '13' THEN 'SM'
        WHEN special_education = '14' THEN 'SLD'
        WHEN special_education = '15' THEN 'TBI'
        WHEN special_education = '16' THEN 'VI'
        WHEN special_education = '17' THEN 'ESLS'
        WHEN special_education = '99' THEN '99'
        WHEN special_education = '0' THEN '00'
       END AS special_education_code
      ,[nj_se_reevaluationdate]
      ,[nj_se_delayreason]
      ,[nj_se_placement]
      ,[nj_timeinregularprogram]
      ,[ti_serv_counseling]
      ,[ti_serv_occup]
      ,[ti_serv_physical]
      ,[ti_serv_speech]
      ,[ti_serv_other]
      ,CASE 
        WHEN PATINDEX('%_[0-9]%',_file) = 0 THEN gabby.utilities.GLOBAL_ACADEMIC_YEAR()
        ELSE SUBSTRING(_file, PATINDEX('%_[0-9]%',_file) + 1, 4)
       END AS academic_year
      ,CASE
        WHEN [special_education] = '17' THEN 'SPED SPEECH'
        WHEN [special_education] IN ('0','99') THEN NULL
        WHEN special_education IS NULL THEN NULL
        ELSE 'SPED'
       END AS spedlep
FROM [gabby].[easyiep].[njsmart_powerschool_team]