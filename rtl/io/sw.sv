//  stat = 
//    0 switch is down
//    1 switch is up
module switch (input sw, output stat);
  assign stat = sw;
endmodule