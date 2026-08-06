module Slave #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32
)(
    input ACLK, 
    input ARESETn,

    input [ADDR_WIDTH-1:0] S_AWADDR,
    input [DATA_WIDTH-1:0] S_WDATA,
    input [ADDR_WIDTH-1:0] S_ARADDR,
    input [DATA_WIDTH/8-1:0] S_WSTRB,

    input S_WVALID,  
    input S_BREADY,
    input S_RREADY,
    input S_ARVALID,
    input S_AWVALID,
    
    output reg S_AWREADY,
    output reg S_WREADY, 
    output reg S_BVALID,
    output reg S_RVALID,
    output reg S_ARREADY,
    output reg [1:0] S_BRESP,
    output reg [1:0] S_RRESP,

    output reg [DATA_WIDTH-1:0] S_RDATA 
    
);
    localparam OKAY              = 2'b11;
    localparam NO_REG            = 32;
   
    localparam IDLE              = 3'b000;
    localparam WADDR_CHANNEL     = 3'b001;
    localparam WDATA_CHANNEL     = 3'b010;
    localparam WRESP_CHANNEL     = 3'b011;
    localparam RADDR_CHANNEL     = 3'b100;
    localparam RDATA_CHANNEL     = 3'b101;
   
    reg [ADDR_WIDTH-1:0] WADDR; 
    reg [ADDR_WIDTH-1:0] RADDR;
   
    reg [2:0] cs ,ns;
    reg [1:0] RESP;

    reg [DATA_WIDTH-1:0] register [0:NO_REG-1];
    
    reg WDATA_DONE;
    reg RESP_DONE; 
    reg ADDR_DONE; 
    reg RDATA_DONE; 
    reg RADDR_DONE; 

    integer i;


    always @(posedge ACLK or negedge ARESETn) begin 

        if(!ARESETn) cs <= IDLE;

        else  cs <= ns;
    end 

    always@(posedge ACLK or negedge ARESETn)begin 

        if(!ARESETn) begin
            S_AWREADY  <= 1'b0;
            S_WREADY   <= 1'b0;
            S_BRESP    <= 1'b0;
            S_BVALID   <= 1'b0;
            S_RVALID   <= 1'b0;
            S_ARREADY  <= 1'b0;
            S_RRESP    <= 1'b0;
            WDATA_DONE <= 1'b0;
            RESP_DONE  <= 1'b0;
            ADDR_DONE  <= 1'b0;
            RDATA_DONE <= 1'b0;
            RADDR_DONE <= 1'b0;
            RESP       <= 1'b0;

            for(i = 0 ; i < NO_REG ; i = i + 1)begin
                register[i] <= 0;
            end 
        end 

        else begin 
            case (cs)
                IDLE : begin 
                    S_AWREADY  <= 1'b0;
                    S_WREADY   <= 1'b0;
                    S_BRESP    <= 1'b0;
                    S_BVALID   <= 1'b0;
                    S_RVALID   <= 1'b0;
                    S_ARREADY  <= 1'b0;
                    S_RRESP    <= 1'b0;
                    WDATA_DONE <= 1'b0;
                    RESP_DONE  <= 1'b0;
                    ADDR_DONE  <= 1'b0;
                    RDATA_DONE <= 1'b0;
                    RADDR_DONE <= 1'b0;
                    RESP       <= 1'b0;
                end  

                WADDR_CHANNEL: begin 
                    S_AWREADY <= 1'b1;
                    if(S_AWREADY && S_AWVALID)begin
                        WADDR <= S_AWADDR;
                    end 
                end 

                WDATA_CHANNEL : begin 
                    S_AWREADY  <= 1'b0;
                    S_WREADY   <= 1'b1;
                    if(S_WREADY && S_WVALID)  begin
                        if (S_WSTRB[0]) register[WADDR][7:0]   <= S_WDATA[7:0];
                        if (S_WSTRB[1]) register[WADDR][15:8]  <= S_WDATA[15:8];
                        if (S_WSTRB[2]) register[WADDR][23:16] <= S_WDATA[23:16];
                        if (S_WSTRB[3]) register[WADDR][31:24] <= S_WDATA[31:24];
                        S_BVALID <= 1'b1;
                        RESP <= OKAY ;
                        WDATA_DONE <=1'b1;
                    end
                end 

                WRESP_CHANNEL : begin
                    WDATA_DONE <=1'b0;
                    S_WREADY   <=1'b0;
                    S_BRESP    <= RESP;
                    RESP_DONE  <=1'b1;
                    S_BVALID   <= 1'b0;
                end

                RADDR_CHANNEL : begin 
                    RESP_DONE <= 1'b0;
                    S_ARREADY <= 1'b1;
                    if(S_ARVALID && S_ARREADY) begin  
                        RADDR <= S_ARADDR;
                        RADDR_DONE <= 1 ;
                    end 
                end 

                RDATA_CHANNEL : begin  
                    RADDR_DONE <= 1'b0;
                    S_RVALID <=1'b1;
                    S_RDATA <= register[RADDR];
                    S_RRESP <= OKAY ;
                    if(S_RREADY) RDATA_DONE <= 1;
                end 

                default :  ;
            endcase 
        end
    end 

    always @(*) begin 
        ns = cs;
        case(cs)
            IDLE : begin
                if(S_AWVALID)  ns = WADDR_CHANNEL;
                else if (S_ARVALID) ns = RADDR_CHANNEL;
                else  ns = IDLE;    
            end 

            WADDR_CHANNEL : if(S_WVALID) ns = WDATA_CHANNEL;
            WDATA_CHANNEL : if (S_BREADY && S_BVALID) ns = WRESP_CHANNEL;
            WRESP_CHANNEL : if (RESP_DONE)  ns = IDLE;
            RADDR_CHANNEL : if (RADDR_DONE) ns = RDATA_CHANNEL;
            RDATA_CHANNEL : if (RDATA_DONE) ns  = IDLE;
           
            default : ns = IDLE;
        endcase 
    end 
endmodule