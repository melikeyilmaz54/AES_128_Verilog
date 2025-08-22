`timescale 1ns / 1ps

module AES_top (
    input              clk,
    input              rst_n,          // aktif düşük
    input      [127:0] key,
    input      [127:0] plaintext,

    output     [127:0] ciphertext,
    output     [127:0] decrypted_text
);

  // ====== İç kablolar ======
  wire [127:0] enc_out;
  wire [127:0] dec_out;

  // Decrypt'i tutmak için ayrı reset
  reg          dec_rst_n;

  // Encrypt çıktı yakalama/latch
  reg  [127:0] cipher_latched;

  // Basit durum makinesi
  localparam S_ENC_RUN  = 2'b00;
  localparam S_LATCH    = 2'b01;
  localparam S_DEC_RUN  = 2'b10;
  localparam S_DONE     = 2'b11;

  reg [1:0] state;

  // Güvenlik için sayaç (encrypt'in biteceği makul bir üst sınır)
  // Bu üst sınır tasarım gecikmelerine göre ayarlanabilir.
  reg [15:0] wait_cnt;
  localparam WAIT_MAX = 16'd5000; // simülasyon için rahat bir üst sınır

  // Çıkışlar
  assign ciphertext      = enc_out;
  assign decrypted_text  = dec_out;

  AES_Encrypt u_enc (
    .clk      (clk),
    .rst      (rst_n),     // modül içinde negedge rst, aktif düşük bekleniyor
    .key      (key),
    .data_in  (plaintext),
    .data_out (enc_out)
  );

  AES_Decrypt u_dec (
    .clk      (clk),
    .rst      (dec_rst_n), // decrypt'i top kontrol ediyor
    .key      (key),
    .data_in  (cipher_latched),
    .data_out (dec_out)
  );

  // ====== Kontrol FSM ======
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state          <= S_ENC_RUN;
      dec_rst_n      <= 1'b0;         // decrypt resetli başlasın
      cipher_latched <= 128'h0;
      wait_cnt       <= 16'd0;
    end else begin
      case (state)
        // Encrypt çalışıyor. enc_out S_WRITE'e kadar 0 kalır (modülünüz böyle tasarlanmış)
        S_ENC_RUN: begin
          dec_rst_n <= 1'b0; // decrypt'i tut
          if (enc_out != 128'h0 || wait_cnt >= WAIT_MAX) begin
            cipher_latched <= enc_out;
            state          <= S_LATCH;
            wait_cnt       <= 16'd0;
          end else begin
            wait_cnt       <= wait_cnt + 16'd1;
          end
        end

        // Bir döngü bekleyip decrypt'i serbest bırak
        S_LATCH: begin
          dec_rst_n <= 1'b1;  // decrypt'i resetten çıkar
          state     <= S_DEC_RUN;
        end

        // Decrypt çalışıyor; benzer şekilde dec_out 0'dan farklı olunca DONE sayalım
        S_DEC_RUN: begin
          if (dec_out != 128'h0 || wait_cnt >= WAIT_MAX) begin
            state    <= S_DONE;
          end else begin
            wait_cnt <= wait_cnt + 16'd1;
          end
        end

        S_DONE: begin
          // Sabit kal
          dec_rst_n <= 1'b1;
        end
      endcase
    end
  end

endmodule
