
server <- function(input, output, session) {

  # Aggregate BBL Info ------------------------------------------------------
  
  # add button to table: https://stackoverflow.com/a/45739826/7051239 
  all_bbl_agg_info <- dbGetQuery(con, '
    SELECT
      bbl,
      format(\'<button id="button_%1$s" type="button" class="btn btn-default action-button" 
        onclick="Shiny.onInputChange(&quot;bbl_button&quot;, this.id)">%1$s</button>\', bbl) AS bbl_link,
      address,
      residential_units,
      hpd_complaint_count,
      hpd_violation_count,
      hpd_comp_or_viol_apt,
      ecb_violation_count,
      oath_hearing_count
    FROM defacto_bk_bbl_details
  ')
  
  output$all_bbl_agg_info_tbl = renderDT(
    all_bbl_agg_info[-1], 
    extensions = 'FixedColumns',
    escape = 1,
    filter = "top",
    selection = "none",
    options = list(
      dom = 'Brtip',
      scrollX = TRUE,
      fixedColumns = list(leftColumns = 2)
    )
  )
  
  output$download_all <- downloadHandler(
    filename = function() {
      glue("potential-defacto-bbls_{Sys.Date()}.csv")
    },
    content = function(file) {
      write.csv(all_bbl_agg_info[-2], file, na = "")
    }
  )
  

  # Selected BBL ------------------------------------------------------------

  bbl_address <- reactive({
    req(input$bbl)
    
    query <- sqlInterpolate(con, "
      SELECT 
        bbl || ': ' || address 
      FROM defacto_bk_bbl_details 
      WHERE bbl = ?bbl
    ", bbl = input$bbl)
    
    dbGetQuery(con, query)[[1]]
  })
  
  output$bbl_address <- renderText(bbl_address())
  
  observeEvent(input$bbl_button, {
    req(input$bbl_button)
  
    clicked_bbl <- gsub("button_", "", input$bbl_button) # Get bbl out of button id
    updateTextInput(session, "bbl", value = clicked_bbl)
  })
  

  # ECB Violation Details ---------------------------------------------------
  
  callModule(
    module = detailsTable, 
    id = "ecb_details_table", 
    .con = con,
    selected_bbl = reactive(input$bbl), 
    details_col = "ecb_details", 
    download_file_slug = "ecb-violation-details", 
    dataset_name = "ECB Violations"
  )
  
  # OATH Hearing Details ----------------------------------------------------
  
  callModule(
    module = detailsTable, 
    id = "oath_details_table", 
    .con = con,
    selected_bbl = reactive(input$bbl), 
    details_col = "oath_details", 
    download_file_slug = "oath-hearing-details", 
    dataset_name = "Oath Hearings"
  )
  
}