USE gabby
GO

ALTER VIEW powerschool.gradebook_assignments_scores WITH SCHEMABINDING AS

SELECT s.student_number
      
      ,a.scorepoints
      ,a.islate
      ,a.isexempt
      ,a.ismissing
      ,a.assignmentsectionid
      
      ,asec.assignmentid       
      ,asec.sectionsdcid
FROM powerschool.assignmentscore a
JOIN powerschool.students s
  ON a.studentsdcid = s.dcid
JOIN powerschool.assignmentsection asec
  ON a.assignmentsectionid = asec.assignmentsectionid    