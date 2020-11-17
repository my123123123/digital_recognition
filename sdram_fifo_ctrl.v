module sdram_fifo_ctrl(
    input             clk_ref,           
    input             rst_n,             
                                         
                        
    input             clk_write,         
    input             wrf_wrreq,         
    input      [15:0] wrf_din,           
    input      [23:0] wr_min_addr,       
    input      [23:0] wr_max_addr,       
    input      [ 9:0] wr_length,         
    input             wr_load,           
                                                                 
    input             clk_read,          
    input             rdf_rdreq,         
    output     [15:0] rdf_dout,          
    input      [23:0] rd_min_addr,       
    input      [23:0] rd_max_addr,       
    input      [ 9:0] rd_length,         
    input             rd_load,           
                                                              
    input             sdram_read_valid,  
    input             sdram_init_done,   
    input             sdram_pingpang_en, 
                                                        
    output reg        sdram_wr_req,      
    input             sdram_wr_ack,      
    output reg [23:0] sdram_wr_addr,     
    output     [15:0] sdram_din,         
                                                        
    output reg        sdram_rd_req,      
    input             sdram_rd_ack,      
    output reg [23:0] sdram_rd_addr,     
    input      [15:0] sdram_dout         
    );

reg        wr_ack_r1;                    
reg        wr_ack_r2;                    
reg        rd_ack_r1;                    
reg        rd_ack_r2;                    
reg        wr_load_r1;                   
reg        wr_load_r2;                   
reg        rd_load_r1;                   
reg        rd_load_r2;                   
reg        read_valid_r1;                
reg        read_valid_r2;                
reg        sw_bank_en;                   
reg        rw_bank_flag;                 
                                                                    
wire       write_done_flag;              
wire       read_done_flag;               
wire       wr_load_flag;                 
wire       rd_load_flag;                 
wire [9:0] wrf_use;                      
wire [9:0] rdf_use;                      

assign write_done_flag = wr_ack_r2   & ~wr_ack_r1;  
assign read_done_flag  = rd_ack_r2   & ~rd_ack_r1;

assign wr_load_flag    = ~wr_load_r2 & wr_load_r1;
assign rd_load_flag    = ~rd_load_r2 & rd_load_r1;

always @(posedge clk_ref or negedge rst_n) begin
    if(!rst_n) begin
        wr_ack_r1 <= 1'b0;
        wr_ack_r2 <= 1'b0;
    end
    else begin
        wr_ack_r1 <= sdram_wr_ack;
        wr_ack_r2 <= wr_ack_r1;     
    end
end 

always @(posedge clk_ref or negedge rst_n) begin
    if(!rst_n) begin
        rd_ack_r1 <= 1'b0;
        rd_ack_r2 <= 1'b0;
    end
    else begin
        rd_ack_r1 <= sdram_rd_ack;
        rd_ack_r2 <= rd_ack_r1;
    end
end 

always @(posedge clk_ref or negedge rst_n) begin
    if(!rst_n) begin
        wr_load_r1 <= 1'b0;
        wr_load_r2 <= 1'b0;
    end
    else begin
        wr_load_r1 <= wr_load;
        wr_load_r2 <= wr_load_r1;
    end
end

always @(posedge clk_ref or negedge rst_n) begin
    if(!rst_n) begin
        rd_load_r1 <= 1'b0;
        rd_load_r2 <= 1'b0;
    end
    else begin
        rd_load_r1 <= rd_load;
        rd_load_r2 <= rd_load_r1;
    end
end

always @(posedge clk_ref or negedge rst_n) begin
    if(!rst_n) begin
        read_valid_r1 <= 1'b0;
        read_valid_r2 <= 1'b0;
    end
    else begin
        read_valid_r1 <= sdram_read_valid;
        read_valid_r2 <= read_valid_r1;
    end
end

always @(posedge clk_ref or negedge rst_n) begin
    if (!rst_n) begin
        sdram_wr_addr <= 24'd0;
        sw_bank_en <= 1'b0;
        rw_bank_flag <= 1'b0;
    end
    else if(wr_load_flag) begin              
        sdram_wr_addr <= wr_min_addr;   
        sw_bank_en <= 1'b0;
        rw_bank_flag <= 1'b0;
    end
    else if(write_done_flag) begin           
                                             
        if(sdram_pingpang_en) begin          
            if(sdram_wr_addr[22:0] < wr_max_addr - wr_length)
                sdram_wr_addr <= sdram_wr_addr + wr_length;
            else begin                       
                rw_bank_flag <= ~rw_bank_flag;   
                sw_bank_en <= 1'b1;          
            end            
        end       
                                             
        else if(sdram_wr_addr < wr_max_addr - wr_length)
            sdram_wr_addr <= sdram_wr_addr + wr_length;
        else                                
            sdram_wr_addr <= wr_min_addr;
    end
    else if(sw_bank_en) begin                
        sw_bank_en <= 1'b0;
        if(rw_bank_flag == 1'b0)             
            sdram_wr_addr <= {1'b0,wr_min_addr[22:0]};
        else
            sdram_wr_addr <= {1'b1,wr_min_addr[22:0]};     
    end
end

always @(posedge clk_ref or negedge rst_n) begin
    if(!rst_n) begin
        sdram_rd_addr <= 24'd0;
    end 
    else if(rd_load_flag)                    
        sdram_rd_addr <= rd_min_addr;
    else if(read_done_flag) begin            
                                                            
        if(sdram_pingpang_en) begin          
            if(sdram_rd_addr[22:0] < rd_max_addr - rd_length)
                sdram_rd_addr <= sdram_rd_addr + rd_length;
            else begin                       
                                             
                if(rw_bank_flag == 1'b0)     
                    sdram_rd_addr <= {1'b1,rd_min_addr[22:0]};
                else
                    sdram_rd_addr <= {1'b0,rd_min_addr[22:0]};    
            end    
        end
                                             
        else if(sdram_rd_addr < rd_max_addr - rd_length)  
            sdram_rd_addr <= sdram_rd_addr + rd_length;
        else                                 
            sdram_rd_addr <= rd_min_addr;
    end
end

always@(posedge clk_ref or negedge rst_n) begin
    if(!rst_n) begin
        sdram_wr_req <= 0;
        sdram_rd_req <= 0;
    end
    else if(sdram_init_done) begin       
                                         
        if(wrf_use >= wr_length) begin   
            sdram_wr_req <= 1;           
            sdram_rd_req <= 0;           
        end
        else if((rdf_use < rd_length)    
                 && read_valid_r2) begin 
            sdram_wr_req <= 0;           
            sdram_rd_req <= 1;           
        end
        else begin
            sdram_wr_req <= 0;
            sdram_rd_req <= 0;
        end
    end
    else begin
        sdram_wr_req <= 0;
        sdram_rd_req <= 0;
    end
end

wrfifo  u_wrfifo(
  
    .wrclk      (clk_write),            
    .wrreq      (wrf_wrreq),            
    .data       (wrf_din),              

    .rdclk      (clk_ref),              
    .rdreq      (sdram_wr_ack),         
    .q          (sdram_din),            

    .rdusedw    (wrf_use),              
    .aclr       (~rst_n | wr_load_flag) 
    );  

rdfifo  u_rdfifo(
 
    .wrclk      (clk_ref),               
    .wrreq      (sdram_rd_ack),          
    .data       (sdram_dout),            
    

    .rdclk      (clk_read),              
    .rdreq      (rdf_rdreq),             
    .q          (rdf_dout),              

    .wrusedw    (rdf_use),               
    .aclr       (~rst_n | rd_load_flag)  
    );
    
endmodule 