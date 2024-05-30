package Incrementer

import chisel3._
import chisel3.util._

class Incrementer(dataSize: Int, pFrameSize: Int) extends Module {

  val io = IO(new Bundle {
    val enq = Flipped(Decoupled(UInt(dataSize.W)))
    val deq = Decoupled(UInt(dataSize.W))
  })

    io.deq.valid := io.enq.valid
    io.deq.bits  := io.enq.bits + 1.U
    io.enq.ready := io.deq.ready
    
}