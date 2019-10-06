# Column descriptions to appear in toolip
# https://stackoverflow.com/a/31508033/7051239

header_tooltip_js <- function(table = c("bbl_agg", "ecb_details", "oath_details", "hpdvacate_details")) {
  table <- match.arg(table)
  
  tips <- switch(table, 
    bbl_agg = bbl_tips, 
    ecb_details = ecb_tips, 
    oath_details = oath_tips, 
    hpdvacate_details = hpdvacate_tips
  )
  
  tips_list <- glue_collapse(glue("'{tips}'"), sep = ", ")
  
  glue("
  var tips = [{tips_list}],
  header = table.columns().header();
  for (var i = 0; i < tips.length; i++) {{
    $(header[i]).attr('title', tips[i]);
  }}")
}

bbl_tips <- c(
  "", # frist column has row numbers, and we don't include them
	bbl = "Borough-Block-Lot property ID",
	address = "Property Address",
	residential_units = "Official number of residential units in property",
	hpd_complaint_count = "Number of HPD complaints since 2013",
	hpd_violation_count = "Number of HPD violations since 2012",
	hpd_comp_or_viol_apt = "All apartment numbers associated with HPD complaints and violations",
	ecb_violation_count = "Number of DOB ECB violations for illegal units",
	oath_hearing_count = "Number of OATH hearings for illegal units",
	dob_vacate_complaint_latest = "The date of the most recent DOB vacate order, if available",
	hpd_vacate_order_count = "The number of HPD vacate orders"
)

ecb_tips <- c(
  "", # frist column has row numbers, and we don't include them
	ecb_owner_in_building = "Whether the owner address is the same as the property",
	ecb_owner_address = "The owner address",
	ecb_violation_status = "Whether the violation is active or resolved",
	ecb_hearing_status = "The current status of the hearing (in violation, dismissed, pending, etc.)",
	ecb_issue_date = "Date that the violation was issued",
	ecb_hearing_date = "Date of the latest scheduled hearing for the respondent named on the violation to admit to it or contest the violation",
	ecb_served_date = "Date that the violation was served to the respondent",
	ecb_violation_description = "Comments from the ECB inspector who issued the violation"
)

oath_tips <- c(
  "", # frist column has row numbers, and we don't include them
	oath_owner_in_building = "Whether the owner address is the same as the property",
	oath_owner_address = "The owner address",
	oath_violation_date = "The date on which the alleged violation indicated on the summons occurred",
	oath_hearing_status = "Hearing status (paid in full, stayed, stipulation offered, etc.)",
	oath_hearing_result = "Outcome or result of the hearing (in violation, default, dismissed, etc.)"
)

hpdvacate_tips <- c(
  "", # frist column has row numbers, and we don't include them
	hpdvacate_primary_reason = "Primary reason the unit/building is vacated",
	hpdvacate_effective_date = "The date the Order to Repair/Vacate Order was made effective",
	hpdvacate_rescind_date = "The date the Order to Repair/Vacate Order was rescinded",
	hpdvacate_vacate_type = "Area affected by the vacate (Entire Building or Partial)",
	hpdvacate_units_vacated = "Number of units vacated"
)
