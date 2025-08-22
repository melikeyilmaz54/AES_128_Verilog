`timescale 1ns/1ps

module AES_tb;

  reg         clk;
  reg         rst_n;
  reg [127:0] key;
  reg [127:0] data_in;

  wire [127:0] Cipher;
  wire [127:0] Decrypted;

  // 100 MHz saat
  initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
  end

  AES_top DUT (
    .clk           (clk),
    .rst_n         (rst_n),
    .key           (key),
    .plaintext     (data_in),
    .ciphertext    (Cipher),
    .decrypted_text(Decrypted)
  );

  // NIST AES-128 test vektörü:
  // Key = 00010203 04050607 08090A0B 0C0D0E0F
  // PT  = 00112233 44556677 8899AABB CCDDEEFF
  // CT  = 69C4E0D8 6A7B0430 D8CDB780 70B4C55A
  initial begin
    rst_n = 1'b0;
    key   = 128'h2b7e151628aed2a6abf7158809cf4f3c;
    data_in    = 128'h3243f6a8885a308d313198a2e0370734;

    repeat (4) @(posedge clk);
    rst_n = 1'b1;

    // Gözlem süresi: Encrypt ve Decrypt'in bitmesini bekle
    // (Top içindeki sayaç-sınırları yeterli, yine de simülasyonda bir süre bekletelim)
    repeat (3900) @(posedge clk);

    $display("Key        = %032h", key);
    $display("Plaintext  = %032h", data_in);
    $display("Ciphertext = %032h", Cipher);
    $display("Decrypted  = %032h", Decrypted);

    if (Decrypted === data_in)
      $display("PASS: Decryption matches plaintext.");
    else
      $display("FAIL: Decryption does not match plaintext.");

    $finish;
  end

endmodule
