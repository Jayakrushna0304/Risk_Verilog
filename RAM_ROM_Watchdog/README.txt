DAY 2 - Q2.8: RAM, ROM AND WATCHDOG

Files:
- ram.v / ram_tb.v: 16 x 8 single-port synchronous RAM and testbench
- rom.v / rom_tb.v: 16 x 8 synchronous ROM and testbench
- rom.hex: initialization contents loaded by $readmemh
- watchdog.v / watchdog_tb.v: programmable watchdog and testbench

RAM:
- On a rising clock edge, writes data_in to mem[addr] when we=1.
- data_out is registered (synchronous read).

ROM:
- Loads 16 hexadecimal bytes from rom.hex at simulation start.
- data_out updates on the rising clock edge.

Watchdog:
- kick reloads the timeout counter.
- If no kick arrives before timeout, reset_pulse asserts for one clock.
- The testbench uses TIMEOUT_CYCLES=4 for a short simulation.

Run each testbench separately in ModelSim. Keep rom.hex in the current
working directory when running rom_tb.

RAM commands:
pwd
vlib work
vmap work work
vlog ram.v ram_tb.v
vsim work.ram_tb
add wave -r *
run -all
wave zoom full

ROM commands:
vlog rom.v rom_tb.v
vsim work.rom_tb
add wave -r *
run -all
wave zoom full

Watchdog commands:
vlog watchdog.v watchdog_tb.v
vsim work.watchdog_tb
add wave -r *
run -all
wave zoom full

If ModelSim reports that a module is already loaded, use:
restart -f
or start a fresh simulation with the relevant vsim command.
