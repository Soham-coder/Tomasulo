`include "head.v"
`timescale 1ns/1ps
module CU(
    input [5:0] op,
    input [5:0] func,
    output reg[1:0]ALUop,
    output reg[1:0]ALUSel,
    output reg[3:0]ResStationEN,
    input [2:0]isFull,
    output isFullOut,
    output RegDst,
    output vkSrc,
    output QueueOp
);
    always@(*) begin
        case(op)
            `opRFormat:
                case(func)
                    `funcADD, `funcMULU:
                        ALUop = 0;  
                    `funcSUB : ALUop = `ALUSub;
                    `funcAND : ALUop = `ALUAnd;
                    default : ALUop = `ALUOr;
                endcase
            `opADDI : ALUop = `ALUAdd;
            `opORI : ALUop = `ALUOr;
            default:
                ALUop = 1;
        endcase
        if (op == `opHALT) begin
            //ALUSel = 2'b00;
            ResStationEN = 4'b0000;
        end
        else if (func == `funcMULU) begin
            ALUSel = `multipleALU;
            ResStationEN = 4'b0010;
        end
        else if (func == `funcDIVU) begin
            ALUSel = `divideALU;
            ResStationEN = 4'b0100;
        end 
        else if (op == `opLW || op == `opSW) begin
            //ALUSel = 2'b11;
            ResStationEN = 4'b1000;
        end else begin
            ALUSel = `addsubALU;
            ResStationEN = 4'b0001;
        end
    end
    assign isFullOut = isFull[ALUSel];
    assign RegDst = op == `opRFormat ? `FromRd : `FromRt;
    assign vkSrc = op == `opRFormat ? `FromRtData : `FromImmd;
    assign QueueOp = op == `opLW ? `opLoad : `opStore;
endmodule    