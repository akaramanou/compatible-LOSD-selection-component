#
# This is the server of the compatible-LOSD-selection-component
#


source("setServerOptions.R")
source("getCubeObservations.R")

results <-reactiveValues(SME=NULL, NV=NULL,SE=NULL)

ML_server <- shinyServer(function(input, output) {
  setServerOptions(4607, "127.0.0.1") #define the port and host of the app
  
  #initialize some variables
  v <- reactiveValues(data = NULL)
  b <- reactiveValues(data = NULL)

  
  #observe actions in buttons of the UI
  observeEvent(input$action, {
    v$data <- rnorm(100)
  }) #end of observeEvent
  
  observeEvent(input$action2, {
    b$data <- rnorm(100)
  })#end of observeEvent
  
  #########################################################################################
  
  #create the dropdown for the reference period
  output$yearCB <- renderUI({ 
    if (identical(input$var, "")) return()
    
    selectionInput <- reactive(input$var) #get the selected response variable
   
    #currently the years of the dropdown are inserted manually
    selectInput("y", label = "Please select time period", 
                list("2011"=2011,"2012"=2012,"2013"=2013,"2014"=2014))
    
  })#end of renderUI
  
  #########################################################################################
  
  #create the checkboxGroup with the compatible datasets
  output$xdatasets <- renderUI ({
    if (is.null(v$data)) return()
    selectionInput <- reactive(input$var) #get the selected response dataset
    selectionInput2 <- reactive(paste("http://reference.data.gov.uk/id/year/",input$y,sep="")) #get the selected year
   
    #create the query to get 
    q <-paste('{datasets(and:{ componentValues:
                    [{component: \"http://purl.org/linked-data/sdmx/2009/dimension#refArea\" 
                    level: \"http://statistics.gov.scot/def/geography/collection/dz-2001\"} ] 
                    } 
                    or:  { componentValues:[ 
                    {component:\"http://purl.org/linked-data/sdmx/2009/dimension#refPeriod\"  
                    values: ["',selectionInput2(),'"] }]}) 
                    {uri title schema}}', sep="")
    
    #execute the query and get the results
    results <- runQuery(q)
    
    #create the checkboxGroup
    checkboxGroupInput("checkGroup", label = "Please select compatible datasets", 
                       choices = results$data.datasets.schema,
                       selected = 1)
  })#end of renderUI
  
  #########################################################################################
  
  #create action buttons of the UI
  output$actionbutton <-renderUI ({
    if (identical(input$var, "")) return()
    actionButton("action", label = "Find compatible datasets") 
  }
  )

  output$download <- renderUI({
    if (is.null(v$data)) return()
    downloadButton('OutputFile', 'Extract Datasets')
  })
  
  output$OutputFile <- downloadHandler(
      filename = function() {
         paste('datasets', '.csv', sep='')
       },
      content = function(file) {
         x <- as.vector(input$checkGroup)
         write.table(x, file, row.names = FALSE, col.names=FALSE)
       }
    )
}) #end of shinyServer
