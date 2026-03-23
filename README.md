# TokenGenerator
A Token Generator with Metastability using queue management System
# 🏷️ Token Queue System — FPGA / Digital Design

A hardware-based customer token queue system implemented in Verilog. Customers press a button to receive a numbered token; a teller presses another button to serve the next customer in line. Two seven-segment displays show the **current** token being served and the **next** token in queue.

---

## 📐 System Architecture

```
btn_get_token  ──►  token_generator  ──►  fifo_queue  ──►  seven_seg_driver  ──►  seg_next_token
                                              │
btn_next_customer  ─────────────────────────►│
                                              │
                                              └──►  current_token_reg  ──►  seven_seg_driver  ──►  seg_current_token
```

---

## 📁 Module Overview

### 1. `fifo_queue.v`
A synchronous FIFO queue with parameterizable width and depth.

| Parameter    | Default | Description                        |
|--------------|---------|------------------------------------|
| `DATA_WIDTH` | 4       | Bit-width of each stored word      |
| `DEPTH`      | 8       | Number of entries the FIFO can hold |
| `PTR_WIDTH`  | 3       | Address bits (2³ = 8 entries)      |

**Key design detail:** Uses the classic **extra MSB pointer trick** to distinguish full vs. empty — same low-order address bits but differing MSB means full; identical full pointer means empty.

---

### 2. `token_generator.v`
Generates a new 4-bit token number each time the customer button is pressed.

- Includes a **2-flop synchronizer** to prevent metastability
- Detects rising edge of button to produce a **single-cycle pulse**
- Token counter runs from `1` to `15`, wrapping back to `1`
- Outputs `new_token_valid` (1-cycle high) and `new_token_value`

---

### 3. `seven_seg_driver.v`
Combinational 4-bit to 7-segment decoder.

- Supports hex digits `0–F`
- **Active-low** encoding in `gfedcba` bit order
- `default` case turns all segments off

---

### 4. `queue_system_top.v`
Top-level glue module wiring all submodules together.

- Debounces the **teller button** (same 2-flop + edge-detect pattern)
- Controls FIFO write/read enables with guard conditions:
  - Write only when `new_token_valid && !fifo_full`
  - Read only when `btn_next_pulse && !fifo_empty`
- Latches `fifo_dout` into `current_token_reg` on each read
- Drives both seven-segment displays:
  - `seg_current_token` — token currently being served
  - `seg_next_token` — next token at head of queue (shows `0` if empty)

---

## 🔌 Top-Level Port Map

| Port                | Direction | Width | Description                        |
|---------------------|-----------|-------|------------------------------------|
| `clk`               | Input     | 1     | System clock                       |
| `rst_n`             | Input     | 1     | Active-low asynchronous reset      |
| `btn_get_token`     | Input     | 1     | Customer button (get a token)      |
| `btn_next_customer` | Input     | 1     | Teller button (serve next)         |
| `seg_current_token` | Output    | 7     | 7-segment: "Now Serving"           |
| `seg_next_token`    | Output    | 7     | 7-segment: "Next in Queue"         |

---

## 🚀 Getting Started

### Prerequisites
- Verilog simulator: [ModelSim](https://www.intel.com/content/www/us/en/software/programmable/quartus-prime/model-sim.html), [Icarus Verilog](http://iverilog.icarus.com/), or [Verilator](https://www.veripool.org/verilator/)
- (Optional) FPGA toolchain: Xilinx Vivado or Intel Quartus

### Simulate with Icarus Verilog
```bash
# Compile all modules
iverilog -o queue_sim \
  fifo_queue.v \
  token_generator.v \
  seven_seg_driver.v \
  queue_system_top.v \
  tb_queue_system_top.v

# Run simulation
vvp queue_sim

# View waveforms (requires GTKWave)
gtkwave dump.vcd
```

### Synthesize for FPGA
1. Add all `.v` files to your Quartus / Vivado project
2. Set `queue_system_top` as the **top-level entity**
3. Assign pins:
   - `clk` → oscillator pin
   - `rst_n` → push-button (active low)
   - `btn_get_token` → push-button
   - `btn_next_customer` → push-button
   - `seg_current_token[6:0]` → 7-segment display 1
   - `seg_next_token[6:0]` → 7-segment display 2
4. Run Synthesis → Implementation → Generate Bitstream → Program

---

## ⚠️ Known Limitations / Notes

- **Token drop on full queue:** If a customer presses the button while the FIFO is full, the token is silently discarded. No overflow indicator is currently implemented.
- **Combinational read:** `dout` from the FIFO is combinational — be aware of timing if adding registered output stages.
- **No gray-code pointers:** Pointers are binary; this design is for a single-clock-domain system only. Do not use across asynchronous clock domains without modification.
- **Active-low display:** Confirm `seven_seg_driver` bit order matches your physical board's segment wiring.

---

## 🤝 Contributing

Contributions are welcome! To contribute:

1. **Fork** this repository
2. Create a new branch: `git checkout -b feature/your-feature-name`
3. Commit your changes: `git commit -m "Add: description of change"`
4. Push to your branch: `git push origin feature/your-feature-name`
5. Open a **Pull Request** with a clear description

Please ensure your Verilog follows consistent formatting and includes comments for any new modules.

---

## 📄 License

This project is open source. See (LICENSE) for details.
