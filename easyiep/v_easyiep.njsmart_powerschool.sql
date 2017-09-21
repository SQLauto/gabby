USE gabby
GO

CREATE OR ALTER VIEW easyiep.njsmart_powerschool AS

SELECT [student_number]
      ,[state_studentnumber]
      ,[first_name]
      ,[last_name]      
      ,[nj_se_parental_consentobtained]
      ,[nj_se_delayreason]
      ,[nj_se_placement]
      ,[nj_timeinregularprogram]
      ,[ti_serv_counseling]
      ,[ti_serv_occup]
      ,[ti_serv_physical]
      ,[ti_serv_speech]
      ,[ti_serv_other]
      ,[special_education]      
      
      ,academic_year
      ,CONVERT(DATE,[dob]) AS dob
      ,CONVERT(DATE,[nj_se_referraldate]) AS nj_se_referraldate
      ,CONVERT(DATE,[nj_se_parentalconsentdate]) AS nj_se_parentalconsentdate
      ,CONVERT(DATE,[nj_se_eligibilityddate]) AS nj_se_eligibilityddate
      ,CONVERT(DATE,[nj_se_initialiepmeetingdate]) AS nj_se_initialiepmeetingdate
      ,CONVERT(DATE,[nj_se_consenttoimplementdate]) AS nj_se_consenttoimplementdate
      ,CONVERT(DATE,[nj_se_lastiepmeetingdate]) AS nj_se_lastiepmeetingdate
      ,CONVERT(DATE,[nj_se_reevaluationdate]) AS nj_se_reevaluationdate

      ,CASE
        WHEN [special_education] = '17' THEN 'SPED SPEECH'
        WHEN [special_education] IN ('00','99') THEN NULL
        WHEN special_education IS NULL THEN NULL
        ELSE 'SPED'
       END AS spedlep
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
FROM
    (
     SELECT e.[student_number]
           ,e.[state_studentnumber]
           ,e.[first_name]
           ,e.[last_name]
           ,e.[dob]
           ,e.[nj_se_referraldate]
           ,e.[nj_se_parentalconsentdate]
           ,e.[nj_se_eligibilityddate]
           ,e.[nj_se_initialiepmeetingdate]
           ,e.[nj_se_parental_consentobtained]
           ,e.[nj_se_consenttoimplementdate]
           ,e.[nj_se_lastiepmeetingdate]           
           ,e.[nj_se_reevaluationdate]
           ,e.[nj_se_delayreason]
           ,e.[nj_se_placement]
           ,e.[nj_timeinregularprogram]
           ,e.[ti_serv_counseling]
           ,e.[ti_serv_occup]
           ,e.[ti_serv_physical]
           ,e.[ti_serv_speech]
           ,e.[ti_serv_other]
           ,RIGHT('0' + CONVERT(NVARCHAR,e.[special_education]), 2) AS [special_education]
           ,CASE 
             WHEN PATINDEX('%_[0-9]%', e._file) = 0 THEN gabby.utilities.GLOBAL_ACADEMIC_YEAR()
             ELSE SUBSTRING(e._file, PATINDEX('%_[0-9]%', e._file) + 1, 4)
            END AS academic_year

           ,ROW_NUMBER() OVER(
              PARTITION BY e.student_number, CASE 
                                              WHEN PATINDEX('%_[0-9]%', e._file) = 0 THEN gabby.utilities.GLOBAL_ACADEMIC_YEAR()
                                              ELSE SUBSTRING(e._file, PATINDEX('%_[0-9]%', e._file) + 1, 4)
                                             END
                ORDER BY [special_education] DESC) AS rn
     FROM [gabby].[easyiep].[njsmart_powerschool_kcna] e
     JOIN gabby.powerschool.students s
       ON e.student_number = s.student_number
      AND s.schoolid LIKE '1799%'

     UNION ALL

     SELECT e.[student_number]
           ,e.[state_studentnumber]
           ,e.[first_name]
           ,e.[last_name]
           ,e.[dob]
           ,e.[nj_se_referraldate]
           ,e.[nj_se_parentalconsentdate]
           ,e.[nj_se_eligibilityddate]
           ,e.[nj_se_initialiepmeetingdate]
           ,e.[nj_se_parental_consentobtained]
           ,e.[nj_se_consenttoimplementdate]
           ,e.[nj_se_lastiepmeetingdate]           
           ,e.[nj_se_reevaluationdate]
           ,e.[nj_se_delayreason]
           ,e.[nj_se_placement]
           ,e.[nj_timeinregularprogram]
           ,e.[ti_serv_counseling]
           ,e.[ti_serv_occup]
           ,e.[ti_serv_physical]
           ,e.[ti_serv_speech]
           ,e.[ti_serv_other]
           ,RIGHT('0' + CONVERT(NVARCHAR,e.[special_education]), 2) AS [special_education]
           ,CASE 
             WHEN PATINDEX('%_[0-9]%', e._file) = 0 THEN gabby.utilities.GLOBAL_ACADEMIC_YEAR()
             ELSE SUBSTRING(e._file, PATINDEX('%_[0-9]%', e._file) + 1, 4)
            END AS academic_year
           
           ,ROW_NUMBER() OVER(
              PARTITION BY e.student_number, CASE 
                                              WHEN PATINDEX('%_[0-9]%', e._file) = 0 THEN gabby.utilities.GLOBAL_ACADEMIC_YEAR()
                                              ELSE SUBSTRING(e._file, PATINDEX('%_[0-9]%', e._file) + 1, 4)
                                             END
                ORDER BY [special_education] DESC) AS rn
     FROM [gabby].[easyiep].[njsmart_powerschool_team] e
     JOIN gabby.powerschool.students s
       ON e.student_number = s.student_number
      AND s.schoolid NOT LIKE '1799%'
    ) sub
WHERE rn = 1