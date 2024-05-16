package octopus

import chisel3._
import chisel3.util._

class SurvivorPathStage(param : Viterbi_Param) extends Module {
    val io = IO(new Bundle {
    val i_valid     = Input (Bool())
    val i_data      = Input (UInt(param.N_states.W))
    val i_decision  = Input (UInt(param.N_states.W))
    val o_data      = Output(UInt(param.N_states.W))
    val o_valid     = Output(Bool())
})

    val DataReg = RegInit(0.U(param.N_states.W))
    val Muxes = VecInit(Seq.fill(param.N_states)(Mux(false.B, 0.U, 0.U)))
    val ValidReg = RegInit(false.B)

    ValidReg := false.B
    when(io.i_valid){
        DataReg := io.i_data
        ValidReg := io.i_valid
    }
    io.o_valid := ValidReg

     for(i <- 0 until (param.N_states/2)) {
        Muxes(i                     ) := Mux(io.i_decision(i                     ), DataReg(2*i+1), DataReg(2*i))
        Muxes(i + (param.N_states/2)) := Mux(io.i_decision(i + (param.N_states/2)), DataReg(2*i+1), DataReg(2*i))
     }

    io.o_data := Cat(Muxes.reverse)

}