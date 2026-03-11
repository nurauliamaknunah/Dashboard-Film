# KONFIGURASI DATABASE ----------------------------------------------------

db_config <- list(
  host = "127.0.0.1",
  port = 3307,
  user = "root",
  password = "",
  dbname = "project_pdb"
)

## Membuat Koneksi Database ----------------------------------------------
con <- dbConnect(
  RMySQL::MySQL(),
  host     = db_config$host,
  port     = db_config$port,
  user     = db_config$user,
  password = db_config$password,
  dbname   = db_config$dbname
)

## Database Connection Management ------------------------------------------
onStop(function(){
  if(DBI::dbIsValid(con)){
    dbDisconnect(con)
  }
})

## Database Helper Function ------------------------------------------------
def_safe_query <- function(q) {
  tryCatch({
    dbGetQuery(con, q)
  }, error = function(e) {
    warning(e$message)
    return(data.frame())
  })
}


# POSTER ----------------------------------------------------------------
get_poster_omdb <- function(imdb_id){
  
  url <- paste0(
    "http://www.omdbapi.com/?i=",
    imdb_id,
    "&apikey=20344ce8"
  )
  
  res <- tryCatch(
    jsonlite::fromJSON(url),
    error = function(e) NULL
  )
  
  if(!is.null(res) && res$Response == "True" && res$Poster != "N/A"){
    
    return(res$Poster)
    
  } else {
    
    return("https://via.placeholder.com/300x450?text=No+Poster")
    
  }
  
}

