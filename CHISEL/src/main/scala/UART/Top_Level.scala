package UART

import stream_PU._
import Incrementer._

import chisel3._
import chisel3.util._
import chisel3.stage.{ChiselStage, ChiselGeneratorAnnotation}
import firrtl.options.TargetDirAnnotation
import firrtl.transforms.FlattenAnnotation

class Top_Level[T <: Bits](dataType : T, pFrameSize: Int) extends Module {
    val io = IO(new Bundle {
        val i_dv    = Input(Bool())
        val i_data  = Input(dataType)
        val i_ready = Input(Bool())
        val o_dv    = Output(Bool())
        val o_data  = Output(dataType)
        val o_ready = Output(Bool())
    })

    val sock1 = Module(new Socket(dataType, pFrameSize))
    val sock2 = Module(new Socket(dataType, pFrameSize))
    val sock3 = Module(new Socket(dataType, pFrameSize))

    val incr1 = Module(new Incrementer(dataType.getWidth, pFrameSize))
    val incr2 = Module(new Incrementer(dataType.getWidth, pFrameSize))

    // val tx_fifo = Module(new FIFO(dataType, pFrameSize))
    val tx = Module(new UART_Tx(baudRate = 5000000, clockFreq = 50000000))
    val rx = Module(new UART_Rx(baudRate = 5000000, clockFreq = 50000000))

    sock1.io.enq.valid := io.i_dv
    sock1.io.enq.bits  := io.i_data
    io.o_ready := sock1.io.enq.ready

    sock1.io.deq <> incr1.io.enq
    incr1.io.deq <> incr2.io.enq
    
    incr2.io.deq <> sock2.io.enq
    sock2.io.deq <> tx.io.in
    rx.io.rx := tx.io.tx 
    rx.io.out <> sock3.io.enq

    io.o_dv := sock3.io.deq.valid
    io.o_data := sock3.io.deq.bits
    sock3.io.deq.ready := io.i_ready

}

object Top_LevelMain extends App {
  val stage = new ChiselStage
  stage.execute(
    Array(
    "-X", "verilog", 
    "-e", "verilog",
    "--target-dir", "../VERILOG/generated/UART"), 
  Seq(ChiselGeneratorAnnotation(() => new Top_Level(UInt(8.W), 20)))
  )
}