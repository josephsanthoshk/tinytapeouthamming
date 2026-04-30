# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_project(dut):

    dut._log.info("Start")

    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0

    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1


    # -------------------------
    # ENCODE TEST
    # -------------------------

    dut._log.info("Encode test")

    data = 0b1011
    mode = 0

    dut.ui_in.value = (mode << 7) | data

    await ClockCycles(dut.clk, 1)

    encoded = int(dut.uo_out.value) & 0x7F
    dut._log.info(f"Encoded codeword = {encoded:07b}")


    # -------------------------
    # DECODE TEST
    # -------------------------

    dut._log.info("Decode test")

    error_code = encoded ^ (1 << 2)  # flip bit 3

    mode = 1
    dut.ui_in.value = (mode << 7) | error_code

    await ClockCycles(dut.clk, 1)

    corrected = int(dut.uo_out.value) & 0x7F
    error_flag = (int(dut.uo_out.value) >> 7) & 1

    dut._log.info(f"Corrected codeword = {corrected:07b}")

    assert error_flag == 1
