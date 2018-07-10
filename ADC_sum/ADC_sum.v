//clks\restart\sum_out暂时没用到
//ADC下降沿获取模数转换值，由于外部硬件存在反相器，所以上升沿获取数据。
//采样时钟从top层连接得到

module ADC_sum(	
				input	wire			clk_s,
				input	wire			rst_n,
				input	wire			clk_40M,
				input	wire[13:0]		data_ain,
				input	wire			restart,
				output	wire			clk_ad40m_r,
				output	reg				sum_out,
				output	reg[7:0]		txd_out,
				output	reg[7:0]		used1,
				output	reg				uart_en
				);

				
				
reg		[5:0]	numP;//sampling nummber in 1 period
reg		[7:0]	numT;//numT个周期累加，即每个点累加numT次
reg				clkT;//
reg				numT_done;//numT_done累加完成标志位


reg [21:0] sum00; reg [21:0] sum01; reg [21:0] sum02; reg [21:0] sum03; reg [21:0] sum04; reg [21:0] sum05; reg [21:0] sum06; reg [21:0] sum07;
reg [21:0] sum08; reg [21:0] sum09; reg [21:0] sum10; reg [21:0] sum11; reg [21:0] sum12; reg [21:0] sum13; reg [21:0] sum14; reg [21:0] sum15;
reg [21:0] sum16; reg [21:0] sum17; reg [21:0] sum18; reg [21:0] sum19; reg [21:0] sum20; reg [21:0] sum21; reg [21:0] sum22; reg [21:0] sum23;
reg [21:0] sum24; reg [21:0] sum25; reg [21:0] sum26; reg [21:0] sum27; reg [21:0] sum28; reg [21:0] sum29; reg [21:0] sum30; reg [21:0] sum31;
reg [21:0] sum32; reg [21:0] sum33; reg [21:0] sum34; reg [21:0] sum35; reg [21:0] sum36; reg [21:0] sum37; reg [21:0] sum38; reg [21:0] sum39;
reg [21:0] sum;

reg 			rdreq;
reg[11:0]	cnt;
reg			clk_read;		
wire[15:0]	q_out;
wire			rdempty_sig;
wire			wrempty;
wire			wrfull_sig;
reg[7:0]		txd_out_nt;
reg			up_clk_read;
reg			old_clk_read;
reg			negedge_empty;
reg			old_rdempty_sig;
reg			negedge_wrempty;
reg			old_wrempty_sig;
reg			rdclk_en;
reg[5:0]		cnt_frame;
reg[2:0]		state;
wire  [7:0] used;
wire[15:0]		data_fifo; /*synthesis keep*/

//初始化
initial
begin
	uart_en = 1'b0;
	txd_out = 1'b1;
	clk_read= 1'b0;
	rdclk_en= 1'b0;
	numP = 6'b0;
	numT = 8'd129;//
	rdreq = 1'b0;
end

/*
//clk system,generate 40MHz sampling rate
pll_clk	pll_clk_inst(	.areset ( rst_n ),
						.inclk0 ( clk_s ),
						.c0 ( clk_ad40m_r ),
						//.c1 ( c1_sig ),
						//.locked ( locked_sig )
					);	

					*/
					
assign	clk_ad40m_r = clk_40M;
//assign clk_ad40m = ~clk_40M;//直接把输入取反 再输出了。


