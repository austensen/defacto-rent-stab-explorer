library(DT)

ui <- basicPage(
  # All BBL Aggregate Info
  br(),
  downloadButton("download_all", "Download Entire Dataset"),
  DTOutput("all_bbl_agg_info_tbl"),
  
  br(),
  textInput("bbl", "BBL", value = NULL),
  br(),
  
  # Single BBL Details
  h2(textOutput("bbl_address")),
  
  h3("ECB Violation Details"),
  downloadButton("download_ecb", "Download All ECB Violation Details for this Property"),
  DTOutput("ecb_details_tbl"),
  br(),
  
  h3("OATH Hearing Details"),
  downloadButton("download_oath", "Download All OATH Hearing Details for this Property"),
  DTOutput("oath_details_tbl"),
  br()
)
