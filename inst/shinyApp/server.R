library(Tetris)
library(beepr)
update.packages(ask=FALSE); beep()
fullTable<-totalMatrix()
cubes<-GnrCubes()
Gameon<-FALSE
server <- function(input, output,session) {
  totalscore<-0
  bgtable <-drawTable()
  active<-reactiveVal(FALSE)
  observeEvent(input$pressedKey,{
    if (!is.null(input$keyPressed) && Gameon)
    {
      active(FALSE)
      code<-input$keyPressed

      if(code==37) #Press <- 
      {
        cubes<<-MoveLeft(cubes,fullTable)#Call the GnrCubes function in TableID to move the square to the left
        beep(1)                          #Call the first sound in the beepr package
      }
      if(code==39) #Press ->
      {
        cubes<<-MoveRight(cubes,fullTable)#Call the GnrCubes function in TableID to move the square to the right
        beep(1) #Call the first sound in the beepr package
      }
      if(code==32) #Press Space
      {
        cubes<<-MoveDownQuickly(cubes,fullTable)#Call the GnrCubes function in TableID to move the square to the down quickly
        beep(1)       #Call the first sound in the beepr package
      }
      if(code==65) ##Press A
      {
        cubes<<-rotate(cubes,fullTable)#Call the GnrCubes function in TableID to rotate the square counterclockwise
        beep(1)     #Call the first sound in the beepr package
      }
      if(code==68) ##Press D
      {
        cubes<<-rev(rotate(cubes,fullTable))#Call the GnrCubes function in TableID to rotate the square clockwise
        beep(1)   #Call the first sound in the beepr package
      }
      if(code==83) ##Press S
      {
        cubes<<-MoveDown(cubes,fullTable)
      }
      if(code==87) ##Press W
      {
        cubes<<-rotate(cubes,fullTable)
      }
      active(TRUE)
    }
  })

  observe(
    {
      invalidateLater(1500, session)
      isolate({
        if(active())
        {
          bt<-UpdateTable(bgtable,cubes$cubesID)
          continueDrop<-checkNextBlock_y(cubes$cubesID,fullTable)
          if(continueDrop)
          {
            cubes$cubesID[,"y"]<<-cubes$cubesID[,"y"]-1
            rownames(cubes$cubeMatrix)<<-as.numeric(rownames(cubes$cubeMatrix))-1
          }
          else
          {
            for (i in 1:nrow(cubes$cubesID))
            {
              if(cubes$cubesID[i,"y"]>20)
                next()
              fullTable[as.character(cubes$cubesID[i,"y"]),as.character(cubes$cubesID[i,"x"])]<<-1
            }
            score<-GetScore(fullTable) #Call the GetScore function in the GameAction file to assign The Score to the getting score
            if(score$score>0)          #If the score score is greater than zero
            {
              fullTable<<-score$tables #fullTable is assigned the value score$tables
              totalscore<<-totalscore+score$score #The score for calculating this score is score$score, and the totalscore is totalscore plus score$score
              {
                output$ScorePanel <- renderText({paste0("Score: ",totalscore)   })#The totalscore calculated is assigned to the page using the output$ScorePanel
              }
            }
            bgtable<<-updateBackGround(fullTable)
            if(endGame(fullTable))
            {
              active(FALSE)
              Gameon<<-FALSE
              output$LevelInfo<-renderText("Game Over")
            }
            cubes<<-GnrCubes()
            #active(FALSE)
          }
          output$plot <- renderPlot({
            bt
          })
        }
      })
    })


  output$plot <- renderPlot({
    bgtable
  })
  output$currentTime <- renderText({
    invalidateLater(1000, session)
    paste("Time: ", Sys.time())
  })
  output$LevelInfo<-renderText("Level 1")
  output$ScorePanel <- renderText({"Score: 0"  })   #Initialize the output$ScorePanel to "Score: 0"
  observeEvent(input$startGame,{active(TRUE)
    fullTable<<-totalMatrix()
    cubes<<-GnrCubes()
    Gameon<<-TRUE
    bgtable <<-drawTable()})
  observeEvent(input$endGame,{
    active(FALSE)
    Gameon<<-FALSE
    })
  observeEvent(input$reset,{active(FALSE)
    output$LevelInfo<-renderText("Level 1")
    cubes<<-GnrCubes()
    bgtable <<-drawTable()
    output$plot <- renderPlot({
      bgtable
    })})
}



