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


    # ------------------------
    # ENCODE TEST
    # ------------------------

    dut._log.info("Encode test")

    data = 0b1011

    dut.ui_in.value = data        # ui[3:0]
    dut.ui_in.value |= 0 << 7     # MODE = 0

    await ClockCycles(dut.clk, 1)

    encoded = dut.uo_out.value & 0x7F
    dut._log.info(f"Encoded word: {encoded}")



    # ------------------------
    # DECODE TEST (with error)
    # ------------------------

    dut._log.info("Decode test")

    error_code = encoded ^ (1 << 2)  # flip bit 3

    dut.ui_in.value = error_code
    dut.ui_in.value |= 1 << 7        # MODE = 1

    await ClockCycles(dut.clk, 1)

    corrected = dut.uo_out.value & 0x7F
    error_flag = (dut.uo_out.value >> 7) & 1

    dut._log.info(f"Corrected code: {corrected}")

    assert error_flag == 1
