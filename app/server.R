# -------------------------------
# KONFIGURASI DATABASE
# -------------------------------
db_config <- list(
  host = "127.0.0.1",
  port = 3307,
  user = "root",
  password = "",
  dbname = "project_pdb"
)

con <- dbConnect(
  RMySQL::MySQL(),
  host     = db_config$host,
  port     = db_config$port,
  user     = db_config$user,
  password = db_config$password,
  dbname   = db_config$dbname
)




# ===============================
# SERVER.R
# ===============================

server <- function(input, output, session) {
  
  # ---------------- LOAD GENRE FROM DATABASE (INIT) ----------------
  observe({
    
    genre_list <- dbGetQuery(con, "
    SELECT genre_name 
    FROM genres
    ORDER BY genre_name
  ")
    
    updateSelectInput(
      session,
      "select_genre",
      choices = c("All", genre_list$genre_name),
      selected = "All"
    )
  })
  
  
  # ---------------- OVERVIEW ----------------
  # (_Total Film_)
  output$total_film <- renderValueBox({
    
    if (input$select_genre == "All") {
      
      query <- "
        SELECT COUNT(*) AS total
        FROM films
        WHERE rating BETWEEN ? AND ?
      "
      
      result <- dbGetQuery(con, query,
                           params = list(
                             input$select_rating[1],
                             input$select_rating[2]
                           ))
      
    } else {
      
      query <- "
        SELECT COUNT(DISTINCT f.imdb_id) AS total
        FROM films f
        JOIN film_genres fg ON f.imdb_id = fg.imdb_id
        JOIN genres g ON fg.genre_id = g.genre_id
        WHERE g.genre_name = ?
          AND f.rating BETWEEN ? AND ?
      "
      
      result <- dbGetQuery(con, query,
                           params = list(
                             input$select_genre,
                             input$select_rating[1],
                             input$select_rating[2]
                           ))
    }
    
    valueBox(result$total,
             "Total Film",
             icon = icon("video"),
             color = "blue")
  })
  
  # (_Average Rating_)
  output$avg_rating <- renderValueBox({
    
    query <- "
      SELECT ROUND(AVG(rating),2) AS avg_rating
      FROM films
      WHERE rating BETWEEN ? AND ?
    "
    
    result <- dbGetQuery(con, query,
                         params = list(
                           input$select_rating[1],
                           input$select_rating[2]
                         ))
    
    valueBox(result$avg_rating,
             "Rata-rata Rating",
             icon = icon("star"),
             color = "yellow")
  })
  
  # (_Top Genre_)
  output$top_genre <- renderValueBox({
    
    query <- "
      SELECT g.genre_name, COUNT(*) AS total
      FROM film_genres fg
      JOIN genres g ON fg.genre_id = g.genre_id
      GROUP BY g.genre_name
      ORDER BY total DESC
      LIMIT 1
    "
    
    result <- dbGetQuery(con, query)
    
    valueBox(result$genre_name,
             "Genre Terpopuler",
             icon = icon("fire"),
             color = "red")
  })
  
  # (_Histogram Rating_)
  output$hist_rating <- renderPlotly({
    
    query <- sprintf("
    SELECT rating
    FROM films
    WHERE rating BETWEEN %f AND %f
    ",
      input$select_rating[1],
      input$select_rating[2]
    )
    
    data <- dbGetQuery(con, query)
    
    p <- ggplot(data, aes(x = rating)) +
      geom_histogram(fill = "#3c8dbc", bins = 20) +
      theme_minimal()
    
    ggplotly(p)
  })
  
  # (_Histogram Year_)
  output$hist_year <- renderPlotly({
    
    if (input$select_genre == "All") {
      
      query <- sprintf("
        SELECT YEAR(release_date) AS year,
               COUNT(*) AS jumlah
        FROM films
        WHERE rating_imdb BETWEEN %f AND %f
        GROUP BY YEAR(release_date)
        ORDER BY year
      ",
       input$select_rating[1],
       input$select_rating[2]
      )
      
    } else {
      
      query <- sprintf("
        SELECT YEAR(f.release_date) AS year,
               COUNT(DISTINCT f.imdb_id) AS jumlah
        FROM films f
        JOIN film_genres fg ON f.imdb_id = fg.imdb_id
        JOIN genres g ON fg.genre_id = g.genre_id
        WHERE g.genre_name = '%s'
          AND f.rating_imdb BETWEEN %f AND %f
        GROUP BY YEAR(f.release_date)
        ORDER BY year
      ",
       input$select_genre,
       input$select_rating[1],
       input$select_rating[2]
      )
    }
    
    data <- dbGetQuery(con, query)
    
    p <- ggplot(data, aes(x = year, y = jumlah)) +
      geom_line() +
      theme_minimal()
    
    ggplotly(p)
  })
  
  # ---------------- EXPLORER ----------------
  output$table_explorer <- renderDT({
    
    query <- "
    SELECT 
        f.imdb_id,
        f.title,
        f.rating,
        COALESCE(r.total_reviews,0) AS total_reviews,
        g.genres,
        f.duration,
        f.release_date,
        d.directors
    FROM films f
    
    LEFT JOIN (
        SELECT imdb_id, COUNT(*) AS total_reviews
        FROM reviews
        GROUP BY imdb_id
    ) r ON f.imdb_id = r.imdb_id
    
    LEFT JOIN (
        SELECT fg.imdb_id,
               GROUP_CONCAT(DISTINCT g.genre_name) AS genres
        FROM film_genres fg
        JOIN genres g ON fg.genre_id = g.genre_id
        GROUP BY fg.imdb_id
    ) g ON f.imdb_id = g.imdb_id
    
    LEFT JOIN (
        SELECT fd.imdb_id,
               GROUP_CONCAT(DISTINCT d.director_name) AS directors
        FROM film_directors fd
        JOIN directors d ON fd.director_id = d.director_id
        GROUP BY fd.imdb_id
    ) d ON f.imdb_id = d.imdb_id
    
    WHERE f.rating BETWEEN ? AND ?
    ORDER BY f.rating DESC
  "
    
    df <- dbGetQuery(
      con,
      query,
      params = list(
        input$select_rating[1],
        input$select_rating[2]
      )
    )
    
    # (_Formatting_)
    df$release_date <- format(as.Date(df$release_date), "%d %b %Y")
    
    # -------- GENRE BADGE --------
    all_genres <- unique(unlist(strsplit(df$genres, ",\\s*")))
    
    genre_palette <- c(
      "#4F46E5","#059669","#DC2626","#D97706","#2563EB",
      "#7C3AED","#0E7490","#BE185D","#1F2937","#9333EA",
      "#EA580C","#0891B2","#65A30D","#C026D3","#0F766E"
    )
    
    genre_color_map <- setNames(
      genre_palette[seq_along(all_genres)],
      all_genres
    )
    
    make_genre_badge <- function(text){
      genres <- strsplit(text, ",\\s*")[[1]]
      paste(sapply(genres, function(g){
        paste0("<span style='
        background-color:", genre_color_map[g], ";
        color:white;
        padding:4px 8px;
        border-radius:999px;
        font-size:12px;
      '>", g, "</span>")
      }), collapse = " ")
    }
    
    df$genres <- sapply(df$genres, make_genre_badge)
    
    # -------- RATING BADGE --------
    make_rating_badge <- function(r){
      color <- ifelse(r >= 8, "#059669",
                      ifelse(r >= 6, "#2563EB", "#DC2626"))
      
      paste0("<span style='
      background-color:", color, ";
      color:white;
      padding:4px 8px;
      border-radius:999px;
      font-weight:600;
    '>", r, "</span>")
    }
    
    df$rating <- sapply(df$rating, make_rating_badge)
    df$total_reviews <- paste0("💬 ", format(df$total_reviews, big.mark=","))
    
    df$title <- paste0(
      "<span style='font-weight:600;color:#1f2937;'>",
      df$title,
      "</span>"
    )
    
    datatable(
      df,
      escape = FALSE,
      selection = "single",
      options = list(
        pageLength = 10,
        scrollX = TRUE
      )
    )
    
  }, server = TRUE)
  
  # (_Modal Detail Film_)
  observeEvent(input$table_explorer_rows_selected, {
    
    selected_row <- input$table_explorer_rows_selected
    
    if(length(selected_row)){
      
      # Ambil imdb_id sesuai urutan query table
      id_query <- "
      SELECT imdb_id
      FROM films
      WHERE rating BETWEEN ? AND ?
      ORDER BY rating DESC
    "
      
      id_table <- dbGetQuery(
        con,
        id_query,
        params = list(
          input$select_rating[1],
          input$select_rating[2]
        )
      )
      
      imdb_selected <- id_table$imdb_id[selected_row]
      
      # -----------------------
      # DETAIL FILM
      # -----------------------
      film_query <- "
      SELECT title, rating, duration, release_date, storyline
      FROM films
      WHERE imdb_id = ?
    "
      
      film_data <- dbGetQuery(
        con,
        film_query,
        params = list(imdb_selected)
      )
      
      # -----------------------
      # REVIEWS
      # -----------------------
      review_query <- "
      SELECT username, rating_user, review_content
      FROM reviews
      WHERE imdb_id = ?
      ORDER BY rating_user DESC
      LIMIT 5
    "
      
      reviews_film <- dbGetQuery(
        con,
        review_query,
        params = list(imdb_selected)
      )
      
      # Generate Review Cards
      review_cards <- if(nrow(reviews_film) == 0){
        "<p>No reviews available.</p>"
      } else {
        paste(
          apply(reviews_film, 1, function(r){
            paste0(
              "<div style='
              padding:12px;
              margin-bottom:12px;
              background:#f9fafb;
              border-radius:10px;
              border:1px solid #e5e7eb;
            '>
              <b>", r["username"], "</b>
              <span style='float:right;font-size:12px;color:#6b7280;'>
                ⭐ ", r["rating_user"], "
              </span>
              <div style='clear:both;margin-top:6px;'>
                ", r["review_content"], "
              </div>
            </div>"
            )
          }),
          collapse = ""
        )
      }
      
      # -----------------------
      # SHOW MODAL
      # -----------------------
      showModal(
        modalDialog(
          size = "l",
          easyClose = TRUE,
          footer = modalButton("Close"),
          
          title = paste("🎬", film_data$title),
          
          tabsetPanel(
            
            tabPanel("Overview",
                     HTML(paste0(
                       "<b>⭐ Rating:</b> ", film_data$rating, "<br><br>",
                       "<b>⏱ Duration:</b> ", film_data$duration, " minutes<br><br>",
                       "<b>📅 Release Date:</b> ",
                       format(as.Date(film_data$release_date), "%d %b %Y"), "<br><br>",
                       "<b>📖 Storyline:</b><br><br>",
                       film_data$storyline
                     ))
            ),
            
            tabPanel("Reviews",
                     HTML(review_cards)
            )
          )
        )
      )
    }
  })
    

  # ---------------- GENRE ----------------
  output$genre_year_trend <- renderPlotly({
    
    query <- "
    SELECT 
        YEAR(f.release_date) AS year,
        g.genre_name,
        COUNT(DISTINCT f.imdb_id) AS total
    FROM films f
    JOIN film_genres fg ON f.imdb_id = fg.imdb_id
    JOIN genres g ON fg.genre_id = g.genre_id
    WHERE f.rating BETWEEN ? AND ?
    GROUP BY YEAR(f.release_date), g.genre_name
    ORDER BY year
  "
    
    data <- dbGetQuery(
      con,
      query,
      params = list(
        input$select_rating[1],
        input$select_rating[2]
      )
    )
    
    p <- ggplot(data, aes(x = year, y = total, fill = genre_name)) +
      geom_area(alpha = 0.6) +
      theme_minimal()
    
    ggplotly(p)
  })
  
  output$genre_rating_dist <- renderPlotly({
    
    query <- "
    SELECT 
        g.genre_name,
        f.rating
    FROM films f
    JOIN film_genres fg ON f.imdb_id = fg.imdb_id
    JOIN genres g ON fg.genre_id = g.genre_id
    WHERE f.rating BETWEEN ? AND ?
  "
    
    data <- dbGetQuery(
      con,
      query,
      params = list(
        input$select_rating[1],
        input$select_rating[2]
      )
    )
    
    p <- ggplot(data, aes(x = genre_name, y = rating)) +
      geom_boxplot() +
      coord_flip() +
      theme_minimal()
    
    ggplotly(p)
  })
  
  output$table_genre_year <- renderDT({
    
    query <- "
    SELECT 
        f.title,
        YEAR(f.release_date) AS year,
        f.rating,
        GROUP_CONCAT(DISTINCT g.genre_name) AS genres
    FROM films f
    JOIN film_genres fg ON f.imdb_id = fg.imdb_id
    JOIN genres g ON fg.genre_id = g.genre_id
    WHERE f.rating BETWEEN ? AND ?
    GROUP BY f.imdb_id
    ORDER BY year DESC
  "
    
    data <- dbGetQuery(
      con,
      query,
      params = list(
        input$select_rating[1],
        input$select_rating[2]
      )
    )
    
    datatable(data, options = list(pageLength = 10))
  })
  
  
  # ---------------- TOP FILM ----------------
  # ---------------- TOP FILM ----------------
  output$bar_top_5 <- renderPlotly({
    
    if (input$select_genre == "All") {
      
      query <- "
      SELECT title, rating
      FROM films
      WHERE rating BETWEEN ? AND ?
      ORDER BY rating DESC
      LIMIT 5
    "
      
      data <- dbGetQuery(
        con,
        query,
        params = list(
          input$select_rating[1],
          input$select_rating[2]
        )
      )
      
    } else {
      
      query <- "
      SELECT DISTINCT f.title, f.rating
      FROM films f
      JOIN film_genres fg ON f.imdb_id = fg.imdb_id
      JOIN genres g ON fg.genre_id = g.genre_id
      WHERE g.genre_name = ?
        AND f.rating BETWEEN ? AND ?
      ORDER BY f.rating DESC
      LIMIT 5
    "
      
      data <- dbGetQuery(
        con,
        query,
        params = list(
          input$select_genre,
          input$select_rating[1],
          input$select_rating[2]
        )
      )
    }
    
    p <- ggplot(data,
                aes(x = reorder(title, rating),
                    y = rating)) +
      geom_col(fill = "red") +
      coord_flip() +
      theme_minimal()
    
    ggplotly(p)
  })
  
  # ---------------- CONTENT ----------------
  output$table_content <- renderDT({
    
    query <- "
    SELECT 
        r.review_id,
        f.title,
        r.review_content
    FROM reviews r
    JOIN films f ON r.imdb_id = f.imdb_id
    ORDER BY r.review_id DESC
    LIMIT 200
  "
    
    data <- dbGetQuery(con, query)
    
    datatable(
      data[, c("title", "review_content")],
      selection = "single",
      options = list(pageLength = 5)
    )
  })
  
  output$wc_review <- renderWordcloud2({
    
    s <- input$table_content_rows_selected
    
    if (length(s)) {
      
      # Ambil review yang dipilih
      query <- "
      SELECT review_content
      FROM reviews
      ORDER BY review_id DESC
      LIMIT 200
    "
      
      data <- dbGetQuery(con, query)
      
      text_data <- data$review_content[s]
      
    } else {
      
      # Ambil semua review (dibatasi)
      query <- "
      SELECT review_content
      FROM reviews
      ORDER BY review_id DESC
      LIMIT 500
    "
      
      data <- dbGetQuery(con, query)
      
      text_data <- paste(data$review_content, collapse = " ")
    }
    
    # ---------------- TEXT PROCESSING ----------------
    words <- text_data %>%
      str_replace_all("[[:punct:][:digit:]]", "") %>%
      tolower() %>%
      str_split("\\s+") %>%
      unlist()
    
    words <- words[nchar(words) > 3]
    
    wf <- as.data.frame(table(words))
    colnames(wf) <- c("word", "freq")
    wf <- wf[order(-wf$freq), ]
    wf <- head(wf, 100)
    
    wordcloud2(wf)
  })
  
  # ---------------- RELATIONS ----------------
  output$scatter_dur_rate <- renderPlotly({
    
    query <- "
    SELECT duration, rating
    FROM films
    WHERE rating BETWEEN ? AND ?
      AND duration IS NOT NULL
  "
    
    data <- dbGetQuery(
      con,
      query,
      params = list(
        input$select_rating[1],
        input$select_rating[2]
      )
    )
    
    p <- ggplot(data,
                aes(x = duration, y = rating)) +
      geom_point(alpha = 0.6) +
      theme_minimal()
    
    ggplotly(p)
  })
  
  output$box_dir_rate <- renderPlotly({
    
    query <- "
    SELECT 
        d.director_name,
        f.rating
    FROM films f
    JOIN film_directors fd ON f.imdb_id = fd.imdb_id
    JOIN directors d ON fd.director_id = d.director_id
    WHERE f.rating BETWEEN ? AND ?
      AND d.director_id IN (
        SELECT director_id
        FROM film_directors
        GROUP BY director_id
        HAVING COUNT(*) >= 3
      )
  "
    
    data <- dbGetQuery(
      con,
      query,
      params = list(
        input$select_rating[1],
        input$select_rating[2]
      )
    )
    
    p <- ggplot(data,
                aes(x = reorder(director_name, rating, median),
                    y = rating)) +
      geom_boxplot() +
      coord_flip() +
      theme_minimal()
    
    ggplotly(p)
  })
  
}