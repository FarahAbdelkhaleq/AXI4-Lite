# AXI4-Lite Master–Slave (Verilog)

A simple AXI4-Lite interconnect: a **Master** that turns a `write_flag` / `read_flag` request into AXI4-Lite channel handshakes, and a **Slave** that implements a small 32-register memory. `Top.v` wires them together; `AXI4_lite_tb.v` drives write/read tests.

## Files
| File | Role |
|---|---|
| `Master.v` | Converts simple `write_start`/`read_start` requests into AXI4-Lite master-side handshakes |
| `Slave.v` | AXI4-Lite slave with a 32 x 32-bit register file |
| `Top.v` | Connects Master and Slave |
| `AXI4_lite_tb.v` | Testbench: issues writes then reads and checks the data |

## The Two Transactions

AXI4-Lite has five independent channels: **AW** (write address), **W** (write data), **B** (write response), **AR** (read address), **R** (read data). Every channel uses the same handshake rule: **data transfers on the clock edge where both VALID and READY are high.**

### 1. Write Transaction
Triggered by `write_flag = 1` (with `WADDR_in`, `WDATA_in`, `WSTRB`).

```
Master                         Slave
  |--- AWADDR, AWVALID  ------->|   (1) send write address
  |<-------------- AWREADY -----|
  |--- WDATA, WSTRB, WVALID --->|   (2) send write data
  |<--------------- WREADY -----|
  |                              |   (3) slave writes register[AWADDR]
  |<--- BRESP, BVALID -----------|   (4) slave sends write response
  |--- BREADY ------------------>|
```
1. **AW channel** – Master drives `M_AWADDR`/`M_AWVALID`; Slave asserts `S_AWREADY` and latches the address.
2. **W channel** – Master drives `M_WDATA`/`M_WSTRB`/`M_WVALID`; when Slave asserts `S_WREADY`, it writes the byte lanes selected by `WSTRB` into `register[WADDR]`.
3. **B channel** – Slave raises `S_BVALID` with `S_BRESP = OKAY (2'b11)`; Master acknowledges with `M_BREADY`. This completes the write.

### 2. Read Transaction
Triggered by `read_flag = 1` (with `RADDR_in`).

```
Master                         Slave
  |--- ARADDR, ARVALID  ------->|   (1) send read address
  |<-------------- ARREADY -----|
  |                              |   (2) slave fetches register[ARADDR]
  |<--- RDATA, RRESP, RVALID ----|   (3) slave returns data
  |--- RREADY ------------------>|
```
1. **AR channel** – Master drives `M_ARADDR`/`M_ARVALID`; Slave asserts `S_ARREADY` and latches the address.
2. **R channel** – Slave puts `register[ARADDR]` on `S_RDATA` with `S_RRESP = OKAY` and raises `S_RVALID`; Master asserts `M_RREADY` and captures the data into `RDATA_out`.

## Master FSM
`IDLE → WADDR_CHANNEL → WRITE_CHANNEL → WRESP_CHANNEL → IDLE` (write)
`IDLE → RADDR_CHANNEL → RDATA_CHANNEL → IDLE` (read)

## Slave FSM
`IDLE → WADDR_CHANNEL → WDATA_CHANNEL → WRESP_CHANNEL → IDLE` (write)
`IDLE → RADDR_CHANNEL → RDATA_CHANNEL → IDLE` (read)

## Response Codes
Only `OKAY (2'b11)` is used — no error responses are generated (address is not range-checked beyond the 32-entry register file, `NO_REG = 32`).

## Testbench Flow (`AXI4_lite_tb.v`)
For each test case:
1. Assert `write_flag`, set `WADDR_in` / `WDATA_in` / `WSTRB`, wait for the write to complete.
2. Assert `read_flag`, set `RADDR_in`, wait for the read to complete.
3. Compare `RDATA_out` against the expected value and print `CORRECT` / `INCORRECT`.

Cases exercised: full-word write/read, single-byte write (`WSTRB = 4'b0001`), and writes/reads to several addresses (`0x2`, `0x5`, `0x8`).
