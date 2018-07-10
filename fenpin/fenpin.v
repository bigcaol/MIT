//偶数分频
//N=1------------二分频
//N=2------------四分频

module fenpin #(  
parameter N = 10,  
    WIDTH = 7  
)  
(  
    input clk,  
    input rst_n,  
    output reg clk_out  
    );  
  
reg [WIDTH:0]counter;  
always @(posedge clk or negedge rst_n) begin  
    if (!rst_n) begin  
        // reset  
        counter <= 0;  
    end  
    else if (counter == N-1) begin  
        counter <= 0;  
    end  
    else begin  
        counter <= counter + 1;  
    end  
end  
  
always @(posedge clk or negedge rst_n) begin  
    if (!rst_n) begin  
        // reset  
        clk_out <= 0;  
    end  
    else if (counter == N-1) begin  
        clk_out <= !clk_out;  
    end  
end  
  
endmodule 