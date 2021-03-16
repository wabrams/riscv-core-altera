//  stat = 
//    0 button is released
//    1 button is pressed
module button (input btn, output stat);
  assign stat = ~btn;
endmodule