# Token Queue System with Metastability Handling

A digital token queue management system implemented in Verilog, featuring FIFO-based queue control, 2-FF metastability synchronization, and 7-segment display output.

---

## Overview

This project implements a hardware token generator and queue controller — the kind of system used in banks, hospitals, and service counters to manage numbered tokens. Tokens are issued on request, queued in a FIFO buffer, and the current serving token is displayed on a 7-segment display.

The design handles the real-world challenge of **metastability** that arises when asynchronous button inputs cross clock domains, resolved using a 2-flip-flop synchronizer chain.

---

## Architecture

```
 Button Input
     │
     ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  2-FF Sync  │────▶│ FIFO Queue  │────▶│  7-Seg      │
│ (Metastab.) │     │ Controller  │     │  Display    │
└─────────────┘     └─────────────┘     └─────────────┘
                          │
                    ┌─────┴─────┐
                    │  Token    │
                    │ Generator │
                    └───────────┘
```

**Modules:**
| Module | Description |
|---|---|
| `token_generator` | Issues sequential token numbers on request |
| `fifo_queue` | Stores pending tokens in a circular FIFO buffer |
| `sync_2ff` | 2-flip-flop synchronizer for async button inputs |
| `seg7_display` | Drives 7-segment display with current token number |
| `top` | Top-level integration module |

---

## Key Concepts

### FIFO Queue
- Circular buffer design with separate read/write pointers
- Full/empty status flags to prevent overflow and underflow
- Parameterizable depth

### Metastability Handling
Asynchronous button presses (issue token / serve next) are synchronized into the system clock domain using a **2-flip-flop synchronizer**, preventing setup/hold violations from propagating into the queue logic.

```
Async Input ──▶ [DFF1] ──▶ [DFF2] ──▶ Stable Synchronized Signal
                  clk         clk
```

### 7-Segment Display
The currently-served token number is decoded and driven onto a 7-segment display, supporting values 0–99.

---

## Simulation

Verified using ModelSim / iVerilog. The testbench covers:
- Token issuance sequence
- Queue full condition (overflow prevention)
- Queue empty condition (underflow prevention)
- Metastability synchronizer timing

**To simulate:**
```bash
iverilog -o token_sim top.v token_generator.v fifo_queue.v sync_2ff.v seg7_display.v tb_top.v
vvp token_sim
```

---

## Tools

- **Language:** Verilog (RTL)
- **Simulation:** ModelSim / iVerilog
- **Synthesis target:** FPGA-ready (simulation only, no board-specific constraints)

---

## Future Improvements

- Add UART output for logging served tokens
- Extend display to 3-digit tokens (0–999)
- Implement priority queue variant for VIP tokens
- Add reset and flush controls

---

## Author

**Narendra Setty** — ECE Student | VLSI & Digital Design  
[LinkedIn](https://www.linkedin.com/in/narendrasetty-vlsi) · [GitHub](https://github.com/Narendra-setty)
