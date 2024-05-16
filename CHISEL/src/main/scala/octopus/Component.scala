package octopus

import chisel3._
import chisel3.util._


abstract class Component( pFrameSize: Int, pDataWidth: Int) extends Module{
  val io = IO(new Bundle {
    val enq = Flipped(Decoupled(UInt(pDataWidth.W)))
    val deq = Decoupled(UInt(pDataWidth.W))
    val i_full = Input(Bool())
    val i_empty = Input(Bool())
  })

    // State definition
    val st_wait :: st_pull :: Nil = Enum(2)
    val stateReg = RegInit(st_wait)

    // Output 
    val dataCounter = RegInit(0.U(pFrameSize.W))

    when(stateReg === st_wait){
        io.enq.ready := false.B
        dataCounter := 0.U(pFrameSize.W)
    }.otherwise {
        io.enq.ready := true.B
        dataCounter := Mux(dataCounter === (pFrameSize-1).U, 0.U, dataCounter + 1.U)
    }

    // Transition
    switch(stateReg) {
        is(st_wait) {
            when(!(io.i_full && io.i_empty)) {
                stateReg := st_wait
            }.otherwise{
                stateReg := st_pull
            }
        }
        is(st_pull) {
            when(dataCounter === (pFrameSize-1).U ) {
                stateReg := st_wait
            }.otherwise {
                stateReg := st_pull
            }
        }
    }
}