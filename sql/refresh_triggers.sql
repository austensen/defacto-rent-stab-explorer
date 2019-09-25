-- If you want to make sure that the data for the app stays up to date with 
-- changes to the underlying nycdb tables you can set up triggers to 
-- refresh the materialized view used by the app.

CREATE OR REPLACE FUNCTION refresh_defacto_bk_bbl_details() 
RETURNS TRIGGER LANGUAGE plpgsql 
AS $$ 
BEGIN 
	REFRESH MATERIALIZED VIEW defacto_bk_bbl_details; 
	RETURN NULL; 
END $$;


CREATE TRIGGER refresh_defacto_bk_bbl_details 
AFTER INSERT OR UPDATE OR DELETE OR TRUNCATE 
ON ecb_violations FOR EACH STATEMENT 
EXECUTE PROCEDURE refresh_defacto_bk_bbl_details();


CREATE TRIGGER refresh_defacto_bk_bbl_details 
AFTER INSERT OR UPDATE OR DELETE OR TRUNCATE 
ON oath_hearings FOR EACH STATEMENT 
EXECUTE PROCEDURE refresh_defacto_bk_bbl_details();


CREATE TRIGGER refresh_defacto_bk_bbl_details 
AFTER INSERT OR UPDATE OR DELETE OR TRUNCATE 
ON hpd_complaints 
FOR EACH STATEMENT EXECUTE PROCEDURE refresh_defacto_bk_bbl_details();
