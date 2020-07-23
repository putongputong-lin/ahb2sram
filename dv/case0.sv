program case0(SramcIf u_sramc_if);
    `include "sramc_dv_class.sv"
    task AhbDriver::load_tr;
        tr.input_tr(1'b1, 32'h0, 2'b10, 32'h5a5a5a5a);
        tr.input_tr(1'b0, 32'h0, 2'b10, 32'h0   );
        tr.input_tr(1'b1, 32'h0, 2'b10, 32'ha5a5a5a5);
        tr.input_tr(1'b0, 32'h0, 2'b10, 32'h0   );
        tr.input_tr(1'b1, 32'd65532, 2'b10, 32'h5a5a5a5a);
        tr.input_tr(1'b0, 32'd65532, 2'b10, 32'h0   );
        tr.input_tr(1'b1, 32'd65532, 2'b10, 32'ha5a5a5a5);
        tr.input_tr(1'b0, 32'd65532, 2'b10, 32'h0   );
      //tr.input_tr(1'b1, 32'd65536, 2'b10, 32'h5a5a5a5a);
      //tr.input_tr(1'b0, 32'd65536, 2'b10, 32'h0   );
      //tr.input_tr(1'b1, 32'd65536, 2'b10, 32'ha5a5a5a5);
      //tr.input_tr(1'b0, 32'd65536, 2'b10, 32'h0   );
        tr.random_tr(100000);
      //tr.input_tr(1'b1, 32'h1, 2'b10, 32'h5a5a);
      //tr.input_tr(1'b0, 32'h1, 2'b10, 32'h0   );
    endtask

    AhbDriver    ahb_driver;
    AhbRecevier  ahb_receiver;
    MirrorMemory mirror_memory;
    ScoreBoard   score_board;  

    initial begin
        fork 
            ahb_driver=new(u_sramc_if);
            ahb_receiver=new(u_sramc_if);
            mirror_memory=new(u_sramc_if);
            score_board=new(u_sramc_if);  
        join
        ahb_driver.drive_init();
        ahb_driver.load_tr();
        fork
            ahb_driver.drive_tr();
            ahb_receiver.receive_data();
            mirror_memory.start_run();
            score_board.start_run(ahb_receiver, mirror_memory);
        join
    end
endprogram
