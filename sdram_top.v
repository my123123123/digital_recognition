module  sdram_top(
    input         ref_clk,                  
    input         out_clk,                  
    input         rst_n,                    
    
          
    input         wr_clk,                   
    input         wr_en,                    
    input  [15:0] wr_data,                  
    input  [23:0] wr_min_addr,              
    input  [23:0] wr_max_addr,              
    input  [ 9:0] wr_len,                   
    input         wr_load,                  
    

    input         rd_clk,                   
    input         rd_en,                    
    output [15:0] rd_data,                  
    input  [23:0] rd_min_addr,              
    input  [23:0] rd_max_addr,              
    input  [ 9:0] rd_len,                   
    input         rd_load,                  
    
 
    input         sdram_read_valid,         
    input         sdram_pingpang_en,        
    output        sdram_init_done,          
    

    output        sdram_clk,                
    output        sdram_cke,                
    output        sdram_cs_n,               
    output        sdram_ras_n,              
    output        sdram_cas_n,              
    output        sdram_we_n,               
    output [ 1:0] sdram_ba,                 
    output [12:0] sdram_addr,               
    inout  [15:0] sdram_data,               
    output [ 1:0] sdram_dqm                 
    );

wire        sdram_wr_req;                   
wire        sdram_wr_ack;                   
wire [23:0] sdram_wr_addr;                  
wire [15:0] sdram_din;                      

wire        sdram_rd_req;                   
wire        sdram_rd_ack;                   
wire [23:0] sdram_rd_addr;                  
wire [15:0] sdram_dout;                     

assign  sdram_clk = out_clk;                
assign  sdram_dqm = 2'b00;                  
            
sdram_fifo_ctrl u_sdram_fifo_ctrl(
    .clk_ref            (ref_clk),          
    .rst_n              (rst_n),            

    
    .clk_write          (wr_clk),           
    .wrf_wrreq          (wr_en),            
    .wrf_din            (wr_data),          
    .wr_min_addr        (wr_min_addr),      
    .wr_max_addr        (wr_max_addr),      
    .wr_length          (wr_len),           
    .wr_load            (wr_load),          
    
                           
    .clk_read           (rd_clk),           
    .rdf_rdreq          (rd_en),            
    .rdf_dout           (rd_data),          
    .rd_min_addr        (rd_min_addr),      
    .rd_max_addr        (rd_max_addr),      
    .rd_length          (rd_len),           
    .rd_load            (rd_load),          
   
   
    .sdram_read_valid   (sdram_read_valid), 
    .sdram_init_done    (sdram_init_done),  
    .sdram_pingpang_en  (sdram_pingpang_en),
    

    .sdram_wr_req       (sdram_wr_req),     
    .sdram_wr_ack       (sdram_wr_ack),     
    .sdram_wr_addr      (sdram_wr_addr),    
    .sdram_din          (sdram_din),        
    

    .sdram_rd_req       (sdram_rd_req),     
    .sdram_rd_ack       (sdram_rd_ack),     
    .sdram_rd_addr      (sdram_rd_addr),    
    .sdram_dout         (sdram_dout)        
    );


sdram_controller u_sdram_controller(
    .clk                (ref_clk),          
    .rst_n              (rst_n),            

    .sdram_wr_req       (sdram_wr_req),     
    .sdram_wr_ack       (sdram_wr_ack),     
    .sdram_wr_addr      (sdram_wr_addr),    
    .sdram_wr_burst     (wr_len),           
    .sdram_din          (sdram_din),        

    .sdram_rd_req       (sdram_rd_req),     
    .sdram_rd_ack       (sdram_rd_ack),     
    .sdram_rd_addr      (sdram_rd_addr),    
    .sdram_rd_burst     (rd_len),           
    .sdram_dout         (sdram_dout),       
    
    .sdram_init_done    (sdram_init_done),  


    .sdram_cke          (sdram_cke),        
    .sdram_cs_n         (sdram_cs_n),       
    .sdram_ras_n        (sdram_ras_n),      
    .sdram_cas_n        (sdram_cas_n),      
    .sdram_we_n         (sdram_we_n),       
    .sdram_ba           (sdram_ba),         
    .sdram_addr         (sdram_addr),       
    .sdram_data         (sdram_data)        
    );
    
endmodule 