`timescale 1ns / 100ps

import definitions::*; // import package into $unit space 


module fpu(fpu_interface fpu_if);


parameter	INF  = 31'h7f800000,
	    	QNAN = 31'h7fc00001,
		    SNAN = 31'h7f800001;

////////////////////////////////////////////////////////////////////////
//
// Local Wires
//			
logic clk;
logic reset;
logic	[31:0]	opa_r, opb_r;		 // Input operand registers
logic	signa, signb;		         // alias to opX sign
logic	sign_fasu;		             // sign output
logic   co_d;
logic	[26:0]	fracta, fractb;		 // Fraction Outputs from EQU block
logic	[7:0]	exp_fasu;		     // Exponent output from EQU block
logic	[7:0]	exp_r;			     // Exponent output (registerd)
logic	[26:0]	fract_out_d;		 // fraction output
logic	co;			                 // carry output
logic	[27:0]	fract_out_q;		 // fraction output (registerd)
logic	[30:0]	out_d;			     // Intermediate final result output
logic	overflow_d, underflow_d;     // Overflow/Underflow Indicators
logic	[1:0]	rmode_r1, rmode_r2, rmode_r3;	    // Pipeline registers for rounding mode
logic	[2:0]	fpu_op_r1, fpu_op_r2, fpu_op_r3;	// Pipeline registers for fp opration
logic	mul_inf, div_inf;
logic	mul_00, div_00;
//
logic		fasu_op, fasu_op_r1, fasu_op_r2;		 

//stage 5 regs
logic [31:0] out_st4;
logic inf_st4, snan_st4, qnan_st4, ine_st4, overflow_st4, underflow_st4, zero_st4, div_by_zero_st4;


////////////////////////////////////////////////////////////////////////
// Stage 1
// Input Registers
//


always_ff @(posedge fpu_if.clk or posedge fpu_if.reset)
	if ( fpu_if.reset == 1'b1) opa_r <= 0;
	else opa_r <=  fpu_if.fpu_i.opa;

always_ff @(posedge fpu_if.clk or posedge fpu_if.reset)
	if ( fpu_if.reset == 1'b1) opb_r <= 0;
	else opb_r <=  fpu_if.fpu_i.opb;

always_ff @(posedge fpu_if.clk or posedge fpu_if.reset)
	if ( fpu_if.reset == 1'b1) rmode_r1 <= 0;
	else rmode_r1 <=  fpu_if.fpu_i.rmode;

always_ff @(posedge fpu_if.clk or posedge fpu_if.reset)
	if ( fpu_if.reset == 1'b1) rmode_r2 <= 0;
	else rmode_r2 <=  rmode_r1;

always_ff @(posedge fpu_if.clk or posedge fpu_if.reset)
	if ( fpu_if.reset == 1'b1) rmode_r3 <= 0;
	else rmode_r3 <=  rmode_r2;

always_ff @(posedge fpu_if.clk or posedge fpu_if.reset)
	if ( fpu_if.reset == 1'b1) fpu_op_r1 <= 0;
	else fpu_op_r1 <=  fpu_if.fpu_i.fpu_op;

always_ff @(posedge fpu_if.clk or posedge fpu_if.reset)
	if ( fpu_if.reset == 1'b1) fpu_op_r2 <= 0;
	else fpu_op_r2 <=  fpu_op_r1;

always_ff @(posedge fpu_if.clk or posedge fpu_if.reset)
	if ( fpu_if.reset == 1'b1) fpu_op_r3 <= 0;
	else fpu_op_r3 <=  fpu_op_r2;

////////////////////////////////////////////////////////////////////////
//
// Exceptions block
//
logic		inf_d, ind_d, qnan_d, snan_d, opa_nan, opb_nan;
logic		opa_00, opb_00;
logic		opa_inf, opb_inf;
logic		opa_dn, opb_dn;

except u0(.clk(fpu_if.clk),.reset(fpu_if.reset),
		.opa(opa_r), .opb(opb_r),
		.inf(inf_d), .ind(ind_d),
		.qnan(qnan_d), .snan(snan_d),
		.opa_nan(opa_nan), .opb_nan(opb_nan),
		.opa_00(opa_00), .opb_00(opb_00),
		.opa_inf(opa_inf), .opb_inf(opb_inf),
		.opa_dn(opa_dn), .opb_dn(opb_dn)
		);

////////////////////////////////////////////////////////////////////////
// Stage 2
// Pre-Normalize block
// - Adjusts the numbers to equal exponents and sorts them
// - determine result sign
// - determine actual operation to perform (add or sub)
// 

logic		nan_sign_d, result_zero_sign_d;
logic		sign_fasu_r;
logic	[7:0]	exp_mul;
logic		sign_mul;
logic		sign_mul_r;
logic	[23:0]	fracta_mul, fractb_mul;
logic		inf_mul;
logic		inf_mul_r;
logic	[1:0]	exp_ovf;
logic	[1:0]	exp_ovf_r;
logic		sign_exe;
logic		sign_exe_r;
logic	[2:0]	underflow_fmul_d;


pre_norm u1(.clk(fpu_if.clk),				// System Clock	
	.reset(fpu_if.reset),		 // System Reset
	.rmode(rmode_r2),			// Roundin Mode
	.add(!fpu_op_r1[0]),			// Add/Sub Input
	.opa(opa_r),  .opb(opb_r),		// Registered OP Inputs
	.opa_nan(opa_nan),			// OpA is a NAN indicator
	.opb_nan(opb_nan),			// OpB is a NAN indicator
	.fracta_out(fracta),			// Equalized and sorted fraction
	.fractb_out(fractb),			// outputs (Registered)
	.exp_dn_out(exp_fasu),			// Selected exponent output (registered);
	.sign(sign_fasu),			// Encoded output Sign (registered)
	.nan_sign(nan_sign_d),			// Output Sign for NANs (registered)
	.result_zero_sign(result_zero_sign_d),	// Output Sign for zero result (registered)
	.fasu_op(fasu_op)			// Actual fasu operation output (registered)
	);

always_ff @(posedge fpu_if.clk or posedge fpu_if.reset)
	if ( fpu_if.reset == 1'b1) sign_fasu_r <= 0;
	else sign_fasu_r <=  sign_fasu;

pre_norm_fmul u2(
		.clk(fpu_if.clk),
		.reset(fpu_if.reset),
		.fpu_op(fpu_op_r1),
		.opa(opa_r), .opb(opb_r),
		.fracta(fracta_mul),
		.fractb(fractb_mul),
		.exp_out(exp_mul),	// FMUL exponent output (registered)
		.sign(sign_mul),	// FMUL sign output (registered)
		.sign_exe(sign_exe),	// FMUL exception sign output (registered)
		.inf(inf_mul),		// FMUL inf output (registered)
		.exp_ovf(exp_ovf),	// FMUL exponnent overflow output (registered)
		.underflow(underflow_fmul_d)
		);


always_ff @(posedge fpu_if.clk or posedge fpu_if.reset)
	if ( fpu_if.reset == 1'b1) sign_mul_r <= 0;
	else sign_mul_r <=  sign_mul;

always_ff @(posedge fpu_if.clk or posedge fpu_if.reset)
	if ( fpu_if.reset == 1'b1) sign_exe_r <= 0;
	else sign_exe_r <=  sign_exe;

always_ff @(posedge fpu_if.clk or posedge fpu_if.reset)
	if ( fpu_if.reset == 1'b1) inf_mul_r <= 0;
	else inf_mul_r <=  inf_mul;

always_ff @(posedge fpu_if.clk or posedge fpu_if.reset)
	if ( fpu_if.reset == 1'b1) exp_ovf_r <= 0;
	else exp_ovf_r <=  exp_ovf;

//Stage 3
////////////////////////////////////////////////////////////////////////
//
// Add/Sub
//

add_sub27 u3(
	.add(fasu_op),			// Add/Sub
	.opa(fracta),			// Fraction A input
	.opb(fractb),			// Fraction B Input
	.sum(fract_out_d),		// SUM output
	.co(co_d) );			// Carry Output

always_ff @(posedge fpu_if.clk or posedge fpu_if.reset)
	if ( fpu_if.reset == 1'b1) fract_out_q <= 0;
	else fract_out_q <= /*#1*/ {co_d, fract_out_d};

////////////////////////////////////////////////////////////////////////
//
// Mul
//
logic	[47:0]	prod;

mul_r2 u5(.clk(fpu_if.clk), .reset(fpu_if.reset),.opa(fracta_mul), .opb(fractb_mul), .prod(prod));

////////////////////////////////////////////////////////////////////////
//
// Divide
//
logic	[49:0]	quo;
logic	[49:0]	fdiv_opa;
logic	[49:0]	remainder;
logic		remainder_00;
logic	[4:0]	div_opa_ldz_d, div_opa_ldz_r1, div_opa_ldz_r2;

always_comb //@(fracta_mul)
	casex(fracta_mul[22:0])
	   23'b1??????????????????????: div_opa_ldz_d = 1;
	   23'b01?????????????????????: div_opa_ldz_d = 2;
	   23'b001????????????????????: div_opa_ldz_d = 3;
	   23'b0001???????????????????: div_opa_ldz_d = 4;
	   23'b00001??????????????????: div_opa_ldz_d = 5;
	   23'b000001?????????????????: div_opa_ldz_d = 6;
	   23'b0000001????????????????: div_opa_ldz_d = 7;
	   23'b00000001???????????????: div_opa_ldz_d = 8;
	   23'b000000001??????????????: div_opa_ldz_d = 9;
	   23'b0000000001?????????????: div_opa_ldz_d = 10;
	   23'b00000000001????????????: div_opa_ldz_d = 11;
	   23'b000000000001???????????: div_opa_ldz_d = 12;
	   23'b0000000000001??????????: div_opa_ldz_d = 13;
	   23'b00000000000001?????????: div_opa_ldz_d = 14;
	   23'b000000000000001????????: div_opa_ldz_d = 15;
	   23'b0000000000000001???????: div_opa_ldz_d = 16;
	   23'b00000000000000001??????: div_opa_ldz_d = 17;
	   23'b000000000000000001?????: div_opa_ldz_d = 18;
	   23'b0000000000000000001????: div_opa_ldz_d = 19;
	   23'b00000000000000000001???: div_opa_ldz_d = 20;
	   23'b000000000000000000001??: div_opa_ldz_d = 21;
	   23'b0000000000000000000001?: div_opa_ldz_d = 22;
	   23'b0000000000000000000000?: div_opa_ldz_d = 23;
	endcase

assign fdiv_opa = !(|opa_r[30:23]) ? {(fracta_mul<<div_opa_ldz_d), 26'h0} : {fracta_mul, 26'h0};


div_r2 u6(.clk(fpu_if.clk), .reset(fpu_if.reset),.opa(fdiv_opa), .opb(fractb_mul), .quo(quo), .rem(remainder));

assign remainder_00 = !(|remainder);

always_ff @(posedge fpu_if.clk or posedge fpu_if.reset)
	if ( fpu_if.reset == 1'b1) div_opa_ldz_r1 <= 0;
	else div_opa_ldz_r1 <= /*#1*/ div_opa_ldz_d;

always_ff @(posedge fpu_if.clk or posedge fpu_if.reset)
	if ( fpu_if.reset == 1'b1) div_opa_ldz_r2 <= 0;
	else div_opa_ldz_r2 <= /*#1*/ div_opa_ldz_r1;



////////////////////////////////////////////////////////////////////////
// Stage 4
// Normalize Result
//
logic		ine_d;
logic	[47:0]	fract_denorm;
logic	[47:0]	fract_div;
logic		sign_d;
logic		sign;
logic	[30:0]	opa_r1;
logic	[47:0]	fract_i2f;
logic		opas_r1, opas_r2;
logic		f2i_out_sign;

always_ff @(posedge fpu_if.clk or posedge fpu_if.reset)			// Exponent must be once cycle delayed
	if ( fpu_if.reset == 1'b1) exp_r <= 0;
	else begin
	case(fpu_op_r2)
	  0,1:	exp_r <= /*#1*/ exp_fasu;
	  2,3:	exp_r <= /*#1*/ exp_mul;
	  4:	exp_r <= /*#1*/ 0;
	  5:	exp_r <= /*#1*/ opa_r1[30:23];
	endcase
	end

assign fract_div = (opb_dn ? quo[49:2] : {quo[26:0], 21'h0});

always_ff @(posedge fpu_if.clk or posedge fpu_if.reset)
	if ( fpu_if.reset == 1'b1) opa_r1 <= 0;
	else opa_r1 <= /*#1*/ opa_r[30:0];

always_ff @(posedge fpu_if.clk or posedge fpu_if.reset)
	if ( fpu_if.reset == 1'b1) fract_i2f <= 0;
	else fract_i2f <= /*#1*/ (fpu_op_r2==5) ?
			(sign_d ?  1-{24'h00, (|opa_r1[30:23]), opa_r1[22:0]}-1 : {24'h0, (|opa_r1[30:23]), opa_r1[22:0]}) :
			(sign_d ? 1 - {opa_r1, 17'h01} : {opa_r1, 17'h0});

always_comb //@(fpu_op_r3 or fract_out_q or prod or fract_div or fract_i2f)
	case(fpu_op_r3)
	   0,1:	fract_denorm = {fract_out_q, 20'h0};
	   2:	fract_denorm = prod;
	   3:	fract_denorm = fract_div;
	   4,5:	fract_denorm = fract_i2f;
	endcase


always_ff @(posedge fpu_if.clk or posedge fpu_if.reset)
	if ( fpu_if.reset == 1'b1) opas_r1 <= 0;
	else opas_r1 <= /*#1*/ opa_r[31];

always_ff @(posedge fpu_if.clk or posedge fpu_if.reset)
	if ( fpu_if.reset == 1'b1) opas_r2 <= 0;
	else opas_r2 <= /*#1*/ opas_r1;

assign sign_d = fpu_op_r2[1] ? sign_mul : sign_fasu;

always_ff @(posedge fpu_if.clk or posedge fpu_if.reset)
	if ( fpu_if.reset == 1'b1) sign <= 0;
	else sign <= /*#1*/ (rmode_r2==2'h3) ? !sign_d : sign_d;

post_norm u4(.clk(fpu_if.clk),			// System Clock	  
	.reset(fpu_if.reset),
	.fpu_op(fpu_op_r3),		// Floating Point Operation
	.opas(opas_r2),			// OPA Sign
	.sign(sign),			// Sign of the result
	.rmode(rmode_r3),		// Rounding mode
	.fract_in(fract_denorm),	// Fraction Input
	.exp_ovf(exp_ovf_r),		// Exponent Overflow
	.exp_in(exp_r),			// Exponent Input
	.opa_dn(opa_dn),		// Operand A Denormalized
	.opb_dn(opb_dn),		// Operand A Denormalized
	.rem_00(remainder_00),		// Diveide Remainder is zero
	.div_opa_ldz(div_opa_ldz_r2),	// Divide opa leading zeros count
	.output_zero(mul_00 | div_00),	// Force output to Zero
	.out(out_d),			// Normalized output (un-registered)
	.ine(ine_d),			// Result Inexact output (un-registered)
	.overflow(overflow_d),		// Overflow output (un-registered)
	.underflow(underflow_d),	// Underflow output (un-registered)
	.f2i_out_sign(f2i_out_sign)	// F2I Output Sign
	);

////////////////////////////////////////////////////////////////////////
//
// FPU Outputs

logic	[30:0]	out_fixed;
logic		output_zero_fasu;
logic		output_zero_fdiv;
logic		output_zero_fmul;
logic		inf_mul2;
logic		overflow_fasu;
logic		overflow_fmul;
logic		overflow_fdiv;
logic		inf_fmul;
logic		sign_mul_final;
logic		out_d_00;
logic		sign_div_final;
logic		ine_mul, ine_mula, ine_div, ine_fasu;
logic		underflow_fasu, underflow_fmul, underflow_fdiv;
logic		underflow_fmul1;
logic	[2:0]	underflow_fmul_r;
logic		opa_nan_r;


always_ff @(posedge fpu_if.clk or posedge fpu_if.reset)
	if ( fpu_if.reset == 1'b1) fasu_op_r1 <= 0;
	else fasu_op_r1 <=  fasu_op;

always_ff @(posedge fpu_if.clk or posedge fpu_if.reset)	
	if ( fpu_if.reset == 1'b1) fasu_op_r2 <= 0;
	else fasu_op_r2 <=  fasu_op_r1;

always_ff @(posedge fpu_if.clk or posedge fpu_if.reset)
	if ( fpu_if.reset == 1'b1) inf_mul2 <= 0;
	else inf_mul2 <=   exp_mul == 8'hff;


// Force pre-set values for non numerical output
assign mul_inf = (fpu_op_r3==3'b010) & (inf_mul_r | inf_mul2) & (rmode_r3==2'h0);
assign div_inf = (fpu_op_r3==3'b011) & (opb_00 | opa_inf);

assign mul_00 = (fpu_op_r3==3'b010) & (opa_00 | opb_00);
assign div_00 = (fpu_op_r3==3'b011) & (opa_00 | opb_inf);

assign out_fixed = (	(qnan_d | snan_d) |
			(ind_d & !fasu_op_r2) | 
			((fpu_op_r3==3'b011) & opb_00 & opa_00) |
			(((opa_inf & opb_00) | (opb_inf & opa_00 )) & fpu_op_r3==3'b010)
		   )  ? QNAN : INF;

always_ff @(posedge fpu_if.clk or posedge fpu_if.reset)
	if ( fpu_if.reset == 1'b1) out_st4[30:0] <= 0;
	else out_st4[30:0] <=  (mul_inf | div_inf | (inf_d & (fpu_op_r3!=3'b011) & (fpu_op_r3!=3'b101)) | snan_d | qnan_d) & fpu_op_r3!=3'b100 ? out_fixed :
			out_d;

assign out_d_00 = !(|out_d);

assign sign_mul_final = (sign_exe_r & ((opa_00 & opb_inf) | (opb_00 & opa_inf))) ? !sign_mul_r : sign_mul_r;
assign sign_div_final = (sign_exe_r & (opa_inf & opb_inf)) ? !sign_mul_r : sign_mul_r | (opa_00 & opb_00);

always_ff @(posedge fpu_if.clk or posedge fpu_if.reset)
	if ( fpu_if.reset == 1'b1) out_st4[31] <= 0;
	else out_st4[31] <= ((fpu_op_r3==3'b101) & out_d_00) ? (f2i_out_sign & !(qnan_d | snan_d) ) :
			((fpu_op_r3==3'b010) & !(snan_d | qnan_d)) ?	sign_mul_final :
			((fpu_op_r3==3'b011) & !(snan_d | qnan_d)) ?	sign_div_final :
			(snan_d | qnan_d | ind_d) ?	nan_sign_d :
			output_zero_fasu ?	result_zero_sign_d : sign_fasu_r;

// Exception Outputs
assign ine_mula = ((inf_mul_r |  inf_mul2 | opa_inf | opb_inf) & (rmode_r3==2'h1) & 
		!((opa_inf & opb_00) | (opb_inf & opa_00 )) & fpu_op_r3[1]);

assign ine_mul  = (ine_mula | ine_d | inf_fmul | out_d_00 | overflow_d | underflow_d) &
		  !opa_00 & !opb_00 & !(snan_d | qnan_d | inf_d);
assign ine_div  = (ine_d | overflow_d | underflow_d) & !(opb_00 | snan_d | qnan_d | inf_d);
assign ine_fasu = (ine_d | overflow_d | underflow_d) & !(snan_d | qnan_d | inf_d);

always_ff @(posedge fpu_if.clk or posedge fpu_if.reset)
	if ( fpu_if.reset == 1'b1) ine_st4 <= 0;
	else ine_st4 <=   fpu_op_r3[2] ? ine_d :
			!fpu_op_r3[1] ? ine_fasu :
			 fpu_op_r3[0] ? ine_div  : ine_mul;


assign overflow_fasu = overflow_d & !(snan_d | qnan_d | inf_d);
assign overflow_fmul = !inf_d & (inf_mul_r | inf_mul2 | overflow_d) & !(snan_d | qnan_d);
assign overflow_fdiv = (overflow_d & !(opb_00 | inf_d | snan_d | qnan_d));

always_ff @(posedge fpu_if.clk or posedge fpu_if.reset)
	if ( fpu_if.reset == 1'b1) overflow_st4 <= 0;
	else overflow_st4 <=  fpu_op_r3[2] ? 0 :
			!fpu_op_r3[1] ? overflow_fasu :
			 fpu_op_r3[0] ? overflow_fdiv : overflow_fmul;

always_ff @(posedge fpu_if.clk or posedge fpu_if.reset)
	if ( fpu_if.reset == 1'b1) underflow_fmul_r <= 0;
	else underflow_fmul_r <=  underflow_fmul_d;


assign underflow_fmul1 = underflow_fmul_r[0] |
			(underflow_fmul_r[1] & underflow_d ) |
			((opa_dn | opb_dn) & out_d_00 & (prod!=0) & sign) |
			(underflow_fmul_r[2] & ((out_d[30:23]==0) | (out_d[22:0]==0)));

assign underflow_fasu = underflow_d & !(inf_d | snan_d | qnan_d);
assign underflow_fmul = underflow_fmul1 & !(snan_d | qnan_d | inf_mul_r);
assign underflow_fdiv = underflow_fasu & !opb_00;

always_ff @(posedge fpu_if.clk or posedge fpu_if.reset)
	if ( fpu_if.reset == 1'b1) underflow_st4 <= 0;
	else underflow_st4 <=  fpu_op_r3[2] ? 0 :
			!fpu_op_r3[1] ? underflow_fasu :
			 fpu_op_r3[0] ? underflow_fdiv : underflow_fmul;

always_ff @(posedge fpu_if.clk or posedge fpu_if.reset)
	if ( fpu_if.reset == 1'b1) snan_st4 <= 0;
	else snan_st4 <=  snan_d;

// synopsys translate_off
//logic		mul_uf_del;
//logic		uf2_del, ufb2_del, ufc2_del,  underflow_d_del;
//logic		co_del;
//logic	[30:0]	out_d_del;
//logic		ov_fasu_del, ov_fmul_del;
//logic	[2:0]	fop;
//logic	[4:0]	ldza_del;
//logic	[49:0]	quo_del;
//
//delay1  #0 ud000(fpu_if.clk,fpu_if.reset, underflow_fmul1, mul_uf_del);
//delay1  #0 ud001(fpu_if.clk,fpu_if.reset, underflow_fmul_r[0], uf2_del);
//delay1  #0 ud002(fpu_if.clk,fpu_if.reset, underflow_fmul_r[1], ufb2_del);
//delay1  #0 ud003(fpu_if.clk,fpu_if.reset, underflow_d, underflow_d_del);
//delay1  #0 ud004(fpu_if.clk,fpu_if.reset, test.u0.u4.exp_out1_co, co_del);
//delay1  #0 ud005(fpu_if.clk,fpu_if.reset, underflow_fmul_r[2], ufc2_del);
//delay1  #30 ud006(fpu_if.clk,fpu_if.reset, out_d, out_d_del);
//
//delay1  #0 ud007(fpu_if.clk,fpu_if.reset, overflow_fasu, ov_fasu_del);
//delay1  #0 ud008(fpu_if.clk,fpu_if.reset, overflow_fmul, ov_fmul_del);
//
//delay1  #2 ud009(fpu_if.clk,fpu_if.reset, fpu_op_r3, fop);
//
//delay3  #4 ud010(fpu_if.clk,fpu_if.reset, div_opa_ldz_d, ldza_del);
//
//delay1  #49 ud012(fpu_if.clk,fpu_if.reset, quo, quo_del);
//
//always @(test.error_event)
//   begin
//	#0.2
//	$display("muf: %b uf0: %b uf1: %b uf2: %b, tx0: %b, co: %b, out_d: %h (%h %h), ov_fasu: %b, ov_fmul: %b, fop: %h",
//			mul_uf_del, uf2_del, ufb2_del, ufc2_del, underflow_d_del, co_del, out_d_del, out_d_del[30:23], out_d_del[22:0],
//			ov_fasu_del, ov_fmul_del, fop );
//	$display("ldza: %h, quo: %b",
//			ldza_del, quo_del);
//   end
// synopsys translate_on



// Status Outputs
always_ff @(posedge fpu_if.clk or posedge fpu_if.reset)
	if ( fpu_if.reset == 1'b1) qnan_st4 <= 0;
	else qnan_st4 <= fpu_op_r3[2] ? 0 : (
						snan_d | qnan_d | (ind_d & !fasu_op_r2) |
						(opa_00 & opb_00 & fpu_op_r3==3'b011) |
						(((opa_inf & opb_00) | (opb_inf & opa_00 )) & fpu_op_r3==3'b010)
					   );

assign inf_fmul = 	(((inf_mul_r | inf_mul2) & (rmode_r3==2'h0)) | opa_inf | opb_inf) & 
			!((opa_inf & opb_00) | (opb_inf & opa_00 )) &
			fpu_op_r3==3'b010;

always_ff @(posedge fpu_if.clk or posedge fpu_if.reset)
	if ( fpu_if.reset == 1'b1) inf_st4 <= 0;
	else inf_st4 <= fpu_op_r3[2] ? 0 :
			(!(qnan_d | snan_d) & (
						((&out_d[30:23]) & !(|out_d[22:0]) & !(opb_00 & fpu_op_r3==3'b011)) |
						(inf_d & !(ind_d & !fasu_op_r2) & !fpu_op_r3[1]) |
						inf_fmul |
						(!opa_00 & opb_00 & fpu_op_r3==3'b011) |
						(fpu_op_r3==3'b011 & opa_inf & !opb_inf)
					      )
			);

assign output_zero_fasu = out_d_00 & !(inf_d | snan_d | qnan_d);
assign output_zero_fdiv = (div_00 | (out_d_00 & !opb_00)) & !(opa_inf & opb_inf) &
			  !(opa_00 & opb_00) & !(qnan_d | snan_d);
assign output_zero_fmul = (out_d_00 | opa_00 | opb_00) &
			  !(inf_mul_r | inf_mul2 | opa_inf | opb_inf | snan_d | qnan_d) &
			  !(opa_inf & opb_00) & !(opb_inf & opa_00);

always_ff @(posedge fpu_if.clk or posedge fpu_if.reset)
	if ( fpu_if.reset == 1'b1) zero_st4 <= 0;
	else zero_st4 <=  fpu_op_r3==3'b101 ?	out_d_00 & !(snan_d | qnan_d):
			 fpu_op_r3==3'b011 ?	output_zero_fdiv :
			 fpu_op_r3==3'b010 ?	output_zero_fmul :
						output_zero_fasu ;

always_ff @(posedge fpu_if.clk or posedge fpu_if.reset)
	if ( fpu_if.reset == 1'b1) opa_nan_r <= 0;
	else opa_nan_r <=  !opa_nan & fpu_op_r2==3'b011;

always_ff @(posedge fpu_if.clk or posedge fpu_if.reset)
	if ( fpu_if.reset == 1'b1) div_by_zero_st4 <= 0;
	else div_by_zero_st4 <=  opa_nan_r & !opa_00 & !opa_inf & opb_00;




//Square root integration (stages 1-5)
logic [31:0] sqrt_out, final_out;

FpSqrt u0_FpSqrt (.clk(fpu_if.clk), .reset(fpu_if.reset), .opa(fpu_if.fpu_i.opa), .Sqrt(sqrt_out));
	
assign final_out = (fpu_op_r3 != 4'b100)? out_st4 : sqrt_out; 


	
//Stage 5 -- to support same number of stages in sqrt, flop outputs of other operations one time



always_ff@(posedge fpu_if.clk or posedge fpu_if.reset)
  if(fpu_if.reset == 1'b1) begin
	fpu_if.out          <= 0;
	fpu_if.inf          <= 0;
	fpu_if.snan         <= 0;
	fpu_if.qnan         <= 0;
	fpu_if.ine          <= 0;
	fpu_if.overflow     <= 0;
	fpu_if.underflow    <= 0;
	fpu_if.zero         <= 0;
	fpu_if.div_by_zero  <= 0;	
  end
  else 
    begin
        fpu_if.out          <= final_out;
        fpu_if.inf          <= inf_st4;
        fpu_if.snan         <= snan_st4;
        fpu_if.qnan         <= qnan_st4;
        fpu_if.ine          <= ine_st4;
        fpu_if.overflow     <= overflow_st4;
        fpu_if.underflow    <= underflow_st4;
        fpu_if.zero         <= zero_st4;
        fpu_if.div_by_zero  <= div_by_zero_st4;	  
    end




	
		

endmodule