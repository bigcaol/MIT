//
//顶层文件

//*/

module cengxi(
				input	wire		clk_50M		,
				input	wire		rst_n		,
				input	wire[13:0]	data_ain	,
				output	wire		clk_ad40m	,
				output	wire[9:0]	DAC900_Data	,
				output	wire		DAC900_Clk	,
				output	wire		DAC900_PD	,
				output	wire		TXD			
			
			);
				

				
wire[7:0]	txd_out;
wire		uart_en;				
//初始化
initial
begin
	
end
	
//时钟系统c0=40MHz for adc, c1=100MHz for dac 
wire	clk_40M;	//pll输出50M
wire	clk_100M;	//pll输出100M
pll_clk	pll_clk_inst (
				.areset ( !rst_n ),
				.inclk0 ( clk_50M ),
				.c0 ( clk_40M ),
				.c1 ( clk_100M ),
				.locked (  )
	);

	
dac900	dac_inst(
					.clk_50M	(clk_50M),
					.rst_n		(rst_n),
					.clk_100M	(clk_100M),
					.DAC900_Data(DAC900_Data),
					.DAC900_Clk	(DAC900_Clk),
					.DAC900_PD  (DAC900_PD)
				);
				

ADC_sum	adc_inst(	
				.clk_s		(),
				.rst_n		(rst_n),
				.clk_40M	(clk_40M),
				.data_ain	(data_ain),
				.restart	(),
				.clk_ad40m_r(clk_ad40m),
				.sum_out	(),
				.txd_out    (txd_out),
				.uart_en	(uart_en)
				);	

usart_tx	uart_inst(
						.clkH	(clk_ad40m)	,
						.Din	(txd_out)	,
						.wren	(uart_en)	,
						.TXD	(TXD)		,
						.busy   ()
					);				
endmodule
