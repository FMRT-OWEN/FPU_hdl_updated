//This is a top level testbench. HDL side. Contains XRTL Transactor

//`timescale 1ns / 100ps

	module top;

	//clk generation logic 
	reg 	clk;
	reg		reset;
	
	//tbx clkgen
	initial
	begin
        clk=0;
        forever #5 clk=~clk;
	end

	//tbx clkgen
	initial 
	begin
		reset =1;
		#10 reset=0;
	end

	localparam data_width = 32;
	
	//DUT Instantiation 
	wire 	[(data_width)-1:0] 		result;
	wire 	[7:0]					flag_vector;

	//creating interface
	fpu_interface fpu_if(clk,reset);
	
	//instantiating the DUT
	fpu fpu_inst(fpu_if);

	assign result = fpu_if.out;
	assign flag_vector = {fpu_if.inf,fpu_if.snan,fpu_if.qnan,fpu_if.ine,fpu_if.overflow,fpu_if.underflow,fpu_if.zero,fpu_if.div_by_zero};
	
	//Input Pipe Instantiation 
	//receives 9 bytes = 4 bytes for opa + 4 bytes for opb and 
	//1 byte for opcode and rounding mode
	scemi_input_pipe #(.BYTES_PER_ELEMENT(9),
                   .PAYLOAD_MAX_ELEMENTS(1),
                   .BUFFER_MAX_ELEMENTS(500)
                   ) inputpipe(clk);
				   
	//Output Pipe Instantiation 
	//sends 5 bytes
	//first 4 bytes hold output of fpu operation
	//next byte holds the flag vector raised by the operation
	scemi_output_pipe #(.BYTES_PER_ELEMENT(5),
					   .PAYLOAD_MAX_ELEMENTS(1),
					   .BUFFER_MAX_ELEMENTS(500)
					   ) outputpipe(clk);
					   
	//XRTL FSM to obtain operands from the HVL side	
	bit [(data_width*2)+8-1:0]	incoming;
	bit 						eom=0;
	reg [7:0] 					ne_valid=0;
	reg 						issued;

	always@(posedge clk)
	begin
		
        if(reset)
        begin
                fpu_if.fpu_i.opa 		<= '0;
				fpu_if.fpu_i.opb 		<= '0;
				$cast(fpu_if.fpu_i.rmode,'0);
				$cast(fpu_if.fpu_i.fpu_op,'0);
               
        end
        else 
        begin     
			
				outputpipe.send(1,{flag_vector,result},eom);   
				   
				if(!eom)
					inputpipe.receive(1,ne_valid,incoming,eom);
					
				fpu_if.fpu_i.opa 		<= incoming[63:32];
				fpu_if.fpu_i.opb 		<= incoming[31:0];
				$cast(fpu_if.fpu_i.rmode,incoming[65:64]);
				$cast(fpu_if.fpu_i.fpu_op,incoming[68:66]);
				issued 		<=1;
		end
		
        
	end
	
	

endmodule
