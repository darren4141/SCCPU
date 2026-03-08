task automatic expect_32;
  input [31:0] expected;
  input [31:0] actual;
  begin
    if (actual !== expected) begin
      $display("FAIL: expected %0d got %0d", expected, actual);
    end else $display("PASS: expected %0d got %0d", expected, actual);
  end
endtask

task automatic expect_16;
  input [15:0] expected;
  input [15:0] actual;
  begin
    if (actual !== expected) begin
      $display("FAIL: expected %0d got %0d", expected, actual);
    end else $display("PASS: expected %0d got %0d", expected, actual);
  end
endtask

task automatic expect_8;
  input [7:0] expected;
  input [7:0] actual;
  begin
    if (actual !== expected) begin
      $display("FAIL: expected %0d got %0d", expected, actual);
    end else $display("PASS: expected %0d got %0d", expected, actual);
  end
endtask

task automatic expect_1;
  input expected;
  input actual;
  begin
    if (actual !== expected) begin
      $display("FAIL: expected %0d got %0d", expected, actual);
    end else $display("PASS: expected %0d got %0d", expected, actual);
  end
endtask
