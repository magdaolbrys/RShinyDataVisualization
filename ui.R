
shinyUI(fluidPage(

    titlePanel("Data Visualization"),

    sidebarLayout(

        sidebarPanel(

            actionButton("getDataFromServer", "ADD / DELETE DATA"),
            
            selectInput(
              "selectedYears",
              "Choose year:",
              choices = 2000:2023,
              selected = 2022
            ),
            
            checkboxGroupInput(
              "selectedGender",
              "Select gender (to visualize the total number, select both:",
              choices = c("WOMEN", "MEN"),
              selected = c("WOMEN", "MEN")
            ),


            
        ),

        mainPanel(

            tabsetPanel(type = "tabs",
              
                tabPanel("Data Table", tableOutput("dataSample")),
                
                tabPanel("Aggregates", htmlOutput("view")),
                
                tabPanel("Time Series", 
                         selectInput(
                           "selectedCountry",
                           "Select Country:",
                           choices = c("PL", "DE", "both"),
                           selected = "both"
                         ),
                         plotlyOutput("timeSeriesPlot")
                )
                
                
                
                
            )

        

        )


    )

))
