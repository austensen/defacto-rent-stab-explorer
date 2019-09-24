library(DT)
library(DBI)

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
    escape = FALSE,
    selection = "none",
    options = list(
      dom = 'B<"dwnld_all">frtip'
    )
  )
  
  output$download_all <- downloadHandler(
    filename = function() {
      paste0("potential-defacto-bbls_", Sys.Date(), ".csv")
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
  
  ecb_details <- reactive({
    req(input$bbl)
    
    # Expanding json array column - see TMiguelT's answer to 
    # https://www.reddit.com/r/PostgreSQL/comments/2u6ah3/how_to_use_json_to_recordset_on_json_stored_in_a/
    query <- sqlInterpolate(con, "
      SELECT
      	x.bbl,
      	x.address,
      	y.*
      FROM defacto_bk_bbl_details AS x
      CROSS JOIN LATERAL
      	json_to_recordset(x.ecb_details) as 
      	y(
      		ecb_owner_in_building text,
      		ecb_owner_address text,
      		ecb_violation_status text,
      		ecb_hearing_status text,
      		ecb_issue_date date,
      		ecb_hearing_date date,
      		ecb_served_date date,
      		ecb_violation_description text
      	)
      WHERE bbl = ?bbl
    ", bbl = input$bbl)
    
    dbGetQuery(con, query)
  })
  
  output$ecb_details_tbl = renderDT(
    ecb_details()[-c(1:2)], 
    selection = "none",
    options = list(
      dom = 'B<"dwnld_ecb">frtip',
      language = list(zeroRecords = "No data on ECB Violations for this property")    
    )
  )
  
  output$download_ecb <- downloadHandler(
    filename = function() {
      paste0(input$bbl, "_ecb-violation-details_", Sys.Date(), ".csv")
    },
    content = function(file) {
      write.csv(ecb_details(), file, na = "")
    }
  )
  

  # OATH Hearing Details ----------------------------------------------------
  
  oath_details <- reactive({
    req(input$bbl)
    
    query <- sqlInterpolate(con, "
      SELECT
      	x.bbl,
      	x.address,
      	y.*
      FROM defacto_bk_bbl_details AS x
      CROSS JOIN LATERAL
      	json_to_recordset(x.oath_details) as 
      	y(
      		oath_owner_in_building text,
      		oath_owner_address text,
      		oath_violation_date date,
      		oath_hearing_status text,
      		oath_hearing_result text
      	)
      WHERE bbl = ?bbl
    ", bbl = input$bbl)
    
    dbGetQuery(con, query)
  })
  
  output$oath_details_tbl = renderDT(
    oath_details()[-c(1:2)],
    selection = "none",
    options = list(
      dom = 'B<"dwnld_oath">frtip',
      language = list(zeroRecords = "No data on OATH Hearings for this property")
    )
  )
  
  output$download_oath <- downloadHandler(
    filename = function() {
      paste0(input$bbl, "_oath-hearing-details_", Sys.Date(), ".csv")
    },
    content = function(file) {
      write.csv(oath_details(), file, na = "")
    }
  )
  
}
