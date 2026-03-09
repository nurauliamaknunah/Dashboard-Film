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



source("ui.R")
source("server.R")



shinyApp(ui = ui, server = server)
