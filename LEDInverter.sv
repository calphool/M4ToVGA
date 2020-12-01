module LEDInverter (
       inputbits,
		 outputbits
       );
		 
   input [9:0] inputbits;
   output logic [9:0] outputbits;
	
	
   
	//assign outputbits = ~inputbits;
	
   assign outputbits[9] = ~inputbits[9];		 
   assign outputbits[8] = ~inputbits[8];		 
   assign outputbits[7] = ~inputbits[7];		 
   assign outputbits[6] = ~inputbits[6];		 
   assign outputbits[5] = ~inputbits[5];		 
   assign outputbits[4] = ~inputbits[4];		 
   assign outputbits[3] = ~inputbits[3];		 
   assign outputbits[2] = ~inputbits[2];		 
   assign outputbits[1] = ~inputbits[1];		 
   assign outputbits[0] = ~inputbits[0];
	
		
endmodule