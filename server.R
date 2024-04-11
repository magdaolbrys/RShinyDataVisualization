

shinyServer(function(input, output) {

    
    v <- reactiveValues(dataLoadDownload = FALSE)

    observeEvent(input$getDataFromServer,{
      v$dataLoadDownload <- ! v$dataLoadDownload
    })
 
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
            'COUNTRY' = country,
            'WOMEN' = as.integer(gsub(" p","",x[,1])),
            'MEN' = as.integer(gsub(" p","",x[,2])),
            'WEEK' = gsub("X","",rownames(x)), 
            'NUMBER' = as.integer(gsub(" p","",x[,3]))
            
          )
          x <- x[order(as.numeric(substr(x$'WEEK', 1, 4)), as.numeric(substr(x$'WEEK', 6, 7))), ]
          options(warn=0)
          rownames(x) <- NULL
          
          
          return(x)
        })))
        
      }
      else {
        x <- data.frame()
        return(x)
        
      }

      
      
      
      # filtering data based on selected years
      if (!is.null(input$selectedYears) && length(input$selectedYears) > 0) {
        x <- x[substr(x$'WEEK', 1, 4) %in% input$selectedYears, ]}
      
      # filtering data based on selected gender
      if (length(input$selectedGender) > 0) {
        selected_columns <- c("WEEK","COUNTRY","NUMBER", input$selectedGender)}
      else {
        selected_columns <- c("WEEK","COUNTRY","NUMBER")
      }
      
      x <- x[, selected_columns, drop = FALSE]
      rownames(x) <- NULL
      x <- na.omit(x)
      return(x)
 

    })


    # table
    output$dataSample <- renderTable({
      tmpData <- dataIn()
      
      if (nrow(tmpData)>0 ) {
        return(tmpData)
      }
      else {
        return("No data available")
      }
      
    },include.rownames=FALSE)

 
    
    # data aggregates on a map of Europe
    
    output$view <- renderGvis({
    dane <- dataIn()

    if (nrow(dane) > 0) {
      selectedGender <- input$selectedGender
      selectedYear <- as.character(input$selectedYears)
      
      dane_filtr <- dane[substr(dane$WEEK, 1, 4) == selectedYear, ]
      
      
      if (length(selectedGender) > 1) {
        dane_filtr_sum <- aggregate(NUMBER ~ COUNTRY, dane_filtr, sum)
      } else if ("WOMEN" %in% selectedGender) {
        dane_filtr_sum <- aggregate(WOMEN ~ COUNTRY, dane_filtr, sum)
      } else if ("MEN" %in% selectedGender) {
        dane_filtr_sum <- aggregate(MEN ~ COUNTRY, dane_filtr, sum)
      } else {
        dane_filtr_sum <- data.frame( COUNTRY = c("DE", "PL"), NUMBER = c(0, 0))
      }
      
      
      
      d <- data.frame(dane_filtr_sum)
      names(d)[2] <- "NUMBER"

      
        chart <- gvisGeoChart(data = d, 
                              locationvar ="COUNTRY", 
                              colorvar = "NUMBER",
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
    

    
    # time series
    output$timeSeriesPlot <- renderPlotly({
      dane <- dataIn()
      
      if (nrow(dane) > 0) {
        
        selectedCountry <- input$selectedCountry
        selectedGender <- input$selectedGender
        
        if (selectedCountry == "PL") {
          dane_filtr <- dane[dane$COUNTRY == "PL", ]
        } else if (selectedCountry == "DE") {
          dane_filtr <- dane[dane$COUNTRY == "DE", ]
        } else {
          dane_filtr <- dane
        }
        
        dane_filtr1 <- dane_filtr
        
        if (length(selectedGender) > 1) {
          dane_filtr1$NUMBER <- dane_filtr$WOMEN + dane_filtr$MEN
        } else if ("WOMEN" %in% selectedGender) {
          dane_filtr1$NUMBER <- dane_filtr$WOMEN
        } else if ("MEN" %in% selectedGender) {
          dane_filtr1$NUMBER <- dane_filtr$MEN
        } else {
          dane_filtr1$NUMBER <- rep(0, length(dane_filtr$NUMBER))
        }

        wykres <- plot_ly(
          data = dane_filtr1,
          x = ~WEEK,
          y = ~NUMBER, 
          color = ~COUNTRY,
          type = "scatter",
          mode = "lines+markers"
        ) %>%
          layout(
            xaxis = list(
              title = "WEEK",
              categoryorder = "array",
              categoryarray = unique(dane$WEEK)
            ),
            yaxis = list(title = "NUMBER"),
            showlegend = TRUE
          )
        
        
        return(wykres)
      } else {
        wykres <- plot_ly()
        return(wykres)
      }
    })
    
    
    
    
 

})
