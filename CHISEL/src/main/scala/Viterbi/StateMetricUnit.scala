package Viterbi

import chisel3._
import chisel3.util._

class StateMetricUnit( param : Viterbi_Param) extends Module {
    val io = IO(new Bundle {
    val i_valid = Input(Bool())
    val i_BM = Input(Vec(param.N_BM, SInt(param.Q_BM.W)))
    val o_decision  = Output(UInt(8.W))
    val o_valid = Output(Bool())
})

    val vACS = VecInit(Seq.fill(param.N_states)(Module(new ACS(param)).io))
    val vDec = Wire(Vec(param.N_states, Bool()))

    for (i <- 0 until param.N_states) {
        vACS(i).i_valid := io.i_valid
        vDec(i) := vACS(i).o_decision
    }

    io.o_decision := Cat(vDec.reverse).asUInt()

    io.o_valid := vACS(0).o_valid

    for(i <- 0 until (param.N_states/2)) {
        vACS(i).i_SM(0) := vACS(2*i  ).o_SM
        vACS(i).i_SM(1) := vACS(2*i+1).o_SM

        vACS(i+(param.N_states/2)).i_SM(0) := vACS(2*i  ).o_SM
        vACS(i+(param.N_states/2)).i_SM(1) := vACS(2*i+1).o_SM

        vACS(i).i_BM(0) := io.i_BM(param.z(0)(2*i  ))
        vACS(i).i_BM(1) := io.i_BM(param.z(0)(2*i+1))

        vACS(i+(param.N_states/2)).i_BM(0) := io.i_BM(param.z(1)(2*i  ))
        vACS(i+(param.N_states/2)).i_BM(1) := io.i_BM(param.z(1)(2*i+1))
    }

}