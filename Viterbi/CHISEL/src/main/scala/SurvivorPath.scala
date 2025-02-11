package Viterbi

import chisel3._
import chisel3.util._

class SurvivorPath( param : Viterbi_Param) extends Module {
    val io = IO(new Bundle {
    val i_valid     = Input (Bool())
    val i_decision  = Input (UInt(param.N_states.W))
    val o_data      = Output(SInt(1.W))
    val o_valid     = Output(Bool())
})

    // val counter = Module(new Counter(log2Ceil(param.K)))
    // counter.io.data_valid := io.i_valid

    val DecisionReg = RegInit(0.U(param.N_states.W))
    val SPStage = VecInit(Seq.fill(param.SP_length)(Module(new SurvivorPathStage(param)).io))
    val ValidReg = RegInit(false.B)

    val s_data = Wire(UInt(param.N_states.W))
    val s_decision = Wire(UInt(param.N_states.W))

    SPStage(0).i_valid := io.i_valid
    
    val halfLength = param.N_states / 2
    val dataValue = Cat(Fill(halfLength, 1.U), Fill(halfLength, 0.U))
    
    when(io.i_valid) {
        s_data := dataValue
        s_decision := io.i_decision
    } .otherwise {
        s_data := 0.U
        s_decision := 0.U
    }

    SPStage(0).i_data := s_data
    SPStage(0).i_decision := s_decision
    
    for (i <- 1 until param.SP_length) {
        SPStage(i).i_valid := SPStage(i-1).o_valid
        SPStage(i).i_data := SPStage(i-1).o_data
        SPStage(i).i_decision := s_decision
    }

    io.o_data := SPStage(param.SP_length-1).o_data(0).asSInt

    val shiftReg = RegInit(VecInit(Seq.fill(param.SP_length)(false.B)))

    shiftReg := shiftReg.tail :+ io.i_valid

    io.o_valid := shiftReg.head

}