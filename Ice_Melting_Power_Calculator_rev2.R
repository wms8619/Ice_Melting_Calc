library(shiny)
library(bslib) # For modern UI
library(scales) # For pretty number formatting

ui <- page_sidebar(
  title = "Ice Melting Power Calculator",
  theme = bs_theme(bootswatch = "darkly", primary = "#007bff"), # Professional dark theme
  
  sidebar = sidebar(
    title = "Input Parameters",
    numericInput("mass", "Total Mass of Ice (kg):", value = 458500, min = 0),
    sliderInput("temp_initial", "Initial Ice Temp (°C):", value = 0, min = -50, max = 0),
    numericInput("hours", "Time to Melt (Hours):", value = 2, min = 0.01),
    sliderInput("efficiency", "System Efficiency (%):", value = 100, min = 1, max = 100),
    helpText("Assumes phase change to water at 0°C.")
  ),
  
  layout_column_wrap(
    width = 1/2,
    # Value Boxes for key metrics
    value_box(
      title = "Total Energy Required",
      value = textOutput("energy_val"),
      showcase = bsicons::bs_icon("lightning-charge"),
      theme = "primary"
    ),
    value_box(
      title = "Actual Power Needed",
      value = textOutput("power_val"),
      showcase = bsicons::bs_icon("plug"),
      theme = "danger"
    )
  ),
  
  card(
    card_header("Detailed Breakdown"),
    tableOutput("stats_table")
  )
)

server <- function(input, output) {
  
  # Reactive calculation - Robust and Efficient
  results <- reactive({
    # Ensure inputs exist before calculating
    req(input$mass, input$hours, input$efficiency)
    
    Lf <- 334000    # Latent Heat of Fusion (J/kg)
    Ci <- 2108      # Specific Heat of Ice (J/kg*C)
    
    seconds <- input$hours * 3600
    temp_diff <- abs(input$temp_initial)
    
    Q_warm <- input$mass * Ci * temp_diff
    Q_melt <- input$mass * Lf
    Q_total <- Q_warm + Q_melt
    
    P_theoretical <- Q_total / seconds
    P_actual <- P_theoretical / (input$efficiency / 100)
    
    list(
      energy_gj = Q_total / 1e9,
      power_mw = P_actual / 1e6,
      seconds = seconds
    )
  })
  
  output$energy_val <- renderText({
    paste(round(results()$energy_gj, 2), "GJ")
  })
  
  output$power_val <- renderText({
    paste(round(results()$power_mw, 2), "MW")
  })
  
  output$stats_table <- renderTable({
    res <- results()
    data.frame(
      Metric = c("Time Duration (s)", "Energy (GJ)", "Power Needed (MW)"),
      Value = c(res$seconds, res$energy_gj, res$power_mw)
    )
  }, striped = TRUE, hover = TRUE)
}

shinyApp(ui, server)