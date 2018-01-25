USE gabby
GO

CREATE OR ALTER VIEW powerschool.spenrollments_gen AS

SELECT CONVERT(INT,sp.studentid) AS studentid
      ,sp.dcid
      ,sp.enter_date
      ,sp.exit_date
      ,sp.id
      ,sp.exitcode
      ,CONVERT(INT,sp.programid) AS programid
      ,sp.sp_comment
      ,sp.gradelevel
      ,CASE
        WHEN DATEPART(MONTH,sp.enter_date) < 7 THEN (DATEPART(YEAR,sp.enter_date) - 1) 
        ELSE DATEPART(YEAR,sp.enter_date) 
       END AS academic_year

      ,gen.name AS specprog_name
FROM powerschool.spenrollments sp
JOIN powerschool.gen
  ON sp.programid = gen.id
 AND gen.cat = 'specprog'