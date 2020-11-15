module rd_id(
    input              clk    ,
    input              rst_n  ,
    input      [15:0]  lcd_rgb,  
    
    output reg [15:0]  ID_lcd 
);


reg   ID_rd_en;

always @(posedge clk or negedge rst_n) begin         
    if (!rst_n) begin
        ID_lcd <= 16'd5;
        ID_rd_en <= 1'b0;
    end 
    else if(!ID_rd_en) begin 
        ID_lcd <= {13'b0,lcd_rgb[4],lcd_rgb[10],lcd_rgb[15]};
        ID_rd_en <= 1'b1;
    end
    else 
        ID_lcd <= ID_lcd;
end 

endmodule