USE gabby
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER FUNCTION utilities.GLOBAL_ACADEMIC_YEAR()
    RETURNS INT
  AS

BEGIN		

  RETURN 2017

END

GO
