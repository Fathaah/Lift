`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// University:National Instiute Of Technology Calicut 
// Created By: Abdul Fathaah
// Create Date: 10/15/2018 03:41:01 PM 
// Module Name: Elevator
// Project Name: Elevator Controller
// Revision:0.001b
// Revision 0.01 - File Created
//////////////////////////////////////////////////////////////////////////////////
module Elevator();
    parameter N=10;
    reg[3:0] Floor,From,To,temp;
    reg Aboard;
    wire clk;
    reg Door,temp1;
    reg Dir;
    reg[3:0] FromQ[N-1:0],ToQ[N-1:0];
    integer i;
    localparam ON=1'b1,OFF=1'b0,IDLE=4'b0000;
    initial begin
    Aboard=OFF;
    Door=OFF;
    Floor=IDLE+1;
    From=IDLE+7;
    To=IDLE+3;
    i=0;
    
    repeat(N)
    begin
        FromQ[i]=IDLE;
        ToQ[i]=IDLE;
        i=i+1;
    end
    temp1=OFF;
    FromQ[0]=IDLE+4;
    ToQ[0]=IDLE+1;
    FromQ[1]=IDLE+5;
    ToQ[1]=IDLE+1;
    FromQ[2]=IDLE+2;
    ToQ[2]=IDLE+5;
    FromQ[3]=IDLE+3;
    ToQ[3]=IDLE+6;
    #100
    $finish;    
    end
    always@(posedge clk,negedge clk)
    begin
        if(From==IDLE|To==IDLE)
        begin
            //Do nothing
            Door<=OFF;
        end
        else begin    
        if(Aboard==OFF)
        begin
            
            if(Floor<From)
            begin
                Door<=OFF;
                Floor<=Floor+1;
                $display("in1",Floor);
            end
            if(Floor>From)
            begin
                Door<=OFF;
                Floor<=Floor-1;
            end
            if(Floor==From)
            begin
                Door=ON;
                Aboard<=ON;
            end
            
        end//Master if close
        if(Aboard==ON)
        begin
            $display("in2",Floor);
            if(Floor==To)
            begin
                temp1=CheckToStop(Floor);
                Aboard<=OFF;
                From<=IDLE;
                To<=IDLE;
                Door<=ON;
            end
            if(Floor<To)
            begin
                if(CheckToStop(Floor))
                begin
                    Door<=ON;
                end
                else
                begin    
                    Door<=OFF;
                    Floor<=Floor+1;
                end
            end
            if(Floor>To)
            begin
                if(CheckToStop(Floor))
                begin
                   Door<=ON;
                end
                else
                begin
                    Door<=OFF;
                    Floor<=Floor-1;
                end
            end
        end//end  if
        end//else
    end//always
    always@(*)
    begin
        if(From==IDLE)
        begin
            From<=FromQ[0];
            To<=ToQ[0];
            i=0;
            repeat(N-1)
            begin
                FromQ[i]<=FromQ[i+1];
                ToQ[i]<=ToQ[i+1];
                i=i+1;
            end//repeat
            FromQ[N-1]<=IDLE;
            ToQ[N-1]<=IDLE;   
        end//if 1
    end//always
    function automatic CheckToStop;
        input[3:0] Floor;
        reg temp;
        begin
            temp=OFF;
            i=0;
            Dir=From>To?0:1;
            repeat(N)
            begin
                if(Floor==FromQ[i])
                begin
                    if(Dir==(FromQ[i]<ToQ[i]))
                    begin
                        temp=ON;
                        FromQ[i]=IDLE;
                        To=!Dir?(ToQ[i]<To?ToQ[i]:To):(ToQ[i]>To?ToQ[i]:To);
                    end
                end
                if(Floor==ToQ[i])
                begin
                    if(FromQ[i]==IDLE)
                    begin
                        ToQ[i]=IDLE; 
                        temp=ON;
                    end
                end
            i=i+1;
            end
        CheckToStop=temp;
        end    
    endfunction
endmodule