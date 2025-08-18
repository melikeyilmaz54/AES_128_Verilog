`timescale 1ns / 1ps
module AES_Decrypt(
    input clk,rst,          
    input [127:0] key,      
    input [127:0] data_in,  
    output [127:0]data_out  
    );                      

    wire [3:0] key_ready_index;
    wire [127:0] addround_out;
    wire [127:0] invsubbytes_out;
    wire [127:0] invshiftrows_out;
    wire [127:0] invmixcolumns_out;
    wire [1407:0] key_all_out;
    
    reg [3:0] round;
    reg [127:0] temp_reg;
    reg [127:0] out;
    
//    wire [127:0] round_key;
    // 11 round anahtarı (key0..key10)
    wire [127:0] round_keys [0:10];
    
    assign round_keys[0]  = key_all_out[1407:1280]; // key0
    assign round_keys[1]  = key_all_out[1279:1152]; // key1
    assign round_keys[2]  = key_all_out[1151:1024]; // key2
    assign round_keys[3]  = key_all_out[1023:896];  // key3
    assign round_keys[4]  = key_all_out[895:768];   // key4
    assign round_keys[5]  = key_all_out[767:640];   // key5
    assign round_keys[6]  = key_all_out[639:512];   // key6
    assign round_keys[7]  = key_all_out[511:384];   // key7
    assign round_keys[8]  = key_all_out[383:256];   // key8
    assign round_keys[9]  = key_all_out[255:128];   // key9
    assign round_keys[10] = key_all_out[127:0];     // key10
    
    reg [127:0] round_key;

    always @(*) begin
      case (10 - round)
        0:  round_key = round_keys[0];
        1:  round_key = round_keys[1];
        2:  round_key = round_keys[2];
        3:  round_key = round_keys[3];
        4:  round_key = round_keys[4];
        5:  round_key = round_keys[5];
        6:  round_key = round_keys[6];
        7:  round_key = round_keys[7];
        8:  round_key = round_keys[8];
        9:  round_key = round_keys[9];
        10: round_key = round_keys[10];
        default: round_key = 128'h0;
      endcase
    end

    assign data_out = out;
//    assign round_key = key_all_out[1407 - ((10 - round) * 128) -: 128];
    
    localparam S_IDLE              = 3'b000;  //DURUM 0
    localparam S_INVSUBBYTES       = 3'b001;  //DURUM 1
    localparam S_INVSHIFTROWS      = 3'b010;  //DURUM 2
    localparam S_INVMIXCOLUMNS     = 3'b011;  //DURUM 3
    localparam S_ADDROUNDKEY       = 3'b100;  //DURUM 4
    localparam S_WRITE             = 3'b101;  //DURUM 5
    localparam S_WAITKEY           = 3'B110;  //DURUM 6
    
    reg [2:0] state;
    
     always @(posedge clk or negedge rst) begin
        if(!rst)begin
            round <= 0;
            state <= S_IDLE;
        end else begin
            case(state)
                S_IDLE:begin 
                    temp_reg <= data_in;
                    state <= S_WAITKEY; 
                end
                
                S_INVSHIFTROWS:begin
                    round <= round + 1'b1;
                    temp_reg <= invshiftrows_out;
                    state <= S_INVSUBBYTES;
                end
                
                S_INVSUBBYTES:begin
                    temp_reg <= invsubbytes_out;
                    state <= S_WAITKEY;
                end
                
                S_ADDROUNDKEY:begin
                    temp_reg <= addround_out; 
                    
                    if(round==10)begin //10. turda döngü biter yazma aşamasına geçilir
                        state <= S_WRITE; 
                    end else if(round==0)begin //ilk başlangıç turunda mixcolumns atlanır 
                        state <= S_INVSHIFTROWS;                   
                    end else begin
                        state <= S_INVMIXCOLUMNS;
                    end
                end
                
                S_INVMIXCOLUMNS:begin
                    temp_reg <= invmixcolumns_out;
                    state <= S_INVSHIFTROWS;
                end
                
                S_WAITKEY: begin // Bu round için gereken anahtar hazır mı?
                    if(key_ready_index==11)begin//tüm anahtarlar hesaplandığında
                        state <= S_ADDROUNDKEY;        // hazırsa AddRoundKey'e geç
                    end else begin
                        state <= S_WAITKEY;
                    end

                end
                
                S_WRITE:begin
                    out <= temp_reg;
                    state <= S_IDLE;
                end
            endcase
        end
     end
    
    
    
//    AddRoundKey addroundkey2(
//        .datain(temp_reg),
//        .key(round_key),
//        .dataout(addround_out)
//    );
    
//    inverseMixColumns imc(
//        .imcin(temp_reg),
//        .imcout(invmixcolumns_out)
//    );
    
//    inverseShiftRows isr(
//    .in(temp_reg),
//    .ishiftout(invshiftrows_out)
//    );
    
//    inverseSubBytes isb(
//    .in(temp_reg),
//    .out(invsubbytes_out)
//    );
    
//    keySchedule keyschedule(
//    .clk(clk),
//    .rst(rst),
//    .key(key),
//    .w_all(key_all_out),
//    .key_ready_index (key_ready_index) 
//    );

endmodule
