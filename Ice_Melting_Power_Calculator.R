library(shiny)

# Define UI
ui <- fluidPage(
  titlePanel("Ice Melting Power Calculator"),
  
  sidebarLayout(
    sidebarPanel(
      numericInput("mass", "Total Mass of Ice (kg):", value = 458500, min = 0),
      numericInput("temp_initial", "Initial Ice Temp (°C):", value = 0, max = 0),
      numericInput("hours", "Time to Melt (Hours):", value = 2, min = 0.01),
      sliderInput("efficiency", "System Efficiency (%):", value = 100, min = 1, max = 100),
      hr(),
      helpText("Note: Calculation assumes ice is being turned into water at 0°C.")
    ),
    
    mainPanel(
      h3("Calculation Results"),
      wellPanel(
        htmlOutput("results")
      ),
      plotOutput("energyPlot")
    )
  )
)

# Define Server Logic
server <- function(input, output) {
  
  # Constants
  Lf <- 334000    # Latent Heat of Fusion (J/kg)
  Ci <- 2108      # Specific Heat of Ice (J/kg*C)
  
  output$results <- renderUI({
    # 1. Time conversion
    seconds <- input$hours * 3600
    
    # 2. Energy to warm ice (if below 0)
    temp_diff <- abs(input$temp_initial)
    Q_warm <- input$mass * Ci * temp_diff
    
    # 3. Energy to melt ice
    Q_melt <- input$mass * Lf
    
    # 4. Total Energy
    Q_total <- Q_warm + Q_melt
    
    # 5. Power Calculations
    P_theoretical <- Q_total / seconds
    P_actual <- P_theoretical / (input$efficiency / 100)
    
    HTML(paste0(
      "<b>Total Energy Required:</b> ", format(round(Q_total/1e9, 2), big.mark=","), " Gigajoules (GJ)<br/>",
      "<b>Time Duration:</b> ", seconds, " seconds<br/><br/>",
      "<span style='color:blue; font-size:18px;'><b>Theoretical Power:</b> ", 
      format(round(P_theoretical/1e6, 2), big.mark=","), " Megawatts (MW)</span><br/>",
      "<span style='color:red; font-size:18px;'><b>Actual Power Needed (at ", input$efficiency, "% efficiency):</b> ", 
      format(round(P_actual/1e6, 2), big.mark=","), " Megawatts (MW)</span>"
    ))
  })
}

# Run the app
shinyApp(ui = ui, server = server)