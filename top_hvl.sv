`timescale 1ns / 100ps
/**************************************************/
// Design Name: Floating Point Unit Verification
// Description: Interface 
// Dependencies: None
/**************************************************/
import definitions::*;

interface fpu_interface(input clk); 

//Input
//logic		clk;
fpu_instruction_t fpu_i;

//Output
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
input		div_by_zero
);

endinterface



/*****************************************************************/
// Design Name: Class Constructs
// Description: PacketIn,PacketOut, Driver, Reciever, ScoreBoard 
// Dependencies: None 
/*****************************************************************/

																		 
//*************************************PacketIn*****************************************/
class PacketIn;

rand fpu_instruction_t fpu_i;

//new() objects Allocated and Initialized via call to the new Constructor Method.
//Set the fields to values passed from argument default = 0.
//function new(fpu_instruction _fpu_i);
	//this.fpu_i = new(_fpu_i);
//endfunction

//display() -Display the content of the packet in a formatted way.
function void display_pktin();
	$display("rmode:%b",fpu_i.rmode);
	$display("fpu_op:%b",fpu_i.fpu_op);
	$display("opa:%b",fpu_i.opa);
	$display("opb:%b",fpu_i.opb);
endfunction: display_pktin

////pack the contents into a frame of 68 bits.
//function logic[67:0] pack();	   
//	pack = {this.fpu_i.rmode,this.fpu_i.fpu_op,this.fpu_i.opa,this.fpu_i.opb};
//endfunction: pack
//
////unpack the contents of a frame into a given Packet.
//function void unpack(input logic[68:0] _packed_data);
//	this.fpu_i.rmode = _packed_data[68:67];
//	this.fpu_i.fpu_op = _packed_data[66:64];
//	this.fpu_i.opa = _packed_data[64:32];
//	this.fpu_i.opb = _packed_data[31:0];
//endfunction: unpack

endclass


//*************************************PacketOut*****************************************/ 
//PacketOut class takes all output values from DUT
class PacketOut;

  
float_t	out;
logic		inf, snan, qnan;
logic		ine;
logic		overflow, underflow;
logic		zero;
logic 		div_by_zero;
 
//new( ) –Objects Allocated and Initialized via call to the new
//Constructor Method. Set the fields to values passed from argument 
//default = 0.

/*function new(float_t _out = 0,logic _inf = 0, logic _snan = 0,logic  _qnan = 0,logic _ine = 0,logic _overflow = 0, logic _underflow = 0,
             logic  _zero = 0,logic _div_by_zero = 0);
	this.out = _out;
	this.inf = _inf;
	this.snan = _snan;
	this.qnan = _qnan;
	this.ine = _ine;
	this.overflow = _overflow;
	this.underflow = _underflow;
	this.zero = _zero;
	this.div_by_zero = _div_by_zero;
endfunction*/

//display the contents of the packet in a formatted way.
	
function void display_pktout( );
	$display("out:%b",out);
	$display("inf:%b",inf);
	$display("snan:%b",snan);
	$display("qnan:%b",qnan);
	$display("ine:%b",ine);
	$display("overflow:%b",overflow);
	$display("underflow:%b",underflow);
	$display("zero:%b",zero);
	
endfunction: display_pktout

//pack the contents into a frame of 68 bits.
function logic[39:0] pack(logic [31:0] _out = 0, logic _inf =0, logic _snan=0, logic _qnan=0, logic _ine=0,logic _overflow=0,
                     logic _underflow = 0,logic  _zero =0, logic _div_by_zero =0);	   
	pack = {_out,_inf, _snan, _qnan, _ine, _overflow, _underflow, _zero, _div_by_zero};
endfunction: pack

//unpack the contents of a frame into a given Packet.
function void unpack(input logic[39:0] _packed_data);
      this.out = _packed_data[39:8];
	  this.inf = _packed_data[7];
	  this.snan = _packed_data[6];
	  this.qnan = _packed_data[5];
	  this.ine  = _packed_data[4];
	  this.overflow = _packed_data[3];
	  this.underflow = _packed_data[2];
	  this.zero = _packed_data[1];
	  this.div_by_zero = _packed_data[0];
endfunction: unpack  
	
endclass: PacketOut
	
/**************************************************************************************/


//*************************************DRIVER********************************************/
class Driver;	
//Virtual Interface Instantiation
virtual fpu_interface.IN INif;
//Packet to be written
PacketIn sentPkt;

//constraint the input vectors
constraint exponent_c {
  sentPkt.fpu_i.opa.exponent inside {[110:144]};
  sentPkt.fpu_i.opa.exponent inside {[110:144]};
  sentPkt.fpu_i.fpu_op inside {[0:3]};
}



//Constructor
function new(virtual fpu_interface.IN _INif);
	$display("%t [Driver]    new()",$time);
	this.INif = _INif;
endfunction		

task write();  
    sentPkt = new();
    sentPkt.randomize();

	$display("%t [Driver]    write(69'b%b)",$time,sentPkt.fpu_i);
	//Apply randomly generated packet to the interface
	sentPkt.display_pktin();
	this.INif.fpu_i = sentPkt.fpu_i;	 
        $display("Driver: intf = 69'b%b", this.INif.fpu_i);	
	//send to scoreboard
	//scoreboard.pktin = sentPkt.pack;
			   
	#10;
endtask:write

endclass: Driver
/**************************************************************************************/


//*************************************RECEIVER********************************************/
class Receiver;
//Virtual Interface Instantiation
virtual fpu_interface.OUT OUTif;
PacketOut rcvdPkt;

logic [39:0] tmp_pkt;

//constructor -to assign virtual interfaces
function new (virtual  fpu_interface.OUT _OUTif);
	$display("%t [Receiver]   new()", $time);
	this.OUTif = _OUTif;
endfunction
	
//Read Task
task read ();
	// Create a new packet that will be filled with the results 
	// from the device under test
	repeat(5) @(posedge this.OUTif.clk);
	rcvdPkt = new();
	// Take the data from the output interface of the device under test
        rcvdPkt.display_pktout();	
	tmp_pkt = rcvdPkt.pack (this.OUTif.out, 
	                        this.OUTif.inf, 
							this.OUTif.snan, 
							this.OUTif.qnan, 
							this.OUTif.ine,
							this.OUTif.overflow, 
							this.OUTif.underflow, 
							this.OUTif.zero, 
							this.OUTif.div_by_zero);
    	
        //$display("out = 32'h%h, inf = 1'b%b, snan = 1'b%b, qnan= 1'b%b, ine = 1'b%b, overflow = 1'b%b, underflow = 1'b%b, zero = 1'b%b, div_by_zero = 1'b%b",
        //           tmp_pkt[39:8], tmp_pkt[7], tmp_pkt[6], tmp_pkt[5], tmp_pkt[4], tmp_pkt[4], tmp_pkt[3], tmp_pkt[2], tmp_pkt[1], tmp_pkt[0]);

	
	
	//send received pkt to scoreboard
	
endtask:read 
	
endclass:Receiver

/**************************************************************************************/


//*************************************SCOREBOARD********************************************/
class ScoreBoard;

endclass

/**************************************************************************************/


//**************************Class Environment********************************************/
class Environment;																		  

//Virtual Interface Instantiation
virtual fpu_interface.IN INif;
virtual fpu_interface.OUT OUTif;

//Testbench component handles
Receiver receiver_cl;
Driver driver_cl;
ScoreBoard scoreboard_cl;

//Constructor -to assign virtual interface
function new(virtual fpu_interface.IN _INif,virtual fpu_interface.OUT _OUTif);
		this.INif =	_INif;
		this.OUTif = _OUTif;
endfunction

/**************************************************************************************/
//Instantiate the Driver, Receiver, ScoreBoard
task build();
$display("inside build");
driver_cl = new(this.INif);
receiver_cl = new(this.OUTif);	
scoreboard_cl = new();
endtask: build	


/**************************************************************************************/
//Reset the DUT by driving all input signals low
task reset(); 
   $display("execute reset");
   this.INif.fpu_i.opa =0; 
   this.INif.fpu_i.opb =0;
   this.INif.fpu_i.fpu_op =ADD;
   this.INif.fpu_i.rmode = round_nearest_even;
   //repeat(10) @(posedge this.INif.clk);
   $display("done reset");
endtask: reset

/**************************************************************************************/
//Start the Scoreboard
task start();
	//scoreboard_cl.start();
endtask

/**************************************************************************************/
//Run
task run(input integer NUM_OF_TESTS = 10);

    this.build();
	this.reset();							  
	
	$display("writing values");
	//fork
		//this.start();
		for(int i=0;i<NUM_OF_TESTS;i++)begin
			$display("inside num tests");
		//	@(posedge this.INif.clk);
		    driver_cl.write();
			receiver_cl.read();
	            repeat(10) @(posedge this.INif.clk);
		end
	//join_any
endtask

endclass: Environment

/****************************************************************************************/	

/**************************************************/ 
// Design Name  : Floating Point Unit Verification 
// Description  : Program Construct
// Dependencies : None 
/**************************************************/ 

program automatic test_1(fpu_interface.IN _INif,fpu_interface.OUT _OUTif );

//Class Instance creation
Environment env; 

initial 
begin 
	//Allocating memory
	env = new (_INif,_OUTif);
	//Number of Test Cases
	$display("entering env");
	env.run(2);
	$finish;
end 
endprogram : test_1	 




/**************************************************/
// Design Name: Floating Point Unit Verification
// Description: Test Bench Top Module 
// Dependencies: None 
/**************************************************/

module test(); 
	
event error_event;
logic clk;
//Intantiate Interface

fpu_interface fpu_interface_i(.clk(clk)); 


//Intantiate DUT 
fpu u0(.clk(fpu_interface_i.IN.clk), 
			.fpu_i(fpu_interface_i.IN.fpu_i),
			.out(fpu_interface_i.OUT.out),
			.inf(fpu_interface_i.OUT.inf), 
			.snan(fpu_interface_i.OUT.snan),
			.qnan(fpu_interface_i.OUT.qnan),
			.ine(fpu_interface_i.OUT.ine), 
			.overflow(fpu_interface_i.OUT.overflow),
			.underflow(fpu_interface_i.OUT.underflow),
			.zero(fpu_interface_i.OUT.zero),
			.div_by_zero(fpu_interface_i.OUT.div_by_zero));

//Intantiate Program block 
test_1 test_i(fpu_interface_i.IN,fpu_interface_i.OUT); 

initial begin
 clk = 0;
 forever begin 
  #250 clk = ~clk;
 end
end





initial begin
  $monitor("INTF: opa = 32'b%b, opb = 32'b%b", fpu_interface_i.IN.fpu_i.opa, fpu_interface_i.IN.fpu_i.opb); 
  $monitor("RTL: opa = 32'h%h, opb = 32'h%h", u0.opa_r, u0.opb_r);
  $monitor("INTF: out = 32'h%h", fpu_interface_i.OUT.out);
end


endmodule  
