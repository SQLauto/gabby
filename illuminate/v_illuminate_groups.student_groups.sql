USE gabby
GO

CREATE OR ALTER VIEW illuminate_groups.student_groups AS
      
SELECT s.local_student_id
      
      ,g.group_id
      ,g.group_name
      
      ,aff.start_date
      ,aff.end_date
      ,aff.eligibility_start_date
      ,aff.eligibility_end_date
FROM gabby.illuminate_groups.group_student_aff aff
JOIN gabby.illuminate_groups.groups g
  ON aff.group_id = g.group_id
JOIN gabby.illuminate_public.students s
  ON aff.student_id = s.student_id
WHERE aff.start_date >= DATEFROMPARTS(gabby.utilities.GLOBAL_ACADEMIC_YEAR(), 7, 1)