library(shiny)
library(tidyverse)
library(shinyWidgets)
library(glue)

source("helpers.R")

#Code for making app
ui <- fluidPage(
  titlePanel("Gender Labelled Product Pricing - Spain"),
  br(),
  fluidRow(
    column(width = 3,
           multiInput(
             inputId = "product",
             label = "Choose products that you frequently purchase:", 
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
    column(width = 5, 
           mainPanel(width = 12, plotOutput("plot", width = "500"),
            HTML(
            '<p style = "color:gray; font-size:11px">The entire donut represents the average 
            total price of selected products that are not targeted specifically at men 
            (including female-targeted products and non-gender-labelled products). The "Price Male" 
            group represents products specifically targeted at male consumers, such as those labelled 
            "for men". The "Overcharge" group shows the price difference between products targeted 
            at men and those not specifically targeted at men.
            </p>')
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
      Recommend switching to male-targeted products to avoid overcharge: <br>
      {ifelse(length(rec) == 0, '', paste('<li>',rec, collapse = '<br>', '</li>'))}
      </p>
      "
    ))
  })
}

shinyApp(ui, server)