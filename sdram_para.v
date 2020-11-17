
`define     I_NOP           5'd0                            
`define     I_PRE           5'd1                            
`define     I_TRP           5'd2                            
`define     I_AR            5'd3                            
`define     I_TRF           5'd4                            
`define     I_MRS           5'd5                            
`define     I_TRSC          5'd6                            
`define     I_DONE          5'd7                            

`define     W_IDLE          4'd0                            
`define     W_ACTIVE        4'd1                            
`define     W_TRCD          4'd2                            
`define     W_READ          4'd3                            
`define     W_CL            4'd4                            
`define     W_RD            4'd5                            
`define     W_WRITE         4'd6                            
`define     W_WD            4'd7                            
`define     W_TWR           4'd8                            
`define     W_PRE           4'd9                            
`define     W_TRP           4'd10                           
`define     W_AR            4'd11                           
`define     W_TRFC          4'd12                           
  
`define     end_trp         cnt_clk == TRP_CLK             
`define     end_trfc        cnt_clk == TRC_CLK              
`define     end_trsc        cnt_clk == TRSC_CLK             
`define     end_trcd        cnt_clk == TRCD_CLK-1           
`define     end_tcl         cnt_clk == TCL_CLK-1            
`define     end_rdburst     cnt_clk == sdram_rd_burst-4     
`define     end_tread       cnt_clk == sdram_rd_burst+2     
`define     end_wrburst     cnt_clk == sdram_wr_burst-1     
`define     end_twrite      cnt_clk == sdram_wr_burst-1     
`define     end_twr         cnt_clk == TWR_CLK              

`define     CMD_INIT        5'b01111                        
`define     CMD_NOP         5'b10111                        
`define     CMD_ACTIVE      5'b10011                        
`define     CMD_READ        5'b10101                        
`define     CMD_WRITE       5'b10100                        
`define     CMD_B_STOP      5'b10110                        
`define     CMD_PRGE        5'b10010                        
`define     CMD_A_REF       5'b10001                        
`define     CMD_LMR         5'b10000                        
