`timescale 1ns / 100ps
package definitions;

/* FPU Operations (fpu_op):
========================

0 = add
1 = sub
2 = mul
3 = div

Rounding Modes (rmode):
=======================

0 = round_nearest_even
1 = round_to_zero
2 = round_up
3 = round_down */

typedef enum logic [2:0]{ADD = 3'b000, SUB = 3'b001, MULT = 3'b010, DIV = 3'b011} fpu_op_t;   //fpu operation 

typedef enum logic [1:0]{round_nearest_even = 2'b00, round_to_zero = 2'b01, round_up = 2'b10, round_down= 2'b11} rmode_t; //rmode

typedef struct packed{	    //Float type oparand structure
	logic sign;
	logic[7:0] exponent;
	logic[22:0] mantissa;
}float_t;

typedef struct packed{
	fpu_op_t fpu_op;         //3 bit fpu opcode enumarated type
	rmode_t rmode;           //2 bit rmode enumarated type
	float_t opa;	         //32 bit floating type operand 1
	float_t opb;		     //32 bit floating type operand 2
}fpu_instruction_t;

endpackage 

`timescale 1ns / 100ps
import definitions::*; 

//Define the interface
interface fpu_interface(input logic clk,reset); 
	fpu_instruction_t fpu_i;
	float_t out;
	logic		inf, snan, qnan;
	logic		ine;
	logic		overflow, underflow;
	logic		zero;
	logic		div_by_zero;
	//Input Modport
	modport IN(input clk,
	output fpu_i); 
	
	//Output Modport
	modport OUT(input clk,	 
	input	    out,
	input		inf, snan, qnan,
	input		ine,
	input		overflow, underflow,
	input		zero,
	input		div_by_zero);

endinterface




