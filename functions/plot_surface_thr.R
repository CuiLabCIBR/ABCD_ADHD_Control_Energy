plot_surface_thr <- function(data, outpath, thr, atlas, cmap) {
  
  if (missing(cmap)) {
    cmap <- rev(c("#A63726", "#D6604D", "#F4A582", "#FDDBC7", "#F7F7F7", "#D1E5F0", "#92C5DE", "#4393C3", "#2C678C"))
  }
  # cmap <- rev(c("#D6604D" , "#F4A582" , "#FDDBC7", "#F7F7F7", "#D1E5F0", "#92C5DE", "#4393C3"))
 
  p <- ggplot()+
    geom_brain(data = brain_plot_data, atlas = atlas, 
               mapping = aes(fill = deviation, colour = deviation), show.legend = FALSE, position = position_brain(hemi~side)) +
    scale_fill_gradientn(colours = cmap, limits = c(-thr, thr), oob = squish, values = scales::rescale(c(-thr, 0, thr))) + 
    scale_color_gradientn(colours = cmap, limits = c(-thr, thr), oob = squish, values = scales::rescale(c(-thr, 0, thr))) + 
    theme_void() + guides(color = "none")
  
  ggsave(paste0(outpath, '_all.png'), bg = 'transparent', plot = p, width = 13, height = 11, units = "cm", dpi = 1200)
  
  p <- ggplot()+
    geom_brain(data = brain_plot_data, atlas = atlas, 
               mapping = aes(fill = deviation, colour = deviation), show.legend = FALSE, hemi = 'left', side = 'lateral') +
    scale_fill_gradientn(colours = cmap, limits = c(-thr, thr), oob = squish, values = scales::rescale(c(-thr, 0, thr))) + 
    scale_color_gradientn(colours = cmap, limits = c(-thr, thr), oob = squish, values = scales::rescale(c(-thr, 0, thr))) + 
    theme_void() + guides(color = "none")
  
  ggsave(paste0(outpath, '_ll.png'), bg = 'transparent', plot = p, width = 4, height = 4, units = "cm", dpi = 1200)
  
  p <- ggplot()+
    geom_brain(data = brain_plot_data, atlas = atlas, 
               mapping = aes(fill = deviation, colour = deviation), show.legend = FALSE, hemi = 'left', side = 'medial') +
    scale_fill_gradientn(colours = cmap, limits = c(-thr, thr), oob = squish, values = scales::rescale(c(-thr, 0, thr))) +
    scale_color_gradientn(colours = cmap, limits = c(-thr, thr), oob = squish, values = scales::rescale(c(-thr, 0, thr))) +
    theme_void() + guides(color = "none")
  
  ggsave(paste0(outpath, '_lm.png'), bg = 'transparent', plot = p, width = 4, height = 4, units = "cm", dpi = 1200)
  
  p <- ggplot()+
    geom_brain(data = brain_plot_data, atlas = atlas, 
               mapping = aes(fill = deviation, colour = deviation), show.legend = FALSE, hemi = 'right', side = 'lateral') +
    scale_fill_gradientn(colours = cmap, limits = c(-thr, thr), oob = squish, values = scales::rescale(c(-thr, 0, thr))) +
    scale_color_gradientn(colours = cmap, limits = c(-thr, thr), oob = squish, values = scales::rescale(c(-thr, 0, thr))) +
    theme_void() + guides(color = "none")
  
  ggsave(paste0(outpath, '_rl.png'), bg = 'transparent', plot = p, width = 4, height = 4, units = "cm", dpi = 1200)
  
  p <- ggplot()+
    geom_brain(data = brain_plot_data, atlas = atlas, 
               mapping = aes(fill = deviation, colour = deviation), show.legend = FALSE, hemi = 'right', side = 'medial') +
    scale_fill_gradientn(colours = cmap, limits = c(-thr, thr), oob = squish, values = scales::rescale(c(-thr, 0, thr))) +
    scale_color_gradientn(colours = cmap, limits = c(-thr, thr), oob = squish, values = scales::rescale(c(-thr, 0, thr))) +
    theme_void() + guides(color = "none")
  
  ggsave(paste0(outpath, '_rm.png'), bg = 'transparent', plot = p, width = 4, height = 4, units = "cm", dpi = 1200)
  
  
}