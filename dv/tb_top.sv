`ifdef CASE_FILE `include `CASE_FILE `endif

module tb_top();

`ifndef CLK_RESET_TEST
logic hclk;
localparam CYCLE = 10;
initial begin
    hclk = 1'b0;
    forever #(CYCLE/2)hclk = ~hclk;
end

logic hreset;
initial begin
    hreset = 1'b1;
    #(CYCLE*1.3) hreset = 1'b0;
    #(CYCLE*2  ) hreset = 1'b1;
end
`endif

sramc_slave u_sramc_slave(
    .hclk    ( hclk               ),
    .hreset  ( hreset             ),
    .hready  ( u_sramc_if.hready   ),
    .hsel    ( u_sramc_if.hsel     ),
    .htrans  ( u_sramc_if.htrans   ),
    .hsize   ( u_sramc_if.hsize    ),
    .hburst  ( u_sramc_if.hburst   ),
    .hwrite  ( u_sramc_if.hwrite   ),
    .haddr   ( u_sramc_if.haddr    ),
    .hwdata  ( u_sramc_if.hwdata   ),
    .hrdata  ( u_sramc_if.hrdata   ),
    .hresp   ( u_sramc_if.hresp    ),
    .hready_o( u_sramc_if.hready_o ) 
);

SramcIf u_sramc_if(.hclk(hclk), .hreset(hreset));

`ifdef CASE_INST `CASE_INST test_case(u_sramc_if); `endif

endmodule


