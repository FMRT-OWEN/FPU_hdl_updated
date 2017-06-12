#####################################################################################
##		FPU VERFICATION AND DESIGN OF FLOATING POINT SQUARE ROOT				#####
#####################################################################################
#							Rakhee Bhojarkar
#						 Jaisil Muttakulath Joy
#						 Spoorthi Chandra Kanchi
#						Parimala Jyothi Mandalapu
#####################################################################################

######### 				 HOW TO BUILD 							#####################

> To build and run the project in veloce, type make in the terminal from current directory 

################		FILES GENERATED 						#####################

> 	Three files will be generated when the project is run. They are
		input.txt 	: contains the inputs given to FPU
		output.txt	: contains the outputs received from FPU, expected outputs
		error.txt	: contains the testcases which resulted in error

################		INFORMATION		 						#####################	

>	The squareroot algorithm is not very precise, as a result when verifying, the 
	obtained result is compared  with expected result +/- tolerance
	
>	For all operations other than squareroot, if the obtained and expected results are 
	different, even by a digit, then that case is considered as error. Seems like there
	are many such errors due to low precision ~ 75% errors

>	Only round_nearest_even rounding mode is verified, because of the difficulty in 
	generating expected result for other roudnding modes

>	The number of random testcases can be given by providing plusargs +RUNS. The default
	value for this is 10000



