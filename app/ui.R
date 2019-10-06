
ui <- navbarPage(
  title = "Defacto Rent Stabilized Properties Explorer",
  
  tabPanel(
    "Properites Overview",
    
    # All BBL Aggregate Info
    downloadButton("download_all", "Download Entire Dataset"),
    DTOutput("all_bbl_agg_info_tbl")
  ),
  
  tabPanel(
    "Property Details",
    
    # BBL Selector
    textInput("bbl", "Enter a BBL or choose one from Propertries Overview", value = NULL, width = "400px"),
    
    # Single BBL Details Tables
    h2(textOutput("bbl_address")),
    detailsTableOutput("ecb_details_table", "ECB Violations"),
    detailsTableOutput("oath_details_table", "OATH Hearings"),
    detailsTableOutput("hpdvacate_details_table", "HPD Vacate Orders")
  ),
  
  tabPanel(
    "About",
    
    includeMarkdown("about.md")
  )
  
)
