module sram(
    A   ,
    D   ,
    CLK ,
    CEN ,
    WEN ,
    OEN ,
    Q    
    );

input  [12:0]   A   ;
input  [ 7:0]   D   ;
input           CLK ;
input           CEN ;
input           WEN ;
input           OEN ;
output [ 7:0]   Q   ;

reg    [ 7:0]   Q   ;
 
reg    [ 7:0]   mem[8191:0];
reg    [ 7:0]   Q_d1;

// command {{
assign write = ~CEN & ~WEN ;
assign read  = ~CEN &  WEN ; // }}



// write {{
always @(posedge CLK ) begin
    if (write)
        mem[A] <= D;
end // }}



// read {{
always @(posedge CLK ) begin
    Q = OEN   ? 8'bzzzz_zzzz :
        read  ? mem[A]       : 
        write ? D            :
                Q            ;
end // }}


endmodule

