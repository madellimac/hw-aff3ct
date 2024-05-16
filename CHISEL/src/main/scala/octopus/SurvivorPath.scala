package octopus

import chisel3._
import chisel3.util._

class SurvivorPath( param : Viterbi_Param) extends Module {
    val io = IO(new Bundle {
    val i_valid     = Input (Bool())
    val i_data      = Input (UInt(param.N_states.W))
    val o_data      = Output(SInt(1.W))
})

    val SPStage = VecInit(Seq.fill(param.SP_length)(Module(new SurvivorPathStage(param)).io))

    SPStage(0).i_valid := io.i_valid
    SPStage(0).i_data := io.i_data
    SPStage(0).i_decision := io.i_data


    for (i <- 1 until param.SP_length) {
        SPStage(i).i_valid := SPStage(i-1).o_valid
        SPStage(i).i_data := SPStage(i-1).o_data
        SPStage(i).i_decision := io.i_data
    }

    io.o_data := SPStage(param.SP_length-1).o_data(0).asSInt()
}