//numP = sampling nummber in 1 period
always@(posedge clk_40M or negedge rst_n)
begin
	if(!rst_n)	begin	
				numP <= 6'b0;	
				end
	else if(numP == 6'd39)	begin
						numP <= 6'b0;
						end
	else		begin	
				numP <= numP +6'b1;	
				end
end

//采样numT个周期，便于生成标志位
always@(posedge clk_40M or negedge rst_n)
begin
	if(!rst_n)	begin
				numT <= 8'd0;
				end
	else if(numT < 8'd129)//应该129？初始numP=0使numP=1开始计数	
			begin
				if(numP==6'd0)
					begin 
					numT <= numT +8'd1; 
					end
			end
	else	
			begin
			numT <= 8'd0;
			end
end
//-----------------------------------------------
//numT_done标志位生成
always@(posedge clk_40M or negedge rst_n)
begin
	if(!rst_n)	begin
				clkT <= 1'b0;
				end
	else if(numP == 6'b0)	begin
							clkT <= 1'b1;
							end
	else	begin
			clkT <= 1'b0;
			end
end
//
always@(posedge clk_40M or negedge rst_n)
begin
	if(!rst_n)	begin
				numT_done <= 1'b0;
				end
	else if(numT==8'd128)	begin	//numT可持续40个点（一个周期）
							numT_done <= 1'b1;
							end
	else	begin
			numT_done <= 1'b0;
			end
end				
//-----------------------------------------------
//以clk_ad40_r为采样时钟采样
always @(posedge clk_40M or negedge rst_n)
begin
	if(!rst_n)
		begin 
			sum00 <= 22'd0; sum01 <= 22'd0; sum02 <= 22'd0; sum03 <= 22'd0; sum04 <= 22'd0; sum05 <= 22'd0; sum06 <= 22'd0; sum07 <= 22'd0; 
			sum08 <= 22'd0; sum09 <= 22'd0; sum10 <= 22'd0; sum11 <= 22'd0; sum12 <= 22'd0; sum13 <= 22'd0; sum14 <= 22'd0; sum15 <= 22'd0; 
			sum16 <= 22'd0; sum17 <= 22'd0; sum18 <= 22'd0; sum19 <= 22'd0; sum20 <= 22'd0; sum21 <= 22'd0; sum22 <= 22'd0; sum23 <= 22'd0; 
			sum24 <= 22'd0; sum25 <= 22'd0; sum26 <= 22'd0; sum27 <= 22'd0; sum28 <= 22'd0; sum29 <= 22'd0; sum30 <= 22'd0; sum31 <= 22'd0; 
			sum32 <= 22'd0; sum33 <= 22'd0; sum34 <= 22'd0; sum35 <= 22'd0; sum36 <= 22'd0; sum37 <= 22'd0; sum38 <= 22'd0; sum39 <= 22'd0; 
		end
   else
	begin
	case(numP)
	  6'd0	: begin if(numT ==8'd0) sum00 <= {8'd0,data_ain[13:0]};else sum00 <= sum00  + data_ain;end
	  6'd1 	: begin if(numT ==8'd0) sum01 <= {8'd0,data_ain[13:0]};else sum01 <= sum01  + data_ain;end
	  6'd2 	: begin if(numT ==8'd0) sum02 <= {8'd0,data_ain[13:0]};else sum02 <= sum02  + data_ain;end
	  6'd3 	: begin if(numT ==8'd0) sum03 <= {8'd0,data_ain[13:0]};else sum03 <= sum03  + data_ain;end
	  6'd4 	: begin if(numT ==8'd0) sum04 <= {8'd0,data_ain[13:0]};else sum04 <= sum04  + data_ain;end
	  6'd5 	: begin if(numT ==8'd0) sum05 <= {8'd0,data_ain[13:0]};else sum05 <= sum05  + data_ain;end
	  6'd6 	: begin if(numT ==8'd0) sum06 <= {8'd0,data_ain[13:0]};else sum06 <= sum06  + data_ain;end
	  6'd7 	: begin if(numT ==8'd0) sum07 <= {8'd0,data_ain[13:0]};else sum07 <= sum07  + data_ain;end
	  6'd8 	: begin if(numT ==8'd0) sum08 <= {8'd0,data_ain[13:0]};else sum08 <= sum08  + data_ain;end
	  6'd9 	: begin if(numT ==8'd0) sum09 <= {8'd0,data_ain[13:0]};else sum09 <= sum09  + data_ain;end
	  6'd10 : begin if(numT ==8'd0) sum10 <= {8'd0,data_ain[13:0]};else sum10 <= sum10 + data_ain;end
	  6'd11 : begin if(numT ==8'd0) sum11 <= {8'd0,data_ain[13:0]};else sum11 <= sum11 + data_ain;end
	  6'd12 : begin if(numT ==8'd0) sum12 <= {8'd0,data_ain[13:0]};else sum12 <= sum12 + data_ain;end
	  6'd13 : begin if(numT ==8'd0) sum13 <= {8'd0,data_ain[13:0]};else sum13 <= sum13 + data_ain;end
	  6'd14 : begin if(numT ==8'd0) sum14 <= {8'd0,data_ain[13:0]};else sum14 <= sum14 + data_ain;end
	  6'd15 : begin if(numT ==8'd0) sum15 <= {8'd0,data_ain[13:0]};else sum15 <= sum15 + data_ain;end
	  6'd16 : begin if(numT ==8'd0) sum16 <= {8'd0,data_ain[13:0]};else sum16 <= sum16 + data_ain;end
	  6'd17 : begin if(numT ==8'd0) sum17 <= {8'd0,data_ain[13:0]};else sum17 <= sum17 + data_ain;end
	  6'd18 : begin if(numT ==8'd0) sum18 <= {8'd0,data_ain[13:0]};else sum18 <= sum18 + data_ain;end
	  6'd19 : begin if(numT ==8'd0) sum19 <= {8'd0,data_ain[13:0]};else sum19 <= sum19 + data_ain;end
	  6'd20 : begin if(numT ==8'd0) sum20 <= {8'd0,data_ain[13:0]};else sum20 <= sum20 + data_ain;end
	  6'd21 : begin if(numT ==8'd0) sum21 <= {8'd0,data_ain[13:0]};else sum21 <= sum21 + data_ain;end
	  6'd22 : begin if(numT ==8'd0) sum22 <= {8'd0,data_ain[13:0]};else sum22 <= sum22 + data_ain;end
	  6'd23 : begin if(numT ==8'd0) sum23 <= {8'd0,data_ain[13:0]};else sum23 <= sum23 + data_ain;end
	  6'd24 : begin if(numT ==8'd0) sum24 <= {8'd0,data_ain[13:0]};else sum24 <= sum24 + data_ain;end
	  6'd25 : begin if(numT ==8'd0) sum25 <= {8'd0,data_ain[13:0]};else sum25 <= sum25 + data_ain;end
	  6'd26 : begin if(numT ==8'd0) sum26 <= {8'd0,data_ain[13:0]};else sum26 <= sum26 + data_ain;end
	  6'd27 : begin if(numT ==8'd0) sum27 <= {8'd0,data_ain[13:0]};else sum27 <= sum27 + data_ain;end
	  6'd28 : begin if(numT ==8'd0) sum28 <= {8'd0,data_ain[13:0]};else sum28 <= sum28 + data_ain;end
	  6'd29 : begin if(numT ==8'd0) sum29 <= {8'd0,data_ain[13:0]};else sum29 <= sum29 + data_ain;end
	  6'd30 : begin if(numT ==8'd0) sum30 <= {8'd0,data_ain[13:0]};else sum30 <= sum30 + data_ain;end
	  6'd31 : begin if(numT ==8'd0) sum31 <= {8'd0,data_ain[13:0]};else sum31 <= sum31 + data_ain;end
	  6'd32 : begin if(numT ==8'd0) sum32 <= {8'd0,data_ain[13:0]};else sum32 <= sum32 + data_ain;end
	  6'd33 : begin if(numT ==8'd0) sum33 <= {8'd0,data_ain[13:0]};else sum33 <= sum33 + data_ain;end
	  6'd34 : begin if(numT ==8'd0) sum34 <= {8'd0,data_ain[13:0]};else sum34 <= sum34 + data_ain;end
	  6'd35 : begin if(numT ==8'd0) sum35 <= {8'd0,data_ain[13:0]};else sum35 <= sum35 + data_ain;end
	  6'd36 : begin if(numT ==8'd0) sum36 <= {8'd0,data_ain[13:0]};else sum36 <= sum36 + data_ain;end
	  6'd37 : begin if(numT ==8'd0) sum37 <= {8'd0,data_ain[13:0]};else sum37 <= sum37 + data_ain;end
	  6'd38 : begin if(numT ==8'd0) sum38 <= {8'd0,data_ain[13:0]};else sum38 <= sum38 + data_ain;end
	  6'd39 : begin if(numT ==8'd0) sum39 <= {8'd0,data_ain[13:0]};else sum39 <= sum39 + data_ain;end
	 endcase
    end
end

always@(posedge clk_40M or negedge rst_n)
begin
	if(!rst_n)	sum <= 22'd0;
	else if(numT_done)
		begin
		case(numP)
		  6'd0  : sum <= sum00 - 22'd1048576;//去偏置2^13*128
		  6'd1  : sum <= sum01 - 22'd1048576;
		  6'd2  : sum <= sum02 - 22'd1048576;
		  6'd3  : sum <= sum03 - 22'd1048576;
		  6'd4  : sum <= sum04 - 22'd1048576;
		  6'd5  : sum <= sum05 - 22'd1048576;
		  6'd6  : sum <= sum06 - 22'd1048576;
		  6'd7  : sum <= sum07 - 22'd1048576;
		  6'd8  : sum <= sum08 - 22'd1048576;
		  6'd9  : sum <= sum09 - 22'd1048576;
		  6'd10 : sum <= sum10 - 22'd1048576;
		  6'd11 : sum <= sum11 - 22'd1048576;
		  6'd12 : sum <= sum12 - 22'd1048576;
		  6'd13 : sum <= sum13 - 22'd1048576;
		  6'd14 : sum <= sum14 - 22'd1048576;
		  6'd15 : sum <= sum15 - 22'd1048576;
		  6'd16 : sum <= sum16 - 22'd1048576;
		  6'd17 : sum <= sum17 - 22'd1048576;
		  6'd18 : sum <= sum18 - 22'd1048576;
		  6'd19 : sum <= sum19 - 22'd1048576;
		  6'd20 : sum <= sum20 - 22'd1048576;
		  6'd21 : sum <= sum21 - 22'd1048576;
		  6'd22 : sum <= sum22 - 22'd1048576;
		  6'd23 : sum <= sum23 - 22'd1048576;
		  6'd24 : sum <= sum24 - 22'd1048576;
		  6'd25 : sum <= sum25 - 22'd1048576;
		  6'd26 : sum <= sum26 - 22'd1048576;
		  6'd27 : sum <= sum27 - 22'd1048576;
		  6'd28 : sum <= sum28 - 22'd1048576;
		  6'd29 : sum <= sum29 - 22'd1048576;
		  6'd30 : sum <= sum30 - 22'd1048576;
		  6'd31 : sum <= sum31 - 22'd1048576;
		  6'd32 : sum <= sum32 - 22'd1048576;
		  6'd33 : sum <= sum33 - 22'd1048576;
		  6'd34 : sum <= sum34 - 22'd1048576;
		  6'd35 : sum <= sum35 - 22'd1048576;
		  6'd36 : sum <= sum36 - 22'd1048576;
		  6'd37 : sum <= sum37 - 22'd1048576;
		  6'd38 : sum <= sum38 - 22'd1048576;
		  6'd39 : sum <= sum39 - 22'd1048576;
		endcase
		end
	//else	begin sum <= 22'd0;	end
end

//生成FIFO可读标志位rdreq,非空即可读
always@(posedge clk_40M or negedge rst_n)
	   begin
		if(!rst_n) begin rdreq <= 1'b0;	end
		else if(wrempty == 1'b0) 
			begin
			rdreq <= 1'b1;
			end
		else
			begin
			rdreq <= 1'b0;
			end
		end
//FEA5XXXX33=10*4bits//	115200/40=2880hz,

assign data_fifo = sum[20:5];

fifo_16x256	fifo_16x256_inst (
	.data ( data_fifo ),
	.rdclk ( clk_read ),
	.rdreq ( rdreq ),
	.wrclk ( clk_40M ),
	.wrreq ( numT_done ),
	.wrempty ( wrempty ),
	.q ( q_out ),
	.rdempty ( rdempty_sig ),
	//.rdusedw ( rdusedw_sig ),
	.wrfull ( wrfull_sig ),
	.wrusedw ( used )
	);

//
/*
fifo_sum2uart	fifo_sum2uart_inst (
									.data  ( sum[20:5] ),//舍弃低5位，相当于除64
									.rdclk ( clk_read ),//读时钟，保证串口速率
									.rdreq ( rdreq ),		//非空即可读（1）
									.wrclk ( clk_40M ),
									.wrreq ( numT_done ),
									.q 	   ( q_out ),
									.rdempty ( rdempty_sig ),
									.wrfull ( wrfull_sig ),
									.wrusedw ( used )
									);

									
*/

//生成FIFO读时钟，cnt循环一次发送一个八位，115200/10,
always@(posedge clk_40M or negedge rst_n)
begin
	if(!rst_n)	begin	cnt <= 12'd0;	end
	else if(cnt<12'd2600)
			begin
			cnt <= cnt+12'd1;
			end
	else	cnt <= 12'd0;
end

always@(posedge clk_40M or negedge rst_n)
begin
	if(!rst_n)	
				begin
				clk_read <= 1'b0;
				end
	else if((cnt==12'd2600) && (rdclk_en==1'b1))//发送完帧头rdclk_en使能，保证FIFO输出不会随便读出
				begin
				clk_read <= ~clk_read;
				end
	else	clk_read <= clk_read;
end

always@(posedge clk_40M or negedge rst_n)
begin
	if(!rst_n)	begin	up_clk_read <= 1'b0;	end
	else	begin
			old_clk_read <= clk_read;
			up_clk_read <= (~old_clk_read)&clk_read;
			end
end
//-------------------------

//txd_out
//assign frame_r = {8'xFE,8'xA5,q_out[15:8],q_out[7:0],8'x33};

//非空标志
always@(posedge clk_40M)
begin
	negedge_empty <= old_rdempty_sig & (~rdempty_sig);
	old_rdempty_sig <= rdempty_sig;
	used1 <=used;
end

//非空标志
always@(posedge clk_40M)
begin
	negedge_wrempty <= old_wrempty_sig & (~wrempty);
	old_wrempty_sig <= wrempty;
end

//帧结构状态机
always@(posedge clk_40M or negedge rst_n)
begin
	if(!rst_n)	begin
				state <=0;
				end
	else
	case(state)
		3'd0:if(negedge_wrempty)	begin
					txd_out <= 8'hFE;
					uart_en <= ~uart_en;
					cnt_frame <= 6'd40;
					state <= 1;
				end
		3'd1:begin	txd_out <= 8'hA5;
					uart_en <= ~uart_en;
					state <= 2;
			 end
		3'd2:begin	rdclk_en <= 1'b1;//FIFO读时钟使能标志，下一状态后读时钟有效，开始读数据
					state <= 3;
			 end	
		3'd3:begin
					if(up_clk_read == 1'b1)
					begin
					cnt_frame <= cnt_frame - 6'd1;
					txd_out <= q_out[15:8];
					txd_out_nt <= q_out[7:0];
					uart_en <= ~uart_en;
					state <= 4;
					end
			 end
		3'd4:begin
					if(cnt == 12'd2600)
					begin
					txd_out <= txd_out_nt;
					uart_en <= ~uart_en;
					if(cnt_frame==0)	begin	state <= 5;	end
					else				begin	state <= 3;	end
					end
			 end
		3'd5:begin
					txd_out <= 8'h33;
					uart_en <= ~uart_en;
					cnt_frame <= 6'd40;
			 end
		default:state <= 0;
		
	
	endcase
end
endmodule
