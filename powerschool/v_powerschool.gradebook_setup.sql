CREATE OR ALTER VIEW powerschool.gradebook_setup AS

WITH default_gfs AS (
  SELECT gfs.gradeformulasetid	        
        ,gfs.yearid  
        ,gfs.name

        ,gct.abbreviation
        ,gct.storecode
        ,gct.gradecalculationtypeid
        ,gct.type
        
        ,sch.school_number
  FROM powerschool.gradeformulaset gfs 
  JOIN powerschool.gradecalculationtype gct 
    ON gfs.gradeformulasetid = gct.gradeformulasetid
  JOIN powerschool.gradecalcschoolassoc gcsa 
    ON gct.gradecalculationtypeid = gcsa.gradecalculationtypeid
  JOIN powerschool.schools sch 
    ON gcsa.schoolsdcid = sch.dcid
  WHERE gfs.sectionsdcid IS NULL
    AND ((gfs.name IN ('KNJ Middle Schools', 'Middle school') AND sch.high_grade = 8)
         OR (gfs.name IN ('KNJ High Schools') AND sch.high_grade = 12))
 )
    
SELECT CONVERT(INT,sectionsdcid) AS sectionsdcid
      ,CONVERT(INT,sectionsdcid) AS psm_sectionid                
      ,CONVERT(INT,ISNULL(gradeformulasetid, 0)) AS finalgradesetupid
      ,CONVERT(VARCHAR(25),gct_type) AS finalgradesetuptype        
      ,CONVERT(INT,gradecalculationtypeid) AS fg_reportingtermid
      ,CONVERT(VARCHAR(5),storecode) AS reportingterm_name
      ,date_1 AS startdate
      ,date_2 AS enddate
      ,CONVERT(INT,ISNULL(gradecalcformulaweightid, gradecalculationtypeid)) AS gradingformulaid
      ,CONVERT(VARCHAR(25),ISNULL(gcfw_type, gct_type)) AS gradingformulaweightingtype
      ,weight AS weighting
                
      ,CONVERT(INT,COALESCE(districtteachercategoryid, teachercategoryid, gradecalculationtypeid)) AS assignmentcategoryid
      ,CONVERT(VARCHAR(125),COALESCE(dtc_name, tc_name, gct_type)) AS category_name
      ,CONVERT(VARCHAR(125),COALESCE(dtc_name, tc_name, gct_type)) AS category_abbreviation
      ,CONVERT(INT,COALESCE(dtc_defaultscoretype, tc_defaultscoretype)) AS defaultscoretype
      ,CONVERT(INT,COALESCE(dtc_isinfinalgrades, tc_isinfinalgrades, 1)) AS includeinfinalgrades
FROM
    (
     SELECT sec.dcid AS sectionsdcid        
           ,sec.schoolid

           ,tb.storecode
           ,tb.date_1
           ,tb.date_2

           ,COALESCE(gfs.gradeformulasetid, d.gradeformulasetid) AS gradeformulasetid
           ,COALESCE(gct.gradecalculationtypeid, d.gradecalculationtypeid) AS gradecalculationtypeid
           ,COALESCE(gct.type, d.type) AS gct_type       

           ,gcfw.gradecalcformulaweightid
           ,gcfw.teachercategoryid
           ,gcfw.districtteachercategoryid
           ,gcfw.weight
           ,gcfw.type AS gcfw_type        
        
           ,tc.teachermodified
           ,tc.name AS tc_name
           ,tc.defaultscoretype AS tc_defaultscoretype
           ,tc.isinfinalgrades AS tc_isinfinalgrades

           ,dtc.name AS dtc_name
           ,dtc.defaultscoretype AS dtc_defaultscoretype
           ,dtc.isinfinalgrades AS dtc_isinfinalgrades                
     FROM powerschool.sections sec 
     JOIN powerschool.terms rt 
       ON sec.termid = rt.id
      AND sec.schoolid = rt.schoolid
     JOIN powerschool.termbins tb 
       ON rt.schoolid = tb.schoolid
      AND rt.id = tb.termid
     JOIN default_gfs d
       ON sec.schoolid = d.school_number
      AND sec.yearid = d.yearid
      AND rt.abbreviation = d.abbreviation
      AND tb.storecode = d.storecode      
     LEFT JOIN powerschool.gradeformulaset gfs 
       ON sec.dcid = gfs.sectionsdcid         
     LEFT JOIN powerschool.gradecalculationtype gct 
       ON gfs.gradeformulasetid = gct.gradeformulasetid    
      AND tb.storecode = gct.storecode 
     LEFT JOIN powerschool.gradecalcformulaweight gcfw 
       ON COALESCE(gct.gradecalculationtypeid, d.gradecalculationtypeid) = gcfw.gradecalculationtypeid
     LEFT JOIN powerschool.teachercategory tc 
       ON gcfw.teachercategoryid = tc.teachercategoryid 
     LEFT JOIN powerschool.districtteachercategory dtc 
       ON gcfw.districtteachercategoryid = dtc.districtteachercategoryid
     WHERE sec.gradebooktype = 2
    ) sub