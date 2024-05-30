package Viterbi

import chisel3._
import chisel3.util._


class ACS( param : Viterbi_Param) extends Module {
    val io = IO(new Bundle {
    val i_valid = Input(Bool())
    val i_BM    = Input(Vec(2, SInt(param.Q_BM.W)))
    val i_SM    = Input(Vec(2, SInt(param.Q_SM.W)))
    val o_SM    = Output(SInt(param.Q_SM.W))
    val o_valid = Output(Bool())
    val o_decision = Output(Bool())
})

    val sum      = Wire(Vec(2, SInt(param.Q_SM.W)))
    val sel_min  = Wire(Bool())

    val regSM    = RegInit(0.S(param.Q_SM.W))
    val regValid = RegInit(false.B)
    val regDec   = RegInit(false.B)

    sum(0) := io.i_BM(0) + io.i_SM(0)
    sum(1) := io.i_BM(1) + io.i_SM(1)

    sel_min := (sum(0) < sum(1))

    // regValid := false.B
    when (io.i_valid){
        regSM := Mux(sel_min, sum(0), sum(1))
        regValid := true.B
        regDec := !sel_min
    }

    io.o_valid := regValid

    io.o_decision := regDec

    io.o_SM := regSM

}