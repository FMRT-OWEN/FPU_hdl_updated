module Sqrt_testbench;
  reg [26:0] iA_27;
  reg iCLK;
  wire [31:0] oInvSqrt;
  wire [31:0] Sqrt;
  reg [31:0] iA;

  FpSqrt SQT(iCLK,iA,oInvSqrt,Sqrt);

  initial begin	
	  iCLK = 0;	
	  forever #1 iCLK=~iCLK; 
  end
  
  initial begin		  
   repeat(1) begin
	  //@(posedge iCLK )
	  #20;
	  iA_27=   27'b010000011100111100110011001;
	  iA=32'b01000001110011110011001100110011;
	  @(posedge iCLK ) 
	  $display("input_27:%f,input_32:%f,Output:%f",$bitstoshortreal({iA_27,5'b0}),$bitstoshortreal(iA),$bitstoshortreal(Sqrt));
//	  $display("SQT.s1_mult.oProd: %f",$bitstoshortreal(SQT.s1_mult.Prod));	
//	  $display("SQT.s2_mult.oProd: %f",$bitstoshortreal(SQT.s2_mult.Prod));
	 // $display("SQT.s3_add.oSum: %f",$bitstoshortreal(SQT.s3_add.Sum));
	  //$display("SQT.s3_add.oSum: %f",$bitstoshortreal(SQT.s4_add.Sum));
//	  $display("SQT.s3_add.oSum: %f",$bitstoshortreal(SQT.s4_add.opa));
//	  $display("SQT.s3_add.oSum: %f",$bitstoshortreal(SQT.s4_add.opb));	 
//	  $display("SQT.s3_add.oSum: %b",SQT.s4_add.opa_fraction);
//	  $display("SQT.s3_add.oSum: %b",SQT.s4_add.A_f_shifted);
//	  $display("SQT.s3_add.oSum: %b",SQT.s4_add.B_f_shifted);
//	  $display("SQT.s3_add.oSum: %b",SQT.s4_add.A_larger);
//	  $display("SQT.s3_add.oSum: %b",SQT.s4_add.pre_sum);
//	  $display("SQT.s3_add.oSum: %b",SQT.s4_add.shft_amt);
//	   $display("SQT.s3_add.oSum: %b",SQT.s4_add.pre_frac_shft);
//	  $display("SQT.s3_add.oSum: %b",SQT.s4_add.oSum_f);		
//	  $display("SQT.s3_add.oSum: %b",SQT.s4_add.Sum);
//	  $display("SQT.s3_add.oSum: %b",SQT.s4_add.oSum_e);
	  // $display("SQT.s3_add.oSum: %f",$bitstoshortreal(SQT.s3_add.Sum));
	  
	 // $display("SQT.s5_mult.oProd: %f",$bitstoshortreal(SQT.s5_mult.Prod));
//	  $display("SQT.s6_mult.oProd: %f",$bitstoshortreal(SQT.s6_mult.Prod));
	  
	  //@(posedge iCLK )	 
	  #20;
	  iA_27=   27'b010000001101011001100110011;
	  iA=32'b0100_0000_1101_0110_0110_0110_0110_0110;
	  @(posedge iCLK ) 
	  $display("input_27:%f,input_32:%f,Output:%f",$bitstoshortreal({iA_27,5'b0}),$bitstoshortreal(iA),$bitstoshortreal(Sqrt));
	//  $display("SQT.s1_mult.oProd: %f",$bitstoshortreal(SQT.s1_mult.Prod));
//	  $display("SQT.s2_mult.oProd: %f",$bitstoshortreal(SQT.s2_mult.Prod));
	//  $display("SQT.s3_add.oSum: %f",$bitstoshortreal(SQT.s3_add.Sum));
	//  $display("SQT.s3_add.oSum: %f",$bitstoshortreal(SQT.s4_add.Sum));
//	  $display("SQT.s3_add.oSum: %f",$bitstoshortreal(SQT.s4_add.opa));
//	  $display("SQT.s3_add.oSum: %f",$bitstoshortreal(SQT.s4_add.opb));
	 // $display("SQT.s5_mult.oProd: %f",$bitstoshortreal(SQT.s5_mult.Prod));
//	  $display("SQT.s6_mult.oProd: %f",$bitstoshortreal(SQT.s6_mult.Prod));
	  
	  // @(posedge iCLK ) 
	  #20;							   
	  iA_27=   27'b010000101111111011001100110;
	  iA=32'b01000010111111101100110011001101;
	  @(posedge iCLK ) 
	  $display("input_27:%f,input_32:%f,Output:%f",$bitstoshortreal({iA_27,5'b0}),$bitstoshortreal(iA),$bitstoshortreal(Sqrt));
	  //$display("SQT.s1_mult.oProd: %f",$bitstoshortreal(SQT.s1_mult.Prod));	
//	  $display("SQT.s2_mult.oProd: %f",$bitstoshortreal(SQT.s2_mult.Prod));
	 // $display("SQT.s3_add.oSum: %f",$bitstoshortreal(SQT.s3_add.Sum));	
	  // $display("SQT.s3_add.oSum: %f",$bitstoshortreal(SQT.s4_add.Sum));
//	  $display("SQT.s3_add.oSum: %f",$bitstoshortreal(SQT.s4_add.opa));
//	  $display("SQT.s3_add.oSum: %f",$bitstoshortreal(SQT.s4_add.opb));
//	  $display("SQT.s5_mult.oProd: %f",$bitstoshortreal(SQT.s5_mult.Prod));
//	  $display("SQT.s6_mult.oProd: %f",$bitstoshortreal(SQT.s6_mult.Prod));
//	  
	  //@(posedge iCLK ) 
	  #20;
	  iA_27=   27'b010000100011010000000000000;
	  iA =32'b01000010100001111001100110011010;
	  @(posedge iCLK ) 
	  $display("input_27:%f,input_32:%f,Output:%f",$bitstoshortreal({iA_27,5'b0}),$bitstoshortreal(iA),$bitstoshortreal(Sqrt));
	 // $display("SQT.s1_mult.oProd: %f",$bitstoshortreal(SQT.s1_mult.Prod));	
//	  $display("SQT.s2_mult.oProd: %f",$bitstoshortreal(SQT.s2_mult.Prod));
//	  $display("SQT.s3_add.oSum: %f",$bitstoshortreal(SQT.s3_add.Sum));	
//	    $display("SQT.s3_add.oSum: %f",$bitstoshortreal(SQT.s3_add.opa));
//	  $display("SQT.s3_add.oSum: %f",$bitstoshortreal(SQT.s3_add.opb));
//	  $display("SQT.s5_mult.oProd: %f",$bitstoshortreal(SQT.s5_mult.Prod));
//	  $display("SQT.s6_mult.oProd: %f",$bitstoshortreal(SQT.s6_mult.Prod));
	  
	  // @(posedge iCLK )
	  #20;
	  iA_27=   27'b010000000011100110011001100;
	  iA=32'b01000000001110011001100110011010;
	  @(posedge iCLK ) 
	  $display("input_27:%f,input_32:%f,Output:%f",$bitstoshortreal({iA_27,5'b0}),$bitstoshortreal(iA),$bitstoshortreal(Sqrt));
	//  $display("SQT.s1_mult.oProd: %f",$bitstoshortreal(SQT.s1_mult.Prod));	
//	  $display("SQT.s2_mult.oProd: %f",$bitstoshortreal(SQT.s2_mult.Prod));
//	  $display("SQT.s3_add.oSum: %f",$bitstoshortreal(SQT.s3_add.Sum));	
//	    $display("SQT.s3_add.oSum: %f",$bitstoshortreal(SQT.s3_add.opa));
//	  $display("SQT.s3_add.oSum: %f",$bitstoshortreal(SQT.s3_add.opb));
//	  $display("SQT.s5_mult.oProd: %f",$bitstoshortreal(SQT.s5_mult.Prod));
//	  $display("SQT.s6_mult.oProd: %f",$bitstoshortreal(SQT.s6_mult.Prod));

iA =32'b00111111100110011001100110011010;
	   #20;
	    @(posedge iCLK ) 
	  $display("input_27:%f,input_32:%f,Output:%f",$bitstoshortreal({iA_27,5'b0}),$bitstoshortreal(iA),$bitstoshortreal(Sqrt));
//	  $display("SQT.s1_mult.oProd: %f",$bitstoshortreal(SQT.s1_mult.Prod));	
//	  $display("SQT.s2_mult.oProd: %f",$bitstoshortreal(SQT.s2_mult.Prod));
//	  $display("SQT.s3_add.oSum: %f",$bitstoshortreal(SQT.s3_add.Sum));
//	    $display("SQT.s3_add.oSum: %f",$bitstoshortreal(SQT.s3_add.opa));
//	  $display("SQT.s3_add.oSum: %f",$bitstoshortreal(SQT.s3_add.opb));
//	  $display("SQT.s5_mult.oProd: %f",$bitstoshortreal(SQT.s5_mult.Prod));
//	  $display("SQT.s6_mult.oProd: %f",$bitstoshortreal(SQT.s6_mult.Prod));
	  
#20;						
iA =32'b01000010100111000110011001100110;
	   @(posedge iCLK ) 
	   $display("input_27:%f,input_32:%f,Output:%f",$bitstoshortreal({iA_27,5'b0}),$bitstoshortreal(iA),$bitstoshortreal(Sqrt));
	  // $display("SQT.s1_mult.oProd: %f",$bitstoshortreal(SQT.s1_mult.Prod));	
//	  $display("SQT.s2_mult.oProd: %f",$bitstoshortreal(SQT.s2_mult.Prod));
//	  $display("SQT.s3_add.oSum: %f",$bitstoshortreal(SQT.s3_add.Sum));
//	    $display("SQT.s3_add.oSum: %f",$bitstoshortreal(SQT.s3_add.opa));
//	  $display("SQT.s3_add.oSum: %f",$bitstoshortreal(SQT.s3_add.opb));
//	  $display("SQT.s5_mult.oProd: %f",$bitstoshortreal(SQT.s5_mult.Prod));
//	  $display("SQT.s6_mult.oProd: %f",$bitstoshortreal(SQT.s6_mult.Prod));
	   
#20;		
iA =32'b01000010000100000000000000000000;
	   @(posedge iCLK ) 
	   $display("input_27:%f,input_32:%f,Output:%f",$bitstoshortreal({iA_27,5'b0}),$bitstoshortreal(iA),$bitstoshortreal(Sqrt));
	   	//  $display("SQT.s1_mult.oProd: %f",$bitstoshortreal(SQT.s1_mult.Prod));	
//	  $display("SQT.s2_mult.oProd: %f",$bitstoshortreal(SQT.s2_mult.Prod));
//	  $display("SQT.s3_add.oSum: %f",$bitstoshortreal(SQT.s3_add.Sum));
//	    $display("SQT.s3_add.oSum: %f",$bitstoshortreal(SQT.s3_add.opa));
//	  $display("SQT.s3_add.oSum: %f",$bitstoshortreal(SQT.s3_add.opb));
//	  $display("SQT.s5_mult.oProd: %f",$bitstoshortreal(SQT.s5_mult.Prod));
//	  $display("SQT.s6_mult.oProd: %f",$bitstoshortreal(SQT.s6_mult.Prod));
	   
#20;	   
iA =32'b01000001000011100110011001100110;
	   @(posedge iCLK ) 
	   $display("input_27:%f,input_32:%f,Output:%f",$bitstoshortreal({iA_27,5'b0}),$bitstoshortreal(iA),$bitstoshortreal(Sqrt)); 
	   //	  $display("SQT.s1_mult.oProd: %f",$bitstoshortreal(SQT.s1_mult.Prod));	
//	  $display("SQT.s2_mult.oProd: %f",$bitstoshortreal(SQT.s2_mult.Prod));
//	  $display("SQT.s3_add.oSum: %f",$bitstoshortreal(SQT.s3_add.Sum));
//	    $display("SQT.s3_add.oSum: %f",$bitstoshortreal(SQT.s3_add.opa));
//	  $display("SQT.s3_add.oSum: %f",$bitstoshortreal(SQT.s3_add.opb));
//	  $display("SQT.s5_mult.oProd: %f",$bitstoshortreal(SQT.s5_mult.Prod));
//	  $display("SQT.s6_mult.oProd: %f",$bitstoshortreal(SQT.s6_mult.Prod));
//	  	 																	 \


#20;	   

	   @(posedge iCLK ) 
	   $display("input_27:%f,input_32:%f,Output:%f",$bitstoshortreal({iA_27,5'b0}),$bitstoshortreal(iA),$bitstoshortreal(Sqrt)); 
	   //	  $display("SQT.s1_mult.oProd: %f",$bitstoshortreal(SQT.s1_mult.Prod));	
//	  $display("SQT.s2_mult.oProd: %f",$bitstoshortreal(SQT.s2_mult.Prod));
//	  $display("SQT.s3_add.oSum: %f",$bitstoshortreal(SQT.s3_add.Sum));
//	    $display("SQT.s3_add.oSum: %f",$bitstoshortreal(SQT.s3_add.opa));
//	  $display("SQT.s3_add.oSum: %f",$bitstoshortreal(SQT.s3_add.opb));
//	  $display("SQT.s5_mult.oProd: %f",$bitstoshortreal(SQT.s5_mult.Prod));
//	  $display("SQT.s6_mult.oProd: %f",$bitstoshortreal(SQT.s6_mult.Prod));
    end
  $finish;		 
  end				   
 

endmodule