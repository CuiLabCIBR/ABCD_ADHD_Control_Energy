library(dplyr)
library(networkD3)
library(htmlwidgets)
library(webshot2)

plot_sankey_networkD3 <- function(dat,
                                  left_var,
                                  right_var,
                                  left_levels,
                                  right_levels,
                                  left_name_map,
                                  right_name_map,
                                  left_color_key_map,
                                  right_color_key_map,
                                  color_map,
                                  html_file,
                                  png_file=NULL,
                                  pdf_file=NULL,
                                  link_alpha=0.30,
                                  node_alpha=0.95,
                                  show_text=TRUE,
                                  font_size=22,
                                  node_width=22,
                                  node_padding=28,
                                  width=900,
                                  height=500,
                                  zoom=2){
  
  flow <- dat %>%
    filter(
      !is.na(.data[[left_var]]),
      !is.na(.data[[right_var]])
    ) %>%
    transmute(
      left=.data[[left_var]],
      right=.data[[right_var]]
    ) %>%
    filter(
      left %in% left_levels,
      right %in% right_levels
    ) %>%
    count(left,right,name="value") %>%
    mutate(
      left_key=left_color_key_map[left],
      right_key=right_color_key_map[right]
    )
  
  left_nodes <- flow %>%
    group_by(left,left_key) %>%
    summarise(n=sum(value),.groups="drop") %>%
    mutate(left=factor(left,levels=left_levels)) %>%
    arrange(left) %>%
    mutate(
      node_name=paste0(left_name_map[as.character(left)]," (n = ",n,")"),
      group=left_key,
      raw=as.character(left)
    )
  
  right_nodes <- flow %>%
    group_by(right,right_key) %>%
    summarise(n=sum(value),.groups="drop") %>%
    mutate(right=factor(right,levels=right_levels)) %>%
    arrange(right) %>%
    mutate(
      node_name=paste0(right_name_map[as.character(right)]," (n = ",n,")"),
      group=right_key,
      raw=as.character(right)
    )
  
  nodes <- bind_rows(
    left_nodes %>% transmute(name=node_name,group=group,raw=raw),
    right_nodes %>% transmute(name=node_name,group=group,raw=raw)
  )
  
  node_lookup <- data.frame(
    raw_name=c(left_nodes$raw,right_nodes$raw),
    node_id=0:(nrow(nodes)-1),
    stringsAsFactors=FALSE
  )
  
  links <- flow %>%
    left_join(
      node_lookup %>% rename(left=raw_name,source=node_id),
      by="left"
    ) %>%
    left_join(
      node_lookup %>% rename(right=raw_name,target=node_id),
      by="right"
    ) %>%
    mutate(link_group=right_key) %>%
    select(source,target,value,link_group)
  
  colourScale <- paste0(
    'd3.scaleOrdinal()',
    '.domain(["',paste(names(color_map),collapse='","'),'"])',
    '.range(["',paste(unname(color_map),collapse='","'),'"])'
  )
  
  p <- sankeyNetwork(
    Links=links,
    Nodes=nodes,
    Source="source",
    Target="target",
    Value="value",
    NodeID="name",
    NodeGroup="group",
    LinkGroup="link_group",
    colourScale=JS(colourScale),
    fontSize=font_size,
    nodeWidth=node_width,
    nodePadding=node_padding,
    sinksRight=TRUE,
    iterations=0,
    width=width,
    height=height
  )
  
  text_display <- ifelse(show_text,"block","none")
  
  p <- htmlwidgets::onRender(
    p,
    sprintf(
      '
      function(el,x){
        var svg=d3.select(el).select("svg");

        svg
          .style("background","white")
          .style("font-family","Arial, Helvetica, sans-serif");

        svg.selectAll(".link")
          .style("stroke-opacity",%f)
          .style("fill","none")
          .style("mix-blend-mode","multiply");

        svg.selectAll(".node rect")
          .style("fill-opacity",%f)
          .style("stroke","none")
          .style("stroke-width",0);

        svg.selectAll(".node text")
          .style("display","%s")
          .style("font-family","Arial, Helvetica, sans-serif")
          .style("font-size","22px")
          .style("font-weight","400")
          .style("fill","#111111");

        svg.selectAll("title").remove();
      }
      ',
      link_alpha,node_alpha,text_display
    )
  )
  
  saveWidget(p,html_file,selfcontained=TRUE)
  
  if(!is.null(png_file)){
    webshot2::webshot(
      url=html_file,
      file=png_file,
      vwidth=width,
      vheight=height,
      zoom=zoom
    )
  }
  
  if(!is.null(pdf_file)){
    webshot2::webshot(
      url=html_file,
      file=pdf_file,
      vwidth=width,
      vheight=height,
      zoom=zoom
    )
  }
  
  return(p)
}