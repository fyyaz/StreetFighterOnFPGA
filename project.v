`timescale 1ps/1ps

module clock60hz(reset_n, clk, enable, Q);
	input reset_n, clk, enable;
	output reg [19:0] Q;
	
	always @ (posedge clk) begin
	//)
		if ((!reset_n) || (Q == 20'b11001011011100110111))
			Q<=0;
		else if (enable)
			Q<=Q+1;
	end
endmodule

module yCounter(clock, reset_n, enable, q);
	input clock, reset_n, enable;
	output reg [6:0] q;
	
	always@(posedge clock)
	begin
	if(!reset_n)
		q <= 7'b0;
	else if(q == 7'd120)
		q <= 7'b0;
	else if(enable)
		q <= q+1'b1;
	end
endmodule

module xCounter(clock, reset_n, enable, q);
	input clock, reset_n, enable;
	output reg [7:0] q;
	
	always@(posedge clock)
	begin
	if(!reset_n)
		q <= 8'b0;
	else if(q == 8'd159)
		q <= 8'b0;
	else if(enable)
		q <= q+1'b1;
	end
endmodule

module charX_count(clock, reset_n, enable, q);
	input clock, reset_n, enable;
	output reg [4:0] q;
	
	always@(posedge clock)
	begin
	if(!reset_n)
		q <= 5'b0;
	else if(q == 5'd23)
		q <= 5'b0;
	else if(enable)
		q <= q+1'b1;
	end
endmodule

module charY_count(clock, reset_n, enable, q);
	input clock, reset_n, enable;
	output reg [5:0] q;
	
	always@(posedge clock)
	begin
	if(!reset_n)
		q <= 6'b0;
	else if(q == 6'd40)
		q <= 6'b0;
	else if(enable)
		q <= q+1'b1;
	end
endmodule

module charMemCountPixels(clock, reset_n, enable, q);
	input clock, reset_n, enable;
	output reg [9:0] q;
	
	always@(posedge clock)
	begin
	if(!reset_n)
		q <= 10'b0;
	else if(q == 10'd959)
		q <= 10'b0;
	else if(enable)
		q <= q+1'b1;
	end
endmodule

module count4(clk, enable, Q, reset_n);
	input clk, enable, reset_n;
	output reg [2:0] Q;
	always @ (posedge clk) begin
		if (!reset_n || Q == 3'd4)
			Q <= 3'b000;
		else if (enable)
			Q <= Q + 1'b1;
	end
endmodule

module count70(clk, enable, Q, reset_n);
	input clk, enable, reset_n;
	output reg [6:0] Q;
	always @ (posedge clk) begin
		if (!reset_n || Q == 7'd70)
			Q<=7'b0000000;
		else if (enable)
			Q<=Q+1'b1;
	end
endmodule

module game_state_machine(
	clk, reset_n, enable_ryu, enable_ken, win,big_x_count, big_y_count,
	enable_big_count, fill_black, plot_enable, state_out, char_count_X,
	char_count_Y, counter_reset, delay_enable, delay_in, enable_start_screen_draw, 
	key_input, key_input2, enable_change_sprite, load_ryu, load_ken, keyboard_reset,
	success_recieved, kpicture_select, rpicture_select, dec_ken, dec_ryu, health_ken_count, health_ryu_count,
	enable_ken_health, enable_ryu_health, health_y_ken, health_y_ryu, check_dist, win_signal
	);
	
	input clk, win, reset_n, success_recieved;
	output reg enable_ryu, enable_ken, enable_big_count, fill_black, plot_enable, counter_reset, delay_enable,
	enable_start_screen_draw, enable_change_sprite, load_ryu, load_ken, keyboard_reset, dec_ken, dec_ryu,
	enable_ken_health, enable_ryu_health, check_dist, win_signal;
	input [4:0] kpicture_select, rpicture_select;
	input [7:0] big_x_count;
	input [6:0] big_y_count, health_ken_count, health_ryu_count;
	output [9:0] state_out;
	input [4:0] char_count_X; 
	input [5:0] char_count_Y;
	input [19:0]delay_in;
	input [7:0] key_input, key_input2;
	input [2:0] health_y_ken, health_y_ryu;
	
	//assign state codes
	parameter S_reset = 11'd0, S_wait = 11'd1,S_fillblack = 11'd2, 
	S_draw_fill_black  = 11'd3, S_exit_fill_black	= 11'd4, 
	S_game = 11'd5,
	S_win = 11'd6, S_draw_ken = 11'd7, S_draw_ken_exit = 11'd8, 
	S_draw_ryu = 11'd9, S_draw_ryu_exit = 11'd10, S_hold = 11'd11, 
	S_draw_start_screen = 11'd12, S_start_screen_exit = 11'd13,
	S_hold2 = 11'd14, S_check_input = 11'd15, S_update = 11'd16,
	S_move = 11'd25,
	S_draw_health_ken = 11'd27, S_draw_health_ryu = 11'd28,
	S_draw_health_ken_exit = 11'd29, S_draw_health_ryu_exit = 11'd30;
	
	//state registers
	reg [10:0] current_state, next_state;
	
	//state table
	always @ (*) begin
		case (current_state)
			S_reset: begin
				next_state = S_draw_start_screen;
			end
			S_draw_start_screen: begin
				if (big_y_count <=7'd118)
					next_state = S_draw_start_screen;
				else 
					next_state = S_start_screen_exit;
			end
			S_start_screen_exit: begin
				if (big_x_count< 8'd159)
					next_state = S_start_screen_exit;
				else 
					next_state = S_hold2;
			end
			S_hold2: begin
				//20'b11001011011100110110
				if (delay_in <= 20'b11001011011100110110)
					next_state = S_hold2;
				else 
					next_state = S_wait;
			end
			S_wait: begin
				if (key_input == 8'h29 || key_input2 == 8'h29) // starts the game
					next_state = S_fillblack;
				else
					next_state = S_wait;
			end
			S_fillblack: begin
				next_state = S_draw_fill_black;
			end
			S_draw_fill_black:
			begin
				if (big_y_count <=7'd118)
					next_state = S_draw_fill_black;
				else
					next_state = S_exit_fill_black;
			end
			S_exit_fill_black:
			begin
				if (big_x_count< 8'd159)
					next_state = S_exit_fill_black;
				else 
					next_state = S_hold;
			end
			S_hold: 
			//
			begin
				if (delay_in <= 20'b00000011011100110110)
					next_state = S_hold;
				else 
					next_state = S_draw_health_ken;
			end
			S_draw_health_ken: begin
				if (health_ken_count<7'd70)
					next_state = S_draw_health_ken;
				else next_state = S_draw_health_ken_exit;
			end
			S_draw_health_ken_exit: begin
				if (health_y_ken<=3'd3)
					next_state = S_draw_health_ken_exit;
				else
					next_state = S_draw_health_ryu;
			end
			S_draw_health_ryu: begin
				if (health_ryu_count<7'd70)
					next_state = S_draw_health_ryu;
				else 
					next_state = S_draw_health_ryu_exit;
			end
			S_draw_health_ryu_exit: begin
				if (health_y_ryu<=3'd3)
					next_state = S_draw_health_ryu_exit;
				else 
					next_state = S_draw_ken;
			end
			S_draw_ken: begin
				if (char_count_Y <= 6'd39)
					next_state = S_draw_ken;
				else next_state = S_draw_ken_exit;
			end
			S_draw_ken_exit: begin
				next_state = S_draw_ryu;
			end
			S_draw_ryu: begin
				if (char_count_Y <= 6'd39)
					next_state = S_draw_ryu;
				else
					next_state = S_draw_ryu_exit;
			end
			S_draw_ryu_exit: begin
				next_state = S_check_input;
			end
			S_check_input: begin
				next_state = S_update;
			end
			S_update: begin
				next_state = S_game;
			end
			S_game: begin
				if (win)
					next_state = S_win;
				else if (key_input !=8'd0 || key_input2 !=8'd0)
					next_state = S_move;
			end
			S_move: begin
				next_state = S_fillblack;
			end
			S_win: next_state = S_win;
			default: next_state = S_reset;
		endcase
	end
	
	//state flip flop
	always @ (posedge clk) begin
		if (!reset_n)
			current_state = S_reset;
		else 
			current_state = next_state;
	end
	
	//output logic
	always @ (*) begin
		case (current_state)
			S_reset: begin
				win_signal = 1'b0;
				enable_change_sprite = 1'b0;
				enable_start_screen_draw = 1'b0;
				delay_enable = 1'b0;
				fill_black = 1'b0;
				enable_ken = 1'b0;
				enable_ryu = 1'b0;
				plot_enable = 1'b0;
				enable_big_count = 1'b0;
				dec_ken = 1'b0;
				dec_ryu = 1'b0;
				enable_ken_health = 1'b0;
				enable_ryu_health = 1'b0;
			end
			S_draw_start_screen: begin
				enable_change_sprite = 1'b0;
				enable_start_screen_draw = 1'b1;
				delay_enable = 1'b0;
				fill_black = 1'b0;
				enable_ken = 1'b0;
				enable_ryu = 1'b0;
				plot_enable = 1'b1;
				enable_big_count = 1'b1;
				enable_ken_health = 1'b0;
				enable_ryu_health = 1'b0;
			end
			S_start_screen_exit: begin
				enable_change_sprite = 1'b0;
				enable_start_screen_draw = 1'b1;
				delay_enable = 1'b0;
				fill_black = 1'b0;
				enable_ken = 1'b0;
				enable_ryu = 1'b0;
				plot_enable = 1'b1;
				enable_big_count = 1'b1;
				enable_ken_health = 1'b0;
				enable_ryu_health = 1'b0;
			end
			S_wait: begin
				enable_change_sprite = 1'b0;
				delay_enable = 1'b0;
				fill_black = 1'b0;
				enable_ken = 1'b0;
				enable_ryu = 1'b0;
				plot_enable = 1'b0;
				enable_big_count = 1'b0;
				enable_start_screen_draw = 1'b0;
				dec_ryu = 1'b0;
				enable_ken_health = 1'b0;
				enable_ryu_health = 1'b0;
			end	
			S_fillblack: begin
				enable_change_sprite = 1'b0;
				delay_enable = 1'b0;
				fill_black = 1'b1;
				enable_ken = 1'b0;
				enable_ryu = 1'b0;
				plot_enable = 1'b1;
				enable_big_count = 1'b1;
				enable_start_screen_draw = 1'b0;
				enable_ken_health = 1'b0;
				enable_ryu_health = 1'b0;
			end
			S_draw_fill_black: begin
				enable_change_sprite = 1'b0;
				delay_enable = 1'b0;
				fill_black = 1'b1;
				enable_ken = 1'b0;
				enable_ryu = 1'b0;
				plot_enable = 1'b1;
				enable_big_count = 1'b1;
				enable_start_screen_draw = 1'b0;
				enable_ken_health = 1'b0;
				enable_ryu_health = 1'b0;
			end
			S_exit_fill_black: begin
				enable_change_sprite = 1'b0;
				delay_enable = 1'b0;
				fill_black = 1'b1;
				enable_ken = 1'b0;
				enable_ryu = 1'b0;
				plot_enable = 1'b1;
				enable_big_count = 1'b1;
				enable_start_screen_draw = 1'b0;
				enable_ken_health = 1'b0;
				enable_ryu_health = 1'b0;
			end
			S_hold2: begin
				enable_change_sprite = 1'b0;
				delay_enable = 1'b1;
				fill_black = 1'b0;
				enable_ken = 1'b0;
				enable_ryu = 1'b0;
				plot_enable = 1'b0;
				enable_big_count = 1'b0;
				enable_start_screen_draw = 1'b0;
				enable_ken_health = 1'b0;
				enable_ryu_health = 1'b0;
			end
			S_hold: begin
				enable_change_sprite = 1'b0;
				delay_enable = 1'b1;
				fill_black = 1'b0;
				enable_ken = 1'b0;
				enable_ryu = 1'b0;
				plot_enable = 1'b0;
				enable_big_count = 1'b0;
				enable_start_screen_draw = 1'b0;
				enable_ken_health = 1'b0;
				enable_ryu_health = 1'b0;
			end
			S_draw_health_ken: begin
				enable_change_sprite = 1'b0;
				delay_enable = 1'b0;
				fill_black = 1'b0;
				enable_ken = 1'b0;
				enable_ryu = 1'b0;
				plot_enable = 1'b1;
				enable_big_count = 1'b0;
				enable_start_screen_draw = 1'b0;
				enable_ken_health = 1'b1;
				enable_ryu_health = 1'b0;
			end
			S_draw_health_ryu: begin
				enable_change_sprite = 1'b0;
				delay_enable = 1'b0;
				fill_black = 1'b0;
				enable_ken = 1'b0;
				enable_ryu = 1'b0;
				plot_enable = 1'b1;
				enable_big_count = 1'b0;
				enable_start_screen_draw = 1'b0;
				enable_ken_health = 1'b0;
				enable_ryu_health = 1'b1;
			end
			S_draw_ken: begin
				enable_ken_health = 1'b0;
				enable_ryu_health = 1'b0;
				enable_change_sprite = 1'b0;
				delay_enable = 1'b0;
				fill_black = 1'b0;
				enable_ken = 1'b1;
				enable_ryu = 1'b0;
				plot_enable = 1'b1;
				enable_big_count = 1'b0;
				enable_start_screen_draw = 1'b0;
			end
			S_draw_ken_exit: begin
				enable_change_sprite = 1'b0;
				delay_enable = 1'b0;
				fill_black = 1'b0;
				enable_ken = 1'b0;
				enable_ryu = 1'b0;
				plot_enable = 1'b1;
				enable_big_count = 1'b0;
				enable_start_screen_draw = 1'b0;
			end
			S_draw_ryu: begin
				enable_change_sprite = 1'b0;
				delay_enable = 1'b0;
				fill_black = 1'b0;
				enable_ken = 1'b0;
				enable_ryu = 1'b1;
				plot_enable = 1'b1;
				enable_big_count = 1'b0;
				enable_start_screen_draw = 1'b0;
			end
			S_draw_ryu_exit: begin
				enable_change_sprite = 1'b0;
				delay_enable = 1'b0;
				fill_black = 1'b0;
				enable_ken = 1'b0;
				enable_ryu = 1'b0;
				plot_enable = 1'b1;
				enable_big_count = 1'b0;
				enable_start_screen_draw = 1'b0;
			end
			S_check_input: begin
				enable_change_sprite = 1'b1;
				delay_enable = 1'b0;
				fill_black = 1'b0;
				enable_ken = 1'b0;
				enable_ryu = 1'b0;
				plot_enable = 1'b1;
				enable_big_count = 1'b0;
				enable_start_screen_draw = 1'b0;
			end
			S_game: begin
				enable_change_sprite = 1'b0;
				delay_enable = 1'b0;
				fill_black = 1'b0;
				enable_ken = 1'b0;
				enable_ryu = 1'b0;
				plot_enable = 1'b1;
				enable_big_count = 1'b0;
				enable_start_screen_draw = 1'b0;
				delay_enable = 1'b0;
				fill_black = 1'b0;
				enable_ken = 1'b0;
				enable_ryu = 1'b0;
				plot_enable = 1'b0;
				enable_big_count = 1'b0;
				enable_start_screen_draw = 1'b0;
			end
			S_move: begin
				check_dist = 1'b0;
			end
			S_update: begin
				check_dist = 1'b1;
			end
			S_win: begin
				win_signal = 1'b1;
				enable_change_sprite = 1'b0;
				enable_start_screen_draw = 1'b0;
				delay_enable = 1'b0;
				fill_black = 1'b0;
				enable_ken = 1'b0;
				enable_ryu = 1'b0;
				plot_enable = 1'b1;
				enable_big_count = 1'b1;
				enable_ken_health = 1'b0;
				enable_ryu_health = 1'b0;
			end
			default: begin
				enable_change_sprite = 1'b0;
				delay_enable = 1'b0;
				fill_black = 1'b0;
				enable_ken = 1'b0;
				enable_ryu = 1'b0;
				plot_enable = 1'b1;
				enable_big_count = 1'b0;
				enable_start_screen_draw = 1'b0;
			end
		endcase
	end
	assign state_out = current_state[9:0];
endmodule

module kenRX(clk, reset_n, D, Q, add);
	input clk, reset_n;
	input [1:0] add;
	input [7:0] D;
	output reg [7:0] Q;
	parameter ADD = 2'b01, SUB = 2'b10;
	always @ (posedge clk) begin
		if (!reset_n)
			Q<=8'd10;//ken initial x position is 10
		else if (add == ADD && Q < D - 8'd23)
			Q<=Q+3'b100;
		else if (add == SUB && Q > 8'd4)
			Q<=Q-3'b100;
	end
endmodule

module kenRY(clk, reset_n, D, Q, load);
	input clk, reset_n, load;
	input [6:0] D;
	output reg [6:0] Q;
	always @ (posedge clk) begin
		if (!reset_n)
			Q<=7'd40;//ken initial Y is at 40
		else if (load)
			Q<=D;
	end
endmodule

module count19200 (clock, reset_n, enable, q);
	input clock, reset_n, enable;
	output reg [14:0] q;//100101100000000
	
	always @ (posedge clock) begin
		if (!reset_n || q == 15'b100101011111111)
			q<=15'd0;
		else if (enable)
			q<=q+1'b1;
	end
	
endmodule

module ryuRX(clk, reset_n, D, Q, add);
	input clk, reset_n;
	input [7:0] D;
	output reg [7:0] Q;
	input [1:0] add;
	parameter ADD = 2'b01, SUB = 2'b10;
	always @ (posedge clk) begin
		if (!reset_n)
			Q<=8'd120;//ryu initial x poseition is at 120
		else if (add == ADD && Q<8'd140)
			Q<=Q+3'b100;
		else if (add == SUB && Q>D + 8'd23)
			Q<=Q-3'b100;
	end
endmodule

module ryuRY(clk, reset_n, D, Q, load, add);
	input clk, reset_n, load;
	input [6:0] D;
	input add;
	output reg [6:0] Q;
	always @ (posedge clk) begin
		if (!reset_n) 
			Q<=7'd40;
		else if (load)
			Q<=D;
	end
endmodule

module health_reg (clk, dec, reset_b, zero, Q);
	input clk, dec, reset_b;
	output reg [6:0] Q;
	output reg zero;
	
	always @ (posedge clk) begin
		if (reset_b == 0) begin
			zero <= 1'b0;
			Q <= 7'b1000110;
		end
		else if (Q <= 7'd0) begin
			zero = 1'b1;
		end
		else if (dec == 1'b1) begin
			Q<=Q-7'd1;
		end
	end
	
endmodule

module datapath(
		fill_black, clk, reset_n, x_out, y_out, big_count_enable, ryu_enable, 
		ken_enable, plot_out, plot_in, big_y_out, big_x_out, color_out,
		reset_counters, char_x_count, char_y_count,
		delay_enable, delay_out, enable_start_screen_draw, enable_change_sprite,
		key_input, key_output, key_en, key_input2, key_output2, key_en2, kpicture_select,
		rpicture_select, ken_health, ryu_health, enable_ken_health_count,
		enable_ryu_health_count, health_ken_X_out, health_ryu_X_out, health_ryu_Y_out, health_ken_Y_out,
		check_dist, d, win_signal
	);
	input check_dist, win_signal;
	input enable_ken_health_count, enable_ryu_health_count;
	input delay_enable, enable_start_screen_draw, enable_change_sprite;
	output [19:0]delay_out;
	output [4:0] kpicture_select, rpicture_select;
	output [7:0] x_out;
	output [6:0] y_out;
	output [4:0] char_x_count;
	output [5:0] char_y_count;
	output plot_out;
	output [2:0] color_out;
	input fill_black, clk, reset_n, plot_in, big_count_enable, ryu_enable, ken_enable, reset_counters;
	output [6:0] big_y_out;
	output [7:0] big_x_out;
	input [7:0] key_input, key_input2;
	input key_en, key_en2;
	output [7:0] key_output, key_output2;
	output [6:0] ken_health, ryu_health, health_ken_X_out, health_ryu_X_out;
	
	wire [6:0] big_y_count_wire, ryu_start_y, ken_start_y;
	wire [7:0] big_x_count_wire, ryu_start_x, ken_start_x;
	wire dec_ken, dec_ryu;
	reg [1:0] ryu_add, ken_add;
	wire [1:0] ryu_add_wire, ken_add_wire;
	wire [2:0]ken_win_color, ryu_win_color;
	assign ryu_add_wire = ryu_add;
	assign ken_add_wire = ken_add;
	parameter ADD = 2'b01, SUB = 2'b10, NONE = 2'b00;
	
	//registers to hold the position of the characters
	wire zero_ken, zero_ryu;
	
	//clk, dec, reset_b, zero, Q
	
	//counters to draw ken health bar
	output [2:0] health_ken_Y_out;
	count70 ken_health_X(
		.clk(clk),
		.reset_n(reset_n),
		.enable(health_ken_Y_out == 3'd4),
		.Q(health_ken_X_out)
	);
	count4 ken_health_y(
		.clk(clk),
		.reset_n(reset_n),
		.enable(enable_ken_health_count),
		.Q(health_ken_Y_out)
	);
	
	//counter to draw ryu health bar
	output [2:0] health_ryu_Y_out;
	count70 ryu_health_X(
		.clk(clk),
		.reset_n(reset_n),
		.enable(health_ryu_Y_out == 3'd4),
		.Q(health_ryu_X_out)
	);
	count4 ryu_health_y(
		.clk(clk),
		.reset_n(reset_n),
		.enable(enable_ryu_health_count),
		.Q(health_ryu_Y_out)
	);
	
	
	health_reg ken_health_reg(
		.clk(clk),
		.dec(dec_ken),
		.reset_b(reset_n),
		.zero(zero_ken),
		.Q(ken_health)
	);
	
	health_reg ryu_health_reg(
		.clk(clk),
		.dec(dec_ryu),
		.reset_b(reset_n),
		.zero(zero_ryu),
		.Q(ryu_health)
	);
	
	ryuRX ryuXReg(
		.clk(clk),
		.reset_n(reset_n),
		.add(ryu_add),
		.D(ken_start_x),
		.Q(ryu_start_x)
	);
	ryuRY ryuYReg(
		.clk(clk),
		.reset_n(reset_n),
		.D(ryu_start_y),
		.Q(ryu_start_y)
	);
	kenRX kenXReg(
		.clk(clk),
		.reset_n(reset_n),
		.add(ken_add),
		.D(ryu_start_x),
		.Q(ken_start_x)
	);
	kenRY kenYReg(
		.clk(clk),
		.reset_n(reset_n),
		.D(ken_start_y),
		.Q(ken_start_y)
	);
	
	xCounter big_x(
		.clock(clk),
		.reset_n(reset_n),
		.enable(big_count_enable),
		.q(big_x_count_wire)
	);
	
	wire big_y_enable;
	assign big_y_enable = (big_x_count_wire == 8'd159);
	yCounter big_y(
		.clock(clk),
		.reset_n(reset_n),
		.enable(big_y_enable),
		.q(big_y_count_wire)
	);
	
	//the counter for memory of start screen 
	//clock, reset_n, enable, q
	
	wire [14:0] start_screen_address, win_address;
	wire [2:0] start_color, win_color;
	count19200 start_screen_counter(
		.clock(clk),
		.reset_n(reset_n),
		.enable(enable_start_screen_draw),
		.q(start_screen_address)
	); 
	
	count19200 win_address_counter(
		.clock(clk),
		.reset_n(reset_n),
		.enable(win_signal),
		.q(win_address)
	);
	
	start_screen_memory memory_start(
		.address(start_screen_address),
		.clock(clk),
		.data(3'bxxx),
		.wren(1'b0),
		.q(start_color)
	);
	ken_win_memory kwin(
		.address(win_address),
		.clock(clk),
		.data(3'bxxx),
		.wren(1'b0),
		.q(ken_win_color)
	);
	ryu_win_memory rwin(
		.address(win_address),
		.clock(clk),
		.data(3'bxxx),
		.wren(1'b0),
		.q(ryu_win_color)
	);
	wire [2:0] ken_color_out, ryu_color_out;
	wire [4:0] ryu_x_wire, ken_x_wire;
	wire [5:0] ryu_y_wire, ken_y_wire;
	wire [9:0] ken_address, ryu_address;

	//Ryu
	//module charMemCountX(clock, reset_n, enable, q);
	charX_count ryu_X(
		.clock(clk),
		.reset_n(reset_n),
		.enable(ryu_enable),
		.q(ryu_x_wire)
	);
	wire ryu_Y_enable, ken_Y_enable;
	//y counter only gets enable signal when x has reached limit and is about to go back to 0
	assign ryu_Y_enable = ryu_enable & (ryu_x_wire == 5'd23);
	assign ken_Y_enable = ken_enable & (ken_x_wire == 5'd23);
	//module charMemCountY(clock, reset_n, enable, q);
	charY_count ryu_Y(
		.clock(clk),
		.reset_n(reset_n),
		.enable(ryu_Y_enable),
		.q(ryu_y_wire)
	);
	//module charMemCountPixels(clock, reset_n, enable, q);
	charMemCountPixels MemCountPixelsRyu(
		.clock(clk),
		.reset_n(reset_n),
		.enable(ryu_enable),
		.q(ryu_address)
	);
	//should have wren 0 always because dont want to change the contents
	ryumemory ryuPicture(
		.address(ryu_address),
		.clock(clk),
		.wren(1'b0),
		.data(3'bxxx),
		.q(ryu_color_out)
	);
	
	wire [2:0] ryu_left_wire;
	ryu_move_left rleft(
		.address(ryu_address),
		.clock(clk),
		.wren(1'b0),
		.data(3'bxxx),
		.q(ryu_left_wire)
	);
	
	wire [2:0] ryu_right_wire;
	ryu_move_right rright(
		.address(ryu_address),
		.clock(clk),
		.wren(1'b0),
		.data(3'bxxx),
		.q(ryu_right_wire)
	);
	
	wire [2:0] ryu_punch_wire;
	ryu_punch rpunch(
		.address(ryu_address),
		.clock(clk),
		.wren(1'b0),
		.data(3'bxxx),
		.q(ryu_punch_wire)
	);
	
	wire [2:0] ryu_kick_wire;
	ryu_kick rkick(
		.address(ryu_address),
		.clock(clk),
		.wren(1'b0),
		.data(3'bxxx),
		.q(ryu_kick_wire)
	);
	//Ken
	charX_count ken_X(
		.clock(clk),
		.reset_n(reset_n),
		.enable(ken_enable),
		.q(ken_x_wire)
	);
	//module charMemCountY(clock, reset_n, enable, q);
	charY_count ken_Y(
		.clock(clk),
		.reset_n(reset_n),
		.enable(ken_Y_enable),
		.q(ken_y_wire)
	);
	//module charMemCountPixels(clock, reset_n, enable, q);
	charMemCountPixels MemCountPixelsKen(
		.clock(clk),
		.reset_n(reset_n),
		.enable(ken_enable),
		.q(ken_address)
	);
	
	//delay counter
	clock60hz delay_counter(
		.reset_n(reset_n),
		.clk(clk),
		.enable(delay_enable),
		.Q(delay_out)
	);
	
	
	//should have the wren set to 0 always because dont want to change the contents
	kenmemory kenPicture(
		.address(ken_address),
		.clock(clk),
		.wren(1'b0),
		.data(3'bxxx),
		.q(ken_color_out)
	);
	
	wire [2:0] ken_left_wire;
	ken_move_left kleft(
		.address(ken_address),
		.clock(clk),
		.wren(1'b0),
		.data(3'bxxx),
		.q(ken_left_wire)
	);
	
	wire [2:0] ken_right_wire;
	ken_move_right kright(
		.address(ken_address),
		.clock(clk),
		.wren(1'b0),
		.data(3'bxxx),
		.q(ken_right_wire)
	);
	
	wire [2:0] ken_punch_wire;
	ken_punch kpunch(
		.address(ken_address),
		.clock(clk),
		.wren(1'b0),
		.data(3'bxxx),
		.q(ken_punch_wire)
	);
	
	wire [2:0] ken_kick_wire;
	ken_kick kkick(
		.address(ken_address),
		.clock(clk),
		.wren(1'b0),
		.data(3'bxxx),
		.q(ken_kick_wire)
	);
	
	reg [7:0] x;
	reg [6:0] y;
	reg [2:0] color;
	//x_out mux
	always @ (*) begin
		if (fill_black)
			x = big_x_count_wire;
		else if (win_signal)
			x = big_x_count_wire;
		else if(ken_enable)
			x = ken_x_wire + ken_start_x;
		else if(ryu_enable)
			x = ryu_x_wire + ryu_start_x;
		else if (enable_start_screen_draw)
			x = big_x_count_wire;
		else if (enable_ken_health_count)
			x = health_ken_X_out + 7'd5;
		else if (enable_ryu_health_count)
			x = health_ryu_X_out + 7'd80;
		else
			x = 0;
	end
	
	//y_out mux
	always @ (*) begin
		if(fill_black)
			y = big_y_count_wire;
		else if (win_signal)
			y = big_y_count_wire;
		else if(ken_enable)
			y = ken_y_wire + ken_start_y;
		else if(ryu_enable)
			y = ryu_y_wire + ryu_start_y;
		else if (enable_start_screen_draw)
			y = big_y_count_wire;
		else if (enable_ken_health_count)
			y = health_ken_Y_out + 7'd5;
		else if (enable_ryu_health_count)
			y = health_ryu_Y_out + 7'd5;
		else
			y = 0;
	end
	output reg [7:0] d;
	//check distance
	always @ (posedge clk) begin
		if (!reset_n)
			d <= 8'd0;
		else if (check_dist)
			d <= ryu_start_x - ken_start_x;
	end
	
	//memory select codes
	parameter M_idle = 5'b00001, M_move_left = 5'b00010, M_move_right = 5'b00100, M_kick = 5'b01000, M_punch = 5'b10000; 
	reg [4:0] kpic, rpic;
	always @ (*) begin
		if (enable_change_sprite) begin
			//ken 
			if (key_input == 8'h23) begin
				ken_add = ADD;
				kpic = M_move_right;
			end
			else if (key_input == 8'h1c) begin
				ken_add = SUB;
				kpic = M_move_left;
			end
			else if (key_input == 8'h1d) begin
				ken_add = NONE;
				kpic = M_kick;
			end
			else if (key_input == 8'h1b) begin
				ken_add = NONE;
				kpic = M_punch;
			end
			else begin
				ken_add = NONE;
				kpic = M_idle;
			end
			if (key_input2 == 8'h4b) begin
				ryu_add = ADD;
				rpic = M_move_right;
			end
			else if (key_input2 == 8'h3b) begin
				ryu_add = SUB;
				rpic = M_move_left;
			end
			else if (key_input2 == 8'h43) begin
				ryu_add = NONE;
				rpic = M_kick;
			end
			else if (key_input2 == 8'h42) begin
				ryu_add = NONE;
				rpic = M_punch;
			end
			else begin
				ryu_add = NONE;
				rpic = M_idle;
			end
		end
		else
			begin
				ken_add = NONE;
				ryu_add = NONE;
			end
	end
	//color_out mux
	always @ (*) begin
		if (fill_black)
			color = 3'b000; //black
		else if (win_signal) begin
			if (ken_health>0)
				color = ken_win_color;
			else color = ryu_win_color;
		end
		else if (ken_enable) 
			begin
				if (kpic == M_idle)
					color = ken_color_out;
				else if (kpic == M_move_left)
					color = ken_left_wire;
				else if (kpic == M_move_right)
					color = ken_right_wire;
				else if (kpic == M_kick)
					color = ken_kick_wire;
				else if (kpic == M_punch)
					color = ken_punch_wire;
				else color = ken_color_out;
			end
		else if (ryu_enable)
			begin
				if (rpic == M_idle)
					color = ryu_color_out;
				else if (rpic == M_move_left)
					color = ryu_left_wire;
				else if (rpic == M_move_right)
					color = ryu_right_wire;
				else if (rpic == M_punch)
					color = ryu_punch_wire;
				else if (rpic == M_kick)
					color = ryu_kick_wire;
				else color = ryu_color_out;
			end
		else if (enable_start_screen_draw)
			color = start_color;
		else if (enable_ken_health_count) begin
			if (health_ken_X_out<=ken_health)
				color = 3'b010;//green for the health that they have
			else 
				color = 3'b100;//red for health lost
		end
		else if (enable_ryu_health_count) begin
			if (health_ryu_X_out<=ryu_health)
				color = 3'b010;
			else 
				color = 3'b100;
		end
		else
			color = 3'b000;//black should be the default
	end
	
	//char_x_count mux
	reg [4:0]charX;
	always @ (*) begin
		if (ken_enable)
			charX = ken_x_wire;
		else if (ryu_enable)
			charX = ryu_x_wire;
		else 
			charX = 5'd0;
	end
	
	//char_y_count mux
	reg [5:0]charY;
	always @ (*) begin
		if (ken_enable)
			charY = ken_y_wire;
		else if (ryu_enable)
			charY = ryu_y_wire;
		else 
			charY	= 6'd0;
	end
	assign dec_ken = (d == 8'h16) && (rpic == M_punch || rpic == M_kick) && enable_change_sprite;
	assign dec_ryu = (d == 8'h16) && (kpic == M_punch || kpic == M_kick) && enable_change_sprite;
	assign char_x_count = charX;
	assign char_y_count = charY;
	assign x_out = x;
	assign y_out = y;
	assign big_x_out = big_x_count_wire;
	assign big_y_out = big_y_count_wire;
	assign color_out = color;
	assign plot_out = plot_in;
	assign key_output = (key_en? key_input : 8'd0);
	assign key_output2 = (key_en2? key_input2 : 8'd0);
	assign rpicture_select = rpic;
	assign kpicture_select = kpic;
endmodule

module project
	(
		LEDR,
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
		  HEX0,
		  HEX1,
		  HEX2,
		  HEX3,
		  HEX4,
		  HEX5,
		// The ports below are for the PS/2 input
		  PS2_CLK,
	     PS2_DAT,
		  PS2_CLK2, 
		  PS2_DAT2,
		// The ports below are for the VGA output.  Do not change.
		  VGA_CLK,   						//	VGA Clock
		  VGA_HS,							//	VGA H_SYNC
		  VGA_VS,							//	VGA V_SYNC
		  VGA_BLANK_N,						//	VGA BLANK
		  VGA_SYNC_N,						//	VGA SYNC
		  VGA_R,   						//	VGA Red[9:0]
		  VGA_G,	 						//	VGA Green[9:0]
		  VGA_B   						//	VGA Blue[9:0]
	);
	inout PS2_CLK, PS2_DAT, PS2_CLK2, PS2_DAT2;
	output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	input			CLOCK_50;				//	50 MHz
	input   [9:0]   SW;
	input   [3:0]   KEY;
	output [9:0]LEDR;

	// Declare your inputs and outputs here
	
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	wire resetn;
	assign resetn = KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.

	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn, keyboard_reset;
	// Internal Wires
	wire [7:0] ps2_key_data, ps2_key_data2, key_out, key_out2;
	wire ps2_key_pressed, ps2_key_pressed2, no, big_count_enable, plot_in, fill_black, counter_reset
	,enable_ryu, enable_ken, enable_change_sprite;
	wire [7:0] big_x_count_wire;
	wire [6:0] big_y_count_wire;
	wire [4:0] charX_wire, select_ken_mem, select_ryu_mem;
	wire [5:0] charY_wire; 
	wire delay_enable, enable_start_screen_draw, load_ryu, load_ken;
	wire [19:0] delay;
	wire dec_ryu, dec_ken, enable_ken_health, enable_ryu_health ;
	wire [7:0] health_ken_count, health_ryu_count;
	wire [9:0] out;
	wire win_signal;
	game_state_machine __game_state_machine(
		.clk(CLOCK_50),
		.reset_n(resetn),
		.enable_ken(enable_ken),
		.enable_ryu(enable_ryu),
		.win(ken_health == 7'd0 || ryu_health == 7'd0),
		.big_x_count(big_x_count_wire),
		.big_y_count(big_y_count_wire),
		.enable_big_count(big_count_enable),
		.fill_black(fill_black),
		.plot_enable(plot_in),
		.state_out(out),
		.counter_reset(counter_reset),
		.char_count_Y(charY_wire),
		.char_count_X(charX_wire),
		.delay_enable(delay_enable),
		.delay_in(delay),
		.enable_start_screen_draw(enable_start_screen_draw),
		.enable_change_sprite(enable_change_sprite),
		.key_input(key_out),
		.key_input2(key_out2),
		.enable_ken_health(enable_ken_health),
		.enable_ryu_health(enable_ryu_health),
		.health_ken_count(health_ken_count),
		.health_ryu_count(health_ryu_count),
		.health_y_ken(health_ken_Y),
		.health_y_ryu(health_ryu_Y),
		.check_dist(check_dist),
		.win_signal(win_signal)
	);
	
	//module datapath(fill_black, clk, reset_n, x_out, y_out, big_count_enable, MemCountXRyu_enable, MemCountXKen_enable, MemCountPixelsRyu_enable,
	//MemCountPixelsKen_enable, MemCountX_Out_Ken, MemCountY_Out_Ken, MemCountPixels_Out_Ken, MemCountX_Out_Ryu, MemCountY_Out_Ryu, 
	//MemCountPixels_Out_Ryu, plot_out, plot_in, big_y_out, big_x_out, color_out);
	wire [7:0] d;
	wire [6:0] ken_health, ryu_health;
	wire [2:0] health_ken_Y, health_ryu_Y;
	wire check_dist;
	datapath __datapath(
		.fill_black(fill_black),
		.clk(CLOCK_50),
		.reset_n(resetn),
		.x_out(x),
		.y_out(y),
		.big_count_enable(big_count_enable),
		.plot_out(writeEn),
		.plot_in(plot_in),
		.ryu_enable(enable_ryu),
		.ken_enable(enable_ken),
		.big_x_out(big_x_count_wire),
		.big_y_out(big_y_count_wire),
		.color_out(colour),
		.char_x_count(charX_wire),
		.char_y_count(charY_wire),
		.delay_enable(delay_enable),
		.delay_out(delay),
		.enable_start_screen_draw(enable_start_screen_draw),
		.key_input(ps2_key_data),
		.key_en(ps2_key_pressed),
		.key_output(key_out),
		.key_input2(ps2_key_data),
		.key_en2(ps2_key_pressed),
		.key_output2(key_out2),
		.enable_change_sprite(enable_change_sprite),
		.ken_health(ken_health),
		.ryu_health(ryu_health),
		.enable_ken_health_count(enable_ken_health),
		.enable_ryu_health_count(enable_ryu_health),
		.health_ken_X_out(health_ken_count),
		.health_ryu_X_out(health_ryu_count),
		.health_ryu_Y_out(health_ryu_Y),
		.health_ken_Y_out(health_ken_Y),
		.check_dist(check_dist),
		.d(d),
		.win_signal(win_signal)
	);
	
	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	
	vga_adapter VGA(
		.resetn(resetn),
		.clock(CLOCK_50),
		.colour(colour),
		.x(x),
		.y(y),
		.plot(writeEn),
		.VGA_R(VGA_R),
		.VGA_G(VGA_G),
		.VGA_B(VGA_B),
		.VGA_HS(VGA_HS),
		.VGA_VS(VGA_VS),
		.VGA_BLANK(VGA_BLANK_N),
		.VGA_SYNC(VGA_SYNC_N),
		.VGA_CLK(VGA_CLK)
	);
			
	defparam VGA.RESOLUTION = "160x120";
	defparam VGA.MONOCHROME = "FALSE";
	defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
	defparam VGA.BACKGROUND_IMAGE = "startup_screen.mif";
	
	wire success_recieved;
	//ps/2 keyboard controller
	PS2_Controller PS2(
		// Inputs
		.CLOCK_50(CLOCK_50),
		.reset(~KEY[0]),
		// Bidirectionals
		.PS2_CLK	(PS2_CLK),
		.PS2_DAT	(PS2_DAT),
		// Outputs
		.received_data(ps2_key_data),
		.received_data_en(ps2_key_pressed)
	);
	
	
	HexDecoder h1(ken_health[6:4], HEX1);
	HexDecoder h0(ken_health[3:0], HEX0);
	HexDecoder h3(ryu_health[6:4], HEX3);
	HexDecoder h2(ryu_health[3:0], HEX2);
	HexDecoder h4(d[7:4], HEX5);
	HexDecoder h5(d[3:0], HEX4);
	
endmodule

