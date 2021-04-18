module LEDInverter (
       i_inputbits,
		 o_outputbits
       );
		 
   input [9:0] i_inputbits;
   output logic [9:0] o_outputbits;
	
	
   
	//assign outputbits = ~inputbits;
	
   assign o_outputbits[9] = ~i_inputbits[9];		 
   assign o_outputbits[8] = ~i_inputbits[8];		 
   assign o_outputbits[7] = ~i_inputbits[7];		 
   assign o_outputbits[6] = ~i_inputbits[6];		 
   assign o_outputbits[5] = ~i_inputbits[5];		 
   assign o_outputbits[4] = ~i_inputbits[4];		 
   assign o_outputbits[3] = ~i_inputbits[3];		 
   assign o_outputbits[2] = ~i_inputbits[2];		 
   assign o_outputbits[1] = ~i_inputbits[1];		 
   assign o_outputbits[0] = ~i_inputbits[0];
	
		
endmodule