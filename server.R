

shinyServer(function(input, output) {

    
    v <- reactiveValues(dataLoadDownload = FALSE)

    observeEvent(input$getDataFromServer,{
      v$dataLoadDownload <- ! v$dataLoadDownload
    })
 
    # wczytywanie danych 
    dataIn <- reactive({
      
      if(v$dataLoadDownload){
        dataDir    <- getwd()
        
        download.file(url="https://ec.europa.eu/eurostat/api/dissemination/sdmx/2.1/data/demo_r_mwk_ts/?format=TSV&compressed=true&i",
                      destfile=file.path(dataDir,"demo_r_mwk_ts.tsv.gz"),method="curl")
        
        d <- read.table(file=file.path(dataDir,"demo_r_mwk_ts.tsv.gz"),sep="\t",dec=".",header=T)
        
        x <- as.data.frame(rbindlist(lapply(c("PL","DE"),function(country){
          
          x <- t(d[grep(country,d[,1]),])
          x <- x[-1,]
          options(warn=-1)
          x <- data.frame(
            'KRAJ' = country,
            'KOBIETY' = as.integer(gsub(" p","",x[,1])),
            'MĘŻCZYŹNI' = as.integer(gsub(" p","",x[,2])),
            'TYDZIEŃ' = gsub("X","",rownames(x)), 
            'LICZBA' = as.integer(gsub(" p","",x[,3]))
            
          )
          x <- x[order(as.numeric(substr(x$'TYDZIEŃ', 1, 4)), as.numeric(substr(x$'TYDZIEŃ', 6, 7))), ]
          options(warn=0)
          rownames(x) <- NULL
          
          
          return(x)
        })))
        
      }
      else {
        x <- data.frame()
        return(x)
        
      }

      
      
      
      #filtrowanie danych na podstawie wybranych lat
      if (!is.null(input$selectedYears) && length(input$selectedYears) > 0) {
        x <- x[substr(x$'TYDZIEŃ', 1, 4) %in% input$selectedYears, ]}
      
      #filtrowanie danych na podstawie plci
      if (length(input$selectedGender) > 0) {
        selected_columns <- c("TYDZIEŃ","KRAJ","LICZBA", input$selectedGender)}
      else {
        selected_columns <- c("TYDZIEŃ","KRAJ","LICZBA")
      }
      
      x <- x[, selected_columns, drop = FALSE]
      rownames(x) <- NULL
      x <- na.omit(x)
      return(x)
 

    })


    # tabela
    output$dataSample <- renderTable({
      tmpData <- dataIn()
      
      if (nrow(tmpData)>0 ) {
        return(tmpData)
      }
      else {
        return("Brak danych")
      }
      
    },include.rownames=FALSE)

 
    
    # agregaty danych na mapie europy
    
    output$view <- renderGvis({
    dane <- dataIn()

    if (nrow(dane) > 0) {
      selectedGender <- input$selectedGender
      selectedYear <- as.character(input$selectedYears)
      
      dane_filtr <- dane[substr(dane$TYDZIEŃ, 1, 4) == selectedYear, ]
      
      
      if (length(selectedGender) > 1) {
        dane_filtr_sum <- aggregate(LICZBA ~ KRAJ, dane_filtr, sum)
      } else if ("KOBIETY" %in% selectedGender) {
        dane_filtr_sum <- aggregate(KOBIETY ~ KRAJ, dane_filtr, sum)
      } else if ("MĘŻCZYŹNI" %in% selectedGender) {
        dane_filtr_sum <- aggregate(MĘŻCZYŹNI ~ KRAJ, dane_filtr, sum)
      } else {
        dane_filtr_sum <- data.frame( KRAJ = c("DE", "PL"), LICZBA = c(0, 0))
      }
      
      
      
      d <- data.frame(dane_filtr_sum)
      names(d)[2] <- "LICZBA"

      
        chart <- gvisGeoChart(data = d, 
                              locationvar ="KRAJ", 
                              colorvar = "LICZBA",
                              options = list(
                                  region = "150",  
                                  displayMode = "regions",
                                  resolution = "countries"
                                  #colorAxis = "{colors:['#FF0000', '#00FF00']}",
                                  #backgroundColor = "#FFFFFF"
                              )
        
        

        )

        return(chart)
    } else {

      
    }
})
    

    
    # szeregi czasowe
    output$timeSeriesPlot <- renderPlotly({
      dane <- dataIn()
      
      if (nrow(dane) > 0) {
        
        selectedCountry <- input$selectedCountry
        selectedGender <- input$selectedGender
        
        if (selectedCountry == "PL") {
          dane_filtr <- dane[dane$KRAJ == "PL", ]
        } else if (selectedCountry == "DE") {
          dane_filtr <- dane[dane$KRAJ == "DE", ]
        } else {
          dane_filtr <- dane
        }
        
        dane_filtr1 <- dane_filtr
        
        if (length(selectedGender) > 1) {
          dane_filtr1$LICZBA <- dane_filtr$KOBIETY + dane_filtr$MĘŻCZYŹNI
        } else if ("KOBIETY" %in% selectedGender) {
          dane_filtr1$LICZBA <- dane_filtr$KOBIETY
        } else if ("MĘŻCZYŹNI" %in% selectedGender) {
          dane_filtr1$LICZBA <- dane_filtr$MĘŻCZYŹNI
        } else {
          dane_filtr1$LICZBA <- rep(0, length(dane_filtr$LICZBA))
        }

        wykres <- plot_ly(
          data = dane_filtr1,
          x = ~TYDZIEŃ,
          y = ~LICZBA, 
          color = ~KRAJ,
          type = "scatter",
          mode = "lines+markers"
        ) %>%
          layout(
            xaxis = list(
              title = "Tydzień",
              categoryorder = "array",
              categoryarray = unique(dane$TYDZIEŃ)
            ),
            yaxis = list(title = "Liczba"),
            showlegend = TRUE
          )
        
        
        return(wykres)
      } else {
        wykres <- plot_ly()
        return(wykres)
      }
    })
    
    
    
    
 

})
