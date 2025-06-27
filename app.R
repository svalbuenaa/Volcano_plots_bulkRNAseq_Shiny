#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)
library(tidyverse)




# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Volcano plots for bulk-RNAseq data"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            fileInput("csv_user", "Choose CSV File with DEG analysis", accept = ".csv"),
            textInput("pvalue_user",
                      "pvalue threshold:",
                      value = 0.05),
            
            textInput("log2FoldChange_user",
                      "log2FoldChange threshold:",
                      value = 2),
            textInput("title_user",
                      "plot title:",
                      placeholder = "Introduce plot title")
        ),

        # Show a plot of the generated distribution
        mainPanel(
           plotOutput("distPlot")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    output$distPlot <- renderPlot({
      file_ <- input$csv_user
      ext <- tools::file_ext(file_$datapath)
      req(file_)
      validate(need(ext == "csv", "Please upload a csv file"))
      dataset <- read.csv(file_$datapath)
      significance_level <- 0.05
      
      names(dataset)[names(dataset) == 'X'] <- 'Gene'
      dataset %>% filter(padj<significance_level) %>% arrange(padj)

      notif_id <- showNotification("Preparing plot", duration = NULL)
      tryCatch({
        # Get values provided by user
        threshold_pvalue_ <- as.numeric(input$pvalue_user)
        threshold_log2FoldChange_ <- as.numeric(input$log2FoldChange_user)
        plot_title_ <- as.character(input$title_user)
        plot_theme_ <- 
        
        # Update dataset significance column based on user-provided values
        dataset$significance <- NA
        for (gene in 1:nrow(dataset)) {
          if (dataset[gene, "log2FoldChange"] >= threshold_log2FoldChange_ & dataset[gene, "padj"] < threshold_pvalue_) {
            dataset[gene, "significance"] <- "Up"
          } else if (dataset[gene, "log2FoldChange"] <= -threshold_log2FoldChange_ & dataset[gene, "padj"] < threshold_pvalue_) {
            dataset[gene, "significance"] <- "Down"
          } else {
            dataset[gene, "significance"] <- "Not significant"
          }
        }
        
        if (threshold_pvalue_ > 0 & threshold_pvalue_ <= 1 & threshold_log2FoldChange_ > 0) {
          removeNotification(notif_id)
          ggplot(dataset, aes(x = log2FoldChange, y = -log10(padj), label = Gene, color = significance)) +
            geom_point(size = 0.8) +
            scale_color_manual(values = c("Up" = "#b02428", "Not significant" = "grey", "Down" = "#6697ea")) +
            labs(title = plot_title_)
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
    })
    
  
  
  
    
}



# Run the application 
shinyApp(ui = ui, server = server) 
