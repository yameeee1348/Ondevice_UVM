# ==========================================
# 1. Xilinx AXI VIP & System Files
# (주의: Vivado 버전에 따라 VIP 패키지 경로를 추가해야 할 수 있습니다)
# ==========================================
# 예시: /opt/Xilinx/Vivado/2023.1/data/xilinx_vip/hdl/axi_vip_pkg.sv
# 예시: ./ip/my_axi_vip/sim/my_axi_vip_pkg.sv

# ==========================================
# 2. RTL Files (새로운 AXI-SPI IP + 더미 슬레이브)
# ==========================================
./rtl/axi_spi_m_v1_0.v
./rtl/axi_spi_m_v1_0_S00_AXI.v
./rtl/SPI_slave.sv

# ==========================================
# 3. Testbench Files
# ==========================================
./tb/axi_spi_interface.sv
./tb/tb_top.sv

# (나머지 axi_spi_*.sv 클래스 파일들은 tb_top.sv에서 include 하므로 생략합니다!)