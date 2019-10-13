module rxtx (clk, ptt, outrel, inrel, pttout, bypass, bs,
bias, band, fault, reset, pwmout, faultout);

input		clk, ptt, fault, reset;
input		[5:0] bs;
output	outrel, inrel, pttout, bias, bypass, pwmout, faultout;
output	[2:0] band;

parameter TIME = 360000; //15ms @ 48MHz
parameter PWMTIME = 120; //25kHz * 8
parameter PWM = 1; //0..7

wire clk, ptt, fault, reset;
wire [5:0] bs;
reg  outrel, inrel, pttout, bias, pwmout, faultout;
reg  [2:0] band;
reg  [20:0] counter;
reg  [6:0] pcount;
reg  [2:0] pwmcounter;
reg state;
reg pstate;
reg bypass;

assign dclk = state;
assign off = ~bypass;
assign tx = outrel;
assign pwmclk = pstate;
	
always @(posedge clk)  
	 begin
	  counter <= counter + 1;
	  if (counter >= TIME)
	  begin
	   counter <= 0;
      state  <= !state;	  
    end
	end

always @(posedge clk)  
	 begin
	  pcount <= pcount + 1;
	  if (pcount >= PWMTIME)
	  begin
	   pcount <= 0;
      pstate  <= !pstate;	  
    end
	end

always @(posedge pwmclk)  
	 begin
	  pwmcounter <= pwmcounter + 1;
	  if (pwmcounter < PWM || tx)
      pwmout <= 1'b0;	  
	  else
	   pwmout <= 1'b1;
    end
	
always @(posedge dclk)  
	 begin
		if(ptt || off)
		begin
		  pttout <= 1'b0;
		  if (pttout == 1'b0)
		  begin
		    inrel <= 1'b0;
		  end
		  if (inrel == 1'b0)
		  begin
		    outrel <= 1'b0;
		  end
		  if (outrel == 1'b0)
		  begin
		    bias <= 1'b0;
		  end
		end
		else
		begin
		  outrel <= 1'b1;
		  if (outrel == 1'b1)
		  begin
		    inrel <= 1'b1;
		  end
		  if (inrel == 1'b1)
		  begin
		    bias <= 1'b1;
		  end
        if (bias == 1'b1)
		  begin
		    pttout <= 1'b1;
        end
     end
	 end

always @(posedge clk) 
	case (bs)
		6'b111110: band <= 3'b000;
		6'b111101: band <= 3'b000;
		6'b111011: band <= 3'b100;
		6'b110111: band <= 3'b010;
		6'b101111: band <= 3'b010;
		6'b011111: band <= 3'b001;
		default: band <= 3'b001;
	endcase
 
always @(posedge clk)  
	begin
	  if(reset)
	   bypass <= 0;
	  else
	   bypass <= 1;
	end

always @(posedge clk)  
	begin
	  if(fault)
	   faultout <= 1;
	  else
	   faultout <= 0;
	end
	 
endmodule