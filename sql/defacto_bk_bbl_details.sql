DROP MATERIALIZED VIEW IF EXISTS defacto_bk_bbl_details;
CREATE MATERIALIZED VIEW IF NOT EXISTS defacto_bk_bbl_details AS (
	SELECT 
		p.bbl,
		(p.address || ', ' || p.borough || ', NY ' || p.zipcode) AS address,
		p.unitsres AS residential_units,

		coalesce(hpd_cv.hpd_complaint_count, 0) AS hpd_complaint_count,
		coalesce(hpd_cv.hpd_violation_count, 0) AS hpd_violation_count,
		hpd_cv.hpd_comp_or_viol_apt,

		-- TODO: make a column with a single value for bbl for indicator of 
		-- owner_in_building by looking in all the details.

		coalesce(json_array_length(ecb.ecb_details), 0) as ecb_violation_count,
		ecb.ecb_details,

		-- TODO: figure out dob_complaints, see below

		coalesce(json_array_length(oath.oath_details), 0) as oath_hearing_count,
		oath.oath_details,

		coalesce(json_array_length(hpdvacate.hpdvacate_details), 0) as hpd_vacate_order_count,
		hpdvacate.hpdvacate_details
	FROM pluto_18v2 AS p
	LEFT JOIN LATERAL (
		-- For each BBL get an indicator of the presence of any ECB violations for
		-- illegal residential conversions, and all relevant details of the violation.
		SELECT
			array_to_json(array_agg(row_to_json(ecb_inner))) AS ecb_details
		FROM (
			SELECT
				CASE 
					WHEN p.address = (respondenthousenumber || ' ' || respondentstreet)
						THEN 'YES'
					ELSE 'UNSURE'
				END AS ecb_owner_in_building,
				(respondenthousenumber || ' ' || respondentstreet) AS ecb_owner_address,
				ecbviolationstatus AS ecb_violation_status,
				hearingstatus AS ecb_hearing_status,
				issuedate AS ecb_issue_date,
				hearingdate AS ecb_hearing_date,
				serveddate AS ecb_served_date,
				violationdescription AS ecb_violation_description
			FROM ecb_violations
			WHERE
				bbl = p.bbl AND -- test bbl: '1000300034'
				( -- NYC Law 28-210.1 Illegal residential conversions.
					sectionlawdescription1	~ '(^|\D)28-210\.1(\D|$)' OR
					sectionlawdescription2	~ '(^|\D)28-210\.1(\D|$)' OR
					sectionlawdescription3	~ '(^|\D)28-210\.1(\D|$)' OR
					sectionlawdescription4	~ '(^|\D)28-210\.1(\D|$)' OR
					sectionlawdescription5	~ '(^|\D)28-210\.1(\D|$)' OR
					sectionlawdescription6	~ '(^|\D)28-210\.1(\D|$)' OR
					sectionlawdescription7	~ '(^|\D)28-210\.1(\D|$)' OR
					sectionlawdescription8	~ '(^|\D)28-210\.1(\D|$)' OR
					sectionlawdescription9	~ '(^|\D)28-210\.1(\D|$)' OR
					sectionlawdescription10 ~ '(^|\D)28-210\.1(\D|$)'
				)
		) as ecb_inner
	) AS ecb ON true
	-- TODO: bbl is missing from dob_complaints, it only has bin, so 
	-- would need to first join in BBL from the pad table
	/* 
	LEFT JOIN LATERAL (

		-- For each BBL get an indicator of the presence of any DOB complaints for 
		-- illegal units, and all relevant details of the complaint.
		SELECT
			true AS dob_complaint,
			-- count(*) OVER() AS dob_complaint_count,
			status AS dob_complaint_status,
			inspectiondate AS dob_complaint_inspection_date,
			dispositiondate AS dob_complaint_disposition_date
		FROM dob_complaints
		WHERE
			bbl = p.bbl AND
			complaintcategory = '71' -- "SRO – Illegal Work/No Permit/Change In Occupancy Use"
	) AS dob_c ON true
	*/
	LEFT JOIN LATERAL (
		-- For each BBL get an indicator of the presence of any OATH hearings for
		-- illegal residential conversions, and all relevant details of the hearing.
		SELECT
			array_to_json(array_agg(row_to_json(oath_inner))) AS oath_details
		FROM (
			SELECT
				CASE
					WHEN violationlocationborough <> respondentaddressborough 
						THEN 'NO'
					WHEN violationlocationhouse = respondentaddresshouse AND violationlocationstreetname = respondentaddressstreetname 
						THEN 'YES'
					WHEN violationlocationhouse <> respondentaddresshouse AND violationlocationstreetname = respondentaddressstreetname 
						THEN 'SAME STREET'
					ELSE 'NO'
				END AS oath_owner_in_building,
				-- TODO: With some cleaning of the street name this could be better (eg. ST to STREET)
				(respondentaddresshouse || ' ' || respondentaddressstreetname) AS oath_owner_address,
				nullif(violationdate, '9999-12-31') AS oath_violation_date,
				hearingstatus AS oath_hearing_status,
				hearingresult AS oath_hearing_result
			FROM oath_hearings
			WHERE
				bbl = p.bbl AND -- test bbl: '2033040035'
				violationdetails ~ '(^|\D)28-210\.1(\D|$)' -- NYC Law 28-210.1 Illegal residential conversions.
			) as oath_inner
	) AS oath ON true
	LEFT JOIN LATERAL (
		-- For each BBL get an indicator of the presence of any HPD complaints or 
		-- violations, and a list of all apartment numbers if available.
		SELECT
			true AS hpd_comp_or_viol,
			MAX(hpd_complaint_count) AS hpd_complaint_count,
			MAX(hpd_violation_count) AS hpd_violation_count,
			array_to_string(array_agg(DISTINCT apartment), ', ') AS hpd_comp_or_viol_apt
		FROM (
			SELECT 
				apartment,
				count(*) OVER() AS hpd_complaint_count,
				NULL AS hpd_violation_count
			FROM hpd_complaints
			WHERE bbl = p.bbl
			UNION ALL
			SELECT 
				apartment,
				NULL AS hpd_complaint_count,
				count(*) OVER() AS hpd_violation_count
			FROM hpd_violations
			WHERE bbl = p.bbl
		) AS cv
	) AS hpd_cv ON true
	LEFT JOIN LATERAL (
		-- For each BBL get an indicator of the presence of any HPD Vacate Orders 
		-- and all relevant details of the orders.
		SELECT
			array_to_json(array_agg(row_to_json(hpdvacate_inner))) AS hpdvacate_details
		FROM (
			SELECT
				primaryvacatereason AS hpdvacate_primary_reason,
				vacateeffectivedate AS hpdvacate_effective_date,
				rescinddate AS hpdvacate_rescind_date,
				numberofvacatedunits AS hpdvacate_units_vacated
			FROM hpd_vacateorders
			WHERE bbl = p.bbl -- test bbl: '3012090052'
			) as hpdvacate_inner
	) AS hpdvacate ON true
	WHERE 
		p.bbl ~ '^3' AND
		p.unitsres between 1 and 5 AND
		(
			json_array_length(ecb.ecb_details) > 0 OR 
			json_array_length(oath.oath_details) > 0
		)
	ORDER BY p.bbl
);
