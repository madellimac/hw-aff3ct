package octopus

import chisel3._

class Debug_Bundle(param : Viterbi_Param) extends Bundle {
    val BM    = Vec(param.N_BM, SInt(param.Q_BM.W))
}