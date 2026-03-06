library(shiny)
library(shinydashboard)
library(RMariaDB)
library(dplyr)
library(tidyr)
library(stringr)
library(plotly)
library(DT)
library(ggplot2)
library(wordcloud)
library(wordcloud2)
library(tm)



ui <- dashboardPage(
  skin = "black",
  dashboardHeader(title = "POPCORN 🎬"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Overview", tabName = "overview", icon = icon("dashboard")),
      menuItem("Film Explorer", tabName = "explorer", icon = icon("table")),
      menuItem("Genre Analysis", tabName = "genre_tab", icon = icon("film")),
      menuItem("Top Films", tabName = "top_film", icon = icon("star")),
      menuItem("Content Analysis", tabName = "content", icon = icon("align-left")),
      menuItem("Variable Relations", tabName = "relations", icon = icon("chart-line"))
    ),
    
    hr(),
    
    selectInput("select_genre", "Pilih Genre:", choices = "All"), 
    sliderInput("select_rating", "Rentang Rating:", min = 0, max = 10, value = c(0, 10), step = 0.5)
  ),
  
  dashboardBody(
    tags$head(tags$style(HTML("
      .small-box { height: 110px; border-radius: 10px; }
      .box { border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
      .genre-badge { display: inline-block; padding: 2px 8px; font-size: 11px; color: white; border-radius: 10px; font-weight: bold; }
      .modal-lg { width: 90% !important; }
    "))),
    
    tabItems(

      
      # --- OVERVIEW ---
      tabItem(tabName = "overview",
              fluidRow(
                valueBoxOutput("total_film", width = 4),
                valueBoxOutput("avg_rating", width = 4),
                valueBoxOutput("top_genre", width = 4)
              ),
              
              hr(style = "border-top: 1px solid #d2d6de; margin: 20px 0;"), 
              
              fluidRow(
                box(title = "Distribusi Rating Film", status = "primary", solidHeader = TRUE, 
                    plotlyOutput("hist_rating"), width = 6),
                box(title = "Tren Produksi Film per Tahun", status = "primary", solidHeader = TRUE, 
                    plotlyOutput("hist_year"), width = 6)
              ),
              
              hr(style = "border-top: 1px solid #d2d6de; margin: 20px 0;"),
              
              fluidRow(
                box(title = "Top 10 Production Companies", status = "success", solidHeader = TRUE, 
                    plotlyOutput("bar_top_studios"), width = 12)
              )
      ),
      
     
      # --- FILM EXPLORER ---
      tabItem(tabName = "explorer",
              box(title = "Database Film (Klik Baris untuk Detail)", width = 12, DTOutput("table_explorer"))
      ),
      
      
      # --- GENRE ANALYSIS ---
      tabItem(tabName = "genre_tab",
              fluidRow(
                box(title = "📈 Tren Top 5 Genre Per Tahun", status = "primary", solidHeader = TRUE, 
                    plotlyOutput("genre_year_trend"), width = 12)
              ),
              
              hr(style = "border-top: 1px solid #d2d6de; margin: 20px 0;"), 
              
              fluidRow(
                box(title = "🔥 Popularitas Genre (Total Reviews)", status = "danger", solidHeader = TRUE, 
                    plotlyOutput("genre_pop_score"), width = 6),
                box(title = "⏳ Karakteristik Durasi Per Genre", status = "warning", solidHeader = TRUE, 
                    plotlyOutput("genre_duration_analisis"), width = 6)
              ),
              
              hr(style = "border-top: 1px solid #d2d6de; margin: 20px 0;"), 
              
              fluidRow(
                box(title = "📊 Distribusi Rating Per Genre", status = "info", solidHeader = TRUE, 
                    plotlyOutput("genre_rating_dist"), width = 6),
                box(title = "📋 Daftar Film Terfilter", status = "success", solidHeader = TRUE, 
                    DTOutput("table_genre_year"), width = 6)
              )
      ),
      
      # --- TOP FILMS ---
      tabItem(tabName = "top_film",
              fluidRow(
                box(title = "🏆 Top 5 Global (Minimal 100 Reviews)", width = 12, status = "danger", solidHeader = TRUE, 
                    uiOutput("poster_global_top"))
              ),
              
              hr(style = "border-top: 1px solid #d2d6de; margin: 20px 0;"), 
              
              fluidRow(
                box(title = textOutput("title_top_rating"), width = 12, status = "primary", solidHeader = TRUE, 
                    uiOutput("poster_genre_rating"))
              ),
              
              hr(style = "border-top: 1px solid #d2d6de; margin: 20px 0;"), 
              
              fluidRow(
                box(title = textOutput("title_top_reviews"), width = 12, status = "success", solidHeader = TRUE, 
                    uiOutput("poster_genre_reviews"))
              ),
              
              hr(style = "border-top: 1px solid #d2d6de; margin: 20px 0;"), 
              
              fluidRow(
                box(title = "Analisis Skor vs Popularitas (Bubble)", status = "info", solidHeader = TRUE, width = 4,
                    plotlyOutput("bubble_score_pop")),
                box(title = "Proporsi Genre dalam Filter (Donut)", status = "warning", solidHeader = TRUE, width = 4,
                    plotlyOutput("donut_genre_filter")),
                box(title = "Kualitas Film dari Tahun ke Tahun", status = "primary", solidHeader = TRUE, width = 4,
                    plotlyOutput("line_rating_trend"))
              ),
                
                hr(style = "border-top: 1px solid #d2d6de; margin: 20px 0;"), 
                
              fluidRow(
                box(title = "💎 Hidden Gems (Rating Tinggi, Review Sedikit)", status = "info", solidHeader = TRUE, width = 4,
                    plotlyOutput("plot_hidden_gems")),
                box(title = "🔥 Movie Engagement (Popularitas vs Rating)", status = "danger", solidHeader = TRUE, width = 4,
                    plotlyOutput("plot_engagement")),
                box(title = "🎬 Top 5 Directors (High Consistent Rating)", status = "warning", solidHeader = TRUE, width = 4,
                    plotlyOutput("plot_top_directors"))
                )
              ),

      
      
      # --- CONTENT ANALYSIS ---
      tabItem(tabName = "content",
              fluidRow(
                box(title = "🔍 Pilih Film untuk Dianalisis", status = "primary", solidHeader = TRUE, width = 6,
                    DTOutput("table_content_select")), 
                box(title = "☁️ Wordcloud Review Pengguna", status = "danger", solidHeader = TRUE, width = 6,
                    uiOutput("wordcloud_dynamic_area"))
              ),
              
              hr(style = "border-top: 1px solid #d2d6de; margin: 20px 0;"), 
              
              uiOutput("dynamic_sentiment_area")
             ),
            
      
      # --- VARIABLE RELATIONS ---
      tabItem(tabName = "relations",
              fluidRow(
                box(title = "🎯 Duration vs Rating", status = "warning", solidHeader = TRUE, width = 6,
                    plotlyOutput("scatter_plot_dur", height = "350px")),
                box(title = "🔥 Popularity vs Rating", status = "danger", solidHeader = TRUE, width = 6,
                    plotlyOutput("scatter_popularity", height = "350px"))
              ),
              
              hr(style = "border-top: 1px solid #d2d6de; margin: 20px 0;"), 
              
              fluidRow(
                box(title = "🌡️ Variable Correlation Heatmap", status = "primary", solidHeader = TRUE, width = 12,
                    plotlyOutput("corr_heatmap", height = "400px"),
                    footer = "Makin kuning warnanya, makin kuat hubungannya, Boss Lady! ✨")
              )
      )
    )
  )
)
