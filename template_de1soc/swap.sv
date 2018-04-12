module swap (CLOCK_50, reset, start_swapping, finish_swapping, data_i, data_j, i, j, address_i, enable_a);
input logic start_swapping, CLOCK_50, reset;
output logic finish_swapping, enable_a;
inout  logic [7:0] data_i, data_j, i, j;
output logic [7:0] address_i, address_j ;

logic [3:0] state;
parameter idle = 4'b0001;
parameter change_pos_i = 4'b0010;
parameter wait_i = 4'b0011;
parameter change_pos_j = 4'b0100;
parameter wait_j = 4'b0101;
parameter finish = 4'b0110;

always_ff@(posedge CLOCK_50)begin
if(reset)
state <= idle;
else begin
case(state)
	idle :begin if(start_swapping)
				state <= change_pos_i;
			else
				state <= idle;
			end
	
	change_pos_i : state <= wait_i;
	wait_i : state <= change_pos_j;
	change_pos_j : state <= wait_j;
	wait_j : state <= finish;
	finish : state <= idle;
	default : state <= idle;
	endcase
	end
	end
	
	always_ff@(posedge CLOCK_50) begin
		case(state)
		change_pos_i : {address_i, data_i, enable_a} <= {i, data_j, 1'b1};
		change_pos_j : {address_j, data_j, enable_a} <= {j, data_i, 1'b1};
		finish : finish_swapping
		default : 	{address_2a, data_2a, enable_2a} <= {8'b0, 8'b0, 1'b0};	
		endcase
		end
		endmodule