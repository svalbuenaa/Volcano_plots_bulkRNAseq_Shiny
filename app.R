#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)

proj_dir <- file.path("C:", "Users", "svalb", "OneDrive", "Escritorio", 
                      "temp_csv_Shiny", "gene_list.csv")
dataset <- read.csv(proj_dir)

# Default values for threshold
significance_level <- 0.05

# Start modifying dataset to prepare it for rendering
names(dataset)[names(dataset) == 'X'] <- 'Gene'
dataset %>% filter(padj<significance_level) %>% arrange(padj)



# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Volcano plots for bulk-RNAseq data"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            textInput("pvalue_user",
                        "pvalue threshold:"),
            
            textInput("log2FoldChange_user",
                      "log2FoldChange threshold:")
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
        tryCatch({
          # Get values provided by user
          threshold_pvalue_ <- as.numeric(input$pvalue_user)
          threshold_log2FoldChange_ <- as.numeric(input$log2FoldChange_user)
          # threshold_pvalue_ <- 0.05
          # threshold_log2FoldChange_ <- 1
          # Update dataset significance column based on user-provided values
          dataset$significance <- NA
          for (gene in 1:nrow(dataset)){
             if (dataset[gene,"log2FoldChange"]>=threshold_log2FoldChange_ & dataset[gene,"padj"]< threshold_pvalue_){
               dataset[gene, "significance"] <- "Up"
             }

             else if (dataset[gene,"log2FoldChange"]<=((-1)*threshold_log2FoldChange_) & dataset[gene,"padj"]< threshold_pvalue_){
               dataset[gene, "significance"] <- "Down"
             }

             else if (abs(dataset[gene,"log2FoldChange"])<threshold_log2FoldChange_ | dataset[gene,"padj"]>= threshold_pvalue_){
               dataset[gene, "significance"] <- "Not significant"
             }
          }
          
          if(threshold_pvalue_ > 0 & threshold_pvalue_ <= 1 & threshold_log2FoldChange_ > 0){
            ggplot(dataset, aes(x=log2FoldChange, y=-log10(padj), label=Gene, color=significance))+ 
              geom_point(size=0.8)+
              scale_color_manual(values = c("Up"="#b02428", "Not significant"="grey", "Down"="#6697ea"))+ 
              labs(title="Plot")
          }
        },
        error = function(e){
          ggplot()+
            labs(title="Please, insert valud numeric values:",
                 subtitle = "--Insert values from 0 to 1 for the pvalue\n--Insert values larger than 0 for log2FoldChange")+
            theme_void()
        })
        
        # draw the histogram with the specified number of bins
        # hist(x, breaks = bins, col = 'darkgray', border = 'white',
             # xlab = 'P-value',
             # main = 'Histogram of p-values')
    })
}

# Run the application 
shinyApp(ui = ui, server = server) 
