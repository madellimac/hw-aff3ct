package octopus

import chisel3._
import chisel3.util._
import chisel3.stage.{ChiselStage, ChiselGeneratorAnnotation}
import firrtl.options.TargetDirAnnotation
import firrtl.transforms.FlattenAnnotation

class Top3(pFrameSize: Int, pDataWidth: Int) extends Module {
    val io = IO(new Bundle {
        val i_dv = Input(Bool())
        val i_data = Input(SInt(pDataWidth.W))
        val i_ready = Input(Bool())
        val o_dv = Output(Bool())
        val o_data = Output(SInt(pDataWidth.W))
        val o_ready = Output(Bool())
    })

    // two sockets and a task


    val sock1 = Module(new Socket(pFrameSize, pDataWidth))
    val sock2 = Module(new Socket(pFrameSize, pDataWidth))
    val incr1 = Module(new PassThrough(pFrameSize, pDataWidth))
    val incr2 = Module(new PassThrough(pFrameSize, pDataWidth))

    sock1.io.enq.valid := io.i_dv
    sock1.io.enq.bits  := io.i_data
    io.o_ready := sock1.io.enq.ready

    sock1.io.deq <> incr1.io.enq
    incr1.io.deq <> incr2.io.enq
    incr2.io.deq <> sock2.io.enq

    io.o_dv := sock2.io.deq.valid
    io.o_data := sock2.io.deq.bits
    sock2.io.deq.ready := io.i_ready

}

object Top3Main extends App {
  val stage = new ChiselStage
  stage.execute(
    Array(
    "-X", "verilog", 
    "-e", "verilog",
    "--target-dir", "../VERILOG/generated/Top3"), 
  Seq(ChiselGeneratorAnnotation(() => new Top3(20, 8)))
  )
}

// object TopMain extends App {
//   println("Generating the Top hardware")
//  // emitVerilog(new Top(), Array("--target-dir", "../VERILOG/generated"))
//   ChiselStage.emitSystemVerilog(new Top(), Array("--target-dir", "../VERILOG/generated"))
// }
