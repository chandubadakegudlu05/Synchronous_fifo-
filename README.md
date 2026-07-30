# Synchronous FIFO (Parameterized) — SystemVerilog

A parameterizable synchronous FIFO (First-In-First-Out) buffer written in
SystemVerilog, with a self-checking-style testbench and full/empty flag
generation using the classic "extra MSB pointer" technique (Cummings-style,
as used in Sunburst Design's FIFO papers).

## Features

- Parameterizable **depth** (`fifo_depth`, must be a power of 2) and
  **data width** (`fifo_width`)
- Single clock domain (synchronous read/write)
- Active-low asynchronous reset
- `full` / `empty` flag generation without a separate counter, using one
  extra pointer bit (Gray-code-free, binary pointer comparison)
- Directed-test testbench covering:
  - Basic sequential write/read
  - Interleaved write/read
  - Fill-to-full and drain-to-empty (boundary condition / flag test)

## Repository Structure

```
synchronous-fifo/
├── README.md                      <- you are here
├── LICENSE
├── .gitignore
├── rtl/
│   └── synchronous_fifo.sv        <- DUT: synthesizable FIFO
├── tb/
│   └── synchronous_fifo_tb.sv     <- testbench
├── sim/
│   └── Makefile                   <- Icarus Verilog sim flow
├── docs/
│   └── design_doc.md              <- microarchitecture + verification notes
└── scripts/
    └── run_edaplayground.md       <- notes for running on EDA Playground
```

## Interface

| Signal     | Dir | Width          | Description                          |
|------------|-----|----------------|---------------------------------------|
| `clk`      | in  | 1              | System clock                          |
| `reset`    | in  | 1              | Active-low async reset                |
| `cs`       | in  | 1              | Chip select / enable                  |
| `wt_en`    | in  | 1              | Write enable                          |
| `rd_en`    | in  | 1              | Read enable                           |
| `data_in`  | in  | `fifo_width`   | Write data                            |
| `data_out` | out | `fifo_width`   | Read data (registered, 1-cycle latency)|
| `full`     | out | 1              | FIFO full flag                        |
| `empty`    | out | 1              | FIFO empty flag                       |

## Quick Start (Icarus Verilog)

```bash
cd sim
make run        # compiles and runs the testbench
make wave        # opens dump.vcd in GTKWave (requires gtkwave installed)
make clean
```

Verified with Icarus Verilog 12.0 — simulation completes at `$time = 800`
with all three test scenarios producing correct write/read data and
correct `full`/`empty` flag transitions.

## Simulation Results

Verified on two simulators:

- **Icarus Verilog 12.0** (local, using the cleaned-up TB in `tb/`) — see
  Quick Start above.
- **Synopsys VCS**, via [EDA Playground](https://www.edaplayground.com/x/GEZM)
  — waveform and console log captured below.

**Waveform** (`docs/waveform.png`):

![FIFO waveform](docs/waveform.png)

`data_in`/`data_out` step through Scenario 1 → 2 → 3 as expected, `empty`
is asserted whenever the pointers coincide, and `full` correctly asserts
during Scenario 3 once all 8 entries are written.

**Console output**: full log in [`docs/sim_output.log`](docs/sim_output.log).

> **Note on the EDA Playground run:** that log was captured with the
> original testbench, where each task's `$display` fires one clock edge
> *before* the read/write actually completes — so every printed
> `data_out` lags the true value by one call (first read prints `x`
> instead of `1`, and so on). This is a print-ordering artifact, not a
> functional bug — the waveform itself shows `data_out` updating with
> the correct values in the correct order. The testbench committed in
> `tb/synchronous_fifo_tb.sv` fixes the display ordering so printed
> values line up with the actual FIFO output (see the Quick Start output
> above, where `data_out` matches immediately).

## Design Notes

- `full` and `empty` are derived purely from comparing an
  `(fifo_depth_log + 1)`-bit write pointer and read pointer — no
  separate up/down counter is needed:
  - `empty` = pointers exactly equal
  - `full`  = pointers equal in all bits except the MSB
- Both write and read pointer/data-path logic use **non-blocking
  assignments** (`<=`) inside clocked `always_ff` blocks, consistent with
  standard RTL coding guidelines (mixing blocking/non-blocking in
  sequential logic is a common source of simulation/synthesis mismatch).
- `data_out` is registered — reads have 1-cycle latency after `rd_en`.

## Possible Extensions

- Add `almost_full` / `almost_empty` programmable thresholds
- Convert to an **asynchronous (dual-clock) FIFO** with Gray-coded
  pointers and 2-flop synchronizers for CDC
- Add SVA assertions (no write when full, no read when empty, pointer
  monotonicity) and a functional coverage model
- Wrap in a UVM environment (agent, scoreboard, coverage) for
  constrained-random verification

## Author

Chandu B V — Electronics and Telecommunication Engineering,
Dr. Ambedkar Institute of Technology, Bengaluru
