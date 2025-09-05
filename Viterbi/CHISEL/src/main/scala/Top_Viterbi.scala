package Viterbi

import chisel3._
import chisel3.util._
import _root_.circt.stage.{ChiselStage}
import chisel3.stage.{ChiselGeneratorAnnotation}

class Top_Viterbi extends Module {
// begin parameters
  val K = 128
  val Q_LLR = 6
// end parameters
  val io = IO(new Bundle {
    val enq = Flipped(Decoupled(SInt(Q_LLR.W)))
    val deq = Decoupled(SInt(1.W))
    // Ajoute d'autres IO si nécessaire
  })

  val octal_poly: Array[String] = Array("5", "7")
  val polynomial: Array[Int] = octal_poly.map(octalString => Integer.parseInt(octalString, 8))

  val viterbi_param = new Viterbi_Param(polynomial, Q_LLR, K)
  val vit_dec = Module(new ViterbiDecoder(viterbi_param))

  vit_dec.io.enq <> io.enq
  io.deq <> vit_dec.io.deq
}

object Top_ViterbiMain extends App {
  _root_.circt.stage.ChiselStage.emitSystemVerilog(
    new Top_Viterbi(),
    firtoolOpts = Array.concat(
      Array(
        "--disable-all-randomization",
        "--strip-debug-info",
        "--split-verilog",
        "-o", "../VERILOG/generated/Viterbi")
      )
    )      
}