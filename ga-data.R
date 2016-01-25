#auth Google API
library(RGoogleAnalytics)

save(token, file="~/credentials/.token")

load("~/credentials/.token")

ValidateToken(token)

#upload profile list
profily_web <- read.csv2("all-sites-rga.csv")

#fetch profile ID and count profiles
profily_id <- profily_web[,1]
pocet_profilu <- length(profily_id)

#fetch profile names
profile_names <- profily_web[,2]
listOfDataFrames <- NULL
test_data_frame <- NULL
profily_id <- as.character(profily_id)


for (i in 1:pocet_profilu){
  print(profily_id[i])
  
  
  
  out <- tryCatch({
    
    query.list <- Init(start.date = "2015-01-01",
                       end.date = "2015-11-30",
                       dimensions = "ga:month,ga:eventLabel",
                       metrics = "ga:eventsPerSessionWithEvent",
                       max.results = 20000,
                       sort = "ga:eventsPerSessionWithEvent",
                       table.id = profily_id[i])
    
    ga.query <- QueryBuilder(query.list)
    
    #  ga.data <- GetReportData(ga.query,token,split_daywise = T) # by day
    
    ga.data <- GetReportData(ga.query,token)
    
    
    
    
    
  }, error=function(e){
    print("chyba-dat")
    return(NA)
    
  })
  
  if (is.na(out)){
    print("nejsou-data") 
    
  } else{
    print("data-ok")  
    
    ncol(ga.data) #pocet sloupcu 
    nrow(ga.data) #pocet radku
    new_col <- ncol(ga.data) + 1 #vytvori novy posledni sloupec
    
    ga.data[,new_col] <- profily_id[i] #vlozi profileID
    colnames(ga.data)[new_col] <- "ProfileId"  #nazev sloupce profileID
    new_col <- new_col + 1 #vytvori novy posledni sloupec
    ga.data[,new_col] <- profile_names[i] #vlozi profileName
    colnames(ga.data)[new_col] <- "ProfileName" #nazev sloupce profileID
    
    nam <- paste("source", profile_names[i], sep = "-")
    assign(nam, ga.data)
    
    
    listOfDataFrames[[i]] <- ga.data #vytvoreni listu ramcu")
    
    
  }
  
  
}

library(plyr)
df <- ldply(listOfDataFrames, data.frame) #vytvoreni 1 tabulky

# make a file
write.table(df, file="session-duration-2015.csv")