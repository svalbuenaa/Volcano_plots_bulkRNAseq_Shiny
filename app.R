#
# Shiny web application for generating volcano plots from bulk-RNAseq DEG data
#

library(shiny)
library(tidyverse)

# Define UI
ui <- fluidPage(
  tags$head(
    tags$style(HTML("
      #distPlot {
        width: 100% !important;
        height: 80vh !important;  /* 80% of viewport height */
      }
    "))
  ),
  
  titlePanel("Volcano plots for bulk-RNAseq data"),
  
  sidebarLayout(
    sidebarPanel(
      fileInput("csv_user", "Choose CSV File with DEG analysis", accept = ".csv"),
      tags$h4("Choose threshold values:"),
      
      # Inputs for p-value and log2FoldChange thresholds
      splitLayout(
        cellWidths = c("50%", "50%"), 
        textInput("pvalue_user", "p-value", value = 0.05),
        textInput("log2FoldChange_user", "log2FoldChange", value = 2)
      ),
      
      textInput("title_user", "Plot title:", placeholder = "Introduce plot title"),
      
      # Select plot theme
      selectInput("theme_user", "Plot theme",
                  choices = list(
                    "theme_gray", "theme_bw", "theme_linedraw", "theme_light",
                    "theme_dark", "theme_minimal", "theme_classic", "theme_void", "theme_test"
                  ),
                  selectize = FALSE)
    ),
    
    mainPanel(
      plotOutput("distPlot", width = "100%", height = "auto"),
      fluidRow(
        column(2, textInput("width_user", "Plot width", value = 8)),
        column(2, textInput("height_user", "Plot height", value = 6)),
        column(2, selectInput("format_user", "Save format",
                              choices = list("PNG", "JPG", "PDF", "EPS", "TIFF", "BMP", "SVG"),
                              selected = "PNG", selectize = FALSE)),
        column(3,
               tags$label("Save plot"),
               br(),
               downloadButton("downloadPlot", "Download"))
      )
    )
  )
)

# Define server logic
server <- function(input, output) {
  
  # Reactive to get the selected format in lowercase
  reactive_format <- reactive({
    tolower(as.character(input$format_user))
  })
  
  # Reactive to generate the plot
  reactive_plot <- reactive({
    file_ <- input$csv_user
    req(file_)
    
    ext <- tools::file_ext(file_$datapath)
    validate(need(ext == "csv", "Please upload a csv file"))
    
    dataset <- read.csv(file_$datapath)
    significance_level <- 0.05
    notif_id <- showNotification("Preparing plot", duration = NULL)
    
    # Check if required columns are present
    if (all(c("Gene", "padj", "log2FoldChange") %in% colnames(dataset))) {
      
      # Filter dataset and prepare significance labels
      tryCatch({
        threshold_pvalue_ <- as.numeric(input$pvalue_user)
        threshold_log2FoldChange_ <- as.numeric(input$log2FoldChange_user)
        plot_title_ <- as.character(input$title_user)
        plot_theme_ <- as.character(input$theme_user)
        
        dataset$significance <- "Not significant"
        dataset$significance[dataset$log2FoldChange >= threshold_log2FoldChange_ & dataset$padj < threshold_pvalue_] <- "Upregulated"
        dataset$significance[dataset$log2FoldChange <= -threshold_log2FoldChange_ & dataset$padj < threshold_pvalue_] <- "Downregulated"
        
        if (threshold_pvalue_ > 0 & threshold_pvalue_ <= 1 & threshold_log2FoldChange_ > 0) {
          removeNotification(notif_id)
          plot_theme_var <- eval(parse(text = paste0(plot_theme_, "()")))
          
          ggplot(dataset, aes(x = log2FoldChange, y = -log10(padj), label = Gene, color = significance)) +
            geom_point(size = 0.8) +
            scale_color_manual(values = c("Upregulated" = "#b02428", "Not significant" = "grey", "Downregulated" = "#6697ea")) +
            labs(title = plot_title_) +
            plot_theme_var +
            theme(plot.title = element_text(hjust = 0.5))
          
        } else {
          removeNotification(notif_id)
          ggplot() +
            labs(
              title = "Please, insert valid numeric values:",
              subtitle = "--Insert values from 0 to 1 for the pvalue\n--Insert values larger than 0 for log2FoldChange"
            ) +
            theme_void()
        }
      }, error = function(e) {
        removeNotification(notif_id)
        ggplot() +
          labs(
            title = "Please, insert valid numeric values:",
            subtitle = "--Insert values from 0 to 1 for the pvalue\n--Insert values larger than 0 for log2FoldChange"
          ) +
          theme_void()
      })
      
    } else {
      removeNotification(notif_id)
      ggplot() +
        labs(
          title = "Please, upload a .csv with the required columns (note case sensitivity):",
          subtitle = "--'Gene': Gene names\n--'padj': Adjusted p-values\n--'log2FoldChange': Log2 fold change over controls"
        ) +
        theme_void()
    }
  })
  
  # Render the plot in UI
  output$distPlot <- renderPlot({
    reactive_plot()
  })
  
  # Download handler to save plot
  output$downloadPlot <- downloadHandler(
    filename = function() {
      paste("myplot-", Sys.Date(), ".", reactive_format(), sep = "")
    },
    content = function(file) {
      width_num <- as.numeric(input$width_user)
      height_num <- as.numeric(input$height_user)
      
      # Fallback to defaults if invalid input
      if (is.na(width_num) || width_num <= 0) width_num <- 8
      if (is.na(height_num) || height_num <= 0) height_num <- 6
      
      ggsave(file, plot = reactive_plot(), width = width_num, height = height_num)
    }
  )
}

# Run the application 
shinyApp(ui = ui, server = server)
