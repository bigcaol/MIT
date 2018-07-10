//模拟开关ADG408
//1路接收完成-en_NT给一个高电平时钟，转为下一路。
//共7路

module	ADG408(
				input	wire		clks			,
				input	wire		rst_n			,
				input	wire		en_NT			,//来自ADC_SUM，表示当前通道接收完成
				input	wire[2:0]	start_state		,
				input	wire		start_state_en	,//来自发送ADG，表示当前发射通道完成，下一通道使能
				output	reg[2:0]	addr
				);


//地址需要根据硬件更改
parameter	chanal0_addr = 3'd0;
parameter	chanal1_addr = 3'd1;
parameter	chanal2_addr = 3'd2;
parameter	chanal3_addr = 3'd3;
parameter	chanal4_addr = 3'd4;
parameter	chanal5_addr = 3'd5;
parameter	chanal6_addr = 3'd6;
parameter	chanal7_addr = 3'd7;

reg[2:0]	state;
reg[2:0]	cnt7;


//循环起始状态
//assign	state = start_state;
//通过使能信号的一个高电平脉冲，将循环起始传递给state
always@(posedge clks)// or posedge rst_n
begin
	if(start_state_en)	
		begin
			state <= start_state;
			cnt7 <=	3'd0;
		end
	else	
		begin
			state <= state;
		end
	
	end
//7个状态循环
always@(posedge clks or negedge rst_n)
begin
	if(!rst_n)	begin	state <= 3'd0;	end
	else
		begin
			if(en_NT)	
				begin
					state <= state +3'd1;
					cnt7  <= cnt7 + 3'd1;
				end				
		end
end	

//产生7通道完成标志位
always@(posedge clks or negedge rst_n)
begin
	if(!rst_n)
		begin
			all7_chs_done <= 1'b0;
		end
	else if(cnt7==)
end
//7个状态对应7种地址
always@(posedge clks or negedge rst_n)
begin
	if(!rst_n)	begin	addr <= 3'd0;	end
	else
		begin
		case(state)
		3'd0:begin	addr <= chanal0_addr;	end
		3'd1:begin	addr <= chanal1_addr;	end
		3'd2:begin	addr <= chanal2_addr;	end
		3'd3:begin	addr <= chanal3_addr;	end
		3'd4:begin	addr <= chanal4_addr;	end
		3'd5:begin	addr <= chanal5_addr;	end
		3'd6:begin	addr <= chanal6_addr;	end
		3'd7:begin	addr <= chanal6_addr;	end
		endcase
		end
		
end			
endmodule
//添加使能信号（7路接收完成）