#vcs -full64 -sverilog -debug_access+all -kdb -lca -ntb_opts uvm-1.2 -timescale=1ns/1ps -o simv ./rtl/counter.sv ./tb/tb_counter.sv
TC ?= counter_test
SEED ?= 1234


VCS_OPTS := -full64 -sverilog -ntb_opts uvm-1.2 -timescale=1ns/1ps -debug_access+all -kdb -lca
VCS_OPTS += -timescale=1ns/1ps
VCS_OPTS += -debug_access+all -kdb -lca
VCS_OPTS += -cm line+cond+fsm+tgl+branch+assert

SIM_OPTS := +UVM_TESTNAME=$(TC)
SIM_OPTS += +UVM_VERBOSITY=UVM_MEDIUM
SIM_OPTS += +ntb_random_seed=$(SEED)
SIM_OPTS += -cm line+cond+fsm+tgl+branch+assert
SIM_OPTS += -cm_dir coverage.vdb
SIM_OPTS += -cm_name sim1

.PHONY: compile sim clean simv


compile:
	vcs $(VCS_OPTS) -f filelist.f -o simv
#vcs -full64 -sverilog -ntb_opts uvm-1.2 -timescale=1ns/1ps -debug_access+all -kdb -lca -f filelist.f
#echo "vcs 컴파일 실행중..."
	@echo "타겟 [$@] 완료"

sim: compile
	./simv $(SIM_OPTS) 
#./simv +UVM_TESTNAME=counter_test +UVM_VERBOSITY=UVM_LOW
#echo "시뮬레이션 실행중..."
	@echo "의존타겟 [$<] 완료"
	@echo "타겟 [$@] 완료"


clean:
	rm -rf simv* csrc *.key *.h *.log
	@echo "결과물 정리중..."



