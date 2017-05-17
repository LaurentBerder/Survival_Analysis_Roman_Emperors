# Roman emperors, a Survival Analysis
Laurent Berder  


# Introduction

This paper will be a survival analysis based on Roman Emperors (from 26 before JC to 395 AD), for which data was found on this website: https://public.opendatasoft.com/explore/dataset/roman-emperors/table/?sort=index


## Preparation
Load libraries (survival and the ones I'm used to working with) and import data

```r
library(survival) # for survival analysis
library(data.table) # for data import
library(tidyverse) # for data manipulation
library(lubridate) # because the dates stretch over AD and BC eras, we need lubridate's as_date() to handle negative dates
library(survminer) # for plotting survival curves
library(plotly) # for other plots

# emperors <- fread("https://public.opendatasoft.com/explore/dataset/roman-emperors/download/?format=csv&timezone=Europe/Berlin&use_labels_for_header=true", stringsAsFactors = TRUE, check.names = TRUE) #download file straight from sourcepage
emperors <- fread("roman-emperors.csv", stringsAsFactors = TRUE, check.names = TRUE) #use previously downloaded file
```

__Cleaning & formatting__

```r
emperors <- emperors %>% select(-Verif, -Image) %>% arrange(Index)

emperors$Birth <- as.character(emperors$Birth) %>% as_date() 
emperors$Death <- as.character(emperors$Death) %>% as_date()
emperors$Reign.Start <- as.character(emperors$Reign.Start) %>% as_date()
emperors$Reign.End <- as.character(emperors$Reign.End) %>% as_date()
```

Some of the birth dates (and the first reign start date) take place in BCE, so we need to change them to negative years, which is where the lubridate package comes into play. The indication of whether the date should be modified is in the Notes field.

```r
ref_year <- as.integer(as_date("1/1/1"))

emperors$Birth[grep("BCE", emperors$Notes)] <- as_date(as.integer(emperors$Birth[grep("BCE", emperors$Notes)]) - 2*(as.integer(emperors$Birth[grep("BCE", emperors$Notes)]) - ref_year) - 365)

emperors$Reign.Start[grep("reign.start are BCE", emperors$Notes)] <- as_date(as.integer(emperors$Reign.Start[grep("reign.start are BCE", emperors$Notes)]) - 2*(as.integer(emperors$Reign.Start[grep("reign.start are BCE", emperors$Notes)]) - ref_year) - 365)
```

## Exploration
How did they die?

```r
plot_ly(data = emperors, x = ~Cause, type = "histogram") %>% layout(title = "Causes of death", xaxis = list(title = "Cause"), yaxis = list(title = "Frequency"))
```

<!--html_preserve--><div id="htmlwidget-ef3320321b4e8c6d006a" style="width:672px;height:480px;" class="plotly html-widget"></div>
<script type="application/json" data-for="htmlwidget-ef3320321b4e8c6d006a">{"x":{"layout":{"margin":{"b":40,"l":60,"t":25,"r":10},"title":"Causes of death","xaxis":{"domain":[0,1],"title":"Cause","type":"category","categoryorder":"array","categoryarray":["Assassination","Captivity","Died in Battle","Execution","Natural Causes","Suicide","Unknown"]},"yaxis":{"domain":[0,1],"title":"Frequency"}},"source":"A","config":{"modeBarButtonsToAdd":[{"name":"Collaborate","icon":{"width":1000,"ascent":500,"descent":-50,"path":"M487 375c7-10 9-23 5-36l-79-259c-3-12-11-23-22-31-11-8-22-12-35-12l-263 0c-15 0-29 5-43 15-13 10-23 23-28 37-5 13-5 25-1 37 0 0 0 3 1 7 1 5 1 8 1 11 0 2 0 4-1 6 0 3-1 5-1 6 1 2 2 4 3 6 1 2 2 4 4 6 2 3 4 5 5 7 5 7 9 16 13 26 4 10 7 19 9 26 0 2 0 5 0 9-1 4-1 6 0 8 0 2 2 5 4 8 3 3 5 5 5 7 4 6 8 15 12 26 4 11 7 19 7 26 1 1 0 4 0 9-1 4-1 7 0 8 1 2 3 5 6 8 4 4 6 6 6 7 4 5 8 13 13 24 4 11 7 20 7 28 1 1 0 4 0 7-1 3-1 6-1 7 0 2 1 4 3 6 1 1 3 4 5 6 2 3 3 5 5 6 1 2 3 5 4 9 2 3 3 7 5 10 1 3 2 6 4 10 2 4 4 7 6 9 2 3 4 5 7 7 3 2 7 3 11 3 3 0 8 0 13-1l0-1c7 2 12 2 14 2l218 0c14 0 25-5 32-16 8-10 10-23 6-37l-79-259c-7-22-13-37-20-43-7-7-19-10-37-10l-248 0c-5 0-9-2-11-5-2-3-2-7 0-12 4-13 18-20 41-20l264 0c5 0 10 2 16 5 5 3 8 6 10 11l85 282c2 5 2 10 2 17 7-3 13-7 17-13z m-304 0c-1-3-1-5 0-7 1-1 3-2 6-2l174 0c2 0 4 1 7 2 2 2 4 4 5 7l6 18c0 3 0 5-1 7-1 1-3 2-6 2l-173 0c-3 0-5-1-8-2-2-2-4-4-4-7z m-24-73c-1-3-1-5 0-7 2-2 3-2 6-2l174 0c2 0 5 0 7 2 3 2 4 4 5 7l6 18c1 2 0 5-1 6-1 2-3 3-5 3l-174 0c-3 0-5-1-7-3-3-1-4-4-5-6z"},"click":"function(gd) { \n        // is this being viewed in RStudio?\n        if (location.search == '?viewer_pane=1') {\n          alert('To learn about plotly for collaboration, visit:\\n https://cpsievert.github.io/plotly_book/plot-ly-for-collaboration.html');\n        } else {\n          window.open('https://cpsievert.github.io/plotly_book/plot-ly-for-collaboration.html', '_blank');\n        }\n      }"}],"modeBarButtonsToRemove":["sendDataToCloud"]},"data":[{"x":["Assassination","Assassination","Assassination","Assassination","Suicide","Assassination","Suicide","Assassination","Natural Causes","Natural Causes","Assassination","Natural Causes","Natural Causes","Natural Causes","Natural Causes","Natural Causes","Natural Causes","Assassination","Assassination","Execution","Natural Causes","Assassination","Assassination","Execution","Assassination","Assassination","Assassination","Suicide","Execution","Assassination","Assassination","Died in Battle","Execution","Died in Battle","Natural Causes","Assassination","Assassination","Captivity","Assassination","Natural Causes","Unknown","Assassination","Natural Causes","Assassination","Assassination","Natural Causes","Unknown","Died in Battle","Natural Causes","Suicide","Natural Causes","Natural Causes","Assassination","Natural Causes","Execution","Execution","Execution","Execution","Natural Causes","Assassination","Unknown","Died in Battle","Natural Causes","Natural Causes","Died in Battle","Assassination","Suicide","Natural Causes"],"type":"histogram","marker":{"fillcolor":"rgba(31,119,180,1)","color":"rgba(31,119,180,1)","line":{"color":"transparent"}},"xaxis":"x","yaxis":"y"}],"base_url":"https://plot.ly"},"evals":["config.modeBarButtonsToAdd.0.click"],"jsHooks":[]}</script><!--/html_preserve-->

## Definition of Survival

We'll look at **Assassination**, **Captivity** and **Execution** as traumatic ends to their reigns (event = 1), while Natural Causes, Died in Battle and Suicide are more "normal" ways for an emperor's reign to come to an end (event = 0). We'll censor on emperors who died after the end of their reign (the ones that abdicated or were deposed without being killed)

```r
emperors$event <- ifelse(emperors$Cause %in% c("Assassination", "Captivity", "Execution"), 1, 0)
emperors$event <- ifelse(emperors$Reign.End < emperors$Death, 0, emperors$event)

emperors <- filter(emperors, Cause != "Unknown" | Reign.End < Death) # Getting rid of the unknown deaths that are not censored
```


We need to calculate ages.

```r
emperors$age_accession <- interval(emperors$Birth, emperors$Reign.Start) / years(1)
emperors$length_reign <- interval(emperors$Reign.Start, emperors$Reign.End) / years(1)
emperors$age_death <- interval(emperors$Birth, emperors$Death) / years(1)

plot_ly(data = filter(emperors, !is.na(age_death)), type = "histogram", alpha = 0.6) %>%
  add_trace(x = ~age_death, type = "histogram", name = "Age of death")  %>% 
  add_trace(x = ~length_reign, type = "histogram", name = "Length of reign") %>%
  layout(barmode = "overlay", title = "Age of Death & Length of Reign", xaxis = list(title = "Years"), yaxis = list(title = "Frequency")) 
```

<!--html_preserve--><div id="htmlwidget-2f3ddfdd3d6655884926" style="width:672px;height:480px;" class="plotly html-widget"></div>
<script type="application/json" data-for="htmlwidget-2f3ddfdd3d6655884926">{"x":{"layout":{"margin":{"b":40,"l":60,"t":25,"r":10},"barmode":"overlay","title":"Age of Death & Length of Reign","xaxis":{"domain":[0,1],"title":"Years"},"yaxis":{"domain":[0,1],"title":"Frequency"}},"source":"A","config":{"modeBarButtonsToAdd":[{"name":"Collaborate","icon":{"width":1000,"ascent":500,"descent":-50,"path":"M487 375c7-10 9-23 5-36l-79-259c-3-12-11-23-22-31-11-8-22-12-35-12l-263 0c-15 0-29 5-43 15-13 10-23 23-28 37-5 13-5 25-1 37 0 0 0 3 1 7 1 5 1 8 1 11 0 2 0 4-1 6 0 3-1 5-1 6 1 2 2 4 3 6 1 2 2 4 4 6 2 3 4 5 5 7 5 7 9 16 13 26 4 10 7 19 9 26 0 2 0 5 0 9-1 4-1 6 0 8 0 2 2 5 4 8 3 3 5 5 5 7 4 6 8 15 12 26 4 11 7 19 7 26 1 1 0 4 0 9-1 4-1 7 0 8 1 2 3 5 6 8 4 4 6 6 6 7 4 5 8 13 13 24 4 11 7 20 7 28 1 1 0 4 0 7-1 3-1 6-1 7 0 2 1 4 3 6 1 1 3 4 5 6 2 3 3 5 5 6 1 2 3 5 4 9 2 3 3 7 5 10 1 3 2 6 4 10 2 4 4 7 6 9 2 3 4 5 7 7 3 2 7 3 11 3 3 0 8 0 13-1l0-1c7 2 12 2 14 2l218 0c14 0 25-5 32-16 8-10 10-23 6-37l-79-259c-7-22-13-37-20-43-7-7-19-10-37-10l-248 0c-5 0-9-2-11-5-2-3-2-7 0-12 4-13 18-20 41-20l264 0c5 0 10 2 16 5 5 3 8 6 10 11l85 282c2 5 2 10 2 17 7-3 13-7 17-13z m-304 0c-1-3-1-5 0-7 1-1 3-2 6-2l174 0c2 0 4 1 7 2 2 2 4 4 5 7l6 18c0 3 0 5-1 7-1 1-3 2-6 2l-173 0c-3 0-5-1-8-2-2-2-4-4-4-7z m-24-73c-1-3-1-5 0-7 2-2 3-2 6-2l174 0c2 0 5 0 7 2 3 2 4 4 5 7l6 18c1 2 0 5-1 6-1 2-3 3-5 3l-174 0c-3 0-5-1-7-3-3-1-4-4-5-6z"},"click":"function(gd) { \n        // is this being viewed in RStudio?\n        if (location.search == '?viewer_pane=1') {\n          alert('To learn about plotly for collaboration, visit:\\n https://cpsievert.github.io/plotly_book/plot-ly-for-collaboration.html');\n        } else {\n          window.open('https://cpsievert.github.io/plotly_book/plot-ly-for-collaboration.html', '_blank');\n        }\n      }"}],"modeBarButtonsToRemove":["sendDataToCloud"]},"data":[{"type":"histogram","marker":{"fillcolor":"rgba(31,119,180,0.6)","color":"rgba(31,119,180,0.6)","line":{"color":"transparent"}},"xaxis":"x","yaxis":"y"},{"type":"histogram","x":[76.3534246575342,78.0739726027397,28.4,63.358904109589,30.483606557377,71.013698630137,36.9671232876712,54.2383561643836,69.6,41.7041095890411,44.9016393442623,67.2191780821918,63.8849315068493,62.4575342465753,74.4630136986301,58.8907103825137,38.2465753424658,31.3342465753425,66.654794520548,60.4164383561644,65.8191780821918,29.0109589041096,22.7841530054645,53.4328767123288,19.1890410958904,26.4602739726027,65.4520547945205,79.2767123287671,46.2767123287671,60.572602739726,60.572602739726,19.0601092896175,45.7479452054795,50.4520547945205,21.7479452054795,47.6191780821918,46.786301369863,69,50.7049180327869,56.6849315068493,61.0163934426229,76.4535519125683,50.1178082191781,53.5808219178082,66.9479452054795,60.5342465753425,56.3178082191781,51.3287671232877,65.2301369863014,34.7677595628415,42.6958904109589,75.1616438356164,23.9150684931507,44.241095890411,30.1205479452055,31.986301369863,33.1284153005465,54.3743169398907,50.6027397260274,24.3524590163934,21.3688524590164,48.0164383561644],"name":"Age of death","marker":{"fillcolor":"rgba(255,127,14,0.6)","color":"rgba(255,127,14,0.6)","line":{"color":"transparent"}},"xaxis":"x","yaxis":"y"},{"type":"histogram","x":[39.6684931506849,22.4904109589041,3.85479452054795,13.7150684931507,13.655737704918,0.605479452054795,0.249315068493151,0.676712328767123,9.50684931506849,2.22191780821918,15.0109589041096,1.35890410958904,19.5232876712329,20.9123287671233,22.6575342465753,19.027397260274,8.02191780821918,15.9972677595628,0.235616438356164,0.26027397260274,17.8246575342466,19.2657534246575,2.98356164383562,1.15890410958904,3.75616438356164,13.0136612021858,3.23835616438356,0.0575342465753425,0.0575342465753425,0.268493150684932,0.268493150684932,5.80601092896175,5.62739726027397,1.7041095890411,0.295081967213115,2.16712328767123,0.167123287671233,6.21311475409836,14.9180327868852,1.33424657534247,5,0.721311475409836,6.04383561643836,0.832876712328767,20.4438356164384,19.0821917808219,1.23287671232877,6,30.8246575342466,6,2.25205479452055,15.8524590163934,2.6120218579235,24.4520547945205,12.7342465753425,3.36164383561644,0.644808743169399,11.7232876712329,14.3671232876712,16.0573770491803,16.4918032786885,16.0438356164384],"name":"Length of reign","marker":{"fillcolor":"rgba(44,160,44,0.6)","color":"rgba(44,160,44,0.6)","line":{"color":"transparent"}},"xaxis":"x","yaxis":"y"}],"base_url":"https://plot.ly"},"evals":["config.modeBarButtonsToAdd.0.click"],"jsHooks":[]}</script><!--/html_preserve-->

An explicit chart of the lifespan and reign length of all the emperors over time.

```r
p <- plot_ly()
for(i in 1:(nrow(emperors) - 1)){
  p <- add_trace(p, type = "scatter", mode = "lines", # Life line
                 x = c(year(emperors$Birth[i]), 
                           year(emperors$Death[i])),
                 y = c(i, i),
                 line = list(color = "white", width = 5),
                 showlegend = F, hoverinfo = "text",
                 # Create custom hover text
                 text = paste("Name: ", emperors$Name[i], "<br>",
                              "Age: ", round(emperors$age_death[i], 1), "years<br>",
                              "Length of reign: ", round(emperors$length_reign[i], 1), "years<br>")) %>% 
    
    add_trace(type = "scatter", x = c(year(emperors$Reign.Start[i]), 
                                      year(emperors$Reign.End[i])), # Reign line
              y = c(i, i), mode = "lines", line = list(color = "blue", width = 3),
              showlegend = F, hoverinfo = "none") %>%
    

    layout(plot_bgcolor = "#424D5C", paper_bgcolor = "#424D5C",
           font=list(color = "white", size = 12),
           yaxis = list(showgrid = F, tickmode = "array", tickfont = list(size = 7),
                        autorange = "reversed",
                        tickvals = 1:nrow(emperors), ticktext = unique(emperors$Name)),
           xaxis = list(showgrid = F,
                        tickval = min(emperors$Birth, na.rm=T):max(emperors$Death, na.rm=T), title = " <b><i>Date</i></b>", titlefont = list(color= c("#7F9FBD"))),
           title = "Life and reign of Roman emperors")
}

p
```

<!--html_preserve--><div id="htmlwidget-86e2442c67eb6f372349" style="width:672px;height:480px;" class="plotly html-widget"></div>


## Distribution observation

```r
table(emperors$event)
```

```
## 
##  0  1 
## 34 32
```

```r
plot_ly(data = emperors, x = ~length_reign, type = "histogram", marker = list(color="red")) %>% layout(title = "Distribution of length reign for all emperors", xaxis = list(title = "Years of reign"), yaxis = list(title = "Frequency"))
```

<!--html_preserve--><div id="htmlwidget-d3825586545552c105e7" style="width:672px;height:480px;" class="plotly html-widget"></div>
<script type="application/json" data-for="htmlwidget-d3825586545552c105e7">{"x":{"layout":{"margin":{"b":40,"l":60,"t":25,"r":10},"title":"Distribution of length reign for all emperors","xaxis":{"domain":[0,1],"title":"Years of reign"},"yaxis":{"domain":[0,1],"title":"Frequency"}},"source":"A","config":{"modeBarButtonsToAdd":[{"name":"Collaborate","icon":{"width":1000,"ascent":500,"descent":-50,"path":"M487 375c7-10 9-23 5-36l-79-259c-3-12-11-23-22-31-11-8-22-12-35-12l-263 0c-15 0-29 5-43 15-13 10-23 23-28 37-5 13-5 25-1 37 0 0 0 3 1 7 1 5 1 8 1 11 0 2 0 4-1 6 0 3-1 5-1 6 1 2 2 4 3 6 1 2 2 4 4 6 2 3 4 5 5 7 5 7 9 16 13 26 4 10 7 19 9 26 0 2 0 5 0 9-1 4-1 6 0 8 0 2 2 5 4 8 3 3 5 5 5 7 4 6 8 15 12 26 4 11 7 19 7 26 1 1 0 4 0 9-1 4-1 7 0 8 1 2 3 5 6 8 4 4 6 6 6 7 4 5 8 13 13 24 4 11 7 20 7 28 1 1 0 4 0 7-1 3-1 6-1 7 0 2 1 4 3 6 1 1 3 4 5 6 2 3 3 5 5 6 1 2 3 5 4 9 2 3 3 7 5 10 1 3 2 6 4 10 2 4 4 7 6 9 2 3 4 5 7 7 3 2 7 3 11 3 3 0 8 0 13-1l0-1c7 2 12 2 14 2l218 0c14 0 25-5 32-16 8-10 10-23 6-37l-79-259c-7-22-13-37-20-43-7-7-19-10-37-10l-248 0c-5 0-9-2-11-5-2-3-2-7 0-12 4-13 18-20 41-20l264 0c5 0 10 2 16 5 5 3 8 6 10 11l85 282c2 5 2 10 2 17 7-3 13-7 17-13z m-304 0c-1-3-1-5 0-7 1-1 3-2 6-2l174 0c2 0 4 1 7 2 2 2 4 4 5 7l6 18c0 3 0 5-1 7-1 1-3 2-6 2l-173 0c-3 0-5-1-8-2-2-2-4-4-4-7z m-24-73c-1-3-1-5 0-7 2-2 3-2 6-2l174 0c2 0 5 0 7 2 3 2 4 4 5 7l6 18c1 2 0 5-1 6-1 2-3 3-5 3l-174 0c-3 0-5-1-7-3-3-1-4-4-5-6z"},"click":"function(gd) { \n        // is this being viewed in RStudio?\n        if (location.search == '?viewer_pane=1') {\n          alert('To learn about plotly for collaboration, visit:\\n https://cpsievert.github.io/plotly_book/plot-ly-for-collaboration.html');\n        } else {\n          window.open('https://cpsievert.github.io/plotly_book/plot-ly-for-collaboration.html', '_blank');\n        }\n      }"}],"modeBarButtonsToRemove":["sendDataToCloud"]},"data":[{"x":[39.6684931506849,22.4904109589041,3.85479452054795,13.7150684931507,13.655737704918,0.605479452054795,0.249315068493151,0.676712328767123,9.50684931506849,2.22191780821918,15.0109589041096,1.35890410958904,19.5232876712329,20.9123287671233,22.6575342465753,19.027397260274,8.02191780821918,15.9972677595628,0.235616438356164,0.26027397260274,17.8246575342466,19.2657534246575,2.98356164383562,1.15890410958904,3.75616438356164,13.0136612021858,3.23835616438356,0.0575342465753425,0.0575342465753425,0.268493150684932,0.268493150684932,5.80601092896175,5.62739726027397,1.7041095890411,0.295081967213115,2.16712328767123,0.167123287671233,6.21311475409836,14.9180327868852,1.33424657534247,5,0.721311475409836,0.252054794520548,6.04383561643836,0.832876712328767,2,20.4438356164384,19.0821917808219,1.23287671232877,6,2.37704918032787,30.8246575342466,6,2.25205479452055,15.8524590163934,2.6120218579235,24.4520547945205,12.7342465753425,0.819178082191781,3.36164383561644,0.644808743169399,11.7232876712329,14.3671232876712,16.0573770491803,16.4918032786885,16.0438356164384],"marker":{"fillcolor":"rgba(31,119,180,1)","color":"red","line":{"color":"transparent"}},"type":"histogram","xaxis":"x","yaxis":"y"}],"base_url":"https://plot.ly"},"evals":["config.modeBarButtonsToAdd.0.click"],"jsHooks":[]}</script><!--/html_preserve-->

```r
plot_ly(data = filter(emperors, event == 1), x = ~length_reign, type = "histogram", marker = list(color="purple")) %>% layout(title = "Distribution of length reign for uncensored emperors", xaxis = list(title = "Years of reign"), yaxis = list(title = "Frequency"))
```

<!--html_preserve--><div id="htmlwidget-a0fd0d6bf72fbecd7c45" style="width:672px;height:480px;" class="plotly html-widget"></div>
<script type="application/json" data-for="htmlwidget-a0fd0d6bf72fbecd7c45">{"x":{"layout":{"margin":{"b":40,"l":60,"t":25,"r":10},"title":"Distribution of length reign for uncensored emperors","xaxis":{"domain":[0,1],"title":"Years of reign"},"yaxis":{"domain":[0,1],"title":"Frequency"}},"source":"A","config":{"modeBarButtonsToAdd":[{"name":"Collaborate","icon":{"width":1000,"ascent":500,"descent":-50,"path":"M487 375c7-10 9-23 5-36l-79-259c-3-12-11-23-22-31-11-8-22-12-35-12l-263 0c-15 0-29 5-43 15-13 10-23 23-28 37-5 13-5 25-1 37 0 0 0 3 1 7 1 5 1 8 1 11 0 2 0 4-1 6 0 3-1 5-1 6 1 2 2 4 3 6 1 2 2 4 4 6 2 3 4 5 5 7 5 7 9 16 13 26 4 10 7 19 9 26 0 2 0 5 0 9-1 4-1 6 0 8 0 2 2 5 4 8 3 3 5 5 5 7 4 6 8 15 12 26 4 11 7 19 7 26 1 1 0 4 0 9-1 4-1 7 0 8 1 2 3 5 6 8 4 4 6 6 6 7 4 5 8 13 13 24 4 11 7 20 7 28 1 1 0 4 0 7-1 3-1 6-1 7 0 2 1 4 3 6 1 1 3 4 5 6 2 3 3 5 5 6 1 2 3 5 4 9 2 3 3 7 5 10 1 3 2 6 4 10 2 4 4 7 6 9 2 3 4 5 7 7 3 2 7 3 11 3 3 0 8 0 13-1l0-1c7 2 12 2 14 2l218 0c14 0 25-5 32-16 8-10 10-23 6-37l-79-259c-7-22-13-37-20-43-7-7-19-10-37-10l-248 0c-5 0-9-2-11-5-2-3-2-7 0-12 4-13 18-20 41-20l264 0c5 0 10 2 16 5 5 3 8 6 10 11l85 282c2 5 2 10 2 17 7-3 13-7 17-13z m-304 0c-1-3-1-5 0-7 1-1 3-2 6-2l174 0c2 0 4 1 7 2 2 2 4 4 5 7l6 18c0 3 0 5-1 7-1 1-3 2-6 2l-173 0c-3 0-5-1-8-2-2-2-4-4-4-7z m-24-73c-1-3-1-5 0-7 2-2 3-2 6-2l174 0c2 0 5 0 7 2 3 2 4 4 5 7l6 18c1 2 0 5-1 6-1 2-3 3-5 3l-174 0c-3 0-5-1-7-3-3-1-4-4-5-6z"},"click":"function(gd) { \n        // is this being viewed in RStudio?\n        if (location.search == '?viewer_pane=1') {\n          alert('To learn about plotly for collaboration, visit:\\n https://cpsievert.github.io/plotly_book/plot-ly-for-collaboration.html');\n        } else {\n          window.open('https://cpsievert.github.io/plotly_book/plot-ly-for-collaboration.html', '_blank');\n        }\n      }"}],"modeBarButtonsToRemove":["sendDataToCloud"]},"data":[{"x":[39.6684931506849,22.4904109589041,3.85479452054795,13.7150684931507,0.605479452054795,0.676712328767123,15.0109589041096,15.9972677595628,0.235616438356164,0.26027397260274,19.2657534246575,2.98356164383562,1.15890410958904,3.75616438356164,13.0136612021858,3.23835616438356,0.0575342465753425,0.268493150684932,0.268493150684932,5.62739726027397,2.16712328767123,0.167123287671233,14.9180327868852,5,0.252054794520548,6.04383561643836,2.37704918032787,6,2.25205479452055,2.6120218579235,12.7342465753425,16.0573770491803],"marker":{"fillcolor":"rgba(31,119,180,1)","color":"purple","line":{"color":"transparent"}},"type":"histogram","xaxis":"x","yaxis":"y"}],"base_url":"https://plot.ly"},"evals":["config.modeBarButtonsToAdd.0.click"],"jsHooks":[]}</script><!--/html_preserve-->
The data is evenly split between events and censoring.
Neither of the distributions seem to follow a specific law, so we'll have to skip the classical statistics, and jump straight to the survival analysis.

# Survival Analysis
## Kaplan-Meier
The simplest analysis we can look at is the Kaplan-Meier survival curves.


```r
KM <- survfit(Surv(length_reign, event)~1, data=emperors)
KM
```

```
## Call: survfit(formula = Surv(length_reign, event) ~ 1, data = emperors)
## 
##       n  events  median 0.95LCL 0.95UCL 
##   66.00   32.00   14.92    6.04      NA
```
*Median Survival:* The first observation is that after almost 15 years, half of the 66 emperors had already been killed.


```r
ggsurvplot(KM, risk.table = TRUE, main = "Kaplan-Meier for emperors' survival", xlab = "Length of reign in years", ylab = "Survival rate")
```

![](Roman_Emperors_files/figure-html/unnamed-chunk-11-1.png)<!-- -->

This plot shows the survival rate of emperors based on their length of reign, with crosses for the emperors that were not killed (censored).
The table at the bottom indicates the number of surviving emperors after years of reign from 0 (minimum survival time) to 40 (maximum survival time).

## Logrank
There are two large eras covered by the data's timeframe: the Principate (earlier) and the Dominate (or despotic) eras. Let's find out if there are significant differences in emperors' survival expectation between these two eras or not.

```r
table(emperors$Era, emperors$event)
```

```
##             
##               0  1
##   Dominate   14  6
##   Principate 20 26
```

```r
logrank <- survdiff(Surv(length_reign, event)~Era, data = emperors)
logrank
```

```
## Call:
## survdiff(formula = Surv(length_reign, event) ~ Era, data = emperors)
## 
##                 N Observed Expected (O-E)^2/E (O-E)^2/V
## Era=Dominate   20        6     11.6      2.73       4.4
## Era=Principate 46       26     20.4      1.56       4.4
## 
##  Chisq= 4.4  on 1 degrees of freedom, p= 0.036
```
The rather low p-value of this logrank test shows us that there seems to be a significant difference, which we'll investigate further with stratification.


## Stratification
To find out in which way the era influences survival, we'll plot the distinction.

```r
ggsurvplot(survfit(Surv(length_reign, event) ~Era, data=emperors), pval = TRUE, risk.table = TRUE, main = "Emperors' survival by Era (log-log)", fun="cloglog")
```

![](Roman_Emperors_files/figure-html/unnamed-chunk-13-1.png)<!-- -->
We can see already that there is a steep difference in survival rate if we distinguish the 2 eras: emperors were much likely to get killed in the Principate era than in the Dominate era. This finding is reinforced by the parallelism of both curves, in log-log format.

This result is rather surprising, as we know that the Principate era was characterised by an effort on the part of the emperors to preserve the illusion of continuance of the Roman Republic.


We'll investigate on other possible distinctions that might influence the risk for emperors to get killed.
For example, we can wonder if the way the emperor achieved his position (Succession) influences the risk. There are too many categories, so let's first group some of them together.

```r
emperors$Succession2 <- ifelse(emperors$Succession %in% c("Appointment by Army", "Appointment by Praetorian Guard"), "Appointment by military", ifelse(emperors$Succession %in% c("Appointment by Emperor", "Appointment by Senate"), "Appointment by state", ifelse(emperors$Succession == "Birthright", "Birthright", ifelse(emperors$Succession == "Seized Power", "Seized Power",  "Other"))))


summary(coxph(Surv(length_reign, event) ~Era + Succession2, data = emperors))
```

```
## Call:
## coxph(formula = Surv(length_reign, event) ~ Era + Succession2, 
##     data = emperors)
## 
##   n= 66, number of events= 32 
## 
##                                     coef exp(coef) se(coef)      z
## EraPrincipate                    1.02913   2.79863  0.49705  2.070
## Succession2Appointment by state -0.09463   0.90971  0.68215 -0.139
## Succession2Birthright           -1.21307   0.29728  0.52734 -2.300
## Succession2Other                 0.38298   1.46665  1.14179  0.335
## Succession2Seized Power         -0.78310   0.45699  0.66021 -1.186
##                                 Pr(>|z|)  
## EraPrincipate                     0.0384 *
## Succession2Appointment by state   0.8897  
## Succession2Birthright             0.0214 *
## Succession2Other                  0.7373  
## Succession2Seized Power           0.2356  
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
##                                 exp(coef) exp(-coef) lower .95 upper .95
## EraPrincipate                      2.7986     0.3573    1.0565    7.4138
## Succession2Appointment by state    0.9097     1.0993    0.2389    3.4638
## Succession2Birthright              0.2973     3.3638    0.1058    0.8357
## Succession2Other                   1.4666     0.6818    0.1565   13.7473
## Succession2Seized Power            0.4570     2.1882    0.1253    1.6668
## 
## Concordance= 0.698  (se = 0.056 )
## Rsquare= 0.168   (max possible= 0.963 )
## Likelihood ratio test= 12.1  on 5 df,   p=0.03338
## Wald test            = 11.2  on 5 df,   p=0.04756
## Score (logrank) test = 12.67  on 5 df,   p=0.02671
```

```r
summary(coxph(Surv(length_reign, event) ~Era + strata(Succession2), data = emperors))
```

```
## Call:
## coxph(formula = Surv(length_reign, event) ~ Era + strata(Succession2), 
##     data = emperors)
## 
##   n= 66, number of events= 32 
## 
##                 coef exp(coef) se(coef)     z Pr(>|z|)
## EraPrincipate 0.6993    2.0123   0.4776 1.464    0.143
## 
##               exp(coef) exp(-coef) lower .95 upper .95
## EraPrincipate     2.012     0.4969    0.7892     5.131
## 
## Concordance= 0.536  (se = 0.08 )
## Rsquare= 0.035   (max possible= 0.886 )
## Likelihood ratio test= 2.38  on 1 df,   p=0.1226
## Wald test            = 2.14  on 1 df,   p=0.1431
## Score (logrank) test = 2.22  on 1 df,   p=0.1362
```

```r
ggsurvplot(survfit(Surv(length_reign, event) ~ Succession2, data = emperors), pval = TRUE, pval.coord = c(30,0.8), main = "Emperors' survival by way of accessing power", legend.labs = c("Appointment by military", "Appointment by state", "Birthright", "Other", "Seized Power"))
```

![](Roman_Emperors_files/figure-html/unnamed-chunk-14-1.png)<!-- -->

The first detailed model, displays interesting relevance with low p-values indicating that different succession methods imply different risks, while the second more general model does not offer a credible p-value to be followed as-is. 

Indeed, plotting the Cox in cloglog we can see that the lines are not parralel, which is why the model as a whole is not so effective.

```r
ggsurvplot(survfit(Surv(length_reign, event) ~ Era + Succession2, data = emperors), pval = TRUE, pval.coord = c(30,-2), fun="cloglog", legend.labs = c("Dominate/Appointment by military", "Dominate/Appointment by state", "Dominate/Birthright", "Dominate/Other", "Dominate/Seized Power","Principate/Appointment by military", "Principate/Appointment by state", "Principate/Birthright", "Principate/Other", "Principate/Seized Power"))
```

![](Roman_Emperors_files/figure-html/unnamed-chunk-15-1.png)<!-- -->

We can conclude from this (none of the lines are parallel) that the model is not accurate because the Cox assumption of proportionality of hazards is not respected: we will not be able to use the coefficients from the model, but we may still consider Succession as a somewhat interesting variable, since adding the Succession to the Era improves the p-value.




We can wonder if the __Emperor's origin__ plays a role in his popularity in Rome and therefore his survival likelihood.

```r
table(emperors$Birth.Province, emperors$event)
```

```
##                     
##                       0  1
##   Africa              0  1
##   Dacia Aureliana     0  1
##   Dalmatian           1  0
##   Gallia Lugdunensis  0  2
##   Gallia Narbonensis  1  1
##   Hispania            1  0
##   Hispania Baetica    2  0
##   Italia             11 11
##   Libya               1  0
##   Mauretania          0  1
##   Moesia              3  1
##   Moesia Superior     3  0
##   Pannonia            6  3
##   Pannonia Inferior   1  0
##   Phrygia             1  0
##   Syria               0  3
##   Thrace              1  1
##   Unknown             2  7
```
However, the categories are a little too numerous and therefore too restrictive to be very indicative, so we'll proceed to some grouping in order to have wider groups.

```r
emperors$Birth.Region <- ifelse(emperors$Birth.Province %in% c("Africa", "Libya", "Mauretania"), "Africa", ifelse(emperors$Birth.Province %in% c("Gallia Lugdunensis", "Gallia Narbonensis"), "Gaul", ifelse(emperors$Birth.Province %in% c("Hispania", "Hispania Baetica"), "Spain", ifelse(emperors$Birth.Province %in% c("Dacia Aureliana", "Dalmatian", "Moesia", "Moesia Superior", "Pannonia", "Pannonia Inferior", "Thrace"), "East Europe", ifelse(emperors$Birth.Province %in% c("Phrygia", "Syria"), "Asia Minor", ifelse(emperors$Birth.Province == "Italia", "Italia", "Unknown"))))))
table(emperors$Birth.Region, emperors$event)
```

```
##              
##                0  1
##   Africa       1  2
##   Asia Minor   1  3
##   East Europe 15  6
##   Gaul         1  3
##   Italia      11 11
##   Spain        3  0
##   Unknown      2  7
```
It will be easier to work with 7 levels than 18.

```r
region <- survfit(Surv(length_reign, event) ~Birth.Region, data=emperors)
summary(region)
```

```
## Call: survfit(formula = Surv(length_reign, event) ~ Birth.Region, data = emperors)
## 
##                 Birth.Region=Africa 
##   time n.risk n.event survival std.err lower 95% CI upper 95% CI
##  0.167      3       1    0.667   0.272       0.2995            1
##  1.159      2       1    0.333   0.272       0.0673            1
## 
##                 Birth.Region=Asia Minor 
##   time n.risk n.event survival std.err lower 95% CI upper 95% CI
##   3.76      3       1    0.667   0.272       0.2995            1
##   5.63      2       1    0.333   0.272       0.0673            1
##  13.01      1       1    0.000     NaN           NA           NA
## 
##                 Birth.Region=East Europe 
##   time n.risk n.event survival std.err lower 95% CI upper 95% CI
##   2.25     15       1    0.933  0.0644        0.815        1.000
##   3.24     14       1    0.867  0.0878        0.711        1.000
##   5.00     12       1    0.794  0.1061        0.612        1.000
##   6.04     10       1    0.715  0.1216        0.512        0.998
##  12.73      8       1    0.626  0.1353        0.409        0.956
##  16.06      5       1    0.501  0.1557        0.272        0.921
## 
##                 Birth.Region=Gaul 
##   time n.risk n.event survival std.err lower 95% CI upper 95% CI
##   2.61      3       1    0.667   0.272       0.2995            1
##  13.72      2       1    0.333   0.272       0.0673            1
##  19.27      1       1    0.000     NaN           NA           NA
## 
##                 Birth.Region=Italia 
##    time n.risk n.event survival std.err lower 95% CI upper 95% CI
##   0.236     22       1    0.955  0.0444        0.871        1.000
##   0.260     20       1    0.907  0.0628        0.792        1.000
##   0.605     19       1    0.859  0.0755        0.723        1.000
##   0.677     18       1    0.811  0.0851        0.661        0.996
##   2.167     15       1    0.757  0.0950        0.592        0.968
##   2.984     13       1    0.699  0.1041        0.522        0.936
##   3.855     12       1    0.641  0.1105        0.457        0.898
##  15.011      7       1    0.549  0.1271        0.349        0.864
##  15.997      6       1    0.458  0.1349        0.257        0.816
##  22.490      3       1    0.305  0.1536        0.114        0.819
##  39.668      1       1    0.000     NaN           NA           NA
## 
##                 Birth.Region=Spain 
##      time n.risk n.event survival std.err lower 95% CI upper 95% CI
## 
##                 Birth.Region=Unknown 
##     time n.risk n.event survival std.err lower 95% CI upper 95% CI
##   0.0575      9       1    0.889   0.105       0.7056        1.000
##   0.2521      8       1    0.778   0.139       0.5485        1.000
##   0.2685      7       2    0.556   0.166       0.3097        0.997
##   2.3770      4       1    0.417   0.173       0.1847        0.940
##   6.0000      3       1    0.278   0.162       0.0888        0.869
##  14.9180      1       1    0.000     NaN           NA           NA
```

```r
ggsurvplot(region, pval = TRUE, pval.coord = c(30,0.9), palette = c(c("#00EE00", "#0000EE", "#CD0000", "#BF3EFF", "#EEEE00", "#00FFFF", "#EE9A00")), main = "Emperors' survival by Province of origin", legend.labs = c("Africa","Asia Minor", "East Europe", "Gaul", "Italia", "Spain", "Unknown"))
```

![](Roman_Emperors_files/figure-html/unnamed-chunk-18-1.png)<!-- -->

Here we can see the survival curves based on the region of origin. There is definitively some impact, based on the low p-value, but the lines themselves are not that indicative (in log-log, they are not parallel), so we won't be using the information as such.




Looking at the __age emperors had at the time they took power__. As for the origin, we'll have to categorize first.

```r
emperors$age_accession2 <- ifelse(emperors$age_accession>60, "61+", ifelse(emperors$age_accession>40, "41-60", ifelse(emperors$age_accession>30, "31-40", ifelse(emperors$age_accession<30, "30-", "Unknown"))))
```


```r
age_access <- survfit(Surv(length_reign, event) ~age_accession2, data=emperors)
summary(age_access)
```

```
## Call: survfit(formula = Surv(length_reign, event) ~ age_accession2, 
##     data = emperors)
## 
## 4 observations deleted due to missingness 
##                 age_accession2=30- 
##   time n.risk n.event survival std.err lower 95% CI upper 95% CI
##   2.61     16       1    0.938  0.0605       0.8261        1.000
##   2.98     15       1    0.875  0.0827       0.7271        1.000
##   3.76     13       1    0.808  0.1000       0.6336        1.000
##   3.85     12       1    0.740  0.1121       0.5503        0.996
##   6.00     10       1    0.666  0.1229       0.4642        0.957
##  12.73      9       1    0.592  0.1297       0.3857        0.910
##  13.01      8       1    0.518  0.1329       0.3135        0.857
##  15.01      6       1    0.432  0.1360       0.2330        0.800
##  16.00      5       1    0.346  0.1334       0.1621        0.736
##  16.06      4       1    0.259  0.1249       0.1007        0.667
##  19.27      2       1    0.130  0.1109       0.0242        0.693
## 
##                 age_accession2=31-40 
##  time n.risk n.event survival std.err lower 95% CI upper 95% CI
##  14.9      7       1    0.857   0.132        0.633            1
##  39.7      1       1    0.000     NaN           NA           NA
## 
##                 age_accession2=41-60 
##     time n.risk n.event survival std.err lower 95% CI upper 95% CI
##   0.0575     23       1    0.957  0.0425       0.8767        1.000
##   0.1671     22       1    0.913  0.0588       0.8049        1.000
##   0.6767     21       1    0.870  0.0702       0.7423        1.000
##   1.1589     19       1    0.824  0.0801       0.6809        0.997
##   2.1671     15       1    0.769  0.0916       0.6087        0.971
##   2.2521     14       1    0.714  0.1002       0.5422        0.940
##   5.0000     13       1    0.659  0.1065       0.4801        0.905
##   5.6274     12       1    0.604  0.1109       0.4216        0.866
##   6.0438     10       1    0.544  0.1151       0.3591        0.823
##  13.7151      7       1    0.466  0.1221       0.2789        0.779
##  22.4904      2       1    0.233  0.1757       0.0532        1.000
## 
##                 age_accession2=61+ 
##   time n.risk n.event survival std.err lower 95% CI upper 95% CI
##  0.236      9       1    0.889   0.105       0.7056        1.000
##  0.260      8       1    0.778   0.139       0.5485        1.000
##  0.268      7       2    0.556   0.166       0.3097        0.997
##  0.605      5       1    0.444   0.166       0.2141        0.923
##  3.238      2       1    0.222   0.178       0.0464        1.000
```

```r
ggsurvplot(age_access, pval = TRUE, pval.coord = c(30,0.6), main = "Emperors' survival by age at beginning of reign in log-log", legend.labs = c("30 & less", "31-40", "41-60", "61 and above"), fun="cloglog")
```

![](Roman_Emperors_files/figure-html/unnamed-chunk-20-1.png)<!-- -->

Here the p-value is much lower even, and the lines barely cross which implies that we're closer to a model we could use.

## Cox regression Model

```r
library(networkD3)
```
_**Distribution of emperors by Dynasty**_

```r
simpleNetwork(select(emperors, Name, Dynasty), fontSize = 18, nodeColour = "red")
```

<!--html_preserve--><div id="htmlwidget-d3f4d30945358f68865b" style="width:672px;height:480px;" class="simpleNetwork html-widget"></div>
<script type="application/json" data-for="htmlwidget-d3f4d30945358f68865b">{"x":{"links":{"source":["Augustus","Tiberius","Caligula","Claudius","Nero","Galba","Otho","Vitellius","Vespasian","Titus","Domitian","Nerva","Trajan","Hadrian","Antonius Pius","Marcus Aurelius","Lucius Verus","Commodus","Pertinax","Didius Julianus","Septimus Severus","Caracalla","Geta","Macrinus","Elagabalus","Severus Alexander","Maximinus I","Gordian I","Gordian II","Pupienus","Balbinus","Gordian III","Philip I","Trajan Decius","Hostilian","Trebonianus Gallus","Aemilian","Valerian","Gallienus","Claudius Gothicus","Aurelian","Tacitus","Florian","Probus","Carus","Carinus","Diocletian","Maximian","Constantius I","Galerius","Severus II","Constantine the Great","Maxentius","Maximinus II","Lucinius I","Constantine II","Consantius II","Constans","Vetranio","Julian","Jovian","Valentinian I","Valens","Gratian","Valentinian II","Theodosius I"],"target":["Julio-Claudian","Julio-Claudian","Julio-Claudian","Julio-Claudian","Julio-Claudian","Flavian","Flavian","Flavian","Flavian","Flavian","Flavian","Nerva-Antonine","Nerva-Antonine","Nerva-Antonine","Nerva-Antonine","Nerva-Antonine","Nerva-Antonine","Nerva-Antonine","Severan","Severan","Severan","Severan","Severan","Severan","Severan","Severan","Gordian","Gordian","Gordian","Gordian","Gordian","Gordian","Gordian","Gordian","Gordian","Gordian","Gordian","Gordian","Gordian","Gordian","Gordian","Gordian","Gordian","Gordian","Gordian","Gordian","Constantinian","Constantinian","Constantinian","Constantinian","Constantinian","Constantinian","Constantinian","Constantinian","Constantinian","Constantinian","Constantinian","Constantinian","Constantinian","Constantinian","Constantinian","Valentinian","Valentinian","Valentinian","Valentinian","Theodosian"]},"options":{"linkDistance":50,"charge":-200,"fontSize":18,"fontFamily":"serif","linkColour":"#666","nodeColour":"red","nodeClickColour":"#E34A33","textColour":"#3182bd","opacity":0.6,"zoom":false}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

To find out the difference of survival chance between dynasties, we can use the Cox model.
This will compare all dynasties with the first one. By default, the first one in alphabetical order will be used for comparison. Here, we'll change the order, so that the Flavian dynasty comes first, as it is the only one that had a 50-50 survival rate.

```r
emperors$Dynasty = factor(emperors$Dynasty,levels(emperors$Dynasty)[c(2,1,3:8)])
summary(coxph(formula = Surv(length_reign, event) ~ Dynasty, data = emperors))
```

```
## Warning in fitter(X, Y, strats, offset, init, control, weights = weights, :
## Loglik converged before variable 6 ; beta may be infinite.
```

```
## Call:
## coxph(formula = Surv(length_reign, event) ~ Dynasty, data = emperors)
## 
##   n= 66, number of events= 32 
## 
##                             coef  exp(coef)   se(coef)      z Pr(>|z|)  
## DynastyConstantinian  -1.160e+00  3.134e-01  7.480e-01 -1.551   0.1208  
## DynastyGordian         3.898e-01  1.477e+00  6.577e-01  0.593   0.5534  
## DynastyJulio-Claudian -1.053e+00  3.490e-01  8.502e-01 -1.238   0.2157  
## DynastyNerva-Antonine -2.476e+00  8.410e-02  1.171e+00 -2.114   0.0345 *
## DynastySeveran         7.820e-02  1.081e+00  7.020e-01  0.111   0.9113  
## DynastyTheodosian     -1.808e+01  1.404e-08  6.563e+03 -0.003   0.9978  
## DynastyValentinian    -1.743e+00  1.750e-01  1.163e+00 -1.498   0.1340  
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
##                       exp(coef) exp(-coef) lower .95 upper .95
## DynastyConstantinian  3.134e-01  3.191e+00  0.072341    1.3575
## DynastyGordian        1.477e+00  6.772e-01  0.406893    5.3593
## DynastyJulio-Claudian 3.490e-01  2.865e+00  0.065944    1.8474
## DynastyNerva-Antonine 8.410e-02  1.189e+01  0.008469    0.8352
## DynastySeveran        1.081e+00  9.248e-01  0.273187    4.2802
## DynastyTheodosian     1.404e-08  7.125e+07  0.000000       Inf
## DynastyValentinian    1.750e-01  5.714e+00  0.017907    1.7106
## 
## Concordance= 0.735  (se = 0.058 )
## Rsquare= 0.285   (max possible= 0.963 )
## Likelihood ratio test= 22.16  on 7 df,   p=0.002382
## Wald test            = 16.02  on 7 df,   p=0.02493
## Score (logrank) test = 21.88  on 7 df,   p=0.002667
```
This shows us first that the influence of dynasty on survival chances is significant (p-value 0.02493), and that compared to the Flavian dynasty, emperors in the Constantinian dynasty had 0.31 times more chance to survive (+/- 3.19).
Still compared to the Flavian, Nerva-Antonine had a very small chance to be killed at 0.0841 (+/- 1.189).



## Multiple Covariates
Now, let's look at the three variables of *Succession*, *Era* and *Age at accession* (with redefined categories as seen above), and try to identify the best explicative model for emperors' survival.

To study the covariates, we need to use the Cox proportional hazards regression model.
The model, and the stepwise algorithm, only works with non-missing values, so I'll make a selection of the variables to consider, and remove the rows with missing values.

```r
selection <- emperors %>% select(c(length_reign, event, Succession2, Era, age_accession2))
selection <- filter(selection, complete.cases(selection))

all_variables <- coxph(Surv(length_reign, event) ~ . , data = selection)

AIC <- step(all_variables, direction="forward")
```

```
## Start:  AIC=189.92
## Surv(length_reign, event) ~ Succession2 + Era + age_accession2
```

```r
summary(AIC)
```

```
## Call:
## coxph(formula = Surv(length_reign, event) ~ Succession2 + Era + 
##     age_accession2, data = selection)
## 
##   n= 62, number of events= 30 
## 
##                                     coef exp(coef) se(coef)      z
## Succession2Appointment by state -0.68949   0.50183  0.75586 -0.912
## Succession2Birthright           -1.52425   0.21778  0.69249 -2.201
## Succession2Other                 0.11694   1.12405  1.14540  0.102
## Succession2Seized Power         -0.89749   0.40759  0.66528 -1.349
## EraPrincipate                    0.74244   2.10106  0.55408  1.340
## age_accession231-40             -2.42661   0.08834  1.06704 -2.274
## age_accession241-60             -0.81803   0.44130  0.55508 -1.474
## age_accession261+                0.41303   1.51140  0.74137  0.557
##                                 Pr(>|z|)  
## Succession2Appointment by state   0.3617  
## Succession2Birthright             0.0277 *
## Succession2Other                  0.9187  
## Succession2Seized Power           0.1773  
## EraPrincipate                     0.1803  
## age_accession231-40               0.0230 *
## age_accession241-60               0.1406  
## age_accession261+                 0.5774  
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
##                                 exp(coef) exp(-coef) lower .95 upper .95
## Succession2Appointment by state   0.50183     1.9927   0.11407    2.2077
## Succession2Birthright             0.21778     4.5917   0.05605    0.8462
## Succession2Other                  1.12405     0.8896   0.11907   10.6109
## Succession2Seized Power           0.40759     2.4534   0.11065    1.5015
## EraPrincipate                     2.10106     0.4759   0.70926    6.2240
## age_accession231-40               0.08834    11.3205   0.01091    0.7152
## age_accession241-60               0.44130     2.2660   0.14868    1.3098
## age_accession261+                 1.51140     0.6616   0.35344    6.4631
## 
## Concordance= 0.773  (se = 0.06 )
## Rsquare= 0.343   (max possible= 0.96 )
## Likelihood ratio test= 26.06  on 8 df,   p=0.001027
## Wald test            = 20.22  on 8 df,   p=0.009529
## Score (logrank) test = 28.69  on 8 df,   p=0.0003588
```

```r
ggsurvplot(survfit(AIC), main="Survival function (prediction)", color="blue")
```

![](Roman_Emperors_files/figure-html/unnamed-chunk-24-1.png)<!-- -->

The result of the Cox model and step algorithm (which went through 16 iterations starting with no variable, then adding them one by one) is a predictor based on 8 variables, with low p-values on all tests, indicating that we can safely discard the null hypothesis (that the 8 variables chosen by the stepwise algorithm do not significantly impact chances of survival).

















This gives enough confidence to chose the model for the last step of this paper:
# Prediction
To make a prediction, we need to split the data in 2 parts, one to train the model, the other to test it.

```r
## 75% of the sample size
smp_size <- floor(0.7 * nrow(emperors))

## set the seed to make your partition reproductible
set.seed(24)
train_ind <- sample(seq_len(nrow(emperors)), size = smp_size)

train <- emperors[train_ind, ]
test <- emperors[-train_ind, ]
```
Here I've decided to train the model on 80% of the data (46 emperors), and make the prediction on the 20 left.


Let's only keep the useful variables in the two data.frames, and remove the rows with NA values in train.

```r
test <- test %>% select(Name, Succession2, Era, age_accession2, length_reign, event)
train <- train %>% select(Succession2, Era, age_accession2, length_reign, event)
train <- filter(train, complete.cases(train))

model <- coxph(Surv(length_reign, event) ~ . , data = train)

models <- step(model, direction="forward")
```

```
## Start:  AIC=130.45
## Surv(length_reign, event) ~ Succession2 + Era + age_accession2
```

Now that the model is train, we just need to use it to generate the predictions, and compare the predicted value with the true vale in the "event" column.

```r
test$predicted_value <- ifelse(predict(models, newdata=test, type = "expected") > 0.5, 1,0)
library(ROCR)
```

```
## Loading required package: gplots
```

```
## 
## Attaching package: 'gplots'
```

```
## The following object is masked from 'package:stats':
## 
##     lowess
```

```r
results <- ROCR::prediction(test$event, test$predicted_value)
plot(unlist(results@tp), unlist(results@fp), type="l")
```

![](Roman_Emperors_files/figure-html/unnamed-chunk-27-1.png)<!-- -->

```r
plot(performance(results, measure = "tpr", x.measure = "fpr"))
```

![](Roman_Emperors_files/figure-html/unnamed-chunk-27-2.png)<!-- -->

