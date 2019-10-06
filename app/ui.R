
ui <- navbarPage(
  title = "Defacto Rent Stabilized Properties Explorer",
  id = "inTabset",
  
  tabPanel(
    title = "Properites Overview",
    value = "overviewTab",
    
    # All BBL Aggregate Info
    downloadButton("download_all", "Download Entire Dataset"),
    DTOutput("all_bbl_agg_info_tbl")
  ),
  
  tabPanel(
    title = "Property Details",
    value = "detailsTab",
    
    # BBL Selector
    textInput("bbl", "Enter a BBL or choose one from Propertries Overview", value = NULL, width = "400px"),
    
    # Single BBL Tables
    h2(textOutput("bbl_address")),
    h3("Overview"),
    DTOutput("single_bbl_agg_info_tbl"),
    detailsTableOutput("ecb_details_table", "ECB Violations"),
    detailsTableOutput("oath_details_table", "OATH Hearings"),
    detailsTableOutput("hpdvacate_details_table", "HPD Vacate Orders")
  ),
  
  tabPanel(
    title = "About",
    value = "aboutTab",
    
    includeMarkdown("about.md")
  )
  
)
