interface SramcIf(input hclk, input hreset);

parameter CYCLE = 20;

logic        hready;
logic        hsel  ;
logic [1 :0] htrans;
logic [1 :0] hsize ;
logic [3 :0] hburst;
logic        hwrite;
logic [31:0] haddr ;
logic [31:0] hwdata;

logic [31:0] hrdata;
logic [2 :0] hresp ;
logic        hready_o;

clocking driver_cb @(posedge hclk);
    default input #1step output #0;
    output hsel, htrans, hsize, hburst, hwrite, haddr, hwdata;
endclocking

clocking receiver_cb @(posedge hclk);
    default input #1step output #0;
    input hrdata;
endclocking
    
clocking mirror_memory_cb @(posedge hclk);
    default input #1step output #0;
endclocking

modport driver(clocking driver_cb, input hready);
modport receiver(clocking receiver_cb, input hready, hsel, htrans, hsize, hburst, hwrite, haddr);
modport mirror_memory(clocking mirror_memory_cb, input hready, hsel, htrans, hsize, hburst, hwrite, haddr, hwdata);
modport score_board(input hclk);

// assign hready 
assign #1 hready = hready_o;

endinterface
