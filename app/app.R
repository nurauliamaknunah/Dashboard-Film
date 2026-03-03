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



source("ui.R")
source("server.R")


shinyApp(ui = ui, server = server)