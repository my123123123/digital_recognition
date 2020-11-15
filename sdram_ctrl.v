module sdram_ctrl(
    input            clk,			    
    input            rst_n,			    
    
    input            sdram_wr_req,	    
    input            sdram_rd_req,	    
    output           sdram_wr_ack,	    
    output           sdram_rd_ack,	    
    input      [9:0] sdram_wr_burst,	
    input      [9:0] sdram_rd_burst,	
    output           sdram_init_done,   

    output reg [4:0] init_state,	    
    output reg [3:0] work_state,	    
    output reg [9:0] cnt_clk,	        
    output reg       sdram_rd_wr 		
    );

`include "sdram_para.v"		            
                                        
                    
parameter  TRP_CLK	  = 10'd4;	        
parameter  TRC_CLK	  = 10'd6;	        
parameter  TRSC_CLK	  = 10'd6;	        
parameter  TRCD_CLK	  = 10'd2;	        
parameter  TCL_CLK	  = 10'd3;	        
parameter  TWR_CLK	  = 10'd2;	        
                                        
                           
reg [14:0] cnt_200us;                   
reg [10:0] cnt_refresh;	                
reg        sdram_ref_req;		        
reg        cnt_rst_n;		            
reg [ 3:0] init_ar_cnt;                 
                                        
                           
wire       done_200us;		            
wire       sdram_ref_ack;		        

assign done_200us = (cnt_200us == 15'd20_000);


assign sdram_init_done = (init_state == `I_DONE);


