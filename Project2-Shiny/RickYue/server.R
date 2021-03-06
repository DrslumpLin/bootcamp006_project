server = function(input, output) { 
  
  season_select <- reactive({
    season_select <- input$sea
    
  })
  
  data_select_season <- reactive({
    df_lea = df_sea %>% filter(season==season_select())
    ## join the map table with entropy table to create a shp file for leaflet
    oo <- inner_join(league_countries@data, df_lea, by=c("ID"="country"))
    data_select_season=league_countries 
    data_select_season@data=oo
    data_select_season
  })
  
  league_select <- reactive({
    league_select <- input$lea
    
  })
  
  data_select_league <- reactive({
    data_select_league=df_sea%>%filter(country==league_select())%>%group_by(season)%>%summarize(entropy=mean(entropy))
    data_select_league
  })
  

  data_select_team <- reactive({
    data_select_team=df_team%>%filter(country==league_select())%>%group_by(season,team)%>%summarize(entropy=mean(entropy))
    data_select_team
  })
  
  data_select_table <- reactive({
    data_select_table=df_team%>%filter(country==league_select()&season==season_select())%>%group_by(country,season,team)%>%summarize(entropy=mean(entropy))
    data_select_table
  })
  
  
  output$myMap = renderLeaflet({
    mypal <- colorNumeric("OrRd",data_select_season()@data$entropy)
    leaflet(data_select_season()) %>% 
      addMarkers(0.1278,51.5074, popup = "England Premier League") %>%
      addMarkers(2.3522,48.8566, popup = "France Ligue 1") %>%
      addMarkers(13.4050,52.5200, popup = "Germany Bundesliga") %>%
      addMarkers(-9.1393,38.7223, popup = "Portugal Primeira Liga") %>%
      addMarkers(-3.7038,40.4168, popup = "Spain La Liga") %>%
      addMarkers(-3.1883,55.9533, popup = "Scotland Premier League") %>%
      addMarkers(12.4964,41.9028, popup = "Italy Serie A") %>%
      addMarkers(4.8952,52.3702, popup = "Netherlands Eredivisie")%>%
      addTiles()%>%
      addPolygons(smoothFactor = 0.2, fillOpacity = 1,color = ~mypal(entropy), stroke = FALSE)%>%
      addLegend("bottomright", pal = mypal, values = data_select_season()@data$entropy, title = "Preditability", opacity = 0.5)
  })
  
  output$myLinechart=renderPlot({
    ggplot(data=data_select_league(), aes(x=season, y=entropy,color="Purple")) +
      geom_line()+
      ggtitle(league_select())+
      labs(x="Season",y="Predictability")+
      geom_point(size=6, shape=20, fill="blue") + 
      theme(plot.title = element_text(size=32,face="bold",color="deepskyblue2"))+
      theme(axis.title = element_text(size=20,face="bold",color="deepskyblue2"))+
      theme(axis.text = element_text(size=15))+
      theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
            panel.background = element_blank(), axis.line = element_line(colour = "black"))+
      theme(legend.position="none")
  })
##################  
 output$myTeamchart=renderPlotly({
   p=ggplot(data=data_select_team(),aes(x=season, y=entropy)) +
     geom_point(aes(color=team),size=1)+
     ggtitle(league_select())+
     labs(x="Season",y="Predictability")+
     theme(title= element_text(size=20,face="bold",color="deepskyblue2"))+
     theme(axis.title= element_text(size=12,face="bold",color="deepskyblue2"))+
     theme(axis.title.y=element_blank())+
     theme(axis.text.x= element_text(angle = 20, hjust = 1,size=8))+
     theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
           panel.background = element_blank(), axis.line = element_line(colour = "black"))
    ggplotly(p)
    })

   output$myTable = renderDataTable({
     ta=data_select_table()
     colnames(ta)=c("League","Season","Team","Predictability")
     ta
   })

}



