# These two functions create a Shiny Module for creating the details tables for a given datset
# http://shiny.rstudio.com/articles/modules.html

# Module UI function
detailsTableOutput <- function(id, dataset_name) {
  # Create a namespace function using the provided id
  ns <- NS(id)
  
  tagList(
    h3(dataset_name),
    downloadButton(ns("details_download"), glue("Download All {dataset_name} for this Property")),
    DTOutput(ns("details_table"))
  )
}

# Module server function
detailsTable <- function(input, output, session, 
                         .con, 
                         selected_bbl, 
                         details_col, 
                         download_file_slug, 
                         dataset_name) {

  # Retrieve a set of details for a bbl
  details_data <- reactive({
    req(selected_bbl)
    
    # Expanding json array column - see TMiguelT's answer to 
    # https://www.reddit.com/r/PostgreSQL/comments/2u6ah3/how_to_use_json_to_recordset_on_json_stored_in_a/
    query <- glue(
      "SELECT
      	x.bbl,
      	x.address,
      	y.*
      FROM defacto_bk_bbl_details AS x
      CROSS JOIN LATERAL
      	json_to_recordset(x.{col}) as 
      	y({layout})
      WHERE bbl = {bbl}",
      bbl = dbQuoteString(.con, selected_bbl()),
      col = dbQuoteIdentifier(.con, details_col),
      layout = details_layout(details_col)
    )
    
    dbGetQuery(.con, query)
  })
  
  
  output$details_table = renderDT(
    details_data()[-c(1:2)], # remove bbl and address cols
    selection = "none",
    callback = JS(header_tooltip_js(details_col)), # see /tool_tips.R
    options = list(
      dom = 'Brtip',
      language = list(zeroRecords = glue("No data on {dataset_name} for this property")),
      scrollX = TRUE
    )
  )
  
  output$details_download <- downloadHandler(
    filename = function() {
      glue("{selected_bbl()}_{download_file_slug}_{Sys.Date()}.csv")
    },
    content = function(file) {
      write.csv(details_data(), file, na = "")
    }
  )
  
}

details_layout <- function(name = c("ecb_details", "oath_details", "hpdvacate_details")) {
  name <- match.arg(name)
  switch(name,
    ecb_details = "
      ecb_owner_in_building text,
      ecb_owner_address text,
      ecb_violation_status text,
      ecb_hearing_status text,
      ecb_issue_date date,
      ecb_hearing_date date,
      ecb_served_date date,
      ecb_violation_description text",
    oath_details = "
      oath_owner_in_building text,
      oath_owner_address text,
      oath_violation_date date,
      oath_hearing_status text,
      oath_hearing_result text",
    hpdvacate_details = "
      hpdvacate_primary_reason text,
      hpdvacate_effective_date date,
      hpdvacate_rescind_date date,
      hpdvacate_vacate_type text,
      hpdvacate_units_vacated integer"
  )
}