assign sdram_ref_ack = (work_state == `W_AR);


assign sdram_wr_ack = ((work_state == `W_TRCD) & ~sdram_rd_wr) | 
					  ( work_state == `W_WRITE)|
					  ((work_state == `W_WD) & (cnt_clk < sdram_wr_burst - 2'd2));
                      

assign sdram_rd_ack = (work_state == `W_RD) & 
					  (cnt_clk >= 10'd1) & (cnt_clk < sdram_rd_burst + 2'd1);
                      

always @ (posedge clk or negedge rst_n) begin
	if(!rst_n) 
        cnt_200us <= 15'd0;
	else if(cnt_200us < 15'd20_000) 
        cnt_200us <= cnt_200us + 1'b1;
    else
        cnt_200us <= cnt_200us;
end

always @ (posedge clk or negedge rst_n)
	if(!rst_n) 
        cnt_refresh <= 11'd0;
	else if(cnt_refresh < 11'd781)      
        cnt_refresh <= cnt_refresh + 1'b1;	
	else 
        cnt_refresh <= 11'd0;	


always @ (posedge clk or negedge rst_n)
	if(!rst_n) 
        sdram_ref_req <= 1'b0;
	else if(cnt_refresh == 11'd780) 
        sdram_ref_req <= 1'b1;	        
	else if(sdram_ref_ack) 
        sdram_ref_req <= 1'b0;		    

always @ (posedge clk or negedge rst_n) 
	if(!rst_n) 
        cnt_clk <= 10'd0;
	else if(!cnt_rst_n)                 
        cnt_clk <= 10'd0;
	else 
        cnt_clk <= cnt_clk + 1'b1;

always @ (posedge clk or negedge rst_n) 
	if(!rst_n) 
        init_ar_cnt <= 4'd0;
	else if(init_state == `I_NOP) 
        init_ar_cnt <= 4'd0;
	else if(init_state == `I_AR)
        init_ar_cnt <= init_ar_cnt + 1'b1;
    else
        init_ar_cnt <= init_ar_cnt;
	
always @ (posedge clk or negedge rst_n) begin
	if(!rst_n) 
        init_state <= `I_NOP;
	else 
		case (init_state)
                                      
            `I_NOP:  init_state <= done_200us  ? `I_PRE : `I_NOP;
                                       
			`I_PRE:  init_state <= `I_TRP;
                                       
			`I_TRP:  init_state <= (`end_trp)  ? `I_AR  : `I_TRP;
                                        
			`I_AR :  init_state <= `I_TRF;	
                                        
			`I_TRF:  init_state <= (`end_trfc) ? 
                                   
                                   ((init_ar_cnt == 4'd8) ? `I_MRS : `I_AR) : `I_TRF;
                                        
			`I_MRS:	 init_state <= `I_TRSC;	
                                        
			`I_TRSC: init_state <= (`end_trsc) ? `I_DONE : `I_TRSC;
                                       
			`I_DONE: init_state <= `I_DONE;
			default: init_state <= `I_NOP;
		endcase
end


always @ (posedge clk or negedge rst_n) begin
	if(!rst_n) 
		work_state <= `W_IDLE;      
	else
		case(work_state)
                                       
            `W_IDLE: if(sdram_ref_req & sdram_init_done) begin
						 work_state <= `W_AR; 		
					     sdram_rd_wr <= 1'b1;
				     end 		        
                                       
					 else if(sdram_wr_req & sdram_init_done) begin
						 work_state <= `W_ACTIVE;
						 sdram_rd_wr <= 1'b0;	
					 end                
                                       
					 else if(sdram_rd_req && sdram_init_done) begin
						 work_state <= `W_ACTIVE;
						 sdram_rd_wr <= 1'b1;	
					 end                
                                    
					 else begin 
						 work_state <= `W_IDLE;
						 sdram_rd_wr <= 1'b1;
					 end
                     
            `W_ACTIVE:                  
                         work_state <= `W_TRCD;
            `W_TRCD: if(`end_trcd)      
						 if(sdram_rd_wr)
                             work_state <= `W_READ;
						 else           
                             work_state <= `W_WRITE;
					 else 
                         work_state <= `W_TRCD;
                         
            `W_READ:	                
                         work_state <= `W_CL;	
            `W_CL:		                
                         work_state <= (`end_tcl) ? `W_RD:`W_CL;	                                        
            `W_RD:		                
                         work_state <= (`end_tread) ? `W_PRE:`W_RD;
                         
            `W_WRITE:	                
                         work_state <= `W_WD;
            `W_WD:		               
                         work_state <= (`end_twrite) ? `W_TWR:`W_WD;                         
            `W_TWR:	                   
                         work_state <= (`end_twr) ? `W_PRE:`W_TWR;
                         
            `W_PRE:		               
                         work_state <= `W_TRP;
            `W_TRP:	                
                         work_state <= (`end_trp) ? `W_IDLE:`W_TRP;
                         
            `W_AR:		                
                         work_state <= `W_TRFC;             
            `W_TRFC:	                
                         work_state <= (`end_trfc) ? `W_IDLE:`W_TRFC;
            default: 	 work_state <= `W_IDLE;
		endcase
end


always @ (*) begin
	case (init_state)
        `I_NOP:	 cnt_rst_n <= 1'b0;     
                                        
        `I_PRE:	 cnt_rst_n <= 1'b1;     
                                        
        `I_TRP:	 cnt_rst_n <= (`end_trp) ? 1'b0 : 1'b1;
                                       
        `I_AR:
                 cnt_rst_n <= 1'b1;
                                        
        `I_TRF:
                 cnt_rst_n <= (`end_trfc) ? 1'b0 : 1'b1;	
                                        
        `I_MRS:  cnt_rst_n <= 1'b1;	    
                                        
        `I_TRSC: cnt_rst_n <= (`end_trsc) ? 1'b0:1'b1;
                                        
        `I_DONE: begin               
		    case (work_state)
				`W_IDLE:	cnt_rst_n <= 1'b0;
                                        
				`W_ACTIVE: 	cnt_rst_n <= 1'b1;
                                      
				`W_TRCD:	cnt_rst_n <= (`end_trcd)   ? 1'b0 : 1'b1;
                                      
				`W_CL:		cnt_rst_n <= (`end_tcl)    ? 1'b0 : 1'b1;
                                       
				`W_RD:		cnt_rst_n <= (`end_tread)  ? 1'b0 : 1'b1;
                                        
				`W_WD:		cnt_rst_n <= (`end_twrite) ? 1'b0 : 1'b1;
                                       
				`W_TWR:	    cnt_rst_n <= (`end_twr)    ? 1'b0 : 1'b1;
                                       
				`W_TRP:	cnt_rst_n <= (`end_trp) ? 1'b0 : 1'b1;
                                      
				`W_TRFC:	cnt_rst_n <= (`end_trfc)   ? 1'b0 : 1'b1;
				default:    cnt_rst_n <= 1'b0;
		    endcase
        end
		default: cnt_rst_n <= 1'b0;
	endcase
end
 
endmodule 