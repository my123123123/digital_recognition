module lcd(
    input              clk     ,
    input              rst_n   ,
 
    output             lcd_hs  ,       
    output             lcd_vs  ,       
    output             lcd_de  ,       
    inout      [15:0]  lcd_rgb ,       
    output             lcd_bl  ,       
    output             lcd_rst ,       
    output             lcd_pclk,       
       
    output             clk_lcd,
    input      [15:0]  pixel_data,     
    
    output             rd_en  ,        

    input     [15:0]   ID_lcd ,        
    
  
    output     [10:0]  pixel_xpos,
    output     [10:0]  pixel_ypos
);
               
assign lcd_rgb = lcd_de ? pixel_data : 16'dz;

clk_div  u_clk_div(
    .clk          (clk),
    .rst_n        (rst_n),
    .ID_lcd       (ID_lcd),
    .clk_lcd      (clk_lcd)
);
    
lcd_driver u_lcd_driver(                      
    .lcd_clk        (clk_lcd),    
    .sys_rst_n      (rst_n),    

    .lcd_hs         (lcd_hs),       
    .lcd_vs         (lcd_vs),       
    .lcd_de         (lcd_de),       
    .lcd_bl         (lcd_bl),
    .lcd_rst        (lcd_rst),
    .lcd_pclk       (lcd_pclk),
    
    .data_req       (rd_en),                
    .pixel_xpos     (pixel_xpos), 
    .pixel_ypos     (pixel_ypos),
    .ID_lcd         (ID_lcd)
    ); 

endmodule
