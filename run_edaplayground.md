# Running on EDA Playground

1. Go to https://www.edaplayground.com/
2. Create two files in the left-hand editor pane:
   - `synchronous_fifo.sv` → paste contents of `rtl/synchronous_fifo.sv`
   - `synchronous_fifo_tb.sv` → paste contents of `tb/synchronous_fifo_tb.sv`
3. Select a SystemVerilog-capable simulator from the dropdown, e.g.:
   - **Aldec Riviera-PRO** (free tier available)
   - Synopsys VCS / Cadence Xcelium (if you have institutional access)
   - Icarus Verilog (open source, matches local `make run` results)
4. Check **"Open EPWave after run"** to view the waveform directly in the
   browser (equivalent to `dump.vcd` + GTKWave locally).
5. Click **Run**.

No special compile flags are required — the design uses standard
SystemVerilog-2012 syntax (`always_ff`, `logic`, parameterized modules,
`automatic` tasks) supported by all major simulators.
