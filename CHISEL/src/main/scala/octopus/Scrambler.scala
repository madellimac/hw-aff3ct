package octopus

import chisel3._
import chisel3.util._

class Scrambler( pFrameSize: Int, pDataWidth: Int) extends Module{
  val io = IO(new Bundle {
    val enq = Flipped(Decoupled(UInt(pDataWidth.W)))
    val deq = Decoupled(UInt(pDataWidth.W))
  })

    val shiftReg = RegInit(0.U(4.W))
    val scr_output = Wire(Bool())

    io.enq.ready := io.deq.ready
    
    
    when (io.enq.valid) {
        shiftReg := scr_output ## shiftReg(3,1)
    }
    scr_output := io.enq.bits ^ shiftReg(3) ^ shiftReg(2) ^ shiftReg(0)

    io.deq.valid := io.enq.valid
    io.deq.bits := scr_output
}
