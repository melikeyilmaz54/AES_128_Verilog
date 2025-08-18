//galois cisimciği üzerinde matris çarpımı yapan modül.
module mixColumns(
    input [127:0] mcin,
    output [127:0] mcout
    );
    
    function [7:0] gm2; //2 ile çarpma (galois multiplication)
	       input [7:0] x;
	       begin 
			/* 2 ile çarpma, bir biti sola kaydırır ve eğer orijinal 8 bitte MSB'de 1 varsa,
           sonucu {1b} ile  xor eder}*/
			     if(x[7] == 1) gm2 = ((x << 1) ^ 8'h1b);
			     else gm2 = x << 1; 
	       end 	
    endfunction
    
    
    function [7:0] gm3; //3 ile çarpma
	       input [7:0] x;
	       begin 
			     gm3 = gm2(x) ^ x;
	       end      
    endfunction
        //col0 matris çarpımı
        assign mcout[7:0]   = gm2(mcin[7:0]) ^ gm3(mcin[15:8]) ^ mcin[23:16]      ^ mcin[31:24];
        assign mcout[15:8]  = mcin[7:0]     ^ gm2(mcin[15:8])   ^ gm3(mcin[23:16]) ^ mcin[31:24];
        assign mcout[23:16] = mcin[7:0]     ^ mcin[15:8]       ^ gm2(mcin[23:16]) ^ gm3(mcin[31:24]);
        assign mcout[31:24] = gm3(mcin[7:0]) ^ mcin[15:8]     ^ mcin[23:16]      ^ gm2(mcin[31:24]);
        
        //col1 matris çarpımı
        assign mcout[39:32] = gm2(mcin[39:32]) ^ gm3(mcin[47:40]) ^ mcin[55:48]   ^ mcin[63:56];
        assign mcout[47:40] = mcin[39:32]    ^ gm2(mcin[47:40])   ^ gm3(mcin[55:48]) ^ mcin[63:56];
        assign mcout[55:48] = mcin[39:32]    ^ mcin[47:40]        ^ gm2(mcin[55:48]) ^ gm3(mcin[63:56]);
        assign mcout[63:56] = gm3(mcin[39:32]) ^ mcin[47:40]      ^ mcin[55:48]   ^ gm2(mcin[63:56]);
        
        //col3 matris çarpımı
        assign mcout[71:64] = gm2(mcin[71:64]) ^ gm3(mcin[79:72]) ^ mcin[87:80]     ^ mcin[95:88];
        assign mcout[79:72] = mcin[71:64]      ^ gm2(mcin[79:72]) ^ gm3(mcin[87:80]) ^ mcin[95:88];
        assign mcout[87:80] = mcin[71:64]      ^ mcin[79:72]      ^ gm2(mcin[87:80]) ^ gm3(mcin[95:88]);
        assign mcout[95:88] = gm3(mcin[71:64]) ^ mcin[79:72]      ^ mcin[87:80]     ^ gm2(mcin[95:88]);
        
        //col4 matris çarpımı
        assign mcout[103:96]  = gm2(mcin[103:96]) ^ gm3(mcin[111:104]) ^ mcin[119:112]     ^ mcin[127:120];
        assign mcout[111:104] = mcin[103:96]      ^ gm2(mcin[111:104]) ^ gm3(mcin[119:112]) ^ mcin[127:120];
        assign mcout[119:112] = mcin[103:96]      ^ mcin[111:104]      ^ gm2(mcin[119:112]) ^ gm3(mcin[127:120]);
        assign mcout[127:120] = gm3(mcin[103:96]) ^ mcin[111:104]      ^ mcin[119:112]     ^ gm2(mcin[127:120]);

        
endmodule
