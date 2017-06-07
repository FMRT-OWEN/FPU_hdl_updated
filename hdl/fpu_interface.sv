`timescale 1ns / 100ps
import definitions::*; 

  
interface fpu_interface(input logic clk,input logic reset); 
	fpu_instruction_t fpu_i;
	float_t out;
	logic		inf, snan, qnan;
	logic		ine;
	logic		overflow, underflow;
	logic		zero;
	logic		div_by_zero;
	
endinterface




