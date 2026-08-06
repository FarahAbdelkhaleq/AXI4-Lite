module AXI4_lite_tb();
    parameter DATA_WIDTH = 32;
    parameter ADDR_WIDTH = 32;

    reg ACLK_tb;
    reg ARESETn_tb;

    reg read_flag_tb;
    reg write_flag_tb;

    reg [DATA_WIDTH-1:0] WDATA_in_tb;      // input data 
    reg [ADDR_WIDTH-1:0] WADDR_tb;         // input addr_write
    reg [ADDR_WIDTH-1:0] RADDR_tb;         // input addr_read (NEW)
    reg [DATA_WIDTH/8 -1:0] WSTRB_tb; 

    wire [DATA_WIDTH-1:0] RDATA_out_tb;
    wire [1:0] WRESP_tb;
    wire [1:0] RRESP_tb;


    integer i;


    //Expected 
    reg [ADDR_WIDTH-1:0] WADDR_exp;         // input addr_write
    reg [DATA_WIDTH-1:0] WDATA_exp;
    reg [DATA_WIDTH-1:0] RDATA_out_exp;  
    reg [DATA_WIDTH-1:0] exp_mem [0:ADDR_WIDTH-1];   


    Top #(
        .DATA_WIDTH (DATA_WIDTH),
        .ADDR_WIDTH (ADDR_WIDTH)
    ) DUT (
        .ACLK    (ACLK_tb),
        .ARESETn (ARESETn_tb),

        .read_flag  (read_flag_tb),
        .write_flag (write_flag_tb),

        .WADDR_in (WADDR_tb),
        .RADDR_in (RADDR_tb),           
        .WDATA_in (WDATA_in_tb),
        .WSTRB    (WSTRB_tb),

        .WRESP_out (WRESP_tb),
        .RRESP_out (RRESP_tb),

        .RDATA_out (RDATA_out_tb)
    );

    initial begin
        ACLK_tb = 0;
        forever #5 ACLK_tb = ~ACLK_tb;
    end


    
    initial begin

        ///////////////////// Reset Check ///////////////////// 

        ARESETn_tb = 1'b0;
        read_flag_tb  = 1'b0;
        write_flag_tb = 1'b0;
        WADDR_tb = 1'b0;
        RADDR_tb = 1'b0;
        WDATA_in_tb = 1'b0; 
        WSTRB_tb = 4'b1111;

        for (i = 0; i < 32; i = i + 1) exp_mem[i] = 0;

        repeat(2) @(negedge ACLK_tb);
        ARESETn_tb = 1'b1;
        repeat(2) @(negedge ACLK_tb);

        for(i = 0 ; i < 10 ; i = i + 1)begin

        ///////////////////// Write Case Check /////////////////////

            write_flag_tb = 1'b1;
            read_flag_tb  = 1'b0;
            #1;

            WADDR_tb = $urandom_range(0,31);
            WADDR_exp = WADDR_tb;
            repeat(4)@(negedge ACLK_tb);

            write_flag_tb = 1'b0;
            WDATA_in_tb = $urandom;
            WDATA_exp = WDATA_in_tb;
            WSTRB_tb = $urandom_range(0,15);

            if (WSTRB_tb [0]) exp_mem[WADDR_tb][7:0]   = WDATA_in_tb[7:0];
            if (WSTRB_tb [1]) exp_mem[WADDR_tb][15:8]  = WDATA_in_tb[15:8];
            if (WSTRB_tb [2]) exp_mem[WADDR_tb][23:16] = WDATA_in_tb[23:16];
            if (WSTRB_tb [3]) exp_mem[WADDR_tb][31:24] = WDATA_in_tb[31:24];
            repeat(4)@(negedge ACLK_tb);

        ///////////////////// Read Case Check /////////////////////

            read_flag_tb  = 1'b1;
            RADDR_tb = WADDR_exp;
            RDATA_out_exp = exp_mem[RADDR_tb];

            repeat(12)@(negedge ACLK_tb);
            read_flag_tb  = 1'b0;
            repeat(5)@(negedge ACLK_tb);

            if (RDATA_out_tb === RDATA_out_exp) begin  
                $display("CORRECT, ReadDataOUT = %h, ReadExp = %h, Address = %h,STROBE = %h "
                ,RDATA_out_tb,RDATA_out_exp, RADDR_tb,WSTRB_tb);
            end
            else begin
                $display("INCORRECT, ReadDataOUT = %h, ReadExp = %h, Address = %h,STROBE = %h "
                ,RDATA_out_tb,RDATA_out_exp, RADDR_tb,WSTRB_tb);
            end
        end
        $stop;
    end
endmodule
   