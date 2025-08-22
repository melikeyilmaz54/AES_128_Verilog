`timescale 1ns / 1ps//ÇALIŞIYOR
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
                        // Yeni (MSB-first, ÖNERİLEN):
                        w[0] <= key[127:96];  // MSB word
                        w[1] <= key[95:64];
                        w[2] <= key[63:32];
                        w[3] <= key[31:0];    // LSB word
                        
                        w_all_r[1407:1280] <= { key[127:96], key[95:64], key[63:32], key[31:0] };

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
                        if((idx[1:0] == 2'b00))begin// mod 4 - g() fonksiyonuna girmesi gerekir.
                            temp_reg <= w[idx-1];           // w[i-1]
                            round_num <= (idx >> 2);// 2 kaydırarak 4 e bölünür ve round sayısı hesaplanır
                            state    <= S_LEFTSHIFT;        // g(): LEFTSHIFT'e geç
                            
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
                   // idx kelimesini yaz
                    w[idx] <= new_w;
                    
                    // w_all_r'ye yerleştirme (Verilog-2001 uyumlu, sabit dilimler)
                    case (idx)
                      // round0 zaten daha önce: w0..w3 -> [1407:1280]
                    
                       4:  w_all_r[1279:1248] <= new_w; // w4
                       5:  w_all_r[1247:1216] <= new_w; // w5
                       6:  w_all_r[1215:1184] <= new_w; // w6
                       7:  w_all_r[1183:1152] <= new_w; // w7   (round1 tamam)
                    
                       8:  w_all_r[1151:1120] <= new_w; // w8
                       9:  w_all_r[1119:1088] <= new_w; // w9
                      10:  w_all_r[1087:1056] <= new_w; // w10
                      11:  w_all_r[1055:1024] <= new_w; // w11  (round2 tamam)
                    
                      12:  w_all_r[1023:992]  <= new_w; // w12
                      13:  w_all_r[991:960]   <= new_w; // w13
                      14:  w_all_r[959:928]   <= new_w; // w14
                      15:  w_all_r[927:896]   <= new_w; // w15  (round3)
                    
                      16:  w_all_r[895:864]   <= new_w; // w16
                      17:  w_all_r[863:832]   <= new_w; // w17
                      18:  w_all_r[831:800]   <= new_w; // w18
                      19:  w_all_r[799:768]   <= new_w; // w19  (round4)
                    
                      20:  w_all_r[767:736]   <= new_w; // w20
                      21:  w_all_r[735:704]   <= new_w; // w21
                      22:  w_all_r[703:672]   <= new_w; // w22
                      23:  w_all_r[671:640]   <= new_w; // w23  (round5)
                    
                      24:  w_all_r[639:608]   <= new_w; // w24
                      25:  w_all_r[607:576]   <= new_w; // w25
                      26:  w_all_r[575:544]   <= new_w; // w26
                      27:  w_all_r[543:512]   <= new_w; // w27  (round6)
                    
                      28:  w_all_r[511:480]   <= new_w; // w28
                      29:  w_all_r[479:448]   <= new_w; // w29
                      30:  w_all_r[447:416]   <= new_w; // w30
                      31:  w_all_r[415:384]   <= new_w; // w31  (round7)
                    
                      32:  w_all_r[383:352]   <= new_w; // w32
                      33:  w_all_r[351:320]   <= new_w; // w33
                      34:  w_all_r[319:288]   <= new_w; // w34
                      35:  w_all_r[287:256]   <= new_w; // w35  (round8)
                    
                      36:  w_all_r[255:224]   <= new_w; // w36
                      37:  w_all_r[223:192]   <= new_w; // w37
                      38:  w_all_r[191:160]   <= new_w; // w38
                      39:  w_all_r[159:128]   <= new_w; // w39  (round9)
                    
                      40:  w_all_r[127:96]    <= new_w; // w40
                      41:  w_all_r[95:64]     <= new_w; // w41
                      42:  w_all_r[63:32]     <= new_w; // w42
                      43:  w_all_r[31:0]      <= new_w; // w43  (round10)
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
