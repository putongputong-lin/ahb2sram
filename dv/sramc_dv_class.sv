class TransactionRandom;
    rand logic hwrite;
    rand logic [31:0] haddr;
    rand logic [1 :0] hsize;
    rand logic [31:0] hwdata;
    constraint abc {
        haddr<65536;
        hsize<2'b11;
        (hwrite==0)->(hwdata==0);
        solve hwrite before hwdata;
        if (hsize==2'b01) haddr[0]==0;
        if (hsize==2'b10) haddr[1:0]==0;
        solve hsize before haddr;
    }
endclass

class Transaction;
    logic hwrite[$];
    logic [31:0] haddr[$];
    logic [31:0] hwdata[$];
    logic [ 1:0] hsize[$];
    task input_tr(input logic hwrite, input logic [31:0] haddr, input logic [1:0] hsize, input logic [31:0] hwdata=0);
        this.hwrite.push_back(hwrite);
        this.haddr. push_back(haddr );
        this.hsize. push_back(hsize );
        this.hwdata.push_back(hwdata);
    endtask
    task random_tr(input int cmd_num);
        TransactionRandom tr_random=new();
        repeat(cmd_num) begin
            if (tr_random.randomize()==1) begin
                this.hwrite.push_back(tr_random.hwrite);
                this.haddr. push_back(tr_random.haddr );
                this.hsize. push_back(tr_random.hsize );
                this.hwdata.push_back(tr_random.hwdata);
            end
            else
              $display("@%t: Error, random transaction fail!", $time);
        end
    endtask
endclass

class AhbDriver;
    virtual SramcIf.driver sramc_if_drv;
    Transaction tr=new();

    extern task load_tr;

    function new(virtual SramcIf.driver sramc_if_drv);
        this.sramc_if_drv = sramc_if_drv;
    endfunction
    
    task drive_init();
        this.sramc_if_drv.driver_cb.hsel   <= 1'b0;
        this.sramc_if_drv.driver_cb.htrans <= 2'b00;
        this.sramc_if_drv.driver_cb.hburst <= 4'h0;
        this.sramc_if_drv.driver_cb.hwrite <= 1'b0;
        this.sramc_if_drv.driver_cb.haddr  <= 32'b0;
        this.sramc_if_drv.driver_cb.hsize  <= 2'b10;
        this.sramc_if_drv.driver_cb.hwdata <= 32'b0;
        repeat(10) @(this.sramc_if_drv.driver_cb);
    endtask

    task drive_tr();
        logic        hwrite;
        logic [31:0] haddr;
        logic [1:0]  hsize;
        logic [31:0] hwdata;
        int          wr_addr_phase_cnt;
        int          rd_addr_phase_cnt;
        int          data_phase_cnt;
        fork   
            event        e_send_tr;
            semaphore    sm_send_tr;
            sm_send_tr = new(1);
            forever begin
                @(e_send_tr); 
                sm_send_tr.get(1);
                @(this.sramc_if_drv.driver_cb);
                sm_send_tr.put(1);
                hwdata = tr.hwdata.pop_front();
                begin this.sramc_if_drv.driver_cb.hwdata <= hwdata; end
                if (hwrite) begin
                    $display("@%t: Info , drive_tr,     No.%d, send hwdata=%h!", $time, data_phase_cnt, hwdata); 
                    data_phase_cnt++;
                end
            end
            forever begin
                if( this.sramc_if_drv.hready && tr.hwrite.size()!=0 ) 
                    begin 
                        hwrite  = tr.hwrite.pop_front();
                        haddr   = tr.haddr.pop_front();
                        hsize   = tr.hsize.pop_front();
                        this.sramc_if_drv.driver_cb.hsel   <= 1'b1;
                        this.sramc_if_drv.driver_cb.htrans <= 2'b10;
                        this.sramc_if_drv.driver_cb.hburst <= 4'h0;
                        this.sramc_if_drv.driver_cb.hwrite <= hwrite;
                        this.sramc_if_drv.driver_cb.haddr  <= haddr;
                        this.sramc_if_drv.driver_cb.hsize  <= hsize;
                        if (hwrite) begin
                            $display("@%t: Info , drive_tr,     No.%d, hwrite=%b, haddr=%h, hsize=%b!", $time, wr_addr_phase_cnt, hwrite, haddr, hsize);
                            wr_addr_phase_cnt++;
                        end
                        else begin
                            rd_addr_phase_cnt++;
                        end
                        ->e_send_tr;
                        @(this.sramc_if_drv.driver_cb);
                        sm_send_tr.get(1);
                        sm_send_tr.put(1);
                    end
                else if (tr.hwrite.size()==0) begin
                    repeat (10) @(this.sramc_if_drv.driver_cb) begin
                        this.sramc_if_drv.driver_cb.hsel   <= 1'b0;
                        this.sramc_if_drv.driver_cb.htrans <= 2'b00;
                        this.sramc_if_drv.driver_cb.hburst <= 4'h0;
                        this.sramc_if_drv.driver_cb.hwrite <= 1'b0;
                        this.sramc_if_drv.driver_cb.haddr  <= 32'b0;
                        this.sramc_if_drv.driver_cb.hsize  <= 2'b10;
                        this.sramc_if_drv.driver_cb.hwdata <= 32'b0;
                        @(this.sramc_if_drv.driver_cb);
                    end
                    $finish();
                end
                else begin
                    @(this.sramc_if_drv.driver_cb);
                end
            end
        join
    endtask
endclass

class AhbRecevier; //parrallel with AhbDrv
    virtual SramcIf.receiver sramc_if_rcv;
    logic [31:0] rdata[$] = {};
    function new(virtual SramcIf.receiver sramc_if_rcv);
        this.sramc_if_rcv = sramc_if_rcv;
    endfunction
    task receive_data();
        logic [31:0] haddr;
        logic [ 1:0] hsize;
        logic [31:0] hrdata;
        logic [31:0] rdata;
        int data_phase_cnt;
        int cnt = 0;
        fork 
            event evt_rcdt;
            semaphore sm0;
            sm0 = new(1);
            forever @(evt_rcdt) begin                
                while(1) begin
                    sm0.get(1); 
                    @(this.sramc_if_rcv.receiver_cb); 
                    sm0.put(1); 
                    if (this.sramc_if_rcv.hready) begin
                        hrdata = this.sramc_if_rcv.receiver_cb.hrdata;
                        rdata = strobe_data(haddr, hsize, hrdata);
                        this.rdata.push_back( rdata );
                        $display("@%t: Info , receiver,     No.%d, receive      data is %h! haddr is %h! hsize is %b! hrdata is %h!", $time, data_phase_cnt, rdata, haddr, hsize, hrdata);
                        data_phase_cnt++;
                        break;
                    end
                end
            end
            forever begin
                if(this.sramc_if_rcv.hready && ~this.sramc_if_rcv.hwrite && this.sramc_if_rcv.hsel && this.sramc_if_rcv.htrans[1]) begin
                    haddr = this.sramc_if_rcv.haddr;
                    hsize = this.sramc_if_rcv.hsize;
                    ->evt_rcdt;
                end
                @(this.sramc_if_rcv.receiver_cb);
                sm0.get(1);
                sm0.put(1);
            end
        join
    endtask 
    function logic [31:0] strobe_data(input logic [31:0] haddr, input logic [1:0] hsize, input logic[31:0] hrdata);
        case (hsize)
            2'b00: case(haddr[1:0]) 
                2'b00: strobe_data = hrdata[ 7: 0];
                2'b01: strobe_data = hrdata[15: 8];
                2'b10: strobe_data = hrdata[23:16];
                2'b11: strobe_data = hrdata[31:24];
            endcase
            2'b01: case(haddr[1])
                1'b0: strobe_data = hrdata[15: 0];
                1'b1: strobe_data = hrdata[31:16];
            endcase
            default: strobe_data = hrdata[31: 0];
        endcase
    endfunction
endclass

class MirrorMemory; //parrallel with AhbDrv
    virtual SramcIf.mirror_memory sramc_if_mm;
    logic [31:0] mirror_memory [16383:0];
    logic [31:0] rdata[$] = {};
    function new(virtual SramcIf.mirror_memory sramc_if_mm);
        this.sramc_if_mm = sramc_if_mm;
    endfunction
    task start_run();
        logic [31:0] haddr;
        logic [1:0] hsize;
        logic [31:0] rdata;
        logic [31:0] rdata;
        logic [31:0] hwdata;
        logic        hwrite;
        int write_cnt;
        int read_cnt;
        fork 
            event e_wr;
            event e_rd;
            semaphore sm_wr;
            semaphore sm_rd;
            sm_wr = new(1);
            sm_rd = new(1);
            forever begin  
                @(e_rd); 
                rdata = read_mirror_memory(haddr, hsize);
                this.rdata.push_back( rdata ); 
                while(1) begin
                    sm_rd.get(1);
                    @(this.sramc_if_mm.mirror_memory_cb);
                    sm_rd.put(1);
                    if (this.sramc_if_mm.hready) begin
                        $display("@%t: Info , mirrormemory, No.%d, mirrormemory data is %h! haddr is %h! hsize is %b! hrdata is %h!", $time, read_cnt, rdata, haddr, hsize, this.mirror_memory[haddr[31:2]]);
                        read_cnt++;
                        break;
                    end
                 end
            end 

            forever begin 
                @(e_wr); 
                $display("@%t: Info , mirrormemory, No.%d, hwrite=%b, haddr=%h, hsize=%b!", $time, write_cnt, hwrite, haddr, hsize);
                sm_wr.get(1);
                @(this.sramc_if_mm.mirror_memory_cb);
                sm_wr.put(1);
                hwdata = this.sramc_if_mm.hwdata;
                write_mirror_memory(haddr, hsize, hwdata);
                $display("@%t: Info , mirrormemory, No.%d, send hwdata=%h!", $time, write_cnt, hwdata); 
                write_cnt++;
            end

            forever begin 
                if(this.sramc_if_mm.hready && this.sramc_if_mm.hsel && this.sramc_if_mm.htrans[1]) begin
                    haddr = this.sramc_if_mm.haddr;
                    hsize = this.sramc_if_mm.hsize;
                    hwrite = this.sramc_if_mm.hwrite;
                    if (hwrite) 
                        ->e_wr;
                    else
                        ->e_rd;
                end
                @(this.sramc_if_mm.mirror_memory_cb);
                sm_wr.get(1); sm_rd.get(1);
                sm_wr.put(1); sm_rd.put(1);
            end
        join
    endtask
    function void write_mirror_memory(input logic [31:0] haddr, input logic [1:0] hsize, input logic [31:0] hwdata);
        case (hsize)
            2'b00: case(haddr[1:0]) 
                2'b00: this.mirror_memory[haddr[31:2]][ 7: 0] = hwdata;
                2'b01: this.mirror_memory[haddr[31:2]][15: 8] = hwdata;
                2'b10: this.mirror_memory[haddr[31:2]][23:16] = hwdata;
                2'b11: this.mirror_memory[haddr[31:2]][31:24] = hwdata;
            endcase
            2'b01: case(haddr[1])
                1'b0: this.mirror_memory[haddr[31:2]][15: 0] = hwdata;
                1'b1: this.mirror_memory[haddr[31:2]][31:16] = hwdata;
            endcase
            default: this.mirror_memory[haddr[31:2]][31: 0] = hwdata;
        endcase
    endfunction
    function logic [31:0] read_mirror_memory(input logic [31:0] haddr, input logic [1:0] hsize);
        logic [31:0] hrdata;
        case (hsize)
            2'b00: case(haddr[1:0]) 
                2'b00: hrdata = this.mirror_memory[haddr[31:2]][ 7: 0];
                2'b01: hrdata = this.mirror_memory[haddr[31:2]][15: 8];
                2'b10: hrdata = this.mirror_memory[haddr[31:2]][23:16];
                2'b11: hrdata = this.mirror_memory[haddr[31:2]][31:24];
            endcase
            2'b01: case(haddr[1])
                1'b0: hrdata = this.mirror_memory[haddr[31:2]][15: 0];
                1'b1: hrdata = this.mirror_memory[haddr[31:2]][31:16];
            endcase
            default: hrdata = this.mirror_memory[haddr[31:2]][31: 0];
        endcase
        read_mirror_memory = hrdata;
    endfunction
endclass

class ScoreBoard; //parrallel with AhbDrv
    virtual SramcIf.score_board sramc_if_sb;
    function new(virtual SramcIf.score_board sramc_if_sb);
        this.sramc_if_sb         = sramc_if_sb;
    endfunction
    task start_run (ref AhbRecevier ahb_receiver, ref MirrorMemory mirror_memory);  
        int cnt;
        logic [31:0] rdata_receive;
        logic [31:0] rdata_mirror;
        forever @(posedge this.sramc_if_sb.hclk) begin
            if (ahb_receiver.rdata.size()!=0 && mirror_memory.rdata.size()!=0) begin
                rdata_receive = ahb_receiver.rdata.pop_front();
                rdata_mirror  = mirror_memory.rdata.pop_front();
                if ( rdata_mirror === rdata_receive) begin
                    $display("@%t: Info , score_board , No.%d, rdata match, rdata_receive is %h, rdata_mirror is %h!", $time, cnt, rdata_receive, rdata_mirror);
                end
                else 
                    $display("@%t: Error, score_board , No.%d, rdata no match, rdata_receive is %h, rdata_mirror is %h!", $time, cnt, rdata_receive, rdata_mirror);
                cnt++;
            end
        end
    endtask
endclass
