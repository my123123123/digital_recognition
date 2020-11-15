

module picture_size (
    input              rst_n       ,
             
    input       [15:0] ID_lcd      ,
             
    output  reg [12:0] cmos_h_pixel,
    output  reg [12:0] cmos_v_pixel,   
    output  reg [12:0] total_h_pixel,
    output  reg [12:0] total_v_pixel,
    output  reg [23:0] sdram_max_addr
);


parameter  ID_4342 =   0;
parameter  ID_7084 =   1;
parameter  ID_7016 =   2;
parameter  ID_1018 =   5;


always @(*) begin             
    case(ID_lcd ) 
        ID_4342 : begin
            cmos_h_pixel   = 13'd480;    
            cmos_v_pixel   = 13'd272;
            sdram_max_addr =23'd130560;
        end 
        ID_7084 : begin
            cmos_h_pixel   = 13'd800;    
            cmos_v_pixel   = 13'd480;           
            sdram_max_addr =23'd384000;
        end 
        ID_7016 : begin
            cmos_h_pixel   = 13'd1024;    
            cmos_v_pixel   = 13'd600;           
            sdram_max_addr =23'd614400;
        end    
        ID_1018 : begin
            cmos_h_pixel   = 13'd1280;    
            cmos_v_pixel   = 13'd800;           
            sdram_max_addr =23'd1024000;
        end 
    default : begin
        cmos_h_pixel   = 13'd480;
        cmos_v_pixel   = 13'd272; 
        sdram_max_addr =23'd130560;
    end
    endcase
end 

always @(*) begin
    case(ID_lcd)
        ID_4342 : begin 
            total_h_pixel =   13'd1800;
            total_v_pixel =   13'd1000;
        end
        ID_7084 : begin 
            total_h_pixel =   13'd1800;
            total_v_pixel =   13'd1000;
        end
        ID_7016 : begin 
            total_h_pixel =   13'd2200;
            total_v_pixel =   13'd1000;
        end
        ID_1018 : begin
            total_h_pixel =   13'd2570;
            total_v_pixel =   13'd980;
        end 
    default : begin
        total_h_pixel  = 13'd1800;
        total_v_pixel  = 13'd1000;
    end 
    endcase
end 

endmodule