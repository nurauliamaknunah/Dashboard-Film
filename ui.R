library(shiny)
library(shinydashboard)
library(tidyverse)
library(plotly)
library(DT)
library(wordcloud2)
library(lubridate)

# --- 1. Load & Preprocessing Data ---
# Pastikan path file benar. Jika file satu folder dengan app.R, cukup gunakan "Dataset Film Raw.csv"
df_raw <- read.csv("D:/Project WEB/Dataset Film Raw.csv", stringsAsFactors = FALSE)

# Membersihkan format list pada kolom genre dan director agar bisa diolah
df_clean <- df_raw %>%
  mutate(
    release_date = dmy(release_date), # Mengubah ke format Date
    year = year(release_date),
    # Membersihkan string genre ['Action', 'Drama'] menjadi Action, Drama
    genre_clean = str_remove_all(genre, "[\\[\\]']"),
    director_clean = str_remove_all(director, "[\\[\\]']")
  )

# Dataframe untuk keperluan analisis genre (long format)
df_genre_long <- df_clean %>%
  separate_rows(genre_clean, sep = ", ") %>%
  rename(genre_single = genre_clean)

# --- FIX ERROR USIA ---
# Saya hapus bagian perhitungan usia karena kolom 'date_of_birth' biasanya tidak ada di dataset film standar.
# Jika kamu butuh kategori usia, pastikan kolomnya ada di CSV.

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
    tags$head(tags$style(HTML(".small-box {height: 120px;} .table-container {overflow-x: auto;}"))),
    
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
              box(title = "Database Film", width = 12, status = "primary",
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


shinyApp(ui = ui)