# SERVER.R ----------------------------------------------------------------
server <- function(input, output, session) {
  
  # Update Dropdown Genre
  observe({
    genres <- def_safe_query("SELECT genre_name FROM genres ORDER BY genre_name")
    if(nrow(genres) > 0) updateSelectInput(session, "select_genre", choices = c("All", genres$genre_name))
  })
  

  ## Menu Overview -----------------------------------------------------------
  ov_filtered_data <- reactive({
    # Pakai LEFT JOIN agar film tanpa genre tetap masuk hitungan
    q <- sprintf("SELECT DISTINCT f.imdb_id, f.rating_imdb, YEAR(f.release_date) as year, f.title 
                  FROM films f 
                  LEFT JOIN film_genres fg ON f.imdb_id = fg.imdb_id 
                  LEFT JOIN genres g ON fg.genre_id = g.genre_id 
                  WHERE (f.rating_imdb BETWEEN %f AND %f OR f.rating_imdb IS NULL)", 
                 input$select_rating[1], input$select_rating[2])
    
    # Supaya kalau pilih genre tertentu tetap jalan, tapi kalau 'All' tetap 1553
    if(input$select_genre != "All") {
      q <- paste0(q, sprintf(" AND g.genre_name = '%s'", input$select_genre))
    }
    
    def_safe_query(q)
  })

  ### Total Film --------------------------------------------------------------
  output$total_film <- renderUI({
    
    res <- ov_filtered_data()
    total <- nrow(res)
    
    tags$div(
      style="
            background:linear-gradient(135deg,#1f78b4,#2f89c5);
            color:white;
            padding:18px 22px;
            border-radius:12px;
            height:110px;
            position:relative;
            overflow:hidden;
            box-shadow:0 10px 20px rgba(0,0,0,0.18);
            transition:all 0.2s ease;
            ",
      
      # angka KPI
      tags$div(
        style="font-size:34px;font-weight:700;letter-spacing:1px;",
        total
      ),
      
      # label
      tags$div(
        style="font-size:14px;opacity:0.9;",
        "Film Terpilih"
      ),
      
      # icon background
      tags$i(
        class="fa fa-video-camera",
        style="
              position:absolute;
              right:15px;
              top:20px;
              font-size:70px;
              opacity:0.12;
              "
      )
    )
  })

  ### Average Rating ----------------------------------------------------------
  output$avg_rating <- renderUI({
    
    res <- ov_filtered_data()
    avg_v <- if(nrow(res) > 0) round(mean(res$rating_imdb, na.rm=TRUE), 2) else 0
    
    tags$div(
      style="
            background:linear-gradient(135deg,#f59e0b,#ffb020);
            color:white;
            padding:18px 22px;
            border-radius:12px;
            height:110px;
            position:relative;
            overflow:hidden;
            box-shadow:0 10px 20px rgba(0,0,0,0.18);
            transition:all 0.2s ease;
            ",
      
      tags$div(
        style="font-size:34px;font-weight:700;letter-spacing:1px;",
        avg_v
      ),
      
      tags$div(
        style="font-size:14px;opacity:0.9;",
        "Rata-rata Rating"
      ),
      
      tags$i(
        class="fa fa-star",
        style="
              position:absolute;
              right:15px;
              top:20px;
              font-size:70px;
              opacity:0.12;
              "
      )
    )
  })

  ### Top Movie ---------------------------------------------------------------
  output$top_movie <- renderUI({
    
    res <- ov_filtered_data()
    res <- res[!is.na(res$rating_imdb), ]
    
    if(nrow(res)==0) return(NULL)
    
    top <- res[which.max(res$rating_imdb),]
    
    tags$div(
      style="
            background:linear-gradient(135deg,#6b5fa7,#7a6ec2);
            color:white;
            padding:18px 22px;
            border-radius:12px;
            height:110px;
            position:relative;
            display:flex;
            flex-direction:column;
            justify-content:center;
            box-shadow:0 10px 20px rgba(0,0,0,0.18);
            transition:all 0.2s ease;
            ",
      
      # Judul
      tags$div(
        style="font-size:24px;font-weight:600;",
        stringr::str_trunc(top$title, 30)
      ),
      
      # Rating
      tags$div(
        style="font-size:26px;font-weight:700;color:#ffd166;letter-spacing:1px;",
        paste0("⭐ ", round(top$rating_imdb,1))
      ),
      
      tags$div(
        style="font-size:12px;opacity:0.85;",
        "Top Rated Movie"
      ),
      
      # Icon Trophy Background
      tags$i(
        class="fa fa-trophy",
        style="
              position:absolute;
              right:18px;
              top:18px;
              font-size:70px;
              opacity:0.12;
              "
      )
    )
  })

  ### Active Genre ------------------------------------------------------------
  output$genre_active_text <- renderText({
    
    genre <- input$select_genre
    rating <- paste(input$select_rating[1], "-", input$select_rating[2])
    
    paste0("Genre: ",genre," | Rating: ",rating)
    
  })
  

  ### Distribusi Rating Film --------------------------------------------------

  #### Histogram ---------------------------------------------------------------
  output$hist_rating <- renderPlotly({
    
    res <- ov_filtered_data()
    req(nrow(res) > 0)
    avg_rating <- mean(res$rating_imdb, na.rm = TRUE)
    
    label_data <- data.frame(
      rating_imdb = avg_rating,
      count = 5
    )
    
    p <- ggplot(res, aes(x = rating_imdb)) +
      geom_histogram(
        fill = "#4C78A8",
        color = "white",
        bins = 20
      ) +
      geom_text(
        aes(
          x = avg_rating,
          y = Inf,
          label = paste0("Avg: ",round(avg_rating,1))
        ),
        vjust = -0.5,
        color = "#e63946",
        size = 4,
        fontface = "bold"
      ) +
      labs(
        subtitle = paste("Rata-rata rating:",round(avg_rating,2)),
        x = "Rating IMDb",
        y = "Jumlah Film"
      ) +
      theme_minimal() +
      theme(
        panel.grid.minor = element_blank(),
        panel.grid.major.x = element_blank()
      )
    
    ggplotly(p)
    
  })

  #### Insight -----------------------------------------------------------------
  output$overview_insight <- renderText({
    
    res <- ov_filtered_data()
    req(nrow(res) > 0)
    
    avg_rating <- round(mean(res$rating_imdb, na.rm = TRUE),2)
    
    q1 <- quantile(res$rating_imdb, 0.25, na.rm = TRUE)
    q3 <- quantile(res$rating_imdb, 0.75, na.rm = TRUE)
    
    genre <- input$select_genre
    
    if(genre == "All"){
      
      paste0(
        "Mayoritas film memiliki rating antara ",
        round(q1,1)," – ",round(q3,1),
        " dengan rata-rata ",avg_rating,
        ". Distribusi rating menunjukkan kualitas film yang relatif stabil."
      )
      
    } else {
      
      paste0(
        "Film genre ",genre,
        " memiliki rata-rata rating ",avg_rating,
        ", dengan sebagian besar film berada di rentang ",
        round(q1,1)," – ",round(q3,1),"."
      )
      
    }
    
  })

  ### Tren Produksi Pertahun -----------------------------------------------
  #### Line Chart --------------------------------------------------------------
  output$hist_year <- renderPlotly({
    res <- ov_filtered_data()
    
    # Filter NULL hanya untuk keperluan visualisasi grafik
    res_plot <- res %>% 
      group_by(year) %>% 
      summarise(n = n()) %>% 
      filter(!is.na(year)) # Data NULL tidak digambar tapi tetap ada di database
    
    req(nrow(res_plot) > 0)
    
    p <- ggplot(res_plot, aes(x = year, y = n)) + 
      geom_line(color = "#2C5C85", size = 0.8) +
      geom_smooth(method = "loess",
                  se = FALSE,
                  color = "#f59e0b",
                  linetype = "dashed",
                  size = 0.6) + 
      geom_point(color = "#2C5C85", size = 1.2, aes(text = paste("Tahun:", year, "<br>Jumlah:", n))) + 
      labs(x = "Tahun Rilis", y = "Jumlah Film") + 
      theme_minimal()
    
    ggplotly(p, tooltip = "text")
  })

  #### Insight -----------------------------------------------------------------
  output$trend_insight <- renderText({
    
    res <- ov_filtered_data()
    
    trend <- res %>%
      group_by(year) %>%
      summarise(n = n()) %>%
      filter(!is.na(year))
    
    if(nrow(trend) < 3) return("Data tren belum cukup untuk dianalisis.")
    
    peak_year <- trend$year[which.max(trend$n)]
    peak_value <- max(trend$n)
    
    paste0(
      "Produksi film mencapai puncaknya pada tahun ",
      peak_year,
      " dengan total ",
      peak_value,
      " film."
    )
    
  })

  ### Top 10 Studio Produksi --------------------------------------------------
  #### Barchart ----------------------------------------------------------------
  output$bar_top_studios <- renderPlotly({
    # Gunakan LEFT JOIN agar semua film tetap terhitung meskipun studio/genre kosong
    q <- sprintf("SELECT pc.company_name, COUNT(DISTINCT f.imdb_id) as n 
                  FROM films f
                  LEFT JOIN film_production_companies fpc ON f.imdb_id = fpc.imdb_id
                  LEFT JOIN production_companies pc ON fpc.company_id = pc.company_id
                  LEFT JOIN film_genres fg ON f.imdb_id = fg.imdb_id
                  LEFT JOIN genres g ON fg.genre_id = g.genre_id
                  WHERE (f.rating_imdb BETWEEN %f AND %f OR f.rating_imdb IS NULL)", 
                 input$select_rating[1], input$select_rating[2])
    
    if(input$select_genre != "All") {
      q <- paste0(q, sprintf(" AND g.genre_name = '%s'", input$select_genre))
    }
    
    q <- paste0(q, " GROUP BY pc.company_name ORDER BY n DESC LIMIT 10")
    res <- def_safe_query(q)
    req(nrow(res) > 0)
    
    # Beri nama "Unknown Studio" jika ada film tanpa data production company
    res$company_name[is.na(res$company_name)] <- "Unknown Studio"
    
    p <- ggplot(res, aes(x=reorder(company_name,n), y=n, fill=n)) +
      geom_bar(stat="identity") +
      coord_flip() +
      scale_fill_gradient(
        low="#D1FAE5",
        high="#059669"
      ) +
      scale_y_continuous(expand=expansion(mult=c(0, 0.08))) +
      theme_minimal() +
      theme(legend.position="none") +
      labs(x="", y="Total Film")
    
    ggplotly(p)
  })

  #### Insight -----------------------------------------------------------------
  output$studio_insight <- renderText({
    
    q <- sprintf("
    SELECT pc.company_name, COUNT(DISTINCT f.imdb_id) as n
    FROM films f
    LEFT JOIN film_production_companies fpc ON f.imdb_id = fpc.imdb_id
    LEFT JOIN production_companies pc ON fpc.company_id = pc.company_id
    LEFT JOIN film_genres fg ON f.imdb_id = fg.imdb_id
    LEFT JOIN genres g ON fg.genre_id = g.genre_id
    WHERE (f.rating_imdb BETWEEN %f AND %f OR f.rating_imdb IS NULL)
  ",
                 input$select_rating[1],
                 input$select_rating[2])
    
    if(input$select_genre != "All"){
      q <- paste0(q, sprintf(" AND g.genre_name = '%s'", input$select_genre))
    }
    
    q <- paste0(q,"
    GROUP BY pc.company_name
    ORDER BY n DESC
  ")
    
    res <- def_safe_query(q)
    
    if(nrow(res) == 0){
      return("Tidak ada studio pada filter ini.")
    }
    
    # Ganti NA menjadi Unknown Studio
    res$company_name[is.na(res$company_name)] <- "Unknown Studio"
    
    max_n <- max(res$n)
    
    top_studios <- res$company_name[res$n == max_n]
    
    # Format nama studio
    if(length(top_studios) == 1){
      
      studio_list <- top_studios
      
    } else if(length(top_studios) == 2){
      
      studio_list <- paste(top_studios, collapse = " dan ")
      
    } else {
      
      studio_list <- paste(
        paste(top_studios[-length(top_studios)], collapse = ", "),
        top_studios[length(top_studios)],
        sep = ", dan "
      )
      
    }
    
    paste0(
      studio_list,
      " merupakan studio paling produktif dengan ",
      max_n,
      " film pada filter yang dipilih."
    )
    
  })
  
  
  ## Menu Film Explorer ------------------------------------------------------
  ### Reactive Data -----------------------------------------------------------
  # Gabungkan Genre dan Director jadi satu baris per film
  explorer_filtered_data <- reactive({
    q <- sprintf("SELECT f.title, f.rating_imdb as rating, f.rating_count, 
                  f.duration_min, f.release_date, f.imdb_id, f.storyline,
                  GROUP_CONCAT(DISTINCT g.genre_name SEPARATOR ', ') as genres,
                  GROUP_CONCAT(DISTINCT d.director_name SEPARATOR ', ') as directors
                  FROM films f 
                  LEFT JOIN film_genres fg ON f.imdb_id = fg.imdb_id 
                  LEFT JOIN genres g ON fg.genre_id = g.genre_id 
                  LEFT JOIN film_directors fd ON f.imdb_id = fd.imdb_id
                  LEFT JOIN directors d ON fd.director_id = d.director_id
                  WHERE (f.rating_imdb BETWEEN %f AND %f OR f.rating_imdb IS NULL)", 
                 input$select_rating[1], input$select_rating[2])
    
    # Filter Sidebar: Tetap sinkron tapi tidak merusak jumlah total kalau "All"
    if(input$select_genre != "All") {
      q <- paste0(q, sprintf(" AND f.imdb_id IN (
                                SELECT fg2.imdb_id FROM film_genres fg2 
                                JOIN genres g2 ON fg2.genre_id = g2.genre_id 
                                WHERE g2.genre_name = '%s'
                              )", input$select_genre))
    }
    
    # WAJIB ADA: Biar satu film jadi satu baris rapi
    q <- paste0(q, " GROUP BY f.imdb_id") 
    
    def_safe_query(q)
  })
  

  #### Genre badge function ----------------------------------------------------
  all_genres <- def_safe_query(
    "SELECT genre_name FROM genres"
  )$genre_name
  
  genre_palette <- c(
    "#4F46E5","#059669","#DC2626","#D97706","#2563EB",
    "#7C3AED","#0E7490","#BE185D","#1F2937","#9333EA",
    "#EA580C","#0891B2","#65A30D","#C026D3","#0F766E",
    "#B91C1C","#0369A1","#CA8A04","#14B8A6","#A855F7"
  )
  
  genre_color_map <- setNames(
    genre_palette[seq_along(all_genres)],
    all_genres
  )
  
  make_genre_badge <- function(text){
    genres <- strsplit(text, ",\\s*")[[1]]
    badges <- sapply(genres, function(g){
      color <- genre_color_map[g]
      paste0(
        "<span style='
            background:",color,";
            color:white;
            padding:3px 8px;
            border-radius:8px;
            font-size:11px;
            margin-right:4px;
            display:inline-block;
          '>",g,"</span>"
      )
    })
    paste(badges, collapse=" ")
  }

  #### Rating badge function ---------------------------------------------------
  make_rating_badge <- function(r){
    color <- ifelse(
      r >= 8, "#059669",
      ifelse(r >= 6, "#2563EB", "#DC2626")
    )
    
    paste0(
      "<span style='
        background:",color,";
        color:white;
        padding:4px 8px;
        border-radius:999px;
        font-weight:600;
        font-size:12px;
      '>",sprintf("%.1f",r),"</span>"
    )
  }

  ### Tabel -------------------------------------------------------------------
  output$table_explorer <- renderDT({
    df <- explorer_filtered_data()
    req(nrow(df) > 0)
    
    df_display <- df

    # Format release date 
    df_display$release_date <- format(
      as.Date(df_display$release_date),
      "%d %b %Y"
    )

    # Genre badge 
    df_display$genres <- sapply(df_display$genres, make_genre_badge)
    
    # Rating badge 
    rating_raw <- df_display$rating
    rating_raw <- ifelse(is.na(df_display$rating), 0, df_display$rating)
    
    df_display$rating <- sapply(rating_raw, make_rating_badge)
    df_display$rating_sort <- rating_raw

    # Format title review 
    df_display$rating_count <- paste0(
      "💬 ",
      format(df_display$rating_count, big.mark = ",")
    )
    
    # Title style
    df_display$title <- paste0(
      "<span style='font-weight:600;color:#1f2937;'>",
      df_display$title,
      "</span>"
    )
    
    # Datatable
    datatable(
      
      df_display %>%
        select(
          title,
          genres,
          directors,
          rating,
          rating_count,
          duration_min,
          release_date,
          rating_sort
        ),
      
      escape = FALSE,
      selection = "single",
      rownames = FALSE,
      
      colnames = c(
        "Title",
        "Genre",
        "Director",
        "Rating",
        "Reviews",
        "Duration (min)",
        "Release Date",
        "rating_sort"
      ),
      
      options = list(
        pageLength = 10,
        scrollX = TRUE,
        order = list(list(0,"asc")),
        
        columnDefs = list(
          list(visible = FALSE, targets = 7),   # sembunyikan rating_sort
          list(orderData = 7, targets = 3),      # kolom rating pakai rating_sort
          list(className='dt-body-center', targets=c(3,4,5,6)),
          list(width='30%', targets=0)
        )
        
      )
      
    )
    
  }, server = TRUE)

  ### Model Detail ------------------------------------------------------------
  observeEvent(input$table_explorer_rows_selected, {
    
    s <- input$table_explorer_rows_selected
    req(s)
    
    info <- explorer_filtered_data()[s, ]

    # Ambil data review (termasuk rating tanpa review)
    reviews_sub <- def_safe_query(sprintf(
        "SELECT username, rating_user, review_summary, review_content
       FROM reviews
       WHERE imdb_id = '%s'
       ORDER BY rating_user DESC
       LIMIT 20", info$imdb_id
    ))
    
    # Poster Placeholder (jika tidak ada poster)
    poster_url <- "https://via.placeholder.com/220x320?text=No+Poster"
    
    # Ambil data actor
    actors <- def_safe_query(sprintf("
              SELECT GROUP_CONCAT(a.actor_name SEPARATOR ', ') AS actors
              FROM film_actors fa
              JOIN actors a 
                ON fa.actor_id = a.actor_id
              WHERE fa.imdb_id = '%s'
            ", info$imdb_id))
    actors_text <- ifelse(
      nrow(actors) == 0 || is.na(actors$actors[1]),
      "Tidak tersedia",
      actors$actors[1]
    )
    
    # Ambil data review
    reviews_sub <- def_safe_query(sprintf(
      "SELECT username, review_content
       FROM reviews
       WHERE imdb_id = '%s'
       LIMIT 20",
      info$imdb_id
    ))
    
    # Generate review cards
    review_cards <- ""
    
    if(nrow(reviews_sub) > 0){
      
      review_cards <- paste(
        apply(reviews_sub, 1, function(r){
          
          review_text <- ifelse(
            is.na(r["review_content"]) || r["review_content"] == "",
            "<i>User tidak menulis review.</i>",
            substr(r["review_content"],1,350)
          )
          
          paste0(
            "<div style='
          padding:14px;
          margin-bottom:12px;
          background:#f9fafb;
          border-radius:10px;
          border:1px solid #e5e7eb;
        '>

        <b>", r["username"], "</b>

        <div style='margin-top:6px;'>
          <p style='margin-top:4px;'>", review_text, "</p>
        </div>

        </div>"
          )
          
        }),
        collapse=""
      )
      
    }
    
    # Modal Detail Film
    showModal(
      
      modalDialog(
        
        title = paste("🎬 Detail:", info$title),
        size = "l",
        easyClose = TRUE,
        footer = modalButton("Close"),
        fade = TRUE,
        
        tabsetPanel(
          #### Tab Info ----------------------------------------------------------------
          tabPanel(
            
            "Info",
            
            fluidRow(
              
              column(
                4,
                
                tags$img(
                  src = poster_url,
                  style="
                        width:100%;
                        border-radius:10px;
                        box-shadow:0 2px 8px rgba(0,0,0,0.15);
                      "
                )
                
              ),
              
              column(
                8,
                
                tags$h3(info$title),
                
                tags$div(
                  style="margin-bottom:8px;",
                  HTML("⭐ " , make_rating_badge(info$rating)),
                  tags$span(
                    style="margin-left:10px;",
                    paste0("⏱ ", info$duration_min, " min")
                  ),
                  tags$span(
                    paste0("💬 ", format(info$rating_count, big.mark=","), " reviews")
                  )
                ),
                
                tags$div(
                  style="margin-bottom:10px;",
                  HTML(make_genre_badge(info$genres))
                ),
                
                tags$div(
                  style="
                        display:flex;
                        gap:20px;
                        font-size:14px;
                        color:#6b7280;
                        margin-bottom:10px;
                        ",
                  tags$span(
                    paste0("📢 ", info$directors)
                  )
                ),
              )
              
            ),
            
            tags$hr(),
            tags$p(tags$b("📖 Sinopsis")),
            tags$p(info$storyline),
            
            tags$hr(),
            tags$p(tags$b("🎭 Cast")),
            tags$p(actors_text)
            
          ),

          #### Tab Review --------------------------------------------------------------
          tabPanel(
            
            paste0("Review Pengguna (", nrow(reviews_sub), ")"),
            
            if(nrow(reviews_sub) == 0){
              
              tags$p("Belum ada review untuk film ini.")
              
            } else {
              
              tags$div(
                
                style="
                      max-height:400px;
                      overflow-y:auto;
                      padding-right:5px;
                    ",
                
                HTML(review_cards)
                
              )
              
            }
            
          )
          
        )
        
      )
      
    )
    
  })
  

  ## Menu Genre Analysis -----------------------------------------------------
  ### Barchart Genre Popularity --------------------------------------------------------
  output$genre_pop_score <- renderPlotly({
    q <- sprintf("SELECT g.genre_name, SUM(f.rating_count) as total_reviews
                  FROM films f
                  LEFT JOIN film_genres fg ON f.imdb_id = fg.imdb_id
                  LEFT JOIN genres g ON fg.genre_id = g.genre_id
                  WHERE (f.rating_imdb BETWEEN %f AND %f OR f.rating_imdb IS NULL)
                  GROUP BY g.genre_name
                  ORDER BY total_reviews DESC LIMIT 10", 
                 input$select_rating[1], input$select_rating[2])
    res <- def_safe_query(q)
    req(nrow(res) > 0)
    
    # Beri label "No Genre" untuk yang NULL
    res$genre_name[is.na(res$genre_name)] <- "Unknown"
    
    p <- ggplot(res, aes(x = reorder(genre_name, total_reviews), y = total_reviews, fill = total_reviews)) +
      geom_bar(stat = "identity") + coord_flip() +
      scale_fill_gradient(low="#fecaca", high="#ef4444") +
      theme_minimal() + labs(x = "", y = "Total Engagement (Reviews)")
    
    ggplotly(p)
  })

  ### Lolipop Chart Durasi vs Genre ------------------------------------------------
  output$genre_duration_analisis <- renderPlotly({
    q <- sprintf("SELECT g.genre_name, AVG(f.duration_min) as avg_dur
                  FROM films f
                  LEFT JOIN film_genres fg ON f.imdb_id = fg.imdb_id
                  LEFT JOIN genres g ON fg.genre_id = g.genre_id
                  WHERE (f.rating_imdb BETWEEN %f AND %f OR f.rating_imdb IS NULL)
                  GROUP BY g.genre_name
                  ORDER BY avg_dur DESC", 
                 input$select_rating[1], input$select_rating[2])
    res <- def_safe_query(q)
    req(nrow(res) > 0)
    res$genre_name[is.na(res$genre_name)] <- "Unknown"
    
    p <- ggplot(res, aes(x = reorder(genre_name, avg_dur), y = avg_dur)) +
      geom_segment(aes(xend=genre_name, yend=0), color="grey") +
      geom_point(size=4, color="#f59e0b") + coord_flip() +
      theme_minimal() + labs(x = "", y = "Avg Duration (Min)")
    
    ggplotly(p)
  })
  
  ### Tren Top 5 Genre --------------------------------------------------------
  output$genre_year_trend <- renderPlotly({
    # 1. Cari Top 5 Genre dulu (Biar grafik nggak penuh sesak)
    top_5_query <- sprintf("SELECT g.genre_name, COUNT(*) as c 
                             FROM films f
                             LEFT JOIN film_genres fg ON f.imdb_id = fg.imdb_id 
                             LEFT JOIN genres g ON fg.genre_id = g.genre_id 
                             WHERE (f.rating_imdb BETWEEN %f AND %f OR f.rating_imdb IS NULL)
                             GROUP BY g.genre_name 
                             ORDER BY c DESC LIMIT 5", 
                           input$select_rating[1], input$select_rating[2])
    
    top_5_data <- def_safe_query(top_5_query)
    req(nrow(top_5_data) > 0)
    top_names <- top_5_data$genre_name[!is.na(top_5_data$genre_name)]
    
    # 2. Ambil data tahunan (Gunakan YEAR() dari SQL agar cepat)
    q <- sprintf("SELECT g.genre_name, YEAR(f.release_date) as year_val, COUNT(*) as n
                  FROM films f
                  LEFT JOIN film_genres fg ON f.imdb_id = fg.imdb_id
                  LEFT JOIN genres g ON fg.genre_id = g.genre_id
                  WHERE (f.rating_imdb BETWEEN %f AND %f OR f.rating_imdb IS NULL)
                  AND f.release_date IS NOT NULL", 
                 input$select_rating[1], input$select_rating[2])
    
    # Filter Genre Dinamis
    if(input$select_genre != "All") {
      q <- paste0(q, sprintf(" AND g.genre_name = '%s'", input$select_genre))
    } else {
      q <- paste0(q, sprintf(" AND g.genre_name IN ('%s')", paste(top_names, collapse="','")))
    }
    
    q <- paste0(q, " GROUP BY year_val, g.genre_name ORDER BY year_val")
    res <- def_safe_query(q)
    req(nrow(res) > 0)
    
    p <- ggplot(res, aes(x = year_val, y = n, color = genre_name)) + 
      geom_line(size = 1) + geom_point(size = 2) +
      scale_color_brewer(palette = "Set1") + # Warna lebih kontras
      theme_minimal() + labs(x = "Tahun Rilis", y = "Jumlah Film")
    
    ggplotly(p)
  })

  ### Boxplot Distribusi Rating -----------------------------------------------
  output$genre_rating_dist <- renderPlotly({
    q <- sprintf("SELECT f.rating_imdb, g.genre_name 
                  FROM films f 
                  LEFT JOIN film_genres fg ON f.imdb_id = fg.imdb_id 
                  LEFT JOIN genres g ON fg.genre_id = g.genre_id 
                  WHERE (f.rating_imdb BETWEEN %f AND %f OR f.rating_imdb IS NULL)", 
                 input$select_rating[1], input$select_rating[2])
    
    if(input$select_genre != "All") {
      q <- paste0(q, sprintf(" AND g.genre_name = '%s'", input$select_genre))
    }
    
    res <- def_safe_query(q)
    req(nrow(res) > 0)
    res$genre_name[is.na(res$genre_name)] <- "Unknown"
    
    p <- ggplot(res, aes(x = reorder(genre_name, rating_imdb, FUN = median), 
                         y = rating_imdb, fill = genre_name)) + 
      geom_boxplot(alpha = 0.7) + coord_flip() + 
      theme_minimal() + theme(legend.position = "none") +
      labs(x = "", y = "IMDb Rating")
    
    ggplotly(p)
  })

  ### Tabel Daftar Film -------------------------------------------------------
  # Pakai reactive explorer_filtered_data agar sinkron
  output$table_genre_year <- renderDT({
    df <- explorer_filtered_data() # Memanggil fungsi reactive yang sudah ada
    req(nrow(df) > 0)
    datatable(df %>% select(`Judul` = title, `Rating` = rating, `Genre` = genres), 
              options = list(pageLength = 5), rownames = FALSE, escape = FALSE)
  })
  
  
  ## Menu Top Film -----------------------------------------------------------
  # Fungsi Render Kartu Premium (Otomatis Link URL Poster)
  omdb_key <- "20344ce8"
  
  render_premium_cards <- function(data){
    
    if(nrow(data) == 0){
      return(tags$p("Data tidak tersedia"))
    }
    
    fluidRow(
      style="padding:10px; display:flex; flex-wrap:wrap; justify-content:center;",
      
      lapply(1:nrow(data), function(i){
        
        column(
          width = 2,
          style="width:20%; min-width:160px; padding:10px;",
          
          div(
            style="
              background:white;
              border-radius:15px;
              box-shadow:0 8px 25px rgba(0,0,0,0.12);
              overflow:hidden;
              border:1px solid #eee;",
            
            
            # POSTER
            div(
              style="width:100%; height:240px; overflow:hidden;",
              
              tags$img(
                src = data$poster_url[i],
                style="width:100%; height:100%; object-fit:cover;",
                onerror="this.src='https://via.placeholder.com/300x450?text=No+Poster';"
              )
            ),
            
            
            # INFO FILM
            div(
              style="padding:12px; text-align:center;",
              
              tags$p(
                strong(data$title[i]),
                style="font-size:13px; height:32px; overflow:hidden;"
              ),
              
              div(
                style="color:#f1c40f; font-weight:bold; font-size:15px;",
                paste("★", format(data$rating_imdb[i], nsmall=1))
              ),
              
              tags$p(
                paste(data$rating_count[i], "Reviews"),
                style="font-size:10px;color:#999;margin:0;"
              )
              
            )
            
          )
          
        )
        
      })
      
    )
  }
  
  # Judul Dinamis
  output$title_top_rating <- renderText({ paste("⭐ Top 5 Rating Tertinggi - Genre:", input$select_genre) })
  output$title_top_reviews <- renderText({ paste("💬 Top 5 Review Terbanyak - Genre:", input$select_genre) })

  ### Top 5 Global (Minimal 100 Reviews) --------------------------------------
  output$poster_global_top <- renderUI({
    
    query <- sprintf("
      SELECT 
          imdb_id,
          title,
          rating_imdb,
          rating_count
      FROM films
      WHERE rating_count >= 100
      AND rating_imdb BETWEEN %f AND %f
      ORDER BY rating_imdb DESC
      LIMIT 5
  ",
                     input$select_rating[1],
                     input$select_rating[2]
    )
    
    data <- dbGetQuery(con, query)
    
    # Function ambil poster
    get_poster <- function(id){
      
      url <- paste0(
        "http://www.omdbapi.com/?i=",
        id,
        "&apikey=20344ce8"
      )
      
      res <- tryCatch(jsonlite::fromJSON(url), error=function(e) NULL)
      
      if(!is.null(res) && res$Response == "True" && res$Poster != "N/A"){
        return(res$Poster)
      } else{
        return("https://placehold.co/300x450/111827/FFFFFF?text=No+Poster")
      }
    }
    
    data$poster_url <- sapply(data$imdb_id, get_poster)
    
    render_premium_cards(data)
    
  })

  ### Top 5 per Genre ---------------------------------------------------------
  output$poster_genre_rating <- renderUI({
    
    query <- sprintf("
  SELECT DISTINCT
      f.imdb_id,
      f.title,
      f.rating_imdb,
      f.rating_count
  FROM films f
  LEFT JOIN film_genres fg ON f.imdb_id = fg.imdb_id
  LEFT JOIN genres g ON fg.genre_id = g.genre_id
  WHERE (g.genre_name = '%s' OR 'All' = '%s')
  AND (f.rating_imdb BETWEEN %f AND %f OR f.rating_imdb IS NULL)
  ORDER BY f.rating_imdb DESC
  LIMIT 5
  ",
                     input$select_genre,
                     input$select_genre,
                     input$select_rating[1],
                     input$select_rating[2]
    )
    
    data <- def_safe_query(query)
    
    
    # ambil poster dari OMDb
    get_poster <- function(id){
      
      url <- paste0(
        "http://www.omdbapi.com/?i=",
        id,
        "&apikey=20344ce8"
      )
      
      res <- tryCatch(jsonlite::fromJSON(url), error=function(e) NULL)
      
      if(!is.null(res) && res$Response == "True" && res$Poster != "N/A"){
        return(res$Poster)
      } else{
        return("https://via.placeholder.com/300x450?text=No+Poster")
      }
      
    }
    
    data$poster_url <- sapply(data$imdb_id, get_poster)
    
    render_premium_cards(data)
    
  })

  ### Top 5 per Genre ---------------------------------------------------------
  output$poster_genre_reviews <- renderUI({
    
    query <- sprintf("
    SELECT DISTINCT
        f.imdb_id,
        f.title,
        f.rating_imdb,
        f.rating_count
    FROM films f
    LEFT JOIN film_genres fg ON f.imdb_id = fg.imdb_id
    LEFT JOIN genres g ON fg.genre_id = g.genre_id
    WHERE (g.genre_name = '%s' OR 'All' = '%s')
    AND (f.rating_imdb BETWEEN %f AND %f OR f.rating_imdb IS NULL)
    ORDER BY f.rating_count DESC
    LIMIT 5
  ",
                     input$select_genre,
                     input$select_genre,
                     input$select_rating[1],
                     input$select_rating[2]
    )
    
    data <- def_safe_query(query)
    
    
    # ambil poster dari OMDb
    get_poster <- function(id){
      
      url <- paste0(
        "http://www.omdbapi.com/?i=",
        id,
        "&apikey=20344ce8"
      )
      
      res <- tryCatch(jsonlite::fromJSON(url), error=function(e) NULL)
      
      if(!is.null(res) && res$Response == "True" && res$Poster != "N/A"){
        return(res$Poster)
      } else{
        return("https://via.placeholder.com/300x450?text=No+Poster")
      }
      
    }
    
    data$poster_url <- sapply(data$imdb_id, get_poster)
    
    render_premium_cards(data)
    
  })

  ### Bubble Chart (Score vs Popularitas) -------------------------------------
  output$bubble_score_pop <- renderPlotly({
    df <- explorer_filtered_data()
    req(nrow(df) > 0)
    p <- ggplot(df, aes(x = rating, y = rating_count, size = rating_count, text = title)) +
      geom_point(color = "#3498db", alpha = 0.6) +
      theme_minimal() + labs(x = "Rating IMDb", y = "Jumlah Review")
    ggplotly(p, tooltip = "text")
  })

  ### Donut Chart (Distribusi Genre) ------------------------------------------
  output$donut_genre_filter <- renderPlotly({
    q <- sprintf("SELECT IFNULL(g.genre_name, 'Unknown') as genre_name, COUNT(DISTINCT f.imdb_id) as n
                  FROM films f
                  LEFT JOIN film_genres fg ON f.imdb_id = fg.imdb_id
                  LEFT JOIN genres g ON fg.genre_id = g.genre_id
                  WHERE (f.rating_imdb BETWEEN %f AND %f OR f.rating_imdb IS NULL)
                  GROUP BY g.genre_name
                  ORDER BY n DESC LIMIT 8", input$select_rating[1], input$select_rating[2])
    
    res <- def_safe_query(q)
    req(nrow(res) > 0)
    
    plot_ly(res, labels = ~genre_name, values = ~n, type = 'pie', hole = 0.6) %>%
      layout(showlegend = TRUE)
  })

  ### Kualitas Film dari Tahun ke Tahun ---------------------------------------
  output$line_rating_trend <- renderPlotly({
    # 1. Logika SQL (Biar Aman & Sinkron 1553)
    q <- sprintf("SELECT YEAR(f.release_date) as year_val, AVG(f.rating_imdb) as avg_rating
                  FROM films f
                  LEFT JOIN film_genres fg ON f.imdb_id = fg.imdb_id
                  LEFT JOIN genres g ON fg.genre_id = g.genre_id
                  WHERE (f.rating_imdb BETWEEN %f AND %f OR f.rating_imdb IS NULL)
                  AND f.release_date IS NOT NULL", 
                 input$select_rating[1], input$select_rating[2])
    
    if(input$select_genre != "All") {
      q <- paste0(q, sprintf(" AND g.genre_name = '%s'", input$select_genre))
    }
    
    q <- paste0(q, " GROUP BY year_val ORDER BY year_val")
    res <- def_safe_query(q)
    
    # 2. Validasi & Pembersihan (Anti-Error)
    req(nrow(res) > 1) 
    res <- res %>% filter(!is.na(avg_rating), !is.na(year_val))
    
    # 3. Gambar dengan Tampilan Area (Estetik sesuai maumu)
    p <- ggplot(res, aes(x = year_val, y = avg_rating)) +
      # Ini bagian arsiran merah transparan di bawah garis
      geom_area(fill = "#e74c3c", alpha = 0.1) + 
      # Ini garis utamanya
      geom_line(color = "#e74c3c", size = 1, group = 1) + 
      # Titik-titik interaktif
      geom_point(color = "#e74c3c", size = 2, 
                 aes(text = paste("Tahun:", year_val, "<br>Rata Rating:", round(avg_rating, 2)))) +
      theme_minimal() +
      labs(x = "Tahun", y = "Rata Rating")
    
    # 4. Render ke Plotly
    ggplotly(p, tooltip = "text") %>% 
      config(displayModeBar = FALSE)
  })

  ### Hidden Gems -------------------------------------------------------------
  output$plot_hidden_gems <- renderPlotly({
    q <- sprintf("SELECT f.title, f.rating_imdb, f.rating_count 
                  FROM films f 
                  LEFT JOIN film_genres fg ON f.imdb_id = fg.imdb_id 
                  LEFT JOIN genres g ON fg.genre_id = g.genre_id 
                  WHERE (f.rating_imdb BETWEEN %f AND %f OR f.rating_imdb IS NULL)", 
                 input$select_rating[1], input$select_rating[2])
    
    if(input$select_genre != "All") {
      q <- paste0(q, sprintf(" AND g.genre_name = '%s'", input$select_genre))
    }
    
    # Filter Hidden Gems (Review rendah tapi Rating tinggi)
    q <- paste0(q, " AND f.rating_count < 2000 ORDER BY f.rating_imdb DESC LIMIT 10")
    
    res <- def_safe_query(q)
    req(nrow(res) > 0)
    
    p <- ggplot(res, aes(x = reorder(title, rating_imdb), y = rating_imdb, fill = rating_imdb)) +
      geom_bar(stat = "identity") + coord_flip() +
      scale_fill_gradient(low = "#93c5fd", high = "#1e40af") +
      theme_minimal() + labs(x = "", y = "Rating IMDb")
    ggplotly(p)
  })

  ### Movie Engagement --------------------------------------------------------
  output$plot_engagement <- renderPlotly({
    df <- explorer_filtered_data()
    req(nrow(df) > 0)
    
    # Menambahkan garis rata-rata untuk melihat posisi film
    avg_rating <- mean(df$rating)
    avg_reviews <- mean(df$rating_count)
    
    p <- ggplot(df, aes(x = rating, y = rating_count, text = title)) +
      geom_vline(xintercept = avg_rating, linetype = "dashed", color = "grey") +
      geom_hline(yintercept = avg_reviews, linetype = "dashed", color = "grey") +
      geom_point(aes(color = rating), alpha = 0.7, size = 3) +
      scale_color_gradient(low = "#fbbf24", high = "#b91c1c") +
      theme_minimal() + labs(x = "Skor Rating", y = "Jumlah Review")
    
    ggplotly(p, tooltip = "text")
  })

  ### Top 5 Directors ---------------------------------------------------------
  output$plot_top_directors <- renderPlotly({
    q <- sprintf("SELECT IFNULL(d.director_name, 'Unknown') as director_name, 
                  AVG(f.rating_imdb) as avg_rating, COUNT(DISTINCT f.imdb_id) as total_films
                  FROM films f
                  LEFT JOIN film_directors fd ON f.imdb_id = fd.imdb_id
                  LEFT JOIN directors d ON fd.director_id = d.director_id
                  LEFT JOIN film_genres fg ON f.imdb_id = fg.imdb_id
                  LEFT JOIN genres g ON fg.genre_id = g.genre_id
                  WHERE (f.rating_imdb BETWEEN %f AND %f OR f.rating_imdb IS NULL)", 
                 input$select_rating[1], input$select_rating[2])
    
    if(input$select_genre != "All") {
      q <- paste0(q, sprintf(" AND g.genre_name = '%s'", input$select_genre))
    }
    
    q <- paste0(q, " GROUP BY d.director_name ORDER BY avg_rating DESC LIMIT 5")
    
    res <- def_safe_query(q)
    req(nrow(res) > 0)
    
    p <- ggplot(res, aes(x = reorder(director_name, avg_rating), y = avg_rating, fill = avg_rating)) +
      geom_bar(stat = "identity", width = 0.6) + coord_flip() +
      scale_fill_gradient(low = "#fcd34d", high = "#d97706") +
      theme_minimal() + labs(x = "", y = "Avg Rating")
    ggplotly(p)
  })
  

  ## Menu Content Analysis ---------------------------------------------------
  # 1. Tabel Tetap Sama
  output$table_content_select <- renderDT({
    # 1. Ambil data dari reactive utama (Sudah Slay & Sinkron 1553)
    df <- explorer_filtered_data()
    req(nrow(df) > 0)
    
    # 2. Urutkan berdasarkan kolom asli (rating_count), 
    # lalu buat tampilan cantik untuk user (Title, Rating, Reviews)
    df_tampil <- df %>% 
      arrange(desc(rating_count)) %>% 
      select(
        Title = title, 
        Rating = rating, 
        Reviews = rating_count
      )
    
    # 3. Render Tabel (Pilih 'single' biar user bisa klik satu baris)
    datatable(df_tampil, 
              selection = "single", 
              rownames = FALSE, 
              options = list(
                pageLength = 10, 
                dom = 'ltp',
                columnDefs = list(list(className = 'dt-center', targets = 1:2))
              ))
  })
  
  # 2. Area Dinamis (Kuncinya di Sini!)
  output$wordcloud_dynamic_area <- renderUI({
    s <- input$table_content_select_rows_selected
    
    # Style untuk pesan instruksi/error agar di tengah
    centered_style <- "display: flex; justify-content: center; align-items: center; min-height: 400px; flex-direction: column; text-align: center; color: #777;"
    
    # KONDISI 1: Belum ada yang diklik sama sekali
    if (is.null(s)) {
      return(div(style = centered_style,
                 icon("hand-point-left", style = "font-size: 50px; opacity: 0.5; margin-bottom: 15px;"),
                 h4("Silahkan klik salah satu film"),
                 p("Pilih baris di tabel kiri untuk menganalisis review.")))
    }
    
    # Ambil data film
    df_filtered <- explorer_filtered_data()
    selected_id <- df_filtered$imdb_id[s]
    title_film <- df_filtered$title[s]
    
    # Cek ketersediaan review
    review_check <- def_safe_query(sprintf("SELECT COUNT(*) as n FROM reviews WHERE imdb_id = '%s'", selected_id))
    
    # KONDISI 2: Jika data kosong
    if (review_check$n == 0) {
      return(div(style = centered_style,
                 icon("frown", style = "font-size: 50px; margin-bottom: 15px; color: #e74c3c; opacity: 0.7;"),
                 h4(style = "color: #e74c3c;", "Maaf, data tidak ditemukan"),
                 p("Film ini belum memiliki review di database kami.")))
    }
    
    # KONDISI 3: Jika data ada, tampilkan Judul + Placeholder Wordcloud
    # TagList digunakan untuk menggabungkan beberapa elemen UI
    tagList(
      div(style = "text-align: center; color: #2c3e50; padding: 10px; background: #f8f9fa; border-radius: 10px; border: 1px solid #ddd; margin-bottom: 10px;", 
          icon("chart-line"), span(strong(paste(" Analisis Review:", title_film)))),
      wordcloud2Output("wordcloud_plot", height = "400px")
    )
  })
  
  # 3. Fungsi Wordcloud Tetap Sama (Hanya panggil Plot-nya)
  output$wordcloud_plot <- renderWordcloud2({
    s <- input$table_content_select_rows_selected
    req(s)
    
    selected_id <- explorer_filtered_data()$imdb_id[s]
    review_data <- def_safe_query(sprintf("SELECT review_content FROM reviews WHERE imdb_id = '%s'", selected_id))
    
    if(nrow(review_data) == 0) return(NULL)
    
    # Proses Text Mining (tm)
    docs <- Corpus(VectorSource(review_data$review_content))
    docs <- tm_map(docs, content_transformer(tolower))
    docs <- tm_map(docs, removePunctuation)
    docs <- tm_map(docs, removeNumbers)
    docs <- tm_map(docs, removeWords, stopwords("english"))
    docs <- tm_map(docs, removeWords, c("movie", "film", "watch", "story", "character", "acting", "scene"))
    
    dtm <- TermDocumentMatrix(docs)
    m <- as.matrix(dtm)
    v <- sort(rowSums(m), decreasing = TRUE)
    df_wc <- data.frame(word = names(v), freq = v)
    
    # --- SERVER: WORDCLOUD2 (VERSI SUPER ESTETIK) ---
    
    # 1. Pastikan Ada Validasi Data Terlebih Dahulu
    req(nrow(df_wc) > 0)
    
    # 2. Definisikan Palet Warna Custom (Misalnya: Nuansa Biru-Hijau Modern)
    # Kamu bisa ganti kode hex ini sesuai selera
    #color_palette <- rep(c("#1a5276", "#2980b9", "#5499c7", "#aed6f1", "#48c9b0"), length.out = nrow(df_wc))
    
    # 3. Kustomisasi Total Wordcloud2
    # Gunakan palet warna yang kontras dan tajam
    color_palette <- rep(c("#FF5733", "#C70039", "#900C3F", "#581845", "#FFC300"), length.out = nrow(df_wc))
    
    wordcloud2(data = df_wc, 
               size = 0.8, 
               fontFamily = 'Montserrat', # Pakai font yang lebih tegas kalau ada
               fontWeight = '600',
               color = color_palette, 
               backgroundColor = "#1a1a1a", # Ganti background jadi HITAM biar warna katanya "menyala"
               minRotation = 0, 
               maxRotation = 0, # Buat semuanya horizontal biar kelihatan sangat rapi dan modern
               shape = 'square') # Bentuk kotak biasanya terlihat lebih futuristik di dashboard gelap
  })
  
  
  
  # --- SERVER: THE ULTIMATE RESET FOR BOSS LADY (FIXED VERSION) ---
  
  output$dynamic_sentiment_area <- renderUI({
    s <- input$table_content_select_rows_selected
    if (is.null(s)) return(NULL)
    
    df_tampil <- explorer_filtered_data()
    req(nrow(df_tampil) >= s)
    id_film <- df_tampil$imdb_id[s]
    review_df <- def_safe_query(sprintf("SELECT review_content FROM reviews WHERE imdb_id = '%s'", id_film))
    
    # Bungkus dalam div utama agar background tidak belang
    tags$div(
      style = "background-color: transparent; margin-top: 20px;",
      
      if(nrow(review_df) == 0) {
        # Tampilan jika data kosong (Pesan Boss Lady)
        fluidRow(
          box(title = "Opps.. 🎬", status = "danger", solidHeader = TRUE, width = 12,
              div(style="text-align:center; padding:30px; color:#e74c3c; background: white; border-radius: 8px;", 
                  icon("ghost"), br(), "Duh, film ini misterius banget, Boss Lady! Belum ada review-nya di database.. 👻"))
        )
      } else {
        # Tampilan jika data ada
        tagList(
          fluidRow(
            box(title = "🎭 Sentiment Score", status = "info", solidHeader = TRUE, width = 4,
                plotlyOutput("sentiment_gauge", height = "250px")),
            box(title = "📊 Positive vs Negative Words", status = "info", solidHeader = TRUE, width = 8,
                plotOutput("sentiment_bar_chart", height = "250px"))
          ),
          fluidRow(
            box(title = "💬 Featured Review", status = "success", solidHeader = TRUE, width = 12,
                div(style = "background-color: white; border-radius: 0 0 8px 8px; padding: 15px;",
                    uiOutput("featured_review")
                ))
          )
        )
      }
    )
  })
  
  # --- RENDER OUTPUTS (PASTIKAN NAMA ID SESUAI) ---
  
  output$sentiment_gauge <- renderPlotly({
    s <- input$table_content_select_rows_selected
    req(s)
    df <- explorer_filtered_data()
    id <- df$imdb_id[s]
    review_df <- def_safe_query(sprintf("SELECT review_content FROM reviews WHERE imdb_id = '%s'", id))
    req(nrow(review_df) > 0)
    
    txt <- tolower(paste(review_df$review_content, collapse = " "))
    words <- unlist(strsplit(gsub("[[:punct:]]", "", txt), "\\s+"))
    
    pos_words <- c("good", "great", "excellent", "amazing", "best", "love", "wonderful", "perfect", "useful", "moral", "important", "frugal", "protect", "honest")
    neg_words <- c("bad", "worst", "boring", "awful", "terrible", "waste", "poor", "hate", "stupid", "cunning", "careless")
    
    pos_c <- sum(words %in% pos_words)
    neg_c <- sum(words %in% neg_words)
    score <- if((pos_c + neg_c) == 0) 50 else (pos_c / (pos_c + neg_c)) * 100
    
    plot_ly(type = "indicator", mode = "gauge+number", value = score,
            gauge = list(axis = list(range = list(0, 100)), bar = list(color = "#1dd1a1")))
  })
  
  output$sentiment_bar_chart <- renderPlot({
    s <- input$table_content_select_rows_selected
    req(s)
    df <- explorer_filtered_data()
    id <- df$imdb_id[s]
    review_df <- def_safe_query(sprintf("SELECT review_content FROM reviews WHERE imdb_id = '%s'", id))
    req(nrow(review_df) > 0)
    
    txt <- tolower(paste(review_df$review_content, collapse = " "))
    words <- unlist(strsplit(gsub("[[:punct:]]", "", txt), "\\s+"))
    
    pos_c <- sum(words %in% c("good", "great", "excellent", "amazing", "best", "love", "wonderful", "perfect"))
    neg_c <- sum(words %in% c("bad", "worst", "boring", "awful", "terrible", "waste", "poor", "hate"))
    
    ggplot(data.frame(Vibe=factor(c("Positive", "Negative"), levels=c("Positive", "Negative")), Total=c(pos_c, neg_c)), 
           aes(x=Vibe, y=Total, fill=Vibe)) +
      geom_bar(stat="identity", width=0.5) + 
      scale_fill_manual(values=c("Positive"="#1dd1a1", "Negative"="#ff6b6b")) + 
      theme_minimal() + labs(x=NULL, y="Word Count")
  })
  
  output$featured_review <- renderUI({
    s <- input$table_content_select_rows_selected
    req(s)
    df <- explorer_filtered_data()
    id <- df$imdb_id[s]
    review_df <- def_safe_query(sprintf("SELECT review_content FROM reviews WHERE imdb_id = '%s'", id))
    req(nrow(review_df) > 0)
    
    text <- review_df$review_content[1]
    for(i in 1:15) { 
      text <- gsub(paste0(i, "\\. "), paste0("<br><b style='color:#54a0ff;'>", i, ".</b> "), text) 
    }
    div(style = "line-height: 1.8; color: #2d3436;", HTML(text))
  })
  

  ## Menu Variable Relations -------------------------------------------------
  # 1. Scatter Plot: Duration vs Rating
  output$scatter_plot_dur <- renderPlotly({
    df <- explorer_filtered_data()
    req(nrow(df) > 0)
    
    # LOGIKA PENGAMAN: Kita cari kolom durasi & rating apa pun namanya
    if("duration_min" %in% colnames(df)) df$x_var <- df$duration_min
    else if("runtime_minutes" %in% colnames(df)) df$x_var <- df$runtime_minutes
    else if("duration" %in% colnames(df)) df$x_var <- df$duration
    
    if("rating_imdb" %in% colnames(df)) df$y_var <- df$rating_imdb
    else if("rating" %in% colnames(df)) df$y_var <- df$rating
    
    req(df$x_var, df$y_var) # Pastikan kolom ketemu
    
    p <- ggplot(df, aes(x = x_var, y = y_var, text = title)) +
      geom_point(aes(color = y_var), alpha = 0.5, size = 2.5) +
      geom_smooth(method = "lm", color = "#2d3436", se = FALSE, linetype = "dashed") + # <--- Garis Tren Mewah
      scale_color_gradient(low = "#fab1a0", high = "#55efc4") +
      theme_minimal() +
      labs(x = "Duration (Minutes)", y = "IMDb Rating")
    
    ggplotly(p, tooltip = "text")
  })
  
  # 2. Scatter Plot: Popularity vs Rating (Log Scale)
  output$scatter_popularity <- renderPlotly({
    df <- explorer_filtered_data()
    req(nrow(df) > 0)
    
    # Sinkronisasi Nama Kolom (Rating & Pop)
    df$y_val <- if("rating_imdb" %in% colnames(df)) df$rating_imdb else df$rating
    df$pop_val <- if("rating_count" %in% colnames(df)) df$rating_count else if("total_rev" %in% colnames(df)) df$total_rev else df$votes
    
    # Pastikan data yang digambar hanya yang tidak NULL agar Plotly tidak crash
    plot_df <- df %>% filter(!is.na(y_val), !is.na(pop_val), pop_val > 0)
    
    p <- ggplot(plot_df, aes(x = pop_val, y = y_val, text = title)) +
      geom_point(color = "#ff7675", alpha = 0.4) +
      scale_x_log10() + 
      theme_minimal() +
      labs(x = "Total Reviews (Log Scale)", y = "IMDb Rating")
    
    ggplotly(p, tooltip = "text")
  })
  
  # 3. Heatmap Korelasi (Anti-Buang Data)
  output$corr_heatmap <- renderPlotly({
    df <- explorer_filtered_data()
    req(nrow(df) > 0)
    
    # Ambil kolom numerik saja
    num_data <- df %>% select_if(is.numeric)
    
    # Hitung korelasi: Pakai 'pairwise' agar tidak membuang baris film (Tetap Sinkron 1553!)
    corr_mat <- round(cor(num_data, use = "pairwise.complete.obs"), 2)
    
    # Pastikan tidak ada NaN di matrix korelasi (biar heatmap muncul)
    corr_mat[is.na(corr_mat)] <- 0
    
    plot_ly(x = colnames(corr_mat), y = rownames(corr_mat), z = corr_mat, 
            type = "heatmap", colorscale = "Viridis") %>%
      layout(
        title = list(text = "<b>Statistical Correlation Matrix</b>", y = 0.98),
        margin = list(l = 120, r = 20, b = 100, t = 50)
      )
  })
}