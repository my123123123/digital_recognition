module top_digital_recognition(
    input                 sys_clk     ,  
    input                 sys_rst_n   ,  
    
    input                 cam_pclk    ,  
    input                 cam_vsync   ,  
    input                 cam_href    ,  
    input        [7:0]    cam_data    ,  
    output                cam_rst_n   ,  
    output                cam_pwdn    ,  
    output                cam_scl     ,  
    inout                 cam_sda     ,  
    
    output                sdram_clk   ,  
    output                sdram_cke   ,  
    output                sdram_cs_n  ,  
    output                sdram_ras_n ,  
    output                sdram_cas_n ,  
    output                sdram_we_n  ,  
    output       [1:0]    sdram_ba    ,  
    output       [1:0]    sdram_dqm   ,  
    output       [12:0]   sdram_addr  ,  
    inout        [15:0]   sdram_data  ,  
    
    output                lcd_hs      ,  
    output                lcd_vs      ,  
    output                lcd_de      ,  
    output       [15:0]   lcd_rgb     ,  
    output                lcd_bl      ,  
    output                lcd_rst     ,  
    output                lcd_pclk    ,  
    
    output       [5:0]    sel         ,  
    output       [7:0]    seg_led        
    );


parameter  SLAVE_ADDR = 7'h3c         ;  
parameter  BIT_CTRL   = 1'b1          ;  
parameter  CLK_FREQ   = 27'd100_000_000; 
parameter  I2C_FREQ   = 18'd250_000   ;  
parameter  NUM_ROW    = 1'd1          ;  
parameter  NUM_COL    = 3'd4          ;  
parameter  H_PIXEL    = 480           ;  
parameter  V_PIXEL    = 272           ;  
parameter  DEPBIT     = 4'd10         ;  

localparam  ID_4342 =   0;               
localparam  ID_7084 =   1;               
localparam  ID_7016 =   2;               
localparam  ID_1018 =   5;               
parameter   ID_LCD = ID_4342;            

wire                  clk_100m        ;  
wire                  clk_100m_shift  ;  
wire                  clk_100m_lcd    ;  
wire                  clk_lcd         ;  
wire                  locked          ;
wire                  rst_n           ;

wire                  i2c_exec        ;  
wire   [23:0]         i2c_data        ;  
wire                  cam_init_done   ;  
wire                  i2c_done        ;  
wire                  i2c_dri_clk     ;  
wire   [ 7:0]         i2c_data_r      ;  
wire                  i2c_rh_wl       ;  

wire                  wr_en           ;  
wire   [15:0]         wr_data         ;  
wire                  rd_en           ;  
wire   [15:0]         rd_data         ;  
wire                  sdram_init_done ;  
wire                  sys_init_done   ;  

wire   [15:0]         ID_lcd          ;  
wire   [12:0]         cmos_h_pixel    ;  
wire   [12:0]         cmos_v_pixel    ;  
wire   [12:0]         total_h_pixel   ;  
wire   [12:0]         total_v_pixel   ;  
wire   [23:0]         sdram_max_addr  ;  
wire                  clk_lcd_g       ;
wire   [23:0]         digit           ;  
wire   [15:0]         color_rgb       ;
wire   [10:0]         xpos            ;  
wire   [10:0]         ypos            ;  
wire                  hs_t            ;
wire                  vs_t            ;
wire                  de_t            ;

assign  rst_n = sys_rst_n & locked;

assign  sys_init_done = sdram_init_done & cam_init_done;
assign  cam_rst_n = 1'b1;

assign  cam_pwdn = 1'b0;



pll u_pll(
    .areset       (~sys_rst_n),
    .inclk0       (sys_clk),
    .c0           (clk_100m),
    .c1           (clk_100m_shift),
    .c2           (clk_100m_lcd),
    .locked       (locked)
);

i2c_ov5640_rgb565_cfg u_i2c_cfg(
    .clk                  (i2c_dri_clk),
    .rst_n                (rst_n),
    .i2c_done             (i2c_done),
    .i2c_exec             (i2c_exec),
    .i2c_data             (i2c_data),
    .i2c_rh_wl            (i2c_rh_wl),             
    .i2c_data_r           (i2c_data_r),
    .init_done            (cam_init_done),
    .cmos_h_pixel         (cmos_h_pixel),          
    .cmos_v_pixel         (cmos_v_pixel) ,         
    .total_h_pixel        (total_h_pixel),         
    .total_v_pixel        (total_v_pixel)          
);

