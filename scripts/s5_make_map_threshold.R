#################### SKIP IF OUTPUTS EXISTS ALREADY
if(!file.exists(paste0(gfc_dir,"gfc_",countrycode,"_",threshold,"_map_clip_pct.tif"))){
  
  system(sprintf("rm -f %s",
                 paste0(tmp_dir,"tmp_gfc_map_",countrycode,".tif")))
  #################### COMBINATION INTO NATIONAL SCALE MAP
  system(sprintf("gdal_calc.py -A %s -B %s -C %s -D %s --co COMPRESS=LZW --outfile=%s --calc=\"%s\"",
                 paste0(gfc_dir,"gfc_",countrycode,"_",types[1],".tif"),
                 paste0(gfc_dir,"gfc_",countrycode,"_",types[2],".tif"),
                 paste0(gfc_dir,"gfc_",countrycode,"_",types[3],".tif"),
                 paste0(gfc_dir,"gfc_",countrycode,"_",types[4],".tif"),
                 paste0(tmp_dir,"tmp_gfc_map_",countrycode,".tif"),
                 
                 paste0("(A<=",threshold,")*((C==1)*50 + (C==0)*30)+", ### NON FOREST
                        "(A>", threshold,")*",
                        "((C==1)*(",
                        "(B>0)*  51 +",           ### GAIN+LOSS
                        "(B==0)* 50 )+",          ### GAIN
                        "(C==0)*(",
                        "(B>0)*B+",               ### LOSS
                        "(B==0)* 40 ))"           ### FOREST STABLE
                 )
  ))
  
  #############################################################
  ### CROP TO COUNTRY BOUNDARIES
  system(sprintf("python %s/oft-cutline_crop.py -v %s -i %s -o %s -a %s",
                 scriptdir,
                 aoi_shp,
                 paste0(tmp_dir,"tmp_gfc_map_",countrycode,".tif"),
                 paste0(tmp_dir,"tmp_gfc_map_clip_",countrycode,".tif"),
                 aoi_field
  ))
  
  ###############################################################################
  ################### REPROJECT IN EA PROJECTION
  ###############################################################################
  system(sprintf("gdalwarp -t_srs \"%s\" -overwrite -ot Byte -multi -co COMPRESS=LZW %s %s",
                 proj,
                 paste0(tmp_dir,"tmp_gfc_map_clip_",countrycode,".tif"),
                 paste0(tmp_dir,"tmp_gfc_map_clip_prj_",countrycode,".tif")
  ))
  
  
  ################################################################################
  #################### Add pseudo color table to result
  ################################################################################
  system(sprintf("(echo %s) | oft-addpct.py %s %s",
                 paste0(gfc_dir,"color_table.txt"),
                 paste0(tmp_dir,"tmp_gfc_map_clip_prj_",countrycode,".tif"),
                 paste0(tmp_dir,"tmp_gfc_map_clip_prj_pct",countrycode,".tif")
  ))
  
  ################################################################################
  #################### COMPRESS
  ################################################################################
  system(sprintf("gdal_translate -ot Byte -co COMPRESS=LZW %s %s",
                 paste0(tmp_dir,"tmp_gfc_map_clip_prj_pct",countrycode,".tif"),
                 paste0(gfc_dir,"gfc_",countrycode,"_",threshold,"_map_clip_pct.tif")
  ))
  
  #############################################################
  ### CREATE A FOREST MASK FOR MSPA ANALYSIS
  system(sprintf("gdal_calc.py -A %s --co COMPRESS=LZW --outfile=%s --calc=\"%s\"",
                 paste0(gfc_dir,"gfc_",countrycode,"_",threshold,"_map_clip_pct.tif"),
                 paste0(gfc_dir,"mask_mspa_gfc_",countrycode,"_",threshold,".tif"),
                 paste0("(A==40)*2+((A>0)*(A<40)+(A>40))*1")
  ))
  
  #############################################################
  ### CROP TO haute_guinee BOUNDARIES
  system(sprintf("python %s/oft-cutline_crop.py -v %s -i %s -o %s -a %s",
                 scriptdir,
                 paste0(gadm_dir,"haute_guinee.shp"),
                 paste0(tmp_dir,"tmp_gfc_map_",countrycode,".tif"),
                 paste0(tmp_dir,"tmp_gfc_map_clip_haute_guinee.tif"),
                 aoi_field
  ))
  
  ###############################################################################
  ################### REPROJECT IN EA PROJECTION
  ###############################################################################
  system(sprintf("gdalwarp -t_srs \"%s\" -overwrite -ot Byte -multi -co COMPRESS=LZW %s %s",
                 proj,
                 paste0(tmp_dir,"tmp_gfc_map_clip_haute_guinee.tif"),
                 paste0(tmp_dir,"tmp_gfc_map_clip_haute_guinee_proj.tif")
  ))
  
  
  ################################################################################
  #################### Add pseudo color table to result
  ################################################################################
  system(sprintf("(echo %s) | oft-addpct.py %s %s",
                 paste0(gfc_dir,"color_table.txt"),
                 paste0(tmp_dir,"tmp_gfc_map_clip_haute_guinee_proj.tif"),
                 paste0(tmp_dir,"tmp_gfc_map_clip_haute_guinee_proj_pct.tif")
  ))
  
  ################################################################################
  #################### COMPRESS
  ################################################################################
  system(sprintf("gdal_translate -ot Byte -co COMPRESS=LZW %s %s",
                 
                 paste0(tmp_dir,"tmp_gfc_map_clip_haute_guinee_proj_pct.tif"),
                 paste0(gfc_dir,"gfc_haute_guinee_",threshold,"_map_clip_pct.tif")
  ))
  
  #############################################################
  ### CREATE A FOREST MASK FOR MSPA ANALYSIS
  system(sprintf("gdal_calc.py -A %s --co COMPRESS=LZW --outfile=%s --calc=\"%s\"",
                 
                 paste0(gfc_dir,"gfc_haute_guinee_",threshold,"_map_clip_pct.tif"),
                 paste0(gfc_dir,"mask_mspa_gfc_haute_guinee_",threshold,".tif"),
                 paste0("(A==40)*2+((A>0)*(A<40)+(A>40))*1")
  ))
}
