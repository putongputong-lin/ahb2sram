module sram_core(
    sram_clk,
    bank0_cen,
    bank1_cen,
    sram_w_en,
    sram_addr,
    sram_data,
    sram_q0,
    sram_q1,
    sram_q2,
    sram_q3,
    sram_q4,
    sram_q5,
    sram_q6,
    sram_q7 
);

input          sram_clk;
input  [ 3:0]  bank0_cen;
input  [ 3:0]  bank1_cen;
input          sram_w_en;
input  [12:0]  sram_addr;
input  [31:0]  sram_data;
output [ 7:0]  sram_q0;
output [ 7:0]  sram_q1;
output [ 7:0]  sram_q2;
output [ 7:0]  sram_q3;
output [ 7:0]  sram_q4;
output [ 7:0]  sram_q5;
output [ 7:0]  sram_q6;
output [ 7:0]  sram_q7;

wire   [ 7:0]  sram_q0;
wire   [ 7:0]  sram_q1;
wire   [ 7:0]  sram_q2;
wire   [ 7:0]  sram_q3;
wire   [ 7:0]  sram_q4;
wire   [ 7:0]  sram_q5;
wire   [ 7:0]  sram_q6;
wire   [ 7:0]  sram_q7;

sram u_bank0_sram0(
    .Q  (sram_q0        ),
    .A  (sram_addr      ),
    .D  (sram_data[7:0 ]),
    .CLK(sram_clk       ),
    .CEN(bank0_cen[0]   ),
    .WEN(sram_w_en      ),
    .OEN(1'b0           )
);

sram u_bank0_sram1(
    .Q  (sram_q1        ),
    .A  (sram_addr      ),
    .D  (sram_data[15:8]),
    .CLK(sram_clk       ),
    .CEN(bank0_cen[1]   ),
    .WEN(sram_w_en      ),
    .OEN(1'b0           )
);

sram u_bank0_sram2(
    .Q  (sram_q2        ),
    .A  (sram_addr      ),
    .D  (sram_data[23:16]),
    .CLK(sram_clk       ),
    .CEN(bank0_cen[2]   ),
    .WEN(sram_w_en      ),
    .OEN(1'b0           )
);

sram u_bank0_sram3(
    .Q  (sram_q3        ),
    .A  (sram_addr      ),
    .D  (sram_data[31:24]),
    .CLK(sram_clk       ),
    .CEN(bank0_cen[3]   ),
    .WEN(sram_w_en      ),
    .OEN(1'b0           )
);

sram u_bank1_sram4(
    .Q  (sram_q4        ),
    .A  (sram_addr      ),
    .D  (sram_data[7:0 ]),
    .CLK(sram_clk       ),
    .CEN(bank1_cen[0]   ),
    .WEN(sram_w_en      ),
    .OEN(1'b0           )
);

sram u_bank1_sram5(
    .Q  (sram_q5        ),
    .A  (sram_addr      ),
    .D  (sram_data[15:8]),
    .CLK(sram_clk       ),
    .CEN(bank1_cen[1]   ),
    .WEN(sram_w_en      ),
    .OEN(1'b0           )
);

sram u_bank1_sram6(
    .Q  (sram_q6        ),
    .A  (sram_addr      ),
    .D  (sram_data[23:16]),
    .CLK(sram_clk       ),
    .CEN(bank1_cen[2]   ),
    .WEN(sram_w_en      ),
    .OEN(1'b0           )
);

sram u_bank1_sram7(
    .Q  (sram_q7        ),
    .A  (sram_addr      ),
    .D  (sram_data[31:24]),
    .CLK(sram_clk       ),
    .CEN(bank1_cen[3]   ),
    .WEN(sram_w_en      ),
    .OEN(1'b0           )
);

endmodule
