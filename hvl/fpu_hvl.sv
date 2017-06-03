// This is HVL for FPU verification environment that runs on the Workstation


import scemi_pipes_pkg::*; // For trans-language TLM channels.
import definitions::*;

//File Handlers
int		operanda_file;
int		operandb_file;
int		output_file;

//local parameters
localparam data_width =	32;

//SystemVerilog Queue to store test cases that were sent
//These are popped and given to the golden model once a result is obtained from the emulator 
//DUT takes a total of 69 bits as input, closest byte value is 9 bytes
fpu_instruction_t sent_queue [$];

//Since DUT outputs a result of "zero" during reset, it is ignored by startup variable
logic startup = 0;

//When debug is 1, results are printed on terminal
parameter debug=1;

//When file is 1, multiplicand, multiplier and results are written to text files
parameter file = 1;

int error_count;

//Scoreboard class
//This class monitors the output pipe. It creates a new object for outputpipe 
// A task runs continuously monitoring the output pipe 
class scoreboard;
	
	//Class attributes
	float_t 					opa;
	float_t						opb;
	float_t 					result;
	float_t						expected_result;
	byte						flag_vector; 
	fpu_instruction_t			instruction;
	scemi_dynamic_output_pipe 	monitorChannel;
	
	//constructor
	function new ();
	begin
		//instantiates the output pipe
		monitorChannel = new ("top.outputpipe");
		
		//setup the file handle
		if(file) 
		begin
			output_file=$fopen("output.txt","w");
			$fwrite(output_file,"Output\n");
		end
		
	end
	endfunction

	task run();
		
		bit 	eom_flag; 
		bit 	ne_valid; 
		
		while (1)
		begin
			
			//holds the data received from HDL
			//first 4 bytes hold output of fpu operation
			//next byte holds the flag vector raised by the operation
			automatic byte unsigned data_received[] = new[5];
			
			//receives the data from HDL
			//bytes are packed in such way that LSByte of the data sent from HDL
			//will be 0th element of data_received
			//Note- this task is blocking. Waits here until result is available 
			monitorChannel.receive_bytes(1, ne_valid, data_received, eom_flag);
			
			//unpacking the data_received
			//MSByte goes to flag vector
			//remaining bytes go to expected_result of type float_t
			//NOTE: this logic depends on the order in which data is sent from HDL
			{flag_vector, result} = { >> float_t {data_received}};
			
			// if(startup)
			// begin 
			//pop out the instruction which was sent earlier 
			instruction=sent_queue.pop_front;	

			//TODO: write proper logic
			//performing addition of the operands
			expected_result = $shortrealtobits(shortreal'(instruction.opa) + shortreal'(instruction.opb)); 

			//checking the correctness of the received result
			if(expected_result !== result)		//If obtained and expected products don't match, its an error
			begin
			$display("Error: opa=%f opb=%f expected result=%f obtained product =%f",instruction.opa,instruction.opb,expected_result,result);
			error_count++;
			end

			if(file)	//Write to file if file I/O is enabled 
			$fwrite(output_file,"%0f\n",result);
		
			if(debug)	//Display in debug 
			$display("opa=%f opb=%f Expected result=%f Obtained result =%f",instruction.opa,instruction.opb,expected_result,result);
			// end
			
			// if(!startup)	//The first result sent is zero (in reset). Its ignored 
			// startup = 1;
		end	
	endtask

endclass

	

//Stimulus (test) generation class 
//This generates testecases with SV inline randomization 
//To avoid recompilation of the code, user input is taken during vsim command
//invoke. This user input is RUNS and SIGNS. Runs tells how many test cases
//to be generated and Signs tells the sign of the multiplicand and multiplier. 

