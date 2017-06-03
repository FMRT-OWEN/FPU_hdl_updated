//This is a top level testbench. HDL side. Contains XRTL Transactor


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

	//DUT Instantiation 
	reg load;
	reg [data_width-1:0]m,r;
	wire [(data_width*2)-1:0] product;
	wire done;

	booth_fsm #(data_width,data_width) m1(.clk(clk),.reset(reset),.load(load),.m(m),.r(r),.product(product),.done(done));


	//Input Pipe Instantiation 
	//receives 9 bytes = 4 bytes for opa + 4 bytes for opb and 
	//1 byte for opcode and rounding mode
	scemi_input_pipe #(.BYTES_PER_ELEMENT(9),
                   .PAYLOAD_MAX_ELEMENTS(1),
                   .BUFFER_MAX_ELEMENTS(100)
                   ) inputpipe(clk);
				   
	//Output Pipe Instantiation 
	//sends 5 bytes
	//first 4 bytes hold output of fpu operation
	//next byte holds the flag vector raised by the operation
	scemi_output_pipe #(.BYTES_PER_ELEMENT(5),
					   .PAYLOAD_MAX_ELEMENTS(1),
					   .BUFFER_MAX_ELEMENTS(100)
					   ) outputpipe(clk);
	//XRTL FSM to obtain operands from the HVL side
	bit [(data_width*2)-1:0]operands;
	bit eom=0;
	reg [7:0] ne_valid=0;
	reg issued;

	always@(posedge clk)
	begin
        
        if(reset)
        begin
                m <= {data_width{1'b0}};
                r <= {data_width{1'b0}};
                load <= 0;
               
        end
        else 
        if(done)
        begin
                if(!issued)
                  begin
                 
                
	            outputpipe.send(1,product,eom);   
		               
                    if(!eom)
			inputpipe.receive(2,ne_valid,operands,eom);
			
                    m <= operands[63:32];
                    r <= operands[31:0];
                    issued <=1;
                 end
                load <=1;
            end
        else
        
       begin
          issued<=0;
          load <=0;
        end        
        
	end

endmodule
