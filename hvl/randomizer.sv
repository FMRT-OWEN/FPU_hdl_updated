package randomizer;

import definitions::*;	

class random_instruction;

	rand fpu_instruction_t		instruction;

	
	//constraint the input vectors
	constraint exponent_c {
	
		instruction.fpu_op dist 
		{
			ADD:=	20,
			SUB:=	20,
			MULT:=	20,
			DIV:=	20,
			SQRT:=	20
		};
		
		//constrain operand a
		instruction.opa.sign inside {[0:1]};
		instruction.opa.exponent inside {[110:144],0};
		instruction.opa.mantissa inside {[0:2**23-1]};
		
		//non negative operand if operation is SQRT
		(instruction.fpu_op == SQRT)-> instruction.opa.sign == 0;		
		
		//constrain operand b
		instruction.opb.sign inside {[0:1]};
		instruction.opb.exponent inside {[110:144],0};
		instruction.opb.mantissa inside {[0:2**23-1]};

		//constrain round mode and op code
		instruction.rmode dist 
		{
			round_nearest_even	:= 20,
			round_to_zero		:= 0,
			round_up			:= 0,
			round_down			:= 0
		};
		
		
	}
	
endclass

endpackage