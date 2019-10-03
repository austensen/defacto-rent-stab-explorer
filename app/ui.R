
ui <- basicPage(
  # All BBL Aggregate Info
  br(),
  downloadButton("download_all", "Download Entire Dataset"),
  DTOutput("all_bbl_agg_info_tbl"),
  
  # BBL Selector
  br(),
  textInput("bbl", "BBL", value = NULL),
  br(),
  
  # Single BBL Details Tables
  h2(textOutput("bbl_address")),
  detailsTableOutput("ecb_details_table", "ECB Violations"),
  detailsTableOutput("oath_details_table", "OATH Hearings"),
  detailsTableOutput("hpdvacate_details_table", "HPD Vacate Orders")
)
