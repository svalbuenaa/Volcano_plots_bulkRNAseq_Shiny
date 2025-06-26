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
dataset$Gene <- rownames(dataset)
dataset %>% filter(padj<significance_level) %>% arrange(padj)



# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Volcano plots for bulk-RNAseq data"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            sliderInput("bins",
                        "Number of bins:",
                        min = 1,
                        max = 50,
                        value = 30)
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
        # generate bins based on input$bins from ui.R
        x    <- faithful[, 2]
        bins <- seq(min(x), max(x), length.out = input$bins + 1)

        # draw the histogram with the specified number of bins
        hist(x, breaks = bins, col = 'darkgray', border = 'white',
             xlab = 'Waiting time to next eruption (in mins)',
             main = 'Histogram of waiting times')
    })
}

# Run the application 
shinyApp(ui = ui, server = server) 
