package Viterbi

import stream_PU._

import chisel3._
import chisel3.util._
import chisel3.stage.{ChiselStage, ChiselGeneratorAnnotation}
import firrtl.options.TargetDirAnnotation
import firrtl.transforms.FlattenAnnotation

class Top_Level[T <: Data](dataType : T, pFrameSize: Int) extends Module {

    val io = IO(new Bundle {
        val i_dv = Input(Bool())
        val i_data = Input(dataType)
        val i_ready = Input(Bool())
        val o_dv = Output(Bool())
        val o_data = Output(SInt(1.W))
        val o_ready = Output(Bool())
    })

    // A Viterbi decoder between two sockets

    //val polynomial = Array("o13".U, "o15".U, "o10".U)
    // val Q_LLR = 3

    // val polynomial = Array(Integer.parseInt("13", 8), Integer.parseInt("15", 8))
    val Q_LLR = 3

    val octal_poly: Array[String] = Array("13", "15")
    // val octal_poly: Array[String] = Array("133", "155")
    // val octal_poly: Array[String] = Array("13", "15", "10")
    val polynomial: Array[Int] = octal_poly.map(octalString => Integer.parseInt(octalString, 8))

    val viterbi_param = new Viterbi_Param(polynomial, Q_LLR)

    val vit_dec = Module(new ViterbiDecoder(viterbi_param))
    // val scr = Module(new Scrambler(pFrameSize, pDataWidth))
    val sock1 = Module(new Socket(dataType, pFrameSize))
    val sock2 = Module(new Socket(SInt(1.W), pFrameSize))
    
    sock1.io.enq.valid := io.i_dv
    sock1.io.enq.bits  := io.i_data
    io.o_ready := sock1.io.enq.ready

    sock1.io.deq <> vit_dec.io.enq
    vit_dec.io.deq <> sock2.io.enq
    dontTouch(vit_dec.io.debug)
    dontTouch(vit_dec.io.deq)

    io.o_dv := sock2.io.deq.valid
    io.o_data := sock2.io.deq.bits
    sock2.io.deq.ready := io.i_ready



}

object Top_LevelMain extends App {
  val stage = new ChiselStage
  stage.execute(
    Array(
    "-X", "verilog", 
    "-e", "verilog", 
    "--target-dir", "../VERILOG/generated/Viterbi"), 
  Seq(ChiselGeneratorAnnotation(() => new Top_Level(SInt(9.W), 20)))
  )
}

// object TopMain extends App {
//   println("Generating the Top hardware")
//  // emitVerilog(new Top(), Array("--target-dir", "../VERILOG/generated"))
//   ChiselStage.emitSystemVerilog(new Top(), Array("--target-dir", "../VERILOG/generated"))
// }
