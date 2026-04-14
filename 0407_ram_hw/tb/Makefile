VCS_OPTS := -full64 -sverilog -ntb_opts uvm-1.2 -timescale=1ns/1ps -debug_access+all -kdb -lca

.PHONY: compile sim clean

compile:
	vcs $(VCS_OPTS) -o simv ./rtl/ram.sv ./tb/tb_ram.sv
	@echo "vcs 컴파일 완료!"

sim: compile
	./simv +UVM_TESTNAME=ram_test +UVM_VERBOSITY=UVM_HIGH 

clean:
	rm -rf simv* csrc *.key *.h
	@echo "결과물 정리 완료!"