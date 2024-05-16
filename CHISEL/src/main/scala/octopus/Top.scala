package octopus

import chisel3._
import chisel3.util._
import chisel3.stage.{ChiselStage, ChiselGeneratorAnnotation}
import firrtl.options.TargetDirAnnotation
import firrtl.transforms.FlattenAnnotation

class Top(pFrameSize: Int, pDataWidth: Int) extends Module {
    val io = IO(new Bundle {
        val i_dv = Input(Bool())
        val i_data = Input(SInt(pDataWidth.W))
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
    val sock1 = Module(new Socket(pFrameSize, pDataWidth))
    val sock2 = Module(new Socket(pFrameSize, 1))
    
    sock1.io.enq.valid := io.i_dv
    sock1.io.enq.bits  := io.i_data
    io.o_ready := sock1.io.enq.ready

    sock1.io.deq <> vit_dec.io.enq
    vit_dec.io.deq <> sock2.io.enq
    dontTouch(vit_dec.io.debug)
    dontTouch(vit_dec.io.deq)
    // io.debug := vit_dec.io.debug 
    // sock1.io.deq <> scr.io.enq
    // scr.io.deq <> sock2.io.enq

    io.o_dv := sock2.io.deq.valid
    io.o_data := sock2.io.deq.bits
    sock2.io.deq.ready := io.i_ready


    // Only a single socket

    // val sock1 = Module(new Socket(pFrameSize, pDataWidth))

    // sock1.io.enq.valid := io.i_dv
    // sock1.io.enq.bits  := io.i_data
    // io.o_ready := sock1.io.enq.ready

    // io.o_dv := sock1.io.deq.valid
    // io.o_data := sock1.io.deq.bits
    // sock1.io.deq.ready := io.i_ready

    // io.o_full := false.B    
    // io.o_empty := false.B

    // three sockets 

    // val sock1 = Module(new Socket(pFrameSize, pDataWidth))
    // val sock2 = Module(new Socket(pFrameSize, pDataWidth))
    // val sock3 = Module(new Socket(pFrameSize, pDataWidth))

    // sock1.io.enq.valid := io.i_dv
    // sock1.io.enq.bits  := io.i_data
    // io.o_ready := sock1.io.enq.ready

    // sock1.io.deq <> sock2.io.enq
    // sock2.io.deq <> sock3.io.enq

    // io.o_dv := sock3.io.deq.valid
    // io.o_data := sock3.io.deq.bits
    // sock3.io.deq.ready := io.i_ready

    // io.o_full := false.B    
    // io.o_empty := false.B

    // two sockets and a task

    // val sock1 = Module(new Socket(pFrameSize, pDataWidth))
    // val sock2 = Module(new Socket(pFrameSize, pDataWidth))
    // val incr1 = Module(new PassThrough(pFrameSize, pDataWidth))
    // val incr2 = Module(new PassThrough(pFrameSize, pDataWidth))

    // sock1.io.enq.valid := io.i_dv
    // sock1.io.enq.bits  := io.i_data
    // io.o_ready := sock1.io.enq.ready

    // sock1.io.deq <> incr1.io.enq
    // incr1.io.deq <> incr2.io.enq
    // incr2.io.deq <> sock2.io.enq

    // io.o_dv := sock2.io.deq.valid
    // io.o_data := sock2.io.deq.bits
    // sock2.io.deq.ready := io.i_ready


}

object TopMain extends App {
  val stage = new ChiselStage
  stage.execute(
    Array(
    "-X", "verilog", 
    "-e", "verilog", 
    "--target-dir", "../VERILOG/generated/Top"), 
  Seq(ChiselGeneratorAnnotation(() => new Top(20, 9)))
  )
}

// object TopMain extends App {
//   println("Generating the Top hardware")
//  // emitVerilog(new Top(), Array("--target-dir", "../VERILOG/generated"))
//   ChiselStage.emitSystemVerilog(new Top(), Array("--target-dir", "../VERILOG/generated"))
// }
