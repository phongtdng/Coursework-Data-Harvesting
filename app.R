library(shiny)
library(tidyverse)
library(shinyWidgets)
library(glue)

source("helpers.R")

#Code for making app
ui <- fluidPage(
  titlePanel("Pink Tax - Spain"),
  
  fluidRow(
    column(width = 4,
           multiInput(
             inputId = "product",
             label = "Choose your products :", 
             choices = NULL,
             choiceNames = unique(df$product),
             choiceValues = unique(df$product)
           ),
           numericInput("salary",
                        label = "Input your Salary",
                        value = 0,
                        min = 0,
                        step = 1000),
           radioGroupButtons(
             inputId = "freq",
             label = "Purchase Frequency", 
             choices = c("Monthly", "Quarterly", "Annually"),
             status = "primary"
           )
    ),
    column(width = 4, 
           mainPanel(width = 12,
                     plotOutput("plot", width = "300")
           )),
    column(width = 4, 
           h3(strong("Most overcharged item")),
           htmlOutput("top_item"),
           hr(),
           htmlOutput("annual_tax"),
           hr(),
           htmlOutput("recommend")
    )
  ),
)

server <- function(input, output) {
  
  dataInput <- reactive({
    df %>% 
      filter(product %in% input$product) %>% 
      mutate(overcharge = ifelse(price_others - price_male <= 0, 0, price_others - price_male))
  })
  
  output$plot <- renderPlot({
    dataframe <- dataInput()
    make_donut(dataframe, product, price_male, price_others)
  })

  output$top_item <- renderUI({
    top_item <- dataInput() %>% 
      group_by(product) %>% 
      summarize(overcharge = mean(overcharge)) %>% 
      ungroup() %>% 
      slice_max(overcharge)
    
    name <- top_item[["product"]]
    overcharge <- top_item[["overcharge"]]

    HTML(glue(
      "<p>
      Product name: {name}
      <br>
      Average overcharged amount: €{round(overcharge,2)}
      </p>"
    ))
  })

  output$annual_tax <- renderUI({
    sum <- dataInput() %>% 
      group_by(product) %>% 
      summarize(overcharge = mean(overcharge)) %>% 
      ungroup() %>%
      pull(overcharge) %>% 
      sum() 

    freq <- case_when(
      input$freq == "Monthly" ~ 12,
      input$freq == "Quarterly" ~ 4,
      TRUE ~ 1
    )

    HTML(glue(
      "
      <p>
      <strong>Annual overcharge: €{round(sum * freq,2)}</strong>
      <br>
      Monthly budget without overcharge: €{round(input$salary / 12, 2)}
      <br>
      Monthly budget with overcharge: €{round(input$salary/12 - sum*freq/12,2)}
      </p>
      "
    ))
  })

  output$recommend <- renderUI({
    rec_df <- dataInput() %>%
      group_by(product) %>% 
      summarize(overcharge = mean(overcharge)) %>% 
      ungroup() %>% 
      mutate(recommend = ifelse(overcharge > 0, TRUE, FALSE)) %>%
      filter(recommend == TRUE)

    rec <- rec_df$product

    HTML(glue(
      "
      <p>
      Recommend switching products: <br>
      {ifelse(length(rec) == 0, '', paste('<li>',rec, collapse = '<br>', '</li>'))}
      </p>
      "
    ))
  })
}

shinyApp(ui, server)