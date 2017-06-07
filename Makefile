all: clean compile sim

MODE ?= puresim
#MODE ?= veloce

VLOG = \
		hdl/definitions.sv \
		hdl/except.sv \
		hdl/post_norm.sv \
		hdl/pre_norm.sv \
		hdl/pre_norm_fmul.sv \
		hdl/primitives.sv \
		hdl/fpu_interface.sv \
		hdl/FpSqrt.sv \
		hdl/primitives.sv \
        hdl/fpu.sv \
        hdl/top.sv \

compile:
	vlib $(MODE)work
	vmap work $(MODE)work
	vlog -f $(VMW_HOME)/tbx/questa/hdl/scemi_pipes_sv_files.f
	vlog hdl/definitions.sv
	vlog hvl/fpu_hvl.sv 
ifeq ($(MODE),puresim)
	vlog $(VLOG)

else
	velanalyze $(VLOG)
	velcomp -top top
endif
	velhvl -sim $(MODE)


sim:
	vsim -c fpu_hvl top TbxSvManager +RUNS=100 +SIGNS=-+ -do "run -all" +tbxrun+"$(QUESTA_RUNTIME_OPTS)" -l output.log

clean:
	rm -rf work transcript vsim.wlf dpi.so modelsim.ini output.log result.TBX tbxsvlink.log
	rm -rf waves.wlf vsim_stacktrace.vstf sc_dpiheader.h hdl.* debussy.cfg  dmTclClient.log  partition.info 
	rm -rf tbxbindings.h  tbx.dir  tbx.map   veloce_c_transcript dmslogdir    ECTrace.log      Report.out      tbx.log  tbxsim.v  vlesim.log
	rm -rf multiplicand.txt multiplier.txt product.txt veloce.map velrunopts.ini edsenv veloce.log veloce.med veloce.wave velocework puresimwork 


