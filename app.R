library(shiny)

shinyApp(
    ui = basicPage(
        actionButton("show", "Show modal dialog"),
        verbatimTextOutput("dataInfo")
    ),
    
    server = function(input, output) {
        # reactiveValues object for storing current data set.
        vals <- reactiveValues(data = NULL)
        
        # Return the UI for a modal dialog with data selection input. If 'failed' is
        # TRUE, then display a message that the previous value was invalid.
        dataModal <- function(failed = FALSE) {
            modalDialog(
                textInput("dataset", "Choose data set",
                          placeholder = 'Try "mtcars" or "abc"'
                ),
                span('(Try the name of a valid data object like "mtcars", ',
                     'then a name of a non-existent object like "abc")'),
                if (failed)
                    div(tags$b("Invalid name of data object", style = "color: red;")),
                
                footer = tagList(
                    modalButton("Cancel"),
                    actionButton("ok", "OK")
                )
            )
        }
        
        # Show modal when button is clicked.
        observeEvent(input$show, {
            showModal(dataModal())
        })
        
        # When OK button is pressed, attempt to load the data set. If successful,
        # remove the modal. If not show another modal, but this time with a failure
        # message.
        observeEvent(input$ok, {
            # Check that data object exists and is data frame.
            if (!is.null(input$dataset) && nzchar(input$dataset) &&
                exists(input$dataset) && is.data.frame(get(input$dataset))) {
                vals$data <- get(input$dataset)
                removeModal()
            } else {
                showModal(dataModal(failed = TRUE))
            }
        })
        
        # Display information about selected data
        output$dataInfo <- renderPrint({
            if (is.null(vals$data))
                "No data selected"
            else
                summary(vals$data)
        })
    }
)
