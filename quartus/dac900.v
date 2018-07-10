`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//.时序要求：DAC900_Clk >= 6ns,上升沿取数据。
//.外部输入时钟clk_50M
//.pll_clk输出时钟c0=clk=50M,以及c1=clk_adc=100M
//.clk_adc倒相180度，作为外部芯片DAC900的时钟信号。这样做是因为：
//		1.DAC900采样时钟=<165MHz,再次范围内采样时钟（DAC900_Clk）越高采样点数越多，波形越好。自所以没有输出更高频率是因为PLL几乎不能改善时钟的稳定性。
//		2.根据DAC900芯片手册，应：采样时钟下降沿输出数据变化，上升沿输出数据保持稳定，所以进行倒相180度。
//////////////////////////////////////////////////////////////////////////////////
module dac900(
		input 	wire		clk_50M,
		input 	wire		rst_n,
		input	wire		clk_100M,
		output 	reg[9:0]	DAC900_Data,
		output 	wire 		DAC900_Clk,
		output 	wire		DAC900_PD
    );


wire	DAC900_Clk_r;

assign	DAC900_Clk_r = clk_100M;
/*
fenpin div_clk(  
		.clk	(clk_50M)	,  
		.rst_n	(rst_n)		,  
		.clk_out(DAC900_Clk_r)  
    );  
 */

wire dds_en;
wire[9:0]	sin_out;
assign dds_en=1'b1;	

/*//180倒相
always @(DAC900_Clk_r)
	begin
	DAC900_Clk <= !DAC900_Clk_r;
	end
*/
assign DAC900_Clk = ~DAC900_Clk_r;

always @(posedge DAC900_Clk_r or negedge rst_n)
	begin
		if(!rst_n)
		DAC900_Data<=0;
		else 
		DAC900_Data<=sin_out;
	end	
assign DAC900_PD=1'b0;	


dds dds_inst(
		.clk		(DAC900_Clk_r),
		.rst_n		(rst_n),
		.Ken		(1'b1),	
		.K			(32'd42949672),			
		.dds_en		(dds_en),		
		.sin_out	(sin_out)				
			
);

endmodule
