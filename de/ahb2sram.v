module ahb2sram( 
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
    hready_o, 
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
     sram_q7  //}}}
    );

// input and output {{{
// ahb input output {{
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
output       hready_o; // }}

// sram input output {{
output        sram_clk;
output[ 3:0]  bank0_cen;
output[ 3:0]  bank1_cen;
output        sram_w_en;
output[12:0]  sram_addr;
output[31:0]  sram_data;

input [ 7:0]  sram_q0;
input [ 7:0]  sram_q1;
input [ 7:0]  sram_q2;
input [ 7:0]  sram_q3;
input [ 7:0]  sram_q4;
input [ 7:0]  sram_q5;
input [ 7:0]  sram_q6;
input [ 7:0]  sram_q7; // }} 
// }}}

// reg and wire {{{
//     output {{
wire [31:0]  hrdata;
wire [2 :0]  hresp ;
wire         hready_o; 

wire         sram_clk;
wire [ 3:0]  bank0_cen;
wire [ 3:0]  bank1_cen;
wire         sram_w_en;
wire [12:0]  sram_addr;
wire [31:0]  sram_data; // }}

//     internal {{
wire        cmd;
wire        read_cmd;
wire        write_cmd;
wire        read_access;
wire        write_access;
wire        read_enable;
wire        write_enable;
wire        bank_sel;
reg  [ 3:0] hstrobe;
reg  [ 3:0] hstrobe_sto  ;
reg         write_access_sto;
reg  [31:0] haddr_sto    ;
reg  [ 1:0] hsize_sto    ;
reg  [31:0] hrdata_hold; 
reg         read_enable_d1; // }}
// }}}

assign cmd          = hsel & htrans[1];
assign read_cmd     = cmd & ~hwrite;
assign write_cmd    = cmd & hwrite;
assign read_access  = read_cmd & hready;
assign write_access = write_cmd & hready;
assign read_enable  = read_access;
assign write_enable = write_access_sto;
assign bank_sel  = write_enable ? haddr_sto[15] : haddr[15];

assign sram_clk = hclk;

assign bank0_cen = bank_sel     ? 4'b1111      :
                   write_enable ? ~hstrobe_sto :
                   read_enable  ? ~hstrobe     :
                                  4'b1111      ;

assign bank1_cen = ~bank_sel    ? 4'b1111      :
                   write_enable ? ~hstrobe_sto :
                   read_enable  ? ~hstrobe     :
                                  4'b1111      ;

assign sram_w_en = write_enable ? 1'b0 : 1'b1  ; //1,Write's priority is higher for write->read. 2,No write is read

assign sram_addr = write_enable ? haddr_sto[14:2] : 
                   read_enable  ? haddr[14:2]     :
                                  13'b0           ;

assign sram_data = write_enable ? (hsize_sto==2'b00) ? {4{hwdata[7:0]}}  :
                                  (hsize_sto==2'b01) ? {2{hwdata[15:0]}} :
                                                       hwdata            :
                                  32'b0;

assign hresp     = 2'b0;
assign hrdata    = read_enable_d1 ? (haddr_sto[15] ? {sram_q7,sram_q6,sram_q5,sram_q4} : {sram_q3,sram_q2,sram_q1,sram_q0}) :
                                     hrdata_hold ; 

assign hready_o = write_enable&read_cmd ? 1'b0 : 1'b1;

always@(*) begin
    if (cmd)
        case(hsize)
            2'b00: hstrobe = (haddr[1:0]==2'b00) ? 4'b0001 :
                             (haddr[1:0]==2'b01) ? 4'b0010 :
                             (haddr[1:0]==2'b10) ? 4'b0100 :
                                                   4'b1000 ;
            2'b01: hstrobe = (haddr[1]  ==1'b0 ) ? 4'b0011 :
                                                   4'b1100 ;
            2'b10: hstrobe = 4'b1111;
          default: hstrobe = 4'b1111;
        endcase
    else
        hstrobe = 4'b0000;
end

always @(posedge hclk or negedge hreset) begin
    if (!hreset) begin
        hstrobe_sto      <= 4'b0;
        write_access_sto <= 1'b0;
        haddr_sto        <= 32'b0;
    end
    else begin
        hstrobe_sto      <= hstrobe;
        write_access_sto <= write_access;
        haddr_sto        <= haddr;
        hsize_sto        <= hsize;
    end
end

always @(posedge hclk or negedge hreset) begin
    if (!hreset)
        hrdata_hold <= 32'b0;
    else if(read_enable_d1)
        hrdata_hold <= hrdata;
end

always @(posedge hclk or negedge hreset) begin
    if (!hreset)
        read_enable_d1 <= 1'b0;
    else 
        read_enable_d1 <= read_enable;
end

endmodule
