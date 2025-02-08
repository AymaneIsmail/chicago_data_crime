library(shiny)
library(httr)
library(jsonlite)
library(DT)
library(leaflet)
library(dplyr)
library(ggplot2)
library(plotly)

# URLs pour récupérer les données
urls <- list(
  '2023' = "https://data.cityofchicago.org/resource/xguy-4ndq.json",
  '2024' = "https://data.cityofchicago.org/resource/dqcy-ctma.json",
  '2025' = "https://data.cityofchicago.org/resource/ijzp-q8t2.json"
)

# Fonction pour récupérer et transformer les données API en data.frame
fetchCrimeData <- function(url) {
  response <- GET(url)
  
  if (status_code(response) == 200) {
    data_list <- fromJSON(content(response, "text"), simplifyDataFrame = TRUE)
    
    # Vérifier si latitude et longitude existent avant de les convertir
    if ("latitude" %in% colnames(data_list) & "longitude" %in% colnames(data_list)) {
      data_list$latitude <- as.numeric(data_list$latitude)
      data_list$longitude <- as.numeric(data_list$longitude)
    }
    
    return(data_list)
  } else {
    return(NULL)
  }
}

# Fonction pour agréger les données de 2023 à 2025
aggregateCrimeData <- function(selected_years = c(2023, 2024, 2025)) {
  data_2023 <- fetchCrimeData(urls[['2023']])
  data_2024 <- fetchCrimeData(urls[['2024']])
  data_2025 <- fetchCrimeData(urls[['2025']])
  
  # Ajouter la colonne 'year' et combiner les datasets
  data_2023$year <- 2023
  data_2024$year <- 2024
  data_2025$year <- 2025
  
  all_data <- bind_rows(data_2023, data_2024, data_2025)
  
  # Filtrer les données par années sélectionnées
  all_data <- all_data %>% filter(year %in% selected_years)
  
  return(all_data)
}

# Interface Utilisateur (UI)
ui <- fluidPage(
  titlePanel("Crimes à Chicago"),
  
  sidebarLayout(
    sidebarPanel(
      checkboxGroupInput("yearSelection", "Sélectionner les années:",
                         choices = c("2023", "2024", "2025", "Toutes"),
                         selected = c("2023", "2024", "2025")),
      actionButton("refresh", "Rafraîchir les données")
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("Tableau", DTOutput("crimeTable")),
        tabPanel("Carte", leafletOutput("crimeMap")),
        tabPanel("Graphiques", 
                 plotlyOutput("crimeTypeComparisonPlot"),
                 plotlyOutput("districtCrimePlot"))
      )
    )
  )
)

# Serveur
server <- function(input, output, session) {
  
  # Réactif pour récupérer les données
  crime_data <- reactive({
    # Déterminer les années sélectionnées
    selected_years <- if ("Toutes" %in% input$yearSelection) {
      c(2023, 2024, 2025)
    } else {
      as.integer(input$yearSelection)
    }
    
    # Agréger les données pour les années sélectionnées
    aggregateCrimeData(selected_years)
  })
  
  # Rafraîchir les données quand on clique sur le bouton
  observeEvent(input$refresh, {
    crime_data(aggregateCrimeData(input$yearSelection))
  })
  
  # Affichage en Tableau
  output$crimeTable <- renderDT({
    data <- crime_data()
    if (is.null(data)) return(NULL)
    datatable(data[, c("id", "case_number", "date", "primary_type", "description", 
                       "block", "year", "district", "community_area", "latitude", "longitude")], 
              options = list(pageLength = 5), 
              rownames = FALSE)
  })
  
  # Affichage sur une Carte Leaflet
  output$crimeMap <- renderLeaflet({
    data <- crime_data()
    
    if (is.null(data) || nrow(data) == 0) {
      return(NULL)
    }
    
    leaflet(data) %>%
      addTiles() %>%
      addCircleMarkers(
        ~longitude, ~latitude,
        popup = ~paste("<b>", primary_type, "</b><br>", description, "<br><b>Year: </b>", year),
        radius = 5, color = "red"
      )
  })
  
  # Graphique : Comparaison des types de crimes entre 2023, 2024 et 2025
  output$crimeTypeComparisonPlot <- renderPlotly({
    data <- crime_data()
    if (is.null(data)) return(NULL)
    
    # Calculer le nombre de chaque type de crime pour 2023, 2024 et 2025
    crime_comparison <- data %>%
      group_by(year, primary_type) %>%
      summarise(crime_count = n()) %>%
      filter(year %in% c(2023, 2024, 2025))
    
    # Créer un graphique à barres comparant les années
    plot_ly(crime_comparison, x = ~primary_type, y = ~crime_count, color = ~factor(year), 
            type = 'bar', barmode = 'group', text = ~primary_type, hoverinfo = 'text') %>%
      layout(title = "Comparaison des types de crimes entre 2023, 2024 et 2025",
             xaxis = list(title = "Type de Crime"),
             yaxis = list(title = "Nombre de Crimes"),
             barmode = 'group')
  })
  
  # Graphique : Répartition des crimes par district
  output$districtCrimePlot <- renderPlotly({
    data <- crime_data()
    if (is.null(data)) return(NULL)
    
    # Calculer le nombre de crimes par district
    district_crime <- data %>%
      group_by(year, district) %>%
      summarise(crime_count = n())
    
    # Créer un graphique à barres pour chaque année, en fonction du district
    plot_ly(district_crime, x = ~district, y = ~crime_count, color = ~factor(year), 
            type = 'bar', barmode = 'group', text = ~district, hoverinfo = 'text') %>%
      layout(title = "Répartition des crimes par district entre 2023, 2024 et 2025",
             xaxis = list(title = "District"),
             yaxis = list(title = "Nombre de Crimes"),
             barmode = 'group')
  })
}

# Exécuter l'application Shiny
shinyApp(ui = ui, server = server)
