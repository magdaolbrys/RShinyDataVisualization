# RShinyDataVisualization

This Shiny application aims to facilitate the analysis and visualization of demographic data sourced from EUROSTAT. Users can interact with the application to:

**Fetch Latest Data:** Users can retrieve the latest data from the EUROSTAT website by clicking the "Fetch Data" button.

**Select Data Years:** Users can select the years of data they wish to analyze.

**Choose Gender:** Users can choose the gender for which they want to view the data.

**Display Data:** The selected data will be presented in a tabular format showing the country, gender, week, and corresponding numerical value.

**Visualize Data on Europe Map:** The application will provide an aggregate visualization of the data on a map of Europe, showing the sum for the specified period and gender within each country.

**Visualize Time Series:** Users can visualize the selected data as time series plots, displaying one time series for the specified period and gender separately for each country.

This project utilizes the following packages: shiny, ggplot2, plotly, googleVis, and data.table.
