vcs:
	vcs -sverilog\
		+incdir+../dv\
		+incdir+../de\
		-f filelist/filelist_dv.sv\
		-debug_all\
		+define+CASE_FILE=\"case0.sv\"\
		-l compile.log\
		+define+CASE_INST="case0"\

sim:
	simv -ucli -i ucli_sramc.tcl\
		 +fsdb+autoflush\
	     -l sim.log

verdi:
	verdi -top tb_top\
		  +incdir+../dv\
		  +incdir+../de\
		  -sverilog\
		  +define+CASE_FILE=\"case0.sv\"\
		  +define+CASE_INST="case0"\
		  -ssf sramc_tb.fsdb\
		  -f filelist/filelist_dv.sv\
		  &
clean:
	ls \
	| grep -v makefile \
	| grep -v spyglass \
	| grep -v filelist \
	| grep -v ucli_sramc.tcl \
	| xargs -I {} rm {} -r
