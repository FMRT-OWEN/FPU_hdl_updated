package randomizer;

import definitions::*;	

class random_instruction;

	rand fpu_instruction_t		instruction;

	//constraint the input vectors
	constraint exponent_c {
		
		//constrain operand a
		instruction.opa.sign inside {[0:1]};
		instruction.opa.exponent inside {[110:144]};
		instruction.opa.mantissa inside {[1:2**23-1]};
		
		// instruction.opa.sign inside {[0:1]};
		// instruction.opa.exponent inside {[0:255]};
		// instruction.opa.mantissa inside {[1:2**23-1]};
		
		//constrain operand b
		instruction.opb.sign inside {[0:1]};
		instruction.opb.exponent inside {[110:144]};
		instruction.opb.mantissa inside {[1:2**23-1]};
		
		// instruction.opb.sign inside {[0:1]};
		// instruction.opb.exponent inside {[0:255]};
		// instruction.opb.mantissa inside {[1:2**23-1]};


		//constrain round mode and op code
		instruction.rmode dist 
		{
			round_nearest_even	:= 20,
			round_to_zero		:= 0,
			round_up			:= 0,
			round_down			:= 0
		};
		
		instruction.fpu_op dist 
		{
			ADD:=	20,
			SUB:=	20,
			MULT:=	20,
			DIV:=	20,
			SQRT:=	0
		};
	}

	//constraint the input vectors
	constraint squareroot_c {
		
		//constrain operand a
		instruction.opa.sign ==0;
		instruction.opa.exponent inside {[110:144]};
		instruction.opa.mantissa inside {[1:2**23-1]};
		
		//constrain operand b
		instruction.opb.sign == 0;
		instruction.opb.exponent == 0;
		instruction.opb.mantissa == 0;


		//constrain round mode and op code
		instruction.rmode dist 
		{
			round_nearest_even	:= 20,
			round_to_zero		:= 0,
			round_up			:= 0,
			round_down			:= 0
		};
		
		instruction.fpu_op dist 
		{
			ADD:=	20,
			SUB:=	0,
			MULT:=	0,
			DIV:=	0,
			SQRT:=	20
		};
	}
endclass

endpackage