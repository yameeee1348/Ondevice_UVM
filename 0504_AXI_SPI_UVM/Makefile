#VCS_OPTS := -full64 -sverilog -ntb_opts uvm-1.2 -timescale=1ns/1ps -debug_access+all -kdb -lca

# 💡 1. 기본 실행 테스트 이름을 axi_spi_sanity_test로 변경
TC ?= axi_spi_sanity_test
SEED ?= 1234

VCS_OPTS := -full64 -sverilog
VCS_OPTS += -ntb_opts uvm-1.2 
VCS_OPTS += -timescale=1ns/1ps
VCS_OPTS += -debug_access+all -kdb -lca
VCS_OPTS += +incdir+tb
VCS_OPTS += -cm line+cond+fsm+tgl+branch+assert

SIM_OPTS := +UVM_VERBOSITY=UVM_HIGH
SIM_OPTS += +ntb_random_seed=$(SEED)
SIM_OPTS += +UVM_TESTNAME=$(TC)
SIM_OPTS += -cm line+cond+fsm+tgl+branch+assert
SIM_OPTS += -cm_dir coverage.vdb
SIM_OPTS += -cm_name sim1

# 💡 2. fsdb 파일 이름을 tb_top.sv에 맞게 axi_spi_test.fsdb로 변경
VERDI_OPTS := -covdir coverage.vdb -dbdir simv.daidir -ssf axi_spi_test.fsdb

.PHONY: compile sim vw vc verdi clean

compile:
	vcs $(VCS_OPTS) -f filelist.f -o simv
	@echo "vcs 컴파일 완료!"

sim: compile
	# 💡 3. 로그 파일 이름도 axi_spi_sim.log로 변경
	./simv $(SIM_OPTS) | tee axi_spi_sim.log

vw: sim
	# 💡 4. navas.fsdb 오타 수정 및 최신 fsdb 이름으로 변경
	verdi -dbdir simv.daidir -ssf axi_spi_test.fsdb &

vc: sim
	verdi -cov -covdir coverage.vdb &

verdi:
	verdi $(VERDI_OPTS) &

clean:
	rm -rf simv* csrc *.key *.h *.log *.fsdb novas* *.conf *.LOG coverage.* vdCovLog verdiLog *.xml ucli.key
	@echo "결과물 정리 완료!"