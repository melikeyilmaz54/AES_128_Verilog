`timescale 1ns / 1ps//ÇALIŞIYOR
module AES_Encrypt( 
    input clk,rst,
    input [127:0] key,
    input [127:0] data_in,
    output [127:0] data_out
    );
    
    wire [3:0] key_ready_index;
    wire [127:0] addround_out;
    wire [127:0] subbytes_out;
    wire [127:0] shiftrows_out;
    wire [127:0] mixcolumns_out;
    wire [1407:0] key_all_out;
    
    reg [3:0] round;
    reg [127:0] temp_reg_enc;
    reg [127:0] out;
    
    reg [127:0] round_key;
    
    assign data_out = out;


    always @(*) begin
        case (round)
            0:  round_key = key_all_out[1407:1280];
            1:  round_key = key_all_out[1279:1152];
            2:  round_key = key_all_out[1151:1024];
            3:  round_key = key_all_out[1023:896];
            4:  round_key = key_all_out[895:768];
            5:  round_key = key_all_out[767:640];
            6:  round_key = key_all_out[639:512];
            7:  round_key = key_all_out[511:384];
            8:  round_key = key_all_out[383:256];
            9:  round_key = key_all_out[255:128];
            10: round_key = key_all_out[127:0];
            default: round_key = 128'h0;
        endcase
    end

    
    localparam S_IDLE         = 3'b000;  //DURUM 0
    localparam S_SUBBYTES     = 3'b001;  //DURUM 1
    localparam S_SHIFTROWS    = 3'b010;  //DURUM 2
    localparam S_MIXCOLUMNS   = 3'b011;  //DURUM 3
    localparam S_ADDROUNDKEY  = 3'b100;  //DURUM 4
    localparam S_WRITE        = 3'b101;  //DURUM 5
    localparam S_WAITKEY      = 3'b110;  //DURUM 6
    
    reg [2:0] state;
    
    always @(posedge clk or negedge rst) begin
        if(!rst)begin
            round <= 0;
            state <= S_IDLE;
            out   <= 0; 
        end else begin
            case(state)
                S_IDLE:begin //DURUM 0
                        temp_reg_enc <= data_in;
                        state    <= S_WAITKEY;  
                end
                
                S_SUBBYTES:begin//DURUM 1
                    round <= round + 1'b1;
                    temp_reg_enc <= subbytes_out;
                    state <= S_SHIFTROWS;
                end
                
                S_SHIFTROWS:begin//DURUM 2
                    if(round==10)begin
                        temp_reg_enc <= shiftrows_out;
                        state <= S_WAITKEY;
                    end else begin
                        temp_reg_enc <= shiftrows_out;
                        state <= S_MIXCOLUMNS;
                    end
                end
                
                S_MIXCOLUMNS:begin//DURUM 3
                    temp_reg_enc <= mixcolumns_out;
                    state <= S_WAITKEY;
                end
                
                S_WAITKEY: begin // Bu round için gereken anahtar hazır mı?//DURUM 6
                    // round=0 iken key_ready_index >= 1 olmalı (base key)
                    if (key_ready_index >= (round + 4'd1))begin
                        state <= S_ADDROUNDKEY;        // hazırsa AddRoundKey'e geç
                    end else begin
                        state <= S_WAITKEY;            // değilse beklemeye devam
                    end
                end
                
                S_ADDROUNDKEY:begin//DURUM 4
                    if(round==10)begin
                        temp_reg_enc <= addround_out;
                        state <= S_WRITE;
                    end else begin
                        temp_reg_enc <= addround_out;
                        state <= S_SUBBYTES;
                    end
                end
                S_WRITE:begin//DURUM 5
                    out <= temp_reg_enc;
                    state <= S_WRITE;
                end
            endcase
        end
    end 
    
    AddRoundKey addroundkey(
        .datain(temp_reg_enc),
        .key(round_key),
        .dataout(addround_out)
    );
    
    subBytes subbytes(
        .in(temp_reg_enc),
        .out(subbytes_out)
    );
    
    shiftRows shiftrows(
        .in(temp_reg_enc),
        .shiftout(shiftrows_out)
    );
    
    mixColumns mixcolumns(
        .mcin(temp_reg_enc),
        .mcout(mixcolumns_out)
    );
    
    keySchedule keyschedule1(
        .clk(clk),
        .rst(rst),
        .key(key),
        .w_all(key_all_out),
        .key_ready_index (key_ready_index) 
    );
endmodule
