TC   ?= cam_set_sanity_test
SEED ?= 1234
FSDB ?= cam_set_test.fsdb
VDB  ?= coverage.vdb

VCS_OPTS := -full64 -sverilog
VCS_OPTS += -ntb_opts uvm-1.2
VCS_OPTS += -timescale=1ns/1ps
VCS_OPTS += -debug_access+all -kdb -lca
VCS_OPTS += +incdir+./tb
VCS_OPTS += +define+FSDB
VCS_OPTS += -cm line+cond+fsm+tgl+branch+assert

SIM_OPTS := +UVM_TESTNAME=$(TC)
SIM_OPTS += +UVM_VERBOSITY=UVM_MEDIUM
SIM_OPTS += +ntb_random_seed=$(SEED)
SIM_OPTS += -cm line+cond+fsm+tgl+branch+assert
SIM_OPTS += -cm_dir $(VDB)
SIM_OPTS += -cm_name $(TC)_$(SEED)

VERDI_OPTS := -dbdir simv.daidir -ssf $(FSDB)

.PHONY: compile sim sanity full random sccb integration regression verdi coverage clean

compile:
	vcs $(VCS_OPTS) -f filelist.f -o simv -l compile.log

sim: compile
	./simv $(SIM_OPTS) -l cam_set_sim.log

sanity:
	$(MAKE) sim TC=cam_set_sanity_test

full:
	$(MAKE) sim TC=cam_set_full_frame_test

random:
	$(MAKE) sim TC=cam_set_random_test

sccb:
	$(MAKE) sim TC=cam_set_sccb_init_test

integration:
	$(MAKE) sim TC=cam_set_integration_test

regression:
	$(MAKE) sim TC=cam_set_regression_test

verdi:
	@test -f $(FSDB) || { echo "ERROR: $(FSDB) not found. Run make sim or make sccb first."; exit 1; }
	verdi $(VERDI_OPTS) &

coverage:
	@test -d $(VDB) || { echo "ERROR: $(VDB) not found. Run a test first."; exit 1; }
	verdi -cov -covdir $(VDB) &

clean:
	rm -rf simv simv.daidir simv.vdb csrc $(VDB) *.log *.key *.h *.fsdb \
	       novas* verdiLog vdCovLog ucli.key *.xml
