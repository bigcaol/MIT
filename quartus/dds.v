//2018/4/3
//caotengda
//Fout = Fclk*K/(2^32)


module dds(
		input 	wire		clk,
		input 	wire		rst_n,
		input 	wire		Ken,		//频率控制字使能
		input 	wire[31:0]	K,			//频率控制字
		input 	wire		dds_en,		//dds使能
		output	wire[9:0]	sin_out
		);
		
		
	reg[31:0]	K_r;
	reg[31:0]	add_K_r;
	
	
	
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)begin K_r <= 0;
	end
	else if(Ken) begin K_r <= K;
	end
end


always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)begin add_K_r <= 0;
	end
	else if(dds_en) begin add_K_r <= add_K_r + K_r;
	end
end



	wire [9:0]	sin;
	wire[7:0]	rom_address;
	assign rom_address = add_K_r[31:24];	//8bits address for rom to look for,将8位扩展为32位，以缩小频率分辨率 
rom_sin		sin_inst(						//本来应该是Fout = Fclk*K/(2^8)
	.address	(rom_address),
	.clock		(clk),
	.q			(sin)
	);

	
//将rom输出传递给寄存器sin_r	
	reg[9:0]	sin_r; 
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)begin sin_r <= 0;
	end
	else if(dds_en) begin sin_r <= sin;
	end
end


assign sin_out = sin_r;

endmodule