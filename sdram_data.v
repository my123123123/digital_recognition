
module sdram_data(
    input             clk,             
    input             rst_n,           

    input   [15:0]    sdram_data_in,   
    output  [15:0]    sdram_data_out,  
    input   [ 3:0]    work_state,      
    input   [ 9:0]    cnt_clk,         
    
    inout   [15:0]    sdram_data       
    );

`include "sdram_para.v"                

reg        sdram_out_en;               
reg [15:0] sdram_din_r;                
reg [15:0] sdram_dout_r;               

assign sdram_data = sdram_out_en ? sdram_din_r : 16'hzzzz;

assign sdram_data_out = sdram_dout_r;

always @ (posedge clk or negedge rst_n) begin 
    if(!rst_n) 
       sdram_out_en <= 1'b0;
   else if((work_state == `W_WRITE) | (work_state == `W_WD)) 
       sdram_out_en <= 1'b1;           
   else 
       sdram_out_en <= 1'b0;
end

always @ (posedge clk or negedge rst_n) begin
    if(!rst_n) 
        sdram_din_r <= 16'd0;
    else if((work_state == `W_WRITE) | (work_state == `W_WD))
        sdram_din_r <= sdram_data_in;  
end

always @ (posedge clk or negedge rst_n) begin
    if(!rst_n) 
        sdram_dout_r <= 16'd0;
    else if(work_state == `W_RD) 
        sdram_dout_r <= sdram_data;     
end

endmodule 