# Ondevice UVM Verification Portfolio

SystemVerilog/UVM 기반 IP 검증 학습 및 프로젝트 산출물을 정리한 저장소입니다. RAM, APB RAM, UART, SPI, I2C, AXI4-Lite SPI IP, OV7670 카메라 파이프라인까지 단계적으로 DUT 범위를 넓히며 동일한 UVM 구조(sequence, driver, monitor, scoreboard, coverage)를 반복 적용했습니다.


## Core Skills

- SystemVerilog testbench
- UVM 1.2 component 구조화: sequence item, sequence, driver, monitor, agent, env, scoreboard, coverage, test 
- constrained/random test, mode sweep, corner/stress test 구성
- scoreboard reference model 및 queue 기반 expected/actual 비교
- functional coverage, cross coverage, VCS coverage 옵션 사용
- Verdi waveform/coverage 디버깅
- SPI, I2C, UART, APB, AXI4-Lite interface 검증
- OV7670 SCCB 초기화, frame buffer write/read, 320x240 to 640x480 upscale path 검증

## Project Map

| Directory | DUT / Goal | Verification Focus | First Files To Read |
| --- | --- | --- | --- |
| `0409_ram/` | 256-depth, 16-bit RAM | write/read sequence, random access, full address sweep, reference memory scoreboard | `rtl/ram.sv`, `tb/ram_sequence.sv`, `tb/ram_scoreboard.sv`, `tb/ram_coverage.sv` |
| `0410_APB_RAM/` | APB slave RAM | APB write/read transaction, address/read-write cross coverage, APB reference model | `rtl/apb_ram.sv`, `tb/apb_ram_sequence.sv`, `tb/apb_ram_scoreboard.sv`, `tb/apb_ram_coverage.sv` |
| `0410_uart_hw/` | UART TX/RX with FIFO | pattern/random byte transfer, expected queue comparison, UART data coverage | `rtl/uart.sv`, `rtl/uart_tx.sv`, `rtl/uart_rx.sv`, `tb/uart_scoreboard.sv` |
| `0416_SPI_fnd_UVM/` | SPI master/slave core | CPOL/CPHA mode sweep, data match coverage, master-to-slave and slave-to-master comparison | `rtl/SPI_core_top.sv`, `tb/spi_sequence.sv`, `tb/spi_scoreboard.sv`, `tb/spi_coverage.sv` |
| `0418_I2C_led_UVM/` | I2C master/slave core | write/read operation randomization, separate expected queues, read/write-data cross coverage | `rtl/I2C_core_top.sv`, `tb/I2C_sequence.sv`, `tb/I2C_scoreboard.sv`, `tb/I2C_coverage.sv` |
| `0504_AXI_SPI_UVM/` | AXI4-Lite SPI master IP | register-driven SPI transaction, CPOL/CPHA/CLK_DIV coverage, sanity/mode/stress/corner/regression tests | `rtl/axi_spi_m_v1_0_S00_AXI.v`, `tb/axi_spi_pkg.sv`, `tb/axi_spi_sequence.sv`, `tb/axi_spi_scoreboard.sv` |
| `0716_CAM_UVM/` | OV7670 camera setting and framebuffer path | SCCB register initialization, camera pixel capture, write address sequencing, framebuffer read/upscale comparison, camera-specific coverage | `rtl/CAM_Set.sv`, `rtl/OV7670_Controller.sv`, `tb/cam_set_sequence.sv`, `tb/cam_set_scoreboard.sv`, `tb/cam_set_coverage.sv` |

## Common UVM Structure

Most projects follow this layout:

```text
<project>/
  rtl/                 DUT source files
  tb/
    *_interface.sv     clock/reset and DUT signal bundle
    *_item.sv          transaction fields and random constraints
    *_sequence.sv      scenario generation
    *_driver.sv        transaction-to-pin driving
    *_monitor.sv       pin-to-transaction sampling
    *_scoreboard.sv    expected/actual comparison
    *_coverage.sv      functional coverage model
    *_agent.sv         driver/monitor/sequencer integration
    *_env.sv           agent, scoreboard, coverage integration
    *_test.sv          selectable UVM tests
    tb_*.sv            top-level testbench
  filelist.f           compile order
  Makefile             VCS/Verdi run targets
```

## Running Simulations

The Makefiles assume a Linux-like EDA environment with Synopsys VCS, UVM 1.2, and Verdi installed.

```bash
cd 0504_AXI_SPI_UVM
make sim TC=axi_spi_regression_test SEED=1234
make verdi
make vc

cd ../0716_CAM_UVM
make regression SEED=1234
make coverage
```

Each directory defines its own default `TC` and supported test classes. Useful examples include:

- `ram_write_read_test`, `ram_full_sweep_test`, `ram_random_test`
- `apb_write_read_test`, `apb_rand_test`
- `uart_pattern_test`, `uart_rand_test`
- `spi_sanity_test`, `spi_mode_sweep_test`, `spi_stress_test`
- `I2C_pattern_test`, `I2C_rand_test`
- `axi_spi_sanity_test`, `axi_spi_mode_sweep_test`, `axi_spi_stress_test`, `axi_spi_corner_test`, `axi_spi_regression_test`
- `cam_set_sanity_test`, `cam_set_full_frame_test`, `cam_set_random_test`, `cam_set_sccb_init_test`, `cam_set_integration_test`, `cam_set_regression_test`

## Interviewer Guide

If time is short, review the repository in this order:

1. `0504_AXI_SPI_UVM/` - most complete register-level verification example. It connects AXI4-Lite registers to an SPI master and verifies mode/data behavior through reusable UVM components.
2. `0716_CAM_UVM/` - newest camera pipeline example. It verifies OV7670 SCCB initialization, RGB565 pixel capture, framebuffer writes, and 2x upscale readback with a reference-memory scoreboard.
3. `0418_I2C_led_UVM/` - shows read/write transaction separation and expected queue handling for bidirectional protocol behavior.
4. `0416_SPI_fnd_UVM/` - focuses on SPI timing modes and CPOL/CPHA cross coverage.
5. `0410_APB_RAM/` - compact APB example that makes the scoreboard and coverage style easy to inspect.

## Generated Files

`vdCovLog/`, `vc_hdrs.h`, `vdCov.conf`, `*.fsdb`, `simv*`, `coverage.vdb`, and `verdiLog/` are simulator or waveform/coverage artifacts. The main review targets are the `rtl/`, `tb/`, `filelist.f`, and `Makefile` files in each project.
