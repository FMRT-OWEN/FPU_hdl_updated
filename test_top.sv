/////////////////////////////////////////////////////////////////////
////                                                             ////
////  FPU                                                        ////
////  Floating Point Unit (Single precision)                     ////
////                                                             ////
////  TEST BENCH                                                 ////
////                                                             ////
////  Author: Rudolf Usselmann                                   ////
////          rudi@asics.ws                                      ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2000 Rudolf Usselmann                         ////
////                    rudi@asics.ws                            ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////


`timescale 1ns / 100ps
import definitions::*;

module test;				
	
/************************************************************************************/	
//Built in real for verification of code
//real result;
//shortreal opa_real;
//shortreal opb_real;

/************************************************************************************/
	

reg		clk;
reg		reset;

fpu_interface fpu_if(clk,reset);
reg		test_exc;
reg		show_prog;
event	error_event;
//
integer	error, vcount;

fpu u0(fpu_if);
always #10 clk = ~clk; 

initial
   begin
	clk = 0;
	reset = 0; 
	
	#5 reset = 1;
	#5 reset = 0;
end
initial begin
repeat(1) begin
	
    @(posedge clk);	
	//**************************************************************************
			fpu_if.fpu_i.rmode = round_up;
			fpu_if.fpu_i.fpu_op = MULT;
			fpu_if.fpu_i.opa = 32'b 00111111100110011001100110011011;
			fpu_if.fpu_i.opb = 32'b 00111111110110011001100110011011; 
			$display("\n fpu_i.opa: %f,fpu_i.opb: %f,out_hex : %h out_float: %f",$bitstoshortreal(fpu_if.fpu_i.opa),$bitstoshortreal(fpu_if.fpu_i.opb),fpu_if.out,$bitstoshortreal(fpu_if.out));
			$display("reset = %b", fpu_if.reset);
	@(posedge clk);	 
	//**************************************************************************
			fpu_if.fpu_i.rmode = round_up;
			fpu_if.fpu_i.fpu_op = ADD;
			fpu_if.fpu_i.opa = 32'b 01000001101110011001100110011010;
			fpu_if.fpu_i.opb = 32'b 01000001101110011001100110011010; 
			$display("\n fpu_i.opa: %f,fpu_i.opb: %f,out_hex : %h out_float: %f",$bitstoshortreal(fpu_if.fpu_i.opa),$bitstoshortreal(fpu_if.fpu_i.opb),fpu_if.out,$bitstoshortreal(fpu_if.out));
		   $display("reset = %b", fpu_if.reset);
	@(posedge clk);
	//**************************************************************************
			fpu_if.fpu_i.rmode = round_down;
			fpu_if.fpu_i.fpu_op = DIV;
			fpu_if.fpu_i.opa = 32'b 00111111100000000000001000000000;
			fpu_if.fpu_i.opb = 32'b 01000000011011001100110011001101;
			$display("\n fpu_i.opa: %f,fpu_i.opb: %f,out_hex : %h out_float: %f",$bitstoshortreal(fpu_if.fpu_i.opa),$bitstoshortreal(fpu_if.fpu_i.opb),fpu_if.out,$bitstoshortreal(fpu_if.out));
		   $display("reset = %b", fpu_if.reset);
	
	@(posedge clk);
	//**************************************************************************
			fpu_if.fpu_i.rmode = round_down;
			fpu_if.fpu_i.fpu_op = MULT;
			fpu_if.fpu_i.opa = 32'b 01000000000000000000001000000000;
			fpu_if.fpu_i.opb = 32'b 01000000000000000000000010000000;
			
			$display("\n fpu_i.opa: %f,fpu_i.opb: %f,out_hex : %h out_float: %f",$bitstoshortreal(fpu_if.fpu_i.opa),$bitstoshortreal(fpu_if.fpu_i.opb),fpu_if.out,$bitstoshortreal(fpu_if.out));
			$display("reset = %b", fpu_if.reset);
	//**************************************************************************
	@(posedge clk);
	//**************************************************************************
			fpu_if.fpu_i.rmode = round_down;
			fpu_if.fpu_i.fpu_op = ADD;
			fpu_if.fpu_i.opa = 32'b 01000000000000000000001000000000;
			fpu_if.fpu_i.opb = 32'b 01000000000000000000000010000000;
			$display("\n fpu_i.opa: %f,fpu_i.opb: %f,out_hex : %h out_float: %f",$bitstoshortreal(fpu_if.fpu_i.opa),$bitstoshortreal(fpu_if.fpu_i.opb),fpu_if.out,$bitstoshortreal(fpu_if.out));
		   $display("reset = %b", fpu_if.reset);
	//**************************************************************************
	@(posedge clk);
	//**************************************************************************
			fpu_if.fpu_i.rmode = round_down;
			fpu_if.fpu_i.fpu_op = SUB;
			fpu_if.fpu_i.opa = 32'b 01000000000000000000001000000000;
			fpu_if.fpu_i.opb = 32'b 01000000000000000000000010000000;
			$display("\n fpu_i.opa: %f,fpu_i.opb: %f,out_hex : %h out_float: %f",$bitstoshortreal(fpu_if.fpu_i.opa),$bitstoshortreal(fpu_if.fpu_i.opb),fpu_if.out,$bitstoshortreal(fpu_if.out));
			$display("reset = %b", fpu_if.reset);
	//**************************************************************************
	@(posedge clk);
	//**************************************************************************
			fpu_if.fpu_i.rmode = round_down;
			fpu_if.fpu_i.fpu_op = DIV;
			fpu_if.fpu_i.opa = 32'b 01000000000000000000001000000000;
			fpu_if.fpu_i.opb = 32'b 01000000000000000000000010000000; 
			$display("\n fpu_i.opa: %f,fpu_i.opb: %f,out_hex : %h out_float: %f",$bitstoshortreal(fpu_if.fpu_i.opa),$bitstoshortreal(fpu_if.fpu_i.opb),fpu_if.out,$bitstoshortreal(fpu_if.out));
			$display("reset = %b", fpu_if.reset);
	//**************************************************************************
	@(posedge clk);
	//**************************************************************************
			fpu_if.fpu_i.rmode = round_down;
			fpu_if.fpu_i.fpu_op = DIV;
			fpu_if.fpu_i.opa = 32'b 01000000000000000000001000000000;
			fpu_if.fpu_i.opb = 32'b 01000000000000000000000010000000; 
			$display("\n fpu_i.opa: %f,fpu_i.opb: %f,out_hex : %h out_float: %f",$bitstoshortreal(fpu_if.fpu_i.opa),$bitstoshortreal(fpu_if.fpu_i.opb),fpu_if.out,$bitstoshortreal(fpu_if.out));
			$display("reset = %b", fpu_if.reset);
	//**************************************************************************
	@(posedge clk);
	//**************************************************************************
			fpu_if.fpu_i.rmode = round_down;
			fpu_if.fpu_i.fpu_op = DIV;
			fpu_if.fpu_i.opa = 32'b 01000000000000000000001000000000;
			fpu_if.fpu_i.opb = 32'b 01000000000000000000000010000000; 
			$display("\n fpu_i.opa: %f,fpu_i.opb: %f,out_hex : %h out_float: %f",$bitstoshortreal(fpu_if.fpu_i.opa),$bitstoshortreal(fpu_if.fpu_i.opb),fpu_if.out,$bitstoshortreal(fpu_if.out));
			$display("reset = %b", fpu_if.reset);
	//**************************************************************************

	
	@(posedge clk);
	$display("\n fpu_i.opa: %f,fpu_i.opb: %f,out_hex : %h out_float: %f",$bitstoshortreal(fpu_if.fpu_i.opa),$bitstoshortreal(fpu_if.fpu_i.opb),fpu_if.out,$bitstoshortreal(fpu_if.out));
	
	@(posedge clk);
	$display("\n fpu_i.opa: %f,fpu_i.opb: %f,out_hex : %h out_float: %f",$bitstoshortreal(fpu_if.fpu_i.opa),$bitstoshortreal(fpu_if.fpu_i.opb),fpu_if.out,$bitstoshortreal(fpu_if.out));
	
	@(posedge clk);
	$display("\n fpu_i.opa: %f,fpu_i.opb: %f,out_hex : %h out_float: %f",$bitstoshortreal(fpu_if.fpu_i.opa),$bitstoshortreal(fpu_if.fpu_i.opb),fpu_if.out,$bitstoshortreal(fpu_if.out));
	
	@(posedge clk);
	$display("\n fpu_i.opa: %f,fpu_i.opb: %f,out_hex : %h out_float: %f",$bitstoshortreal(fpu_if.fpu_i.opa),$bitstoshortreal(fpu_if.fpu_i.opb),fpu_if.out,$bitstoshortreal(fpu_if.out));
	
	@(posedge clk);
	$display("\n fpu_i.opa: %f,fpu_i.opb: %f,out_hex : %h out_float: %f",$bitstoshortreal(fpu_if.fpu_i.opa),$bitstoshortreal(fpu_if.fpu_i.opb),fpu_if.out,$bitstoshortreal(fpu_if.out));  
	
	@(posedge clk);
	$display("\n fpu_i.opa: %f,fpu_i.opb: %f,out_hex : %h out_float: %f",$bitstoshortreal(fpu_if.fpu_i.opa),$bitstoshortreal(fpu_if.fpu_i.opb),fpu_if.out,$bitstoshortreal(fpu_if.out));
	
	@(posedge clk);
	$display("\n fpu_i.opa: %f,fpu_i.opb: %f,out_hex : %h out_float: %f",$bitstoshortreal(fpu_if.fpu_i.opa),$bitstoshortreal(fpu_if.fpu_i.opb),fpu_if.out,$bitstoshortreal(fpu_if.out));
	
	@(posedge clk);
	$display("\n fpu_i.opa: %f,fpu_i.opb: %f,out_hex : %h out_float: %f",$bitstoshortreal(fpu_if.fpu_i.opa),$bitstoshortreal(fpu_if.fpu_i.opb),fpu_if.out,$bitstoshortreal(fpu_if.out));
	
	@(posedge clk);
	$display("\n fpu_i.opa: %f,fpu_i.opb: %f,out_hex : %h out_float: %f",$bitstoshortreal(fpu_if.fpu_i.opa),$bitstoshortreal(fpu_if.fpu_i.opb),fpu_if.out,$bitstoshortreal(fpu_if.out));
	
	@(posedge clk);
	$display("\n fpu_i.opa: %f,fpu_i.opb: %f,out_hex : %h out_float: %f",$bitstoshortreal(fpu_if.fpu_i.opa),$bitstoshortreal(fpu_if.fpu_i.opb),fpu_if.out,$bitstoshortreal(fpu_if.out));
	
	@(posedge clk);
	$display("\n fpu_i.opa: %f,fpu_i.opb: %f,out_hex : %h out_float: %f",$bitstoshortreal(fpu_if.fpu_i.opa),$bitstoshortreal(fpu_if.fpu_i.opb),fpu_if.out,$bitstoshortreal(fpu_if.out));
	
	@(posedge clk);
	$display("\n fpu_i.opa: %f,fpu_i.opb: %f,out_hex : %h out_float: %f",$bitstoshortreal(fpu_if.fpu_i.opa),$bitstoshortreal(fpu_if.fpu_i.opb),fpu_if.out,$bitstoshortreal(fpu_if.out));
	
	@(posedge clk);
	$display("\n fpu_i.opa: %f,fpu_i.opb: %f,out_hex : %h out_float: %f",$bitstoshortreal(fpu_if.fpu_i.opa),$bitstoshortreal(fpu_if.fpu_i.opb),fpu_if.out,$bitstoshortreal(fpu_if.out));
	
	@(posedge clk);
	$display("\n fpu_i.opa: %f,fpu_i.opb: %f,out_hex : %h out_float: %f",$bitstoshortreal(fpu_if.fpu_i.opa),$bitstoshortreal(fpu_if.fpu_i.opb),fpu_if.out,$bitstoshortreal(fpu_if.out));
	
	@(posedge clk);
	$display("\n fpu_i.opa: %f,fpu_i.opb: %f,out_hex : %h out_float: %f",$bitstoshortreal(fpu_if.fpu_i.opa),$bitstoshortreal(fpu_if.fpu_i.opb),fpu_if.out,$bitstoshortreal(fpu_if.out));
end	

		
   $finish;
   end


endmodule




























