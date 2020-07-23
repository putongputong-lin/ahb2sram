module sramc_slave(
    // declare {{{
    hclk,
    hreset,
    hready,
    hsel  ,
    htrans,
    hsize ,
    hburst,
    hwrite,
    haddr ,
    hwdata,
    hrdata,
    hresp ,
    hready_o  // }}}
);

// input and output {{{
input        hclk;
input        hreset;
input        hready;
input        hsel  ;
input [1 :0] htrans;
input [1 :0] hsize ;
input [3 :0] hburst;
input        hwrite;
input [31:0] haddr ;
input [31:0] hwdata;

output[31:0] hrdata;
output[2 :0] hresp ;
output       hready_o; // }}}


// reg and wire {{{
wire         sram_clk;
wire [ 3:0]  bank0_cen;
wire [ 3:0]  bank1_cen;
wire         sram_w_en;
wire [12:0]  sram_addr;
wire [31:0]  sram_data;
     
wire [ 7:0]  sram_q0;
wire [ 7:0]  sram_q1;
wire [ 7:0]  sram_q2;
wire [ 7:0]  sram_q3;
wire [ 7:0]  sram_q4;
wire [ 7:0]  sram_q5;
wire [ 7:0]  sram_q6;
wire [ 7:0]  sram_q7; // }}}


ahb2sram u_ahb2sram(
    .hclk      (hclk      ),
    .hreset    (hreset    ),      
    .hready    (hready    ),
    .hsel      (hsel      ),
    .htrans    (htrans    ),
    .hsize     (hsize     ),
    .hburst    (hburst    ),
    .hwrite    (hwrite    ),
    .haddr     (haddr     ),
    .hwdata    (hwdata    ),
    .hrdata    (hrdata    ),
    .hresp     (hresp     ),
    .hready_o  (hready_o  ),
    .sram_clk  (sram_clk  ),
    .bank0_cen (bank0_cen ),
    .bank1_cen (bank1_cen ),
    .sram_w_en (sram_w_en ),
    .sram_addr (sram_addr ),
    .sram_data (sram_data ),
    .sram_q0   (sram_q0   ),
    .sram_q1   (sram_q1   ),
    .sram_q2   (sram_q2   ),
    .sram_q3   (sram_q3   ),
    .sram_q4   (sram_q4   ),
    .sram_q5   (sram_q5   ),
    .sram_q6   (sram_q6   ),
    .sram_q7   (sram_q7   ) 
);


sram_core u_sram_core(
    .sram_clk  (sram_clk ),
    .bank0_cen (bank0_cen),
    .bank1_cen (bank1_cen),
    .sram_w_en (sram_w_en),
    .sram_addr (sram_addr),
    .sram_data (sram_data),
    .sram_q0   (sram_q0  ),
    .sram_q1   (sram_q1  ),
    .sram_q2   (sram_q2  ),
    .sram_q3   (sram_q3  ),
    .sram_q4   (sram_q4  ),
    .sram_q5   (sram_q5  ),
    .sram_q6   (sram_q6  ),
    .sram_q7   (sram_q7  ) 
);

endmodule
