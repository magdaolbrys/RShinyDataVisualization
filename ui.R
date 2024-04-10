
shinyUI(fluidPage(

    titlePanel("Wizualizacja Danych"),

    sidebarLayout(

        sidebarPanel(

            # pobieranie danych 
            actionButton("getDataFromServer", "Pobierz / Usuń dane"),
            
            selectInput(
              "selectedYears",
              "Wybierz rok:",
              choices = 2000:2023,
              selected = 2022
            ),
            
            # wybór płci
            checkboxGroupInput(
              "selectedGender",
              "Wybierz płeć (aby zwizualizować sumę zaznacz obydwie):",
              choices = c("KOBIETY", "MĘŻCZYŹNI"),
              selected = c("KOBIETY", "MĘŻCZYŹNI")
            ),


            
        ),

        mainPanel(

            # panel zakladek  
            tabsetPanel(type = "tabs",
              
                # tabela 
                tabPanel("Dane", tableOutput("dataSample")),
                
                # agregaty danych na mapie europy
                tabPanel("Agregaty danych", htmlOutput("view")),
                
                # szeregi czasowe
                tabPanel("Szeregi czasowe", 
                         selectInput(
                           "selectedCountry",
                           "Wybierz kraj:",
                           choices = c("PL", "DE", "PL i DE"),
                           selected = "PL i DE"
                         ),
                         plotlyOutput("timeSeriesPlot")
                )
                
                
                
                
            )

        

        )


    )

))
