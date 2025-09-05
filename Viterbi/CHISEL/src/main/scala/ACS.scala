package Viterbi

import chisel3._
import chisel3.util._


class ACS( param : Viterbi_Param) extends Module {
    val io = IO(new Bundle {
    val i_valid = Input(Bool())
    val i_init = Input(Bool())
    val i_BM    = Input(Vec(2, SInt(param.Q_BM.W)))
    val i_SM    = Input(Vec(2, UInt(param.Q_SM.W)))
    val o_SM    = Output(UInt(param.Q_SM.W))
    val o_valid = Output(Bool())
    val o_decision = Output(Bool())
})

    val sum  = Wire(Vec(2, SInt(param.Q_SM.W)))
    val sel  = Wire(Bool())

    val regSM    = RegInit(0.U(param.Q_SM.W))
    val regValid = RegInit(false.B)
    val regDec   = RegInit(false.B)

    sum(0) := io.i_BM(0) + io.i_SM(0).asSInt
    sum(1) := io.i_BM(1) + io.i_SM(1).asSInt

    if(param.ACS_min_max == "min"){
        sel := (sum(0) < sum(1))
    } else {
        sel := (sum(0) > sum(1))
    }

    // regValid := false.B
    // when (io.i_valid){
    //     regSM := Mux(sel, sum(0).asUInt, sum(1).asUInt)
    //     regValid := true.B
    //     regDec := !sel
    // }
    when(io.i_init) {
        regSM := 0.U
    } .elsewhen(io.i_valid) {
        regSM := Mux(sel, sum(0).asUInt, sum(1).asUInt)
    }

    regValid := false.B
    when(io.i_valid) {
        regValid := true.B
        regDec := !sel
    }

    io.o_valid := regValid

    io.o_decision := regDec

    io.o_SM := regSM

}