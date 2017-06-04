/////////////////////////////////////////////////////////////////////
////                                                             ////
////  EXCEPT                                                     ////
////  Floating Point Exception/Special Numbers Unit              ////
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


//`timescale 1ns / 100ps


module except(	clk, reset,opa, opb, inf, ind, qnan, snan, opa_nan, opb_nan,
		opa_00, opb_00, opa_inf, opb_inf, opa_dn, opb_dn);
input		clk, reset;
input	[31:0]	opa, opb;
output		inf, ind, qnan, snan, opa_nan, opb_nan;
output		opa_00, opb_00;
output		opa_inf, opb_inf;
output		opa_dn;
output		opb_dn;

////////////////////////////////////////////////////////////////////////
//
// Local Wires and registers
//

logic	[7:0]	expa, expb;		// alias to opX exponent
logic	[22:0]	fracta, fractb;		// alias to opX fraction
logic		expa_ff, infa_f_r, qnan_r_a, snan_r_a;
logic		expb_ff, infb_f_r, qnan_r_b, snan_r_b;
logic		inf, ind, qnan, snan;	// Output registers
logic		opa_nan, opb_nan;
logic		expa_00, expb_00, fracta_00, fractb_00;
logic		opa_00, opb_00;
logic		opa_inf, opb_inf;
logic		opa_dn, opb_dn;

////////////////////////////////////////////////////////////////////////
//
// Aliases
//

assign   expa = opa[30:23];
assign   expb = opb[30:23];
assign fracta = opa[22:0];
assign fractb = opb[22:0];

////////////////////////////////////////////////////////////////////////
//
// Determine if any of the input operators is a INF or NAN or any other special number
//

always_ff @(posedge clk or posedge reset)
	if ( reset == 1'b1) expa_ff <= 0;
	else expa_ff <= /*#1*/ &expa;

always_ff @(posedge clk or posedge reset)
	if ( reset == 1'b1) expb_ff <= 0;
	else expb_ff <= /*#1*/ &expb;
	
always_ff @(posedge clk or posedge reset) 
	if ( reset == 1'b1) infa_f_r <= 0;
	else infa_f_r <= /*#1*/ !(|fracta);

always_ff @(posedge clk or posedge reset)
	if ( reset == 1'b1) infb_f_r <= 0;
	else infb_f_r <= /*#1*/ !(|fractb);

always_ff @(posedge clk or posedge reset)
	if ( reset == 1'b1) qnan_r_a <= 0;
	else qnan_r_a <= /*#1*/  fracta[22];

always_ff @(posedge clk or posedge reset)
	if ( reset == 1'b1) snan_r_a <= 0;
	else snan_r_a <= /*#1*/ !fracta[22] & |fracta[21:0];
	
always_ff @(posedge clk or posedge reset)
	if ( reset == 1'b1) qnan_r_b <= 0;
	else qnan_r_b <= /*#1*/  fractb[22];

always_ff @(posedge clk or posedge reset)
	if ( reset == 1'b1) snan_r_b <= 0;
	else snan_r_b <= /*#1*/ !fractb[22] & |fractb[21:0];

always_ff @(posedge clk or posedge reset)
	if ( reset == 1'b1) ind <= 0;
	else ind  <= /*#1*/ (expa_ff & infa_f_r) & (expb_ff & infb_f_r);

always_ff @(posedge clk or posedge reset)
	if ( reset == 1'b1) inf <= 0;
	else inf  <= /*#1*/ (expa_ff & infa_f_r) | (expb_ff & infb_f_r);

always_ff @(posedge clk or posedge reset)
	if ( reset == 1'b1) qnan <= 0;
	else qnan <= /*#1*/ (expa_ff & qnan_r_a) | (expb_ff & qnan_r_b);

always_ff @(posedge clk or posedge reset)
	if ( reset == 1'b1) snan <= 0;
	else snan <= /*#1*/ (expa_ff & snan_r_a) | (expb_ff & snan_r_b);

always_ff @(posedge clk or posedge reset)
	if ( reset == 1'b1) opa_nan <= 0;
	else opa_nan <= /*#1*/ &expa & (|fracta[22:0]);

always_ff @(posedge clk or posedge reset)
	if ( reset == 1'b1) opb_nan <= 0;
	else opb_nan <= /*#1*/ &expb & (|fractb[22:0]);

always_ff @(posedge clk or posedge reset)
	if ( reset == 1'b1) opa_inf <= 0;
	else opa_inf <= /*#1*/ (expa_ff & infa_f_r);

always_ff @(posedge clk or posedge reset)
	if ( reset == 1'b1) opb_inf <= 0;
	else opb_inf <= /*#1*/ (expb_ff & infb_f_r);

always_ff @(posedge clk or posedge reset)
	if ( reset == 1'b1) expa_00 <= 0;
	else expa_00 <= /*#1*/ !(|expa);

always_ff @(posedge clk or posedge reset)
	if ( reset == 1'b1) expb_00 <= 0;
	else expb_00 <= /*#1*/ !(|expb);

always_ff @(posedge clk or posedge reset)
	if ( reset == 1'b1) fracta_00 <= 0;
	else fracta_00 <= /*#1*/ !(|fracta);

always_ff @(posedge clk or posedge reset)
	if ( reset == 1'b1) fractb_00 <= 0;
	else fractb_00 <= /*#1*/ !(|fractb);

always_ff @(posedge clk or posedge reset)
	if ( reset == 1'b1) opa_00 <= 0;
	else opa_00 <= /*#1*/ expa_00 & fracta_00;

always_ff @(posedge clk or posedge reset)
	if ( reset == 1'b1) opb_00 <= 0;
	else opb_00 <= /*#1*/ expb_00 & fractb_00;

always_ff @(posedge clk or posedge reset)
	if ( reset == 1'b1) opa_dn <= 0;
	else opa_dn <= /*#1*/ expa_00;

always_ff @(posedge clk or posedge reset)
	if ( reset == 1'b1) opb_dn <= 0;
	else opb_dn <= /*#1*/ expb_00;

endmodule

