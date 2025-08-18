`timescale 1ns / 1ps
module keySchedule(
    input clk,rst,
    input [127:0] key,
    output [1407:0] w_all,    
    output reg [3:0] key_ready_index // hazır 128-bit anahtar sayısı (round0 dahil)

    );
    
     // S-box modülünün çıkışları
    wire [7:0] sb_b3, sb_b2, sb_b1, sb_b0;

    reg [31:0] w [0:43];         // w[0..3] = base key, w[4..43] üretilecek
    reg [5:0]  idx;              // 0..43, sıradaki üretilecek kelime
    reg [31:0] temp_reg;         // g() ara değeri veya w[idx-1]
    reg [31:0] rot_reg;          // LEFTSHIFT sonrası
    reg [31:0] sub_reg;          // SBOX sonrası
    reg [31:0] rcon_reg;         // RCXOR'da kullanılacak Rcon
    reg [31:0] new_w;            // XOR sonucunda yeni kelime
    reg [3:0]  round_num;        // 1..10 (AES-128)
    reg        did_init;         // S_IDLE içinde tek seferlik init
    
    // Çıkış paketleme
    reg [1407:0] w_all_r;
    assign w_all = w_all_r;
  
    localparam S_IDLE      = 3'b000;  //DURUM 0
    localparam S_LEFTSHIFT = 3'b001;  //DURUM 1
    localparam S_SBOX      = 3'b010;  //DURUM 2
    localparam S_RCON_LOAD = 3'b011;  //DURUM 3
    localparam S_RCXOR     = 3'b100;  //DURUM 4
    localparam S_XOR       = 3'b101;  //DURUM 5
    localparam S_WRITE     = 3'b110;  //DURUM 6
    localparam S_NEXT      = 3'b111;  //DURUM 7
    
    reg [2:0] state;
    integer k; 
    // -----------------------------
    // Durumlar
    // -----------------------------
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            state <= S_IDLE;
            did_init <= 1'b0;//En başta ilk değer atamaları için flag
            key_ready_index <= 4'd0; // başta hiç anahtar hazır değil
        end else begin
            case(state)
                S_IDLE: begin//DURUM 0 tüm başlangıç adımları ilk atamalar
                    if (!did_init) begin// did_init 0 ise ilk atamalar yapılır
                        w[0] <= key[31:0];   
                        w[1] <= key[63:32];  
                        w[2] <= key[95:64];  
                        w[3] <= key[127:96]; 
                        
                        w_all_r[1407:1280] <= {key[127:96], key[95:64], key[63:32], key[31:0]};
                        key_ready_index <= 4'd1; // base key (round0) hazır
                        
                        idx <= 6'b000100;
                        round_num <= 4'b0001;
                        temp_reg  <= 32'b0;
                        rot_reg   <= 32'b0;
                        sub_reg   <= 32'b0;
                        rcon_reg  <= 32'b0;
                        new_w     <= 32'b0;
                        
                        did_init <= 1'b1;
                        state <= S_IDLE;
                    end else begin
                        if((idx[1:0] == 2'b00) == 0 )begin// mod 4 - g() fonksiyonuna girmesi gerekir.
                            temp_reg <= w[idx-1];           // w[i-1]
                            state    <= S_LEFTSHIFT;        // g(): LEFTSHIFT'e geç
                            round_num <= (idx >> 2);// 2 kaydırarak 4 e bölünür ve round sayısı hesaplanır
                        end else begin
                            temp_reg <= w[idx-1];           // g() yoksa temp=w[i-1]
                            state    <= S_XOR;              // direkt XOR'a geç
                        end
                       
                    end
                end
                
                //g() fonksiyonu için gereken adımlar
                S_LEFTSHIFT: begin//DURUM 1 
                    rot_reg <= rotword(temp_reg);
                    state   <= S_SBOX;
                end
                
                S_SBOX: begin//DURUM 2
                    sub_reg <= { sb_b3, sb_b2, sb_b1, sb_b0 };
                    state   <= S_RCON_LOAD;
                end
                
                S_RCON_LOAD: begin//DURUM 3
                    rcon_reg <= rcon32(round_num); // zaten 32-bit
                    state    <= S_RCXOR;
                end
                
                S_RCXOR: begin//DURUM 4
                    temp_reg <= sub_reg ^ rcon_reg;
                    state    <= S_XOR;
                end
                   
                S_XOR: begin//DURUM 5
                    new_w <= w[idx-4] ^ temp_reg;
                    state <= S_WRITE;
                end
                
                S_WRITE: begin//DURUM 6  Sonraki adım için idx/round güncelle ve doğrudan bir sonraki duruma geç
                    w[idx] <= new_w;
                    
                    // w_all_r[...] <= new_w;  (Verilog-2001: case ile)
                    case (idx)
                        0:  w_all_r[1407:1376] <= new_w;
                        1:  w_all_r[1375:1344] <= new_w;
                        2:  w_all_r[1343:1312] <= new_w;
                        3:  w_all_r[1311:1280] <= new_w;
                        4:  w_all_r[1279:1248] <= new_w;
                        5:  w_all_r[1247:1216] <= new_w;
                        6:  w_all_r[1215:1184] <= new_w;
                        7:  w_all_r[1183:1152] <= new_w;
                        8:  w_all_r[1151:1120] <= new_w;
                        9:  w_all_r[1119:1088] <= new_w;
                        10: w_all_r[1087:1056] <= new_w;
                        11: w_all_r[1055:1024] <= new_w;
                        12: w_all_r[1023:992]  <= new_w;
                        13: w_all_r[991:960]   <= new_w;
                        14: w_all_r[959:928]   <= new_w;
                        15: w_all_r[927:896]   <= new_w;
                        16: w_all_r[895:864]   <= new_w;
                        17: w_all_r[863:832]   <= new_w;
                        18: w_all_r[831:800]   <= new_w;
                        19: w_all_r[799:768]   <= new_w;
                        20: w_all_r[767:736]   <= new_w;
                        21: w_all_r[735:704]   <= new_w;
                        22: w_all_r[703:672]   <= new_w;
                        23: w_all_r[671:640]   <= new_w;
                        24: w_all_r[639:608]   <= new_w;
                        25: w_all_r[607:576]   <= new_w;
                        26: w_all_r[575:544]   <= new_w;
                        27: w_all_r[543:512]   <= new_w;
                        28: w_all_r[511:480]   <= new_w;
                        29: w_all_r[479:448]   <= new_w;
                        30: w_all_r[447:416]   <= new_w;
                        31: w_all_r[415:384]   <= new_w;
                        32: w_all_r[383:352]   <= new_w;
                        33: w_all_r[351:320]   <= new_w;
                        34: w_all_r[319:288]   <= new_w;
                        35: w_all_r[287:256]   <= new_w;
                        36: w_all_r[255:224]   <= new_w;
                        37: w_all_r[223:192]   <= new_w;
                        38: w_all_r[191:160]   <= new_w;
                        39: w_all_r[159:128]   <= new_w;
                        40: w_all_r[127:96]    <= new_w;
                        41: w_all_r[95:64]     <= new_w;
                        42: w_all_r[63:32]     <= new_w;
                        43: w_all_r[31:0]      <= new_w;
                        default: ;
                    endcase
                     // Her kelime yazıldığında w_all_r'yi güncelle
//                    w_all_r[1407 - 32*idx -: 32] <= new_w;
                    
                    if (idx[1:0] == 2'b11) begin
                        key_ready_index <= key_ready_index + 4'd1;
                    end

                    
                    if (idx == 6'd43) begin//son kelime yazıldıysa next e gidilir ve beklenir.
                        state <= S_NEXT;
                    end else begin
                        idx <= idx + 6'b1;
                        state <= S_IDLE;
                               
                    end
                end

                // --------------------------------------------------------
                // Paketle ve bekle
                // --------------------------------------------------------
                S_NEXT: begin//DURUM 7
                    state <= S_NEXT; // burada kal
                end
                
            endcase
        end

    end
   
    // Rcon32 (AES-128 için 10 tur)
  function [31:0] rcon32;
  input [3:0] round;
  begin
    case (round)
      4'd1:  rcon32 = 32'h01_00_00_00;
      4'd2:  rcon32 = 32'h02_00_00_00;
      4'd3:  rcon32 = 32'h04_00_00_00;
      4'd4:  rcon32 = 32'h08_00_00_00;
      4'd5:  rcon32 = 32'h10_00_00_00;
      4'd6:  rcon32 = 32'h20_00_00_00;
      4'd7:  rcon32 = 32'h40_00_00_00;
      4'd8:  rcon32 = 32'h80_00_00_00;
      4'd9:  rcon32 = 32'h1B_00_00_00;
      4'd10: rcon32 = 32'h36_00_00_00;
      default: rcon32 = 32'h00_00_00_00;
    endcase
  end
endfunction
  
  // RotWord: {b0,b1,b2,b3} -> {b1,b2,b3,b0}
  function [31:0] rotword;
    input [31:0] x;
    begin
      rotword = {x[23:0], x[31:24]};
    end
  endfunction
 
// 4 paralel S-box instance (rot_reg'in byte'ları)
    sbox u_sbox3 (
    .sbin(rot_reg[31:24]), 
    .sbout(sb_b3)
    ); // MSB
    sbox u_sbox2 (
    .sbin(rot_reg[23:16]), 
    .sbout(sb_b2)
    );
    sbox u_sbox1 (
    .sbin(rot_reg[15:8]),   
    .sbout(sb_b1)
    );
    sbox u_sbox0 (
    .sbin(rot_reg[7:0]),   
    .sbout(sb_b0)
    ); // LSB

endmodule
