# CNN Dot-Product Accelerator (SystemVerilog)

A parameterized **CNN dot-product accelerator** implemented in **SystemVerilog**, using **parallel MAC (Multiply–Accumulate) arrays**.  
The design supports **windowed accumulation**, **valid-in / valid-out control**, and **pipelined output timing**, similar to real hardware accelerators used in CNNs.

---

## Architecture Overview

The accelerator computes a dot product of multiple input pairs in parallel:
(a0 × b0) + (a1 × b1) + (a2 × b2) + (a3 × b3)

### Key Blocks

- **MAC Unit (`mac.v`)**
  - Signed multiply–accumulate
  - Supports `clear` for windowed accumulation

- **MAC Array (`mac_array.v`)**
  - Parameterized number of MACs
  - Parallel accumulation using generate constructs
  - Registered dot-product output

- **Control Signals**
  - `start` → clears accumulators (new compute window)
  - `valid_in` → input data valid
  - `valid_out` → dot-product output valid (pipelined)

---

##  Dataflow & Timing

1. `start` pulse clears all MAC accumulators
2. `valid_in` asserted for one or more cycles
3. MACs accumulate products in parallel
4. Dot product is computed and registered
5. `valid_out` goes high **one cycle after `valid_in`**
6. Output remains stable when `valid_in` is deasserted (freeze behavior)

This models **real CNN accelerator pipelines**.

---

##  File Structure
.
├── mac.v # Signed MAC with clear control
├── mac_array.v # Parallel MAC array + dot-product logic
├── mac_array_4_tb.v # Testbench with windowed accumulation
└── README.md

---

##  Verification

- Simulated using **Icarus Verilog**
- Waveforms viewed in **GTKWave**
- Verified:
  - Signed arithmetic
  - Parallel MAC operation
  - Windowed accumulation
  - Pipelined valid control
  - Output freeze behavior

### Run Simulation

```bash
iverilog -g2012 -o mac_array_tb.vvp mac.v mac_array.v mac_array_4_tb.v
vvp mac_array_tb.vvp
gtkwave mac_array_4.vcd

## 🔍 4. Add **Unit Tests + Edge Case Tests**
Add more test vectors:

- All zeros
- Max positive and negative values
- Random vectors

This ensures the design is robust and shows real verification effort.

---

## 📊 5. Add a **Coverage Report**
If you move to SystemVerilog coverage (covergroups), you can add coverage percentages:

```systemverilog
covergroup cg @(posedge clk);
  coverpoint valid_in;
  coverpoint valid_out;
  coverpoint mac_out;
endgroup