i2c_dri
   #(
    .SLAVE_ADDR           (SLAVE_ADDR),            
    .CLK_FREQ             (CLK_FREQ  ),
    .I2C_FREQ             (I2C_FREQ  )
    )
   u_i2c_dri(
    .clk                  (clk_100m_lcd),
    .rst_n                (rst_n     ),
  
    .i2c_exec             (i2c_exec  ),
    .bit_ctrl             (BIT_CTRL  ),
    .i2c_rh_wl            (i2c_rh_wl ),            
    .i2c_addr             (i2c_data[23:8]),
    .i2c_data_w           (i2c_data[7:0]),
    .i2c_data_r           (i2c_data_r),
    .i2c_done             (i2c_done  ),
    .scl                  (cam_scl   ),
    .sda                  (cam_sda   ),
   
    .dri_clk              (i2c_dri_clk)            
);


cmos_capture_data u_cmos_capture_data(
    .rst_n                (rst_n & sys_init_done),  
    .cam_pclk             (cam_pclk),
    .cam_vsync            (cam_vsync),
    .cam_href             (cam_href),
    .cam_data             (cam_data),
    .cmos_frame_vsync     (),
    .cmos_frame_href      (),
    .cmos_frame_clken     (wr_en),                  
    .cmos_frame_data      (wr_data)                 
);

picture_size u_picture_size (
    .rst_n                (rst_n         ),

    .ID_lcd               (ID_LCD        ),  

    .cmos_h_pixel         (cmos_h_pixel  ),  
    .cmos_v_pixel         (cmos_v_pixel  ),  
    .total_h_pixel        (total_h_pixel ),  
    .total_v_pixel        (total_v_pixel ),  
    .sdram_max_addr       (sdram_max_addr)   
);

sdram_top u_sdram_top(
    .ref_clk      (clk_100m),                 
    .out_clk      (clk_100m_shift),           
    .rst_n        (rst_n),                    

    
    .wr_clk       (cam_pclk),                 
    .wr_en        (wr_en),                    
    .wr_data      (wr_data),                  
    .wr_min_addr  (24'd0),                    
    .wr_max_addr  (sdram_max_addr),           
    .wr_len       (10'd512),                  
    .wr_load      (~rst_n),                   

  
    .rd_clk       (clk_lcd),                  
    .rd_en        (rd_en),                    
    .rd_data      (rd_data),                  
    .rd_min_addr  (24'd0),                    
    .rd_max_addr  (sdram_max_addr),           
    .rd_len       (10'd512),                  
    .rd_load      (~rst_n),                   

   
    .sdram_read_valid  (1'b1),                
    .sdram_pingpang_en (1'b1),                
    .sdram_init_done (sdram_init_done),       

   
    .sdram_clk    (sdram_clk),                
    .sdram_cke    (sdram_cke),                
    .sdram_cs_n   (sdram_cs_n),               
    .sdram_ras_n  (sdram_ras_n),              
    .sdram_cas_n  (sdram_cas_n),              
    .sdram_we_n   (sdram_we_n),               
    .sdram_ba     (sdram_ba),                 
    .sdram_addr   (sdram_addr),               
    .sdram_data   (sdram_data),               
    .sdram_dqm    (sdram_dqm)                 
);

lcd u_lcd(
    .clk        (clk_100m_lcd),
    .rst_n      (rst_n),

    .lcd_hs     (hs_t ),
    .lcd_vs     (vs_t ),
    .lcd_de     (de_t ),
    .lcd_rgb    (color_rgb),
    .lcd_bl     (lcd_bl),
    .lcd_rst    (lcd_rst),
    .lcd_pclk   (lcd_pclk),

    .clk_lcd    (clk_lcd),

    .pixel_data (rd_data),
    .rd_en      (rd_en  ),

    .ID_lcd     (ID_LCD),
    
    .pixel_xpos (xpos  ),
    .pixel_ypos (ypos  )
);

altclkctrl clk_ctrl(
    .inclk(clk_lcd),
    .outclk(clk_lcd_g)
);


vip #(
    .NUM_ROW(NUM_ROW),
    .NUM_COL(NUM_COL),
    .H_PIXEL(H_PIXEL),
    .V_PIXEL(V_PIXEL)
)u_vip(
    .clk              (clk_lcd_g), 
    .rst_n            (rst_n    ), 
          
    .pre_frame_vsync  (vs_t   ),   
    .pre_frame_hsync  (hs_t   ),   
    .pre_frame_de     (de_t   ),   
    .pre_rgb          (color_rgb), 
    .xpos             (xpos   ),   
    .ypos             (ypos   ),   
          
    .post_frame_vsync (lcd_vs ),  
    .post_frame_hsync (lcd_hs ),  
    .post_frame_de    (lcd_de ),  
    .post_rgb         (lcd_rgb),  
                  
    .digit            (digit  )   
);

seg_bcd_dri u_seg_bcd_dri(
   
   .clk          (clk_lcd),
   .rst_n        (rst_n  ),
   .num          (digit  ),
   .point        (6'b0   ),
   
   .sel          (sel    ),
   .seg_led      (seg_led) 
);

endmodule