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
library(DBI)
library(jsonlite)

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
    selectInput("select_genre", "🎬 Genre:", choices = "All"),
    sliderInput("select_rating", "⭐ Rating:", min = 0, max = 10, value = c(0, 10), step = 0.5)
  ),
  
  dashboardBody(
    ## Tampilan Sidebar -----------------------------------------------------------------
    tags$head(
      tags$style(HTML("
        /* ===== SIDEBAR FIXED ===== */
        .main-sidebar {
            position: fixed !important;
            height: 100vh;
            overflow-y: auto;
        }
        
        /* supaya content tidak ketutup sidebar */
        .content-wrapper, .main-footer {
            margin-left: 230px;
        }
        
        /* ===== SIDEBAR STYLE ===== */

        .sidebar-menu > li > a{
            transition: all 0.25s ease;
            font-weight: 500;
        }
        
        /* hover menu */
        .sidebar-menu > li > a:hover{
            background: #1f2d36 !important;
            padding-left: 20px;
            transition:all .25s ease;
        }
        
        /* menu aktif */
        .sidebar-menu > li.active > a{
            background: linear-gradient(90deg,#4f6df5,#6c8cff);
            color: white !important;
            border-left: 5px solid #ffffff;
            font-weight:600;
        }
        
        /* icon lebih jelas */
        .sidebar-menu i{
            margin-right: 8px;
        }
        
        /* scrollbar sidebar */
        .main-sidebar::-webkit-scrollbar{
            width:6px;
        }
        
        .main-sidebar::-webkit-scrollbar-thumb{
            background:#6c8cff;
            border-radius:4px;
        }
        
        .main-sidebar{
            background: linear-gradient(180deg,#1f2937,#111827);
        }
        
        .small-box { height: 110px; border-radius: 10px; }
        .box { border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
        .genre-badge { display: inline-block; padding: 2px 8px; font-size: 11px; color: white; border-radius: 10px; font-weight: bold; }
        .modal-lg { width: 90% !important; }
      "))),

    ## Tampilan Modal ----------------------------------------------------------
    tags$head(
      tags$style(HTML("
      /* Modal container */
      .modal-dialog {
        max-width: 900px;
        margin-top: 80px;
      }
      
      /* Modal box */
      .modal-content{
        border-radius:14px;
        border:none;
        box-shadow:0 10px 30px rgba(0,0,0,0.25);
      }
      
      /* Header */
      .modal-header{
        border-bottom:1px solid #f0f0f0;
        font-weight:600;
        font-size:16px;
      }
      
      /* Body spacing */
      .modal-body{
        padding:25px 35px;
      }
      
      /* Footer */
      .modal-footer{
        border-top:1px solid #f0f0f0;
      }
      
      /* Close button */
      .modal-footer .btn{
        border-radius:8px;
      }
      
      "))
      
    ),
    
    tabItems(
      # --- UI: OVERVIEW ---
      # --- UI: OVERVIEW ---
      tabItem(tabName = "overview",
              # BARIS 1: Kotak-kotak Angka (Value Boxes)
              fluidRow(
                column(4, uiOutput("total_film")),
                column(4, uiOutput("avg_rating")),
                column(4, uiOutput("top_movie"))
              ),
              
              # --- PEMBATAS 1 ---
              hr(style = "border-top: 1px solid #d2d6de; margin: 20px 0;"), 
              
              # BARIS 2: Grafik Distribusi & Tren
              fluidRow(
                column(12,
                       tags$div(
                         style="
                                margin-bottom:15px;
                                padding:10px 14px;
                                background:#f1f5f9;
                                border-radius:8px;
                                display:flex;
                                align-items:center;
                                gap:10px;
                                ",
                         
                         tags$strong("Filter Aktif:"),
                         
                         tags$span(
                           style="
                                background:#2563eb;
                                color:white;
                                padding:4px 10px;
                                border-radius:20px;
                                font-size:13px;
                                ",
                           textOutput("genre_active_text", inline=TRUE)
                         )
                       )
                )
              ),
              
              fluidRow(
                box(title = "Distribusi Rating Film", status = "primary", solidHeader = TRUE, 
                    plotlyOutput("hist_rating"), width = 6,
                    tags$div(
                      style="
                        background:#F8FAFC;
                        border-left:5px solid #2563eb;
                        padding:10px 14px;
                        border-radius:6px;
                        margin-top:10px;
                        margin-bottom:12px;
                        font-size:14px;
                        box-shadow:0 2px 6px rgba(0,0,0,0.05);
                      ",
                      
                      
                      tags$strong(icon("lightbulb"), "Rating Insight: "),
                      textOutput("overview_insight", inline = TRUE)
                    )),
                
                box(title = "Tren Produksi Film per Tahun", status = "primary", solidHeader = TRUE, 
                    plotlyOutput("hist_year"), width = 6,
                    tags$div(
                      style="
                        background:#f8fafc;
                        border-left:5px solid #f59e0b;
                        padding:10px 14px;
                        border-radius:6px;
                        margin-top:10px;
                        margin-bottom:12px;
                        font-size:14px;
                        box-shadow:0 2px 6px rgba(0,0,0,0.05);
                      ",
                      
                      tags$strong(icon("chart-line"), " Trend Insight: "),
                      textOutput("trend_insight", inline = TRUE)
                    ))
              ),
              
              # --- PEMBATAS 2 ---
              hr(style = "border-top: 1px solid #d2d6de; margin: 20px 0;"),
              
              # BARIS 3: Tabel Perusahaan Produksi
              fluidRow(
                box(title = "Top 10 Production Companies", status = "success", solidHeader = TRUE, 
                    plotlyOutput("bar_top_studios"), width = 12,
                    tags$div(
                      style="
                        background:#f0fdf4;
                        border-left:5px solid #16a34a;
                        padding:10px 14px;
                        border-radius:6px;
                        margin-top:10px;
                        margin-bottom:12px;
                        font-size:14px;
                        box-shadow:0 2px 6px rgba(0,0,0,0.05);
                      ",
                      
                      tags$strong(icon("building"), " Studio Insight: "),
                      textOutput("studio_insight", inline = TRUE)
                    ))
              )
      ),
      
      
      
      # --- UI: FILM EXPLORER ---
      tabItem(tabName = "explorer",
              box(title = "Database Film (Klik Baris untuk Detail)", width = 12, DTOutput("table_explorer"))
      ),
      
      
      # --- UI: GENRE ANALYSIS (PREMIUM VERSION) ---
      tabItem(tabName = "genre_tab",
              # Baris 1: Tren Tahunan
              fluidRow(
                box(title = "📈 Tren Top 5 Genre Per Tahun", status = "primary", solidHeader = TRUE, 
                    plotlyOutput("genre_year_trend"), width = 12)
              ),
              
              # --- PEMBATAS 1 ---
              hr(style = "border-top: 1px solid #d2d6de; margin: 20px 0;"), 
              
              # Baris 2: Popularitas & Durasi
              fluidRow(
                box(title = "🔥 Popularitas Genre (Total Reviews)", status = "danger", solidHeader = TRUE, 
                    plotlyOutput("genre_pop_score"), width = 6),
                box(title = "⏳ Karakteristik Durasi Per Genre", status = "warning", solidHeader = TRUE, 
                    plotlyOutput("genre_duration_analisis"), width = 6)
              ),
              
              # --- PEMBATAS 1 ---
              hr(style = "border-top: 1px solid #d2d6de; margin: 20px 0;"), 
              
              # Baris 3: Distribusi Rating & Tabel
              fluidRow(
                box(title = "📊 Distribusi Rating Per Genre", status = "info", solidHeader = TRUE, 
                    plotlyOutput("genre_rating_dist"), width = 6),
                box(title = "📋 Daftar Film Terfilter", status = "success", solidHeader = TRUE, 
                    DTOutput("table_genre_year"), width = 6)
              )
      ),
      
      # --- UI: TOP FILMS (3 BARIS POSTER + 3 ANALISIS PREMIUM) ---
      tabItem(tabName = "top_film",
              
              # Baris 1: Top 5 Global
              fluidRow(
                box(
                  title = "🏆 Top 5 Global (Minimal 100 Reviews)",
                  width = 12,
                  status = "danger",
                  solidHeader = TRUE,
                  uiOutput("poster_global_top")
                )
              ),
              
              # --- PEMBATAS 1 ---
              hr(style = "border-top: 1px solid #d2d6de; margin: 20px 0;"), 
              
              # Baris 2: Top 5 per Genre (Rating)
              fluidRow(
                box(title = textOutput("title_top_rating"), width = 12, status = "primary", solidHeader = TRUE, 
                    uiOutput("poster_genre_rating"))
              ),
              
              # --- PEMBATAS 1 ---
              hr(style = "border-top: 1px solid #d2d6de; margin: 20px 0;"), 
              
              # Baris 3: Top 5 per Genre (Most Reviews)
              fluidRow(
                box(title = textOutput("title_top_reviews"), width = 12, status = "success", solidHeader = TRUE, 
                    uiOutput("poster_genre_reviews"))
              ),
              
              # --- PEMBATAS 1 ---
              hr(style = "border-top: 1px solid #d2d6de; margin: 20px 0;"), 
              
              # Baris 4: 3 Poin Analisis Tambahan (Dinamis)
              fluidRow(
                # Poin 1: Skor vs Popularitas (Bubble)
                box(title = "Analisis Skor vs Popularitas (Bubble)", status = "info", solidHeader = TRUE, width = 4,
                    plotlyOutput("bubble_score_pop")),
                
                # Poin 2: Distribusi Genre (Donut)
                box(title = "Proporsi Genre dalam Filter (Donut)", status = "warning", solidHeader = TRUE, width = 4,
                    plotlyOutput("donut_genre_filter")),
                
                # Poin 3: Rata-rata Rating per Tahun (Trend Line)
                box(title = "Kualitas Film dari Tahun ke Tahun", status = "primary", solidHeader = TRUE, width = 4,
                    plotlyOutput("line_rating_trend"))
              ),
              
              # --- PEMBATAS 1 ---
              hr(style = "border-top: 1px solid #d2d6de; margin: 20px 0;"), 
              
              # Baris 5: Bonus Premium Insights (Sesuai Ketersediaan Data)
              fluidRow(
                box(title = "💎 Hidden Gems (Rating Tinggi, Review Sedikit)", status = "info", solidHeader = TRUE, width = 4,
                    plotlyOutput("plot_hidden_gems")),
                
                box(title = "🔥 Movie Engagement (Popularitas vs Rating)", status = "danger", solidHeader = TRUE, width = 4,
                    plotlyOutput("plot_engagement")),
                
                box(title = "🎬 Top 5 Directors (High Consistent Rating)", status = "warning", solidHeader = TRUE, width = 4,
                    plotlyOutput("plot_top_directors"))
              )
      ),
      
      
      
      # --- UI: CONTENT ANALYSIS ---
      tabItem(tabName = "content",
              fluidRow(
                # Panel Kiri: Tabel Film (Tetap)
                box(title = "🔍 Pilih Film untuk Dianalisis", status = "primary", solidHeader = TRUE, width = 6,
                    DTOutput("table_content_select")),
                
                # Panel Kanan: Wordcloud (Tetap)
                box(title = "☁️ Wordcloud Review Pengguna", status = "danger", solidHeader = TRUE, width = 6,
                    uiOutput("wordcloud_dynamic_area"))
              ),
              
              # --- PEMBATAS 1 ---
              hr(style = "border-top: 1px solid #d2d6de; margin: 20px 0;"), 
              
              uiOutput("dynamic_sentiment_area")
      ),
      
      
      # --- UI: VARIABLE RELATIONS ---
      tabItem(tabName = "relations",
              fluidRow(
                # Row 1: Korelasi Durasi vs Rating (Kiri) & Popularitas vs Rating (Kanan)
                box(title = "🎯 Duration vs Rating", status = "warning", solidHeader = TRUE, width = 6,
                    plotlyOutput("scatter_plot_dur", height = "350px")),
                
                box(title = "🔥 Popularity vs Rating", status = "danger", solidHeader = TRUE, width = 6,
                    plotlyOutput("scatter_popularity", height = "350px"))
              ),
              
              # --- PEMBATAS 1 ---
              hr(style = "border-top: 1px solid #d2d6de; margin: 20px 0;"), 
              
              fluidRow(
                # Row 2: Heatmap Korelasi di bawahnya biar lebar dan megah
                box(title = "🌡️ Variable Correlation Heatmap", status = "primary", solidHeader = TRUE, width = 12,
                    plotlyOutput("corr_heatmap", height = "400px"),
                    footer = "Makin kuning warnanya, makin kuat hubungannya, Boss Lady! ✨")
              )
      )
    )
  )
)
