USE gabby;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER FUNCTION utilities.GLOBAL_ACADEMIC_YEAR()
  RETURNS INT
  WITH SCHEMABINDING
AS

BEGIN

  RETURN 2017;

END;

GO