class stimulus_gen ;

	// handle is driver channel , the handle is to my pipe
	scemi_dynamic_input_pipe 	driverChannel;
	fpu_instruction_t			instruction;
	
	//Constructor
	function new();			
		begin
			// connecting the handle to the input pipe, input pipe is the instance in  hdl
			driverChannel 		= new ("top.inputpipe");	
			instruction.rmode 	= round_nearest_even;
			instruction.fpu_op	= ADD;
			
			//if true, then stimulus will be taken from file
			if(file) 
			begin 	
				operanda_file=$fopen("operanda.txt","w");
				operandb_file=$fopen("operandb.txt","w");
				$fwrite(operanda_file,"operanda\n");
				$fwrite(operandb_file,"operandb\n");
			end
			
		end
	endfunction

	task run;
		input [31:0]	runs;		
		input [15:0]	signs;
		
		//queue should hold 9 bytes 
		//1 byte for opcode and rounding mode
		//4 bytes for opa + 4 bytes for opb 
		automatic byte unsigned data_send[] = new[9];
		
		//runs number of testcases	wanted to generate	, that no. of cycles
		repeat(runs)		
		begin			
			
			//generating operands based on sign 
			case(signs)	
				   "++": 
						begin
							if(randomize(instruction.opa) with {instruction.opa > 0;instruction.opa < ((2**31)-1);});
							//if(debug) $display("m=%d",m);
							if(randomize(instruction.opb) with { instruction.opb>0;instruction.opb<((2**31)-1);});
							//if(debug) $display("r=%d",r);
						end
					
					"--":
						begin
							if(randomize(instruction.opa) with {instruction.opa<0;instruction.opa>(-(2**31));});
							//if(debug) $display("m=%d",m);
							if(randomize(instruction.opb) with {instruction.opb>(-(2**31));});
						end
  
					"+-":
						begin
							if(randomize(instruction.opa) with { instruction.opa>0;instruction.opa<((2**31)-1);});
							//if(debug) $display("m=%d",m);
							if(randomize(instruction.opb) with { instruction.opb<0;instruction.opb>((-2**31));});
							//if(debug) $display("m=%d",m);         
						end 
						
					"-+":
						begin
							if(randomize(instruction.opa) with {instruction.opa<0;instruction.opa>(-(2**31));});
							//if(debug) $display("m=%d",m);
							if(randomize(instruction.opb) with {instruction.opb>0;instruction.opb<((2**31)-1);});
							//if(debug) $display("m=%d",m);       
						end
  
				default:
						begin
							if(randomize(instruction.opa) with { instruction.opa>0;instruction.opa<50;});
							//if(debug) $display("m=%d",m);
							if(randomize(instruction.opb) with { instruction.opb>0;instruction.opb<20;});
							//if(debug) $display("m=%d",m);								
						end
			endcase	
			
			sent_queue.push_back(instruction);	
			
			// foreach(data_send[i])
			// begin
				// data_send[i] = instruction[7:0];
				// instruction = {8'b0,instruction[31:8]};
			// end 
			
			//packing instruction struct into a queue of bytes
			//0th byte represents {3'b0,3bit opcode,2bit round mode}
			//followed by 4 bytes of opa,
			//followed by 4 bytes of opb
			//total bytes packed = 9 bytes
			data_send= {>>{3'b0,instruction}};
			
			//filling the input pipe with data_send
			driverChannel.send_bytes(1, data_send, 0);
			
			//write the operands to file is the file flag is set
			//TODO: write round mode and opcode as well
			if(file) 
			begin 
				$fwrite(operanda_file,"%0d\n",instruction.opa);
				$fwrite(operandb_file,"%0d\n",instruction.opb);
			end
		end
		
		//when requried number of runs are reached, send eom flag as 1
		data_send[0]=0;
		driverChannel.send_bytes(1,data_send ,1);
		
		//flush the pipe to initiate the processing of data in input pipe
		driverChannel.flush_pipe;		
			 
	endtask

endclass


module booth_hvl;

	scoreboard scb;
	stimulus_gen stim_gen;
	integer runs;
	reg [15:0]signs;

	task run();			//used fork join done to use
	  integer i;
		fork
		begin
			scb.run();
		end
		join_none
	
		fork			
		begin
			stim_gen.run(runs,signs);
		end			
		join_none
	endtask

	initial 
	fork
	  if($value$plusargs("RUNS=%d",runs))	//is a way to take input
		$display("Generating %d Operands",runs);
		
	   if($value$plusargs("SIGNS=%s",signs))
		$display("Generating Multiplicand with %c Sign and Multiplier with %c Sign",signs[15:8],signs[7:0]);
				
		scb = new();			
		stim_gen = new();
		$display("\nStarted at"); $system("date");
		run();
		
		
	join_none

final
begin
	$display("\nEnded at"); $system("date");
	if(!error_count)
	$display("All tests are successful");
	else
	$display("%0d Tests failed",error_count);
end
endmodule
 



