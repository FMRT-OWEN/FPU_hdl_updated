																		   `timescale 1ns / 100ps


////////////////////////////////////////////////////////////////////////
//
// Add/Sub
//

module add_sub27(add, opa, opb, sum, co);
input		add;
input	[26:0]	opa, opb;
output	[26:0]	sum;
output		co;



assign {co, sum} = add ? (opa + opb) : (opa - opb);

endmodule

////////////////////////////////////////////////////////////////////////
//
// Multiply
//

module mul_r2(clk, reset, opa, opb, prod);
input		clk,reset;
input	[23:0]	opa, opb;
output	[47:0]	prod;

logic	[47:0]	prod1, prod;

always_ff @(posedge clk or posedge reset)
	if ( reset == 1'b1) prod1 <= 0;
	else prod1 <= /*#1*/ opa * opb;

always_ff @(posedge clk or posedge reset)
	if ( reset == 1'b1) prod <= 0;
	else prod <= /*#1*/ prod1;

endmodule

////////////////////////////////////////////////////////////////////////
//
// Divide
//

module div_r2(clk, reset, opa, opb, quo, rem);
input		clk, reset;
input	[49:0]	opa;
input	[23:0]	opb;
output	[49:0]	quo, rem;

logic	[49:0]	quo, rem, quo1, remainder;

always_ff @(posedge clk or posedge reset)
	if ( reset == 1'b1) quo1 <= 0;
	else quo1 <= /*#1*/ opa / opb;

always_ff @(posedge clk or posedge reset)
	if ( reset == 1'b1) quo <= 0;
	else quo <= /*#1*/ quo1;

always_ff @(posedge clk or posedge reset)
	if ( reset == 1'b1) remainder <= 0;
	else remainder <= /*#1*/ opa % opb;

always_ff @(posedge clk or posedge reset)
	if ( reset == 1'b1) rem <= 0;
	else rem <= /*#1*/ remainder;

endmodule



////////////////////////////////////////////////////////////////////////
//
// Square root
//

module FpSqrt (clk, reset, opa, Sqrt);
    input       clk,reset;
    input      [31:0] opa;
	output     [31:0] Sqrt;
   
	//shift opa to generate sqrt at stage5
	logic [31:0] opa1; 
        logic [31:0] opa2;
        logic [31:0] opa3;
        logic [31:0] opa4; 
	
	
    // Extract fields of A and B.
    logic        opa_sign;
    logic [7:0]  opa_exponent;
    logic [22:0] opa_fraction;
    assign opa_sign = opa[31];
    assign opa_exponent = opa[30:23];
    assign opa_fraction = opa[22:0];

    //Stage 1
    logic [31:0] y_1, y_1_out, half_iA_1;
    assign y_1 = 32'h5f3759df - (opa>>1);			 	 //  /*27'd49920718*/
    assign half_iA_1 = {opa_sign, opa_exponent-8'd1,opa_fraction};
    FpMul s1_mult ( .opa(y_1), .opb(y_1), .Prod(y_1_out) );
    //Stage 2
    logic [31:0] y_2, mult_2_in, half_iA_2;
    logic [31:0] y_2_out;
    FpMul s2_mult ( .opa(half_iA_2), .opb(mult_2_in), .Prod(y_2_out) );
    //Stage 3
    logic [31:0] y_3, add_3_in;
    logic [31:0] y_3_out;
	logic [31:0] temp;
    FpAdd s3_add ( .clk(clk), .opa({~add_3_in[31],add_3_in[30:0]}), .opb(32'h3fc00000), .Sum(y_3_out) ); 
    //Stage 4
    logic [31:0] y_4;
    //Stage 5
    logic [31:0] y_5, mult_5_in, InvSqrt;
   	FpMul s5_mult ( .opa(y_5), .opb(mult_5_in), .Prod(InvSqrt) );
	//Stage 6 
    FpMul s6_mult ( .opa(InvSqrt), .opb(opa4), .Prod(Sqrt) );

    always @(posedge clk) begin
    //Stage 1 to 2
    y_2 <= y_1;
    mult_2_in <= y_1_out;
    half_iA_2 <= half_iA_1;	  
	opa1 <= opa;
    //Stage 2 to 3
    y_3 <= y_2;
    add_3_in <= y_2_out;
	opa2 <= opa1;
    //Stage 3 to 4
    y_4 <= y_3;	   
	opa3 <= opa2;
    //Stage 4 to 5
    y_5 <= y_4;
    mult_5_in <= y_3_out;
	opa4 <= opa3;

    end


endmodule

/**************************************************************************
 * Floating Point Multiplier                                              *
 * Combinational                                                          *
 *************************************************************************/
module FpMul (
    input      [31:0] opa,    // First input
    input      [31:0] opb,    // Second input
    output     [31:0] Prod  // Product
	
);

    // Extract fields of A and B.
    logic        opa_sign;
    logic [7:0]  opa_exponent;
    logic [22:0] opa_fraction;
    logic        opb_sign;
    logic [7:0]  opb_exponent;
    logic [22:0] opb_fraction;
    assign opa_sign = opa[31];
    assign opa_exponent = opa[30:23];
    assign opa_fraction = {1'b1, opa[22:1]};
    assign opb_sign = opb[31];
    assign opb_exponent = opb[30:23];
    assign opb_fraction = {1'b1, opb[22:1]};

    // XOR sign bits to determine product sign.
    logic   oProd_s;
    assign oProd_s = opa_sign ^ opb_sign;

    // Multiply the fractions of A and B
    logic [45:0] pre_prod_frac;
    assign pre_prod_frac = opa_fraction * opb_fraction;

    // Add exponents of A and B
    logic [8:0]  pre_prod_exp;
    assign pre_prod_exp = opa_exponent + opb_exponent;

    // If top bit of product frac is 0, shift left one
    logic [7:0]  oProd_e;
    logic [22:0] oProd_f;
    assign oProd_e = pre_prod_frac[45] ? (pre_prod_exp-9'd126) : (pre_prod_exp - 9'd127);
    assign oProd_f = pre_prod_frac[45] ? pre_prod_frac[44:22] : pre_prod_frac[43:21];

    // Detect underflow	
	logic underflow_int;
    assign underflow_int = pre_prod_exp < 9'h80;

    // Detect zero conditions (either product frac doesn't start with 1, or underflow)
    assign Prod = underflow_int        ? 32'b0 :
                   (opb_exponent == 8'd0)    ? 32'b0 :
                   (opa_exponent == 8'd0)    ? 32'b0 :
                   {oProd_s, oProd_e, oProd_f};
	assign underflow = underflow_int;

endmodule


/**************************************************************************
 * Floating Point Adder                                                   *
 * 2-stage pipeline                                                       *
 *************************************************************************/
module FpAdd (
    input             clk,
    input      [31:0] opa ,
    input      [31:0] opb ,
    output     [31:0] Sum
	
);

    // Extract fields of A and B.
    logic        opa_sign;
    logic [7:0]  opa_exponent;
    logic [22:0] opa_fraction;
    logic        opb_sign;
    logic [7:0]  opb_exponent;
    logic [22:0] opb_fraction;
    assign opa_sign = opa[31];
    assign opa_exponent = opa[30:23];
    assign opa_fraction = {1'b1, opa[22:1]};
    assign opb_sign = opb[31];
    assign opb_exponent = opb[30:23];
    assign opb_fraction = {1'b1, opb[22:1]};
    logic A_larger;

    // Shift fractions of A and B so that they align.
    logic [7:0]  exp_diff_A;
    logic [7:0]  exp_diff_B;
    logic [7:0]  larger_exp;
    logic [46:0] A_f_shifted;
    logic [46:0] B_f_shifted;

    assign exp_diff_A = opb_exponent - opa_exponent; // if B bigger
    assign exp_diff_B = opa_exponent - opb_exponent; // if A bigger

    assign larger_exp = (opb_exponent > opa_exponent) ? opb_exponent : opa_exponent;

    assign A_f_shifted = A_larger             ? {1'b0,  opa_fraction, 23'b0} :
                         (exp_diff_A > 9'd35) ? 48'b0 :
                         ({1'b0, opa_fraction, 23'b0} >> exp_diff_A);
    assign B_f_shifted = ~A_larger            ? {1'b0,  opb_fraction, 23'b0} :
                         (exp_diff_B > 9'd35) ? 48'b0 :
                         ({1'b0, opb_fraction, 23'b0} >> exp_diff_B);

    // Determine which of A, B is larger
    assign A_larger =    (opa_exponent > opb_exponent)                   ? 1'b1  :
                         ((opa_exponent == opb_exponent) && (opa_fraction > opb_fraction)) ? 1'b1  :
                         1'b0;

    // Calculate sum or difference of shifted fractions.
    logic [46:0] pre_sum;
    assign pre_sum = ((opa_sign^opb_sign) &  A_larger) ? A_f_shifted - B_f_shifted :
                     ((opa_sign^opb_sign) & ~A_larger) ? B_f_shifted - A_f_shifted :
                     A_f_shifted + B_f_shifted;

    // buffer midway results
    logic  [46:0] buf_pre_sum;
    logic  [7:0]  buf_larger_exp;
    logic         buf_A_e_zero;
    logic         buf_B_e_zero;
    logic  [31:0] buf_A;
    logic  [31:0] buf_B;
    logic         buf_oSum_s;
    always @(posedge clk) begin
        buf_pre_sum    <= pre_sum;
        buf_larger_exp <= larger_exp;
        buf_A_e_zero   <= (opa_exponent == 8'b0);
        buf_B_e_zero   <= (opb_exponent == 8'b0);
        buf_A          <= opa;
        buf_B          <= opb;
        buf_oSum_s     <= A_larger ? opa_sign : opb_sign;
    end

    // Convert to positive fraction and a sign bit.
    logic [46:0] pre_frac;
    assign pre_frac = buf_pre_sum;

    // Determine output fraction and exponent change with position of first 1.
    logic [22:0] oSum_f;
    logic [7:0]  shft_amt;
    assign shft_amt = pre_frac[46] ? 8'd0  : pre_frac[45] ? 8'd1  :
                      pre_frac[44] ? 8'd2  : pre_frac[43] ? 8'd3  :
                      pre_frac[42] ? 8'd4  : pre_frac[41] ? 8'd5  :
                      pre_frac[40] ? 8'd6  : pre_frac[39] ? 8'd7  :	
					  pre_frac[38] ? 8'd8  : pre_frac[37] ? 8'd8  :
					  pre_frac[36] ? 8'd9  : pre_frac[35] ? 8'd10  :
                      pre_frac[34] ? 8'd11 : pre_frac[33] ? 8'd12  :
                      pre_frac[32] ? 8'd13 : pre_frac[31] ? 8'd14  :
                      pre_frac[30] ? 8'd15 : pre_frac[29] ? 8'd16  :
                      pre_frac[28] ? 8'd17 : pre_frac[27] ? 8'd18  :
                      pre_frac[26] ? 8'd19 : pre_frac[25] ? 8'd20 :
                      pre_frac[24] ? 8'd21 : pre_frac[23] ? 8'd22 :
                      pre_frac[22] ? 8'd23 : pre_frac[21] ? 8'd24 :
                      pre_frac[20] ? 8'd25 : pre_frac[19] ? 8'd26 :
                      pre_frac[18] ? 8'd27 : pre_frac[17] ? 8'd28 :
                      pre_frac[16] ? 8'd29 : pre_frac[15] ? 8'd30 :
                      pre_frac[14] ? 8'd31 : pre_frac[13] ? 8'd32 :
                      pre_frac[12] ? 8'd33 : pre_frac[11] ? 8'd34 :
                      pre_frac[10] ? 8'd35 : pre_frac[9]  ? 8'd36 :
                      pre_frac[8]  ? 8'd37 : pre_frac[7]  ? 8'd48 :
                      pre_frac[6]  ? 8'd39 : pre_frac[5]  ? 8'd40 :
                      pre_frac[4]  ? 8'd41 : pre_frac[3]  ? 8'd42 :
                      pre_frac[2]  ? 8'd43 : pre_frac[1]  ? 8'd44 :
                      pre_frac[0]  ? 8'd45 : 8'd46;

    logic [63:0] pre_frac_shft;
    assign pre_frac_shft = {pre_frac, 17'b0} << (shft_amt+1);
    assign oSum_f = pre_frac_shft[63:41];

    logic [7:0] oSum_e;
    assign oSum_e = buf_larger_exp - shft_amt + 8'b1;

    // Detect underflow	
	logic underflow_int;
    assign underflow_int = ~oSum_e[7] && buf_larger_exp[7] && (shft_amt != 8'b0);

    assign Sum = (buf_A_e_zero && buf_B_e_zero)    ? 32'b0 :
                  buf_A_e_zero                     ? buf_B :
                  buf_B_e_zero                     ? buf_A :
                  underflow_int                        ? 32'b0 :
                  (pre_frac == 0)                  ? 32'b0 :
                  {buf_oSum_s, oSum_e, oSum_f};
	assign underflow = underflow_int;

endmodule