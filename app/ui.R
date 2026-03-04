library(shiny)
library(shinydashboard)
library(DBI)
library(RMySQL)
library(tidyverse)
library(plotly)
library(DT)
library(wordcloud2)
library(lubridate)
library(digest)
library(dplyr)
library(ggplot2)



# --- 2. UI Section ---
ui <- dashboardPage(
  skin = "black",
  dashboardHeader(title = "Film Analytics Dashboard"),
  
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
    # GLOBAL FILTERS
    selectInput("select_genre", "Pilih Genre:", 
                choices = c("All", unique(df_genre_long$genre_single)), selected = "All"),
    sliderInput("select_rating", "Rentang Rating:", 
                min = 0, max = 10, value = c(0, 10), step = 0.5)
  ),
  
  dashboardBody(
    tags$head(
      tags$style(HTML("
    /* ===== READ MORE BUTTON ===== */
    .toggle-btn {
      color: #3c8dbc;
      font-weight: 600;
      cursor: pointer;
      margin-left: 5px;
    }
    .toggle-btn:hover {
      text-decoration: underline;
    }
    
    /* ===== TABLE HEADER STYLE ===== */
      table.dataTable thead th {
        text-transform: uppercase;
        letter-spacing: 0.5px;
        font-size: 12px;
        font-weight: 700;
        color: #374151;
      }
    
    /* ===== ROW HOVER ===== */
    table.dataTable tbody tr {
    border-bottom: 1px solid #e5e7eb;
    }
    
    /* ===== CELL SPACING ===== */
      table.dataTable tbody td {
        padding: 8px 12px;
        font-size: 13px;
      }

    /* ===== GENRE BADGE ===== */
    .genre-badge {
      display: inline-block;
      padding: 4px 10px;
      margin: 2px 4px 2px 0;
      font-size: 11px;
      font-weight: 600;
      border-radius: 999px;
      color: white;
    }
    
    /* ===== POP-UP DETAIL FILM ===== */
    .modal-content {
      border-radius: 14px;
    }
    
    .modal-header {background-color: #f9fafb;
      border-bottom: 1px solid #e5e7eb;
    }
    
    .modal-body {
      font-size: 14px;
      line-height: 1.6;
    }
    
    .nav-tabs > li > a {
      font-weight: 600;
      color: #374151;
    }

    .nav-tabs > li.active > a {
      background-color: #f3f4f6 !important;
    }
    
    /* Scrollbar modern */
    ::-webkit-scrollbar {
      width: 6px;
    }

    ::-webkit-scrollbar-thumb {
      background: #d1d5db;
      border-radius: 10px;
    }

    ::-webkit-scrollbar-thumb:hover {
      background: #9ca3af;
    }

  "))
    ),
    
    tabItems(
      # --- Tab 1: Overview ---
      tabItem(tabName = "overview",
              fluidRow(
                valueBoxOutput("total_film", width = 4),
                valueBoxOutput("avg_rating", width = 4),
                valueBoxOutput("top_genre", width = 4)
              ),
              fluidRow(
                box(title = "Distribusi Rating Film", status = "primary", solidHeader = TRUE, 
                    plotlyOutput("hist_rating"), width = 6),
                box(title = "Tren Produksi Film per Tahun", status = "primary", solidHeader = TRUE, 
                    plotlyOutput("hist_year"), width = 6)
              )
      ),
      
      # --- Tab 2: Film Explorer ---
      tabItem(tabName = "explorer",
              box(title = "Database Film", width = 12,
                  DTOutput("table_explorer"))
      ),
      
      # --- Tab 3: Genre ---
      tabItem(tabName = "genre_tab",
              fluidRow(
                box(title = "Populer Genre per Tahun", plotlyOutput("genre_year_trend"), width = 12)
              ),
              fluidRow(
                box(title = "Distribusi Rating dalam Genre", plotlyOutput("genre_rating_dist"), width = 6),
                box(title = "Daftar Film Berdasarkan Filter", DTOutput("table_genre_year"), width = 6)
              )
      ),
      
      # --- Tab 4: Top Film ---
      tabItem(tabName = "top_film",
              fluidRow(
                box(title = "🏆 Top 5 Global (Minimal 100 Reviews)", width = 12, status = "danger", solidHeader = TRUE,
                    uiOutput("poster_global_top")),
                
                box(title = textOutput("title_top_rating"), width = 12, status = "primary", solidHeader = TRUE,
                    uiOutput("poster_genre_rating")),
                
                box(title = textOutput("title_top_reviews"), width = 12, status = "success", solidHeader = TRUE,
                    uiOutput("poster_genre_reviews"))
              ),
              fluidRow(
                box(title = "Analisis Skor vs Popularitas (Bubble)", plotlyOutput("bar_top_5"), width = 7),
                box(title = "Distribusi Genre dalam Filter (Donut)", plotlyOutput("wc_synopsis"), width = 5)
              )
      ),
      
      # --- Tab 5: Content Analysis ---
      tabItem(tabName = "content",
              fluidRow(
                # Box Atas: Tabel Film
                box(title = "📌 Pilih Film untuk Analisis Kata", width = 12, status = "primary", solidHeader = TRUE,
                    helpText("Klik pada baris film untuk melihat 15 kata kunci utama dari reviewnya."),
                    div(style = "padding: 10px;", 
                        DTOutput("table_content"))
                )
              ),
              fluidRow(
                # Box Bawah: Wordcloud
                box(title = textOutput("title_wc"), width = 12, status = "warning", solidHeader = TRUE,
                    div(style = "background-color: white; padding: 10px;",
                        wordcloud2Output("wc_review", height = "400px"))
                )
              )
      ),
      
      # --- Tab 6: Relations ---
      tabItem(tabName = "relations",
              fluidRow(
                box(title = "Rating vs Durasi", plotlyOutput("scatter_dur_rate"), width = 6),
                box(title = "Rating Berdasarkan Director", plotlyOutput("box_dir_rate"), width = 6)
              ),
              fluidRow(
                box(title = "Director vs Jumlah Review", plotlyOutput("bar_dir_review"), width = 12)
              )
      )
    )
  )
)