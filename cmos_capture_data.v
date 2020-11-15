module cmos_capture_data(
    input                 rst_n           ,  
    
    input                 cam_pclk        ,  
    input                 cam_vsync       ,  
    input                 cam_href        ,  
    input        [7:0]    cam_data        ,  
 
    output                cmos_frame_vsync,  
    output                cmos_frame_href ,  
    output                cmos_frame_clken,  
    output       [15:0]   cmos_frame_data    
    );

parameter  WAIT_FRAME = 4'd10  ;             

reg             cam_vsync_d0   ;
reg             cam_vsync_d1   ;
reg             cam_href_d0    ;
reg             cam_href_d1    ;
reg    [3:0]    cmos_fps_cnt    ;            
reg             frame_val_flag ;             

reg    [7:0]    cam_data_d0    ;
reg    [15:0]   cmos_data_t    ;             
reg             byte_flag      ;
reg             byte_flag_d0   ;

wire            pos_vsync      ;


assign pos_vsync = (~cam_vsync_d1) & cam_vsync_d0;

assign  cmos_frame_vsync = frame_val_flag  ?  cam_vsync_d1  :  1'b0;

assign  cmos_frame_href  = frame_val_flag  ?  cam_href_d1   :  1'b0;

assign  cmos_frame_clken = frame_val_flag  ?  byte_flag_d0  :  1'b0;

assign  cmos_frame_data  = frame_val_flag  ?  cmos_data_t   :  1'b0;

always @(posedge cam_pclk or negedge rst_n) begin
    if(!rst_n) begin
        cam_vsync_d0 <= 1'b0;
        cam_vsync_d1 <= 1'b0;
        cam_href_d0 <= 1'b0;
        cam_href_d1 <= 1'b0;
    end
    else begin
        cam_vsync_d0 <= cam_vsync;
        cam_vsync_d1 <= cam_vsync_d0;
        cam_href_d0 <= cam_href;
        cam_href_d1 <= cam_href_d0;
    end
end

always @(posedge cam_pclk or negedge rst_n) begin
    if(!rst_n)
        cmos_fps_cnt <= 4'd0;
    else if(pos_vsync && (cmos_fps_cnt < WAIT_FRAME))
        cmos_fps_cnt <= cmos_fps_cnt + 4'd1;
end

always @(posedge cam_pclk or negedge rst_n) begin
    if(!rst_n)
        frame_val_flag <= 1'b0;
    else if((cmos_fps_cnt == WAIT_FRAME) && pos_vsync)
        frame_val_flag <= 1'b1;
    else;
end

always @(posedge cam_pclk or negedge rst_n) begin
    if(!rst_n) begin
        cmos_data_t <= 16'd0;
        cam_data_d0 <= 8'd0;
        byte_flag <= 1'b0;
    end
    else if(cam_href) begin
        byte_flag <= ~byte_flag;
        cam_data_d0 <= cam_data;
        if(byte_flag)
            cmos_data_t <= {cam_data_d0,cam_data};
        else;
    end
    else begin
        byte_flag <= 1'b0;
        cam_data_d0 <= 8'b0;
    end
end

always @(posedge cam_pclk or negedge rst_n) begin
    if(!rst_n)
        byte_flag_d0 <= 1'b0;
    else
        byte_flag_d0 <= byte_flag;
end

endmodule