package octopus

import chisel3._
import chisel3.util._

class PassThrough( pFrameSize: Int, pDataWidth: Int) extends Module{
  val io = IO(new Bundle {
    val enq = Flipped(Decoupled(SInt(pDataWidth.W)))
    val deq = Decoupled(SInt(pDataWidth.W))
  })

    val dataReg = RegNext(io.enq.bits, 0.S(pDataWidth.W))
    val dvReg   = RegNext(io.enq.valid, false.B)
    
    io.deq.valid := dvReg
    io.deq.bits  := dataReg + 1.S(8.W)
    
    io.enq.ready := io.deq.ready
    
}