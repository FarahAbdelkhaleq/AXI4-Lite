module Top #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32
)(
    input ACLK,
    input ARESETn,

    input read_flag,
    input write_flag,

    input [DATA_WIDTH-1:0] WDATA_in,
    input [ADDR_WIDTH-1:0] RADDR_in,  
    input [ADDR_WIDTH-1:0] WADDR_in,

    input [DATA_WIDTH/8 -1:0] WSTRB,
    output [DATA_WIDTH-1:0] RDATA_out,
    output [1:0] WRESP_out, 
    output [1:0] RRESP_out
);   

    
    wire AWVALID;
    wire AWREADY;

    wire ARVALID;
    wire ARREADY;

    wire WVALID;
    wire WREADY;

    wire BREADY;
    wire BVALID;

    wire RREADY;
    wire RVALID;

    wire [DATA_WIDTH-1:0] M_RDATA;
    wire [ADDR_WIDTH-1:0] ARADDR;
    wire [ADDR_WIDTH-1:0] AWADDR;
    wire [DATA_WIDTH-1:0] WDATA;
    wire [DATA_WIDTH/8-1:0] WSTRB_wire; 

    wire [1:0] BRESP_wire;
    wire [1:0] RRESP_wire;

    Master #(
        .DATA_WIDTH (32),
        .ADDR_WIDTH (32)
    ) AXI_MASTER (
        .ACLK    (ACLK),
        .ARESETn (ARESETn),

        .read_start  (read_flag),
        .write_start (write_flag),

        .WDATA    (WDATA_in),
        .WADDR    (WADDR_in),
        .RADDR    (RADDR_in),
        .STROBE   (WSTRB),

        .RDATA   (RDATA_out),
        .M_RDATA (M_RDATA),

        .M_AWVALID (AWVALID),
        .M_AWREADY (AWREADY),
        .M_AWADDR  (AWADDR),

        .M_ARVALID (ARVALID),
        .M_ARREADY (ARREADY),
        .M_ARADDR  (ARADDR),

        .M_WVALID (WVALID),
        .M_WREADY (WREADY),
        .M_WDATA  (WDATA),

        .M_BREADY (BREADY),
        .M_BVALID (BVALID),

        .M_RREADY (RREADY),
        .M_RVALID (RVALID),

        .M_BRESP (BRESP_wire),
        .M_RRESP (RRESP_wire),
        .WRESP   (WRESP_out),
        .RRESP   (RRESP_out),
        .M_WSTRB (WSTRB_wire)
    );


    Slave #(
        .DATA_WIDTH (32),
        .ADDR_WIDTH (32)
    ) AXI_SLAVE (
        .ACLK    (ACLK),
        .ARESETn (ARESETn),
        .S_WDATA (WDATA),
        .S_RDATA (M_RDATA),

        .S_WSTRB (WSTRB_wire),

        .S_AWADDR  (AWADDR),
        .S_AWVALID (AWVALID),
        .S_AWREADY (AWREADY),

        .S_ARADDR  (ARADDR),
        .S_ARVALID (ARVALID),
        .S_ARREADY (ARREADY),

        .S_WVALID  (WVALID),
        .S_WREADY  (WREADY),

        .S_BREADY  (BREADY),
        .S_BVALID  (BVALID),

        .S_RREADY  (RREADY),
        .S_RVALID  (RVALID),

        .S_BRESP  (BRESP_wire),
        .S_RRESP  (RRESP_wire)
    );

endmodule