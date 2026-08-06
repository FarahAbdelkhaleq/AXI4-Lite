module Master #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32)
(
    input ACLK,
    input ARESETn,

    input read_start,
    input write_start,

    input [ADDR_WIDTH-1:0] WADDR,
    input [ADDR_WIDTH-1:0] RADDR,
    input [DATA_WIDTH-1:0] WDATA,
    input [DATA_WIDTH-1:0] M_RDATA,
    input [DATA_WIDTH/8 -1:0] STROBE,
    
    input [1:0] M_BRESP,
    input [1:0] M_RRESP,
 
    input  M_AWREADY,
    input  M_WREADY,
    input  M_RVALID,
    input  M_ARREADY,
    input  M_BVALID,

    output reg M_AWVALID,
    output reg M_WVALID,
    output reg M_ARVALID,
    output reg M_RREADY,
    output reg M_BREADY,

    output reg [1:0] WRESP,  
    output reg [1:0] RRESP,  

    output reg [ADDR_WIDTH-1:0]    M_AWADDR,
    output reg [DATA_WIDTH-1:0]    M_WDATA,
    output reg [DATA_WIDTH/8 -1:0] M_WSTRB,
    output reg [ADDR_WIDTH-1:0]    M_ARADDR,
    output reg [DATA_WIDTH-1:0]    RDATA
);

    localparam IDLE          = 3'b000;
    localparam WADDR_CHANNEL = 3'b001;
    localparam WRITE_CHANNEL = 3'b010;
    localparam WRESP_CHANNEL = 3'b011;
    localparam RADDR_CHANNEL = 3'b100;
    localparam RDATA_CHANNEL = 3'b101;
    
    reg DATA_READY;   
    reg ADDR_READY;  
    reg AD_READY;  
    
    reg [2:0] cs, ns;

    always @(posedge ACLK, negedge ARESETn) begin

        if(!ARESETn) cs <= IDLE;
         
        else         cs <= ns;
    end

    always @(*) begin
        ns = cs;
        case(cs)
            IDLE : begin
                if(write_start) ns = WADDR_CHANNEL;
                    
                else if(read_start) ns = RADDR_CHANNEL;
                    
                else ns = cs;          
            end

            WADDR_CHANNEL : if(ADDR_READY) ns = WRITE_CHANNEL;

            WRITE_CHANNEL : if(DATA_READY) ns = WRESP_CHANNEL;

            WRESP_CHANNEL :  if(WRESP == 2'b11) ns = IDLE;

            RADDR_CHANNEL : if(M_ARREADY && AD_READY) ns = RDATA_CHANNEL;

            RDATA_CHANNEL : if((RRESP == 2'b11) && M_RVALID)   ns = IDLE; 

            default : ns = IDLE;
        endcase
    end

    always @(posedge ACLK, negedge ARESETn) begin
        if(!ARESETn)begin
            M_ARADDR    <= 0;  
            M_AWADDR    <= 0;
            M_WDATA     <= 0;
            M_WSTRB     <= 0;
            M_AWVALID   <= 0;
            M_WVALID    <= 0;
            M_BREADY    <= 0;
            M_RREADY    <= 0;
            M_ARVALID   <= 0;
            ADDR_READY  <= 0;
            DATA_READY  <= 0;
            AD_READY    <= 0;
        end

        else begin
            case(cs)
                IDLE : begin
                    M_AWVALID  <= 0;
                    M_WVALID   <= 0;
                    M_BREADY   <= 0;
                    M_RREADY   <= 0;
                    M_ARVALID  <= 0;
                    RRESP      <= 0;
                    WRESP      <= 0;
                    ADDR_READY <= 0;
                    DATA_READY <= 0;
                    AD_READY   <= 0;
                end

                WADDR_CHANNEL : begin
                    M_AWADDR  <= WADDR;
                    M_AWVALID <= 1'b1;
                    if(M_AWREADY) ADDR_READY <=1'b1;
                end

                WRITE_CHANNEL : begin
                    M_WDATA     <= WDATA;
                    M_WSTRB     <= STROBE;
                    M_WVALID    <= 1'b1;
                    M_AWVALID   <= 1'b0;
                    ADDR_READY  <= 1'b0;
                    if(M_WREADY) DATA_READY <=1'b1;
                end

                WRESP_CHANNEL : begin
                    M_BREADY <= 1'b1;
                    M_WVALID   <= 1'b0;
                    if(M_BREADY)begin
                        WRESP <= M_BRESP;
                        DATA_READY <=1'b0;
                    end
                end

                RADDR_CHANNEL : begin
                    M_ARADDR  <= RADDR;
                    M_ARVALID <= 1'b1;
                    if(M_ARREADY) AD_READY <=1'b1;
                end

                RDATA_CHANNEL : begin
                    M_RREADY <= 1'b1;
                    if(M_RVALID && M_RREADY) begin
                        RDATA  <= M_RDATA;
                        RRESP  <= M_RRESP; 
                        AD_READY  <=1'b0;
                        M_ARVALID <= 1'b0;
                    end
                end

                default : ;
            endcase
        end
    end
endmodule