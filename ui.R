#
# This is the user-interface of the compatible-LOSD-selection-component 
#


#The above is a graphql a query to get all datasets from statistics.gov.scot
q <- '{datasets(and:{ componentValues:
                                    [{component: \"http://purl.org/linked-data/sdmx/2009/dimension#refArea\" 
                                      level: \"http://statistics.gov.scot/def/geography/collection/dz-2001\"} ] 
                                    } ) 
                                   {schema uri title }}'

source('runQuery.R')
result<-runQuery(q)

# Define UI for ML application 
ML_ui <- shinyUI(fluidPage(
  
  # Define the application title
  titlePanel("Compatible LOSD selection"),

  #define the layout of the UI (one sidebar panel and one menupanel)  
  sidebarLayout(
    #sidebar panel is about selecting the response variable
    sidebarPanel(
        width = 4,
        #dropdown list to select the response variable
        selectizeInput(
          'var', 'Please select a response variable', result$data.datasets.schema,
          options = list(
            placeholder = 'Response variable',
            onInitialize = I('function() { this.setValue(""); }')
            )
        )
        #dropdown list to select the reference period of the repsonse variable
        ,uiOutput("yearCB"),
        uiOutput("actionbutton")
        ),
    #mainpanel is about selecting and extracting compatible datasets 
    mainPanel(
              uiOutput("xdatasets"), #Based on the selection of time values this presents compatible datasets
              uiOutput("download")
             )
  )))
 
