package octopus

import chisel3._
import chisel3.util._

class FIFO(pFrameSize: Int, pDataWidth: Int) extends Module {
  val io = IO(new Bundle {
    val enq = Flipped(Decoupled(UInt(pDataWidth.W)))
    val deq = Decoupled(UInt(pDataWidth.W))
  })    

    val count = RegInit(0.U(log2Ceil(pFrameSize+1).W))

    val almost_full = Wire(Bool()) 
    almost_full := count === (pFrameSize-1).U

    val almost_empty = Wire(Bool()) 
    almost_empty := count === 1.U

    //FSM

    // State definition
    val st_wait_enq :: st_wait_deq :: st_enq :: st_deq :: Nil = Enum(4)
    val stateReg = RegInit(st_wait_enq)

    // FSM Output 
    val en_enq = Wire(Bool())
    val en_deq = Wire(Bool())
    val ready = Wire(Bool())
    en_enq := false.B
    en_deq := false.B
    ready := false.B

    io.enq.ready := ready
    switch(stateReg) {
        is(st_wait_enq) {
            ready := true.B
            en_enq := false.B
            en_deq := false.B
        }
        is(st_enq) {
            ready := false.B
            en_enq := true.B
            en_deq := false.B
        }
        is(st_wait_deq) {
            ready := false.B
            en_enq := false.B
            en_deq := false.B
        }
        is(st_deq) {
            ready := false.B
            en_enq := false.B
            en_deq := true.B
        }
    }

    // Transition
    stateReg := st_wait_enq
    switch(stateReg) {
        is(st_wait_enq) {
            when(!io.enq.valid) {
                stateReg := st_wait_enq
            }.otherwise{
                stateReg := st_enq
            }
        }
        is(st_enq) {
            when(!almost_full) {
                stateReg := st_enq
            }.otherwise {
                stateReg := st_wait_deq
            }
        }
        is(st_wait_deq) {
            when(!io.deq.ready) {
                stateReg := st_wait_deq
            }.otherwise {
                stateReg := st_deq
            }
        }
        is(st_deq) {
            when(!almost_empty) {
                stateReg := st_deq
            }.otherwise {
                stateReg := st_wait_enq
            }
        }
    }

    val mem = SyncReadMem(pFrameSize, UInt(pDataWidth.W))
    val enqPtr = RegInit(0.U(log2Ceil(pFrameSize).W))
    val deqPtr = RegInit(0.U(log2Ceil(pFrameSize).W))
    
    val validReg = RegInit(false.B)

    // Input buffer
    val bitsReg = RegInit(0.U(pDataWidth.W))
    when(io.enq.valid){
        bitsReg := io.enq.bits
    }

    io.deq.bits := mem.read(deqPtr)

    when (en_enq) {
        mem.write(enqPtr, bitsReg)
        enqPtr := Mux(enqPtr === (pFrameSize-1).U, 0.U, enqPtr + 1.U)
        count := count + 1.U
    }

    io.deq.valid := validReg
    validReg := false.B
    when (en_deq){
        deqPtr := Mux(deqPtr === (pFrameSize-1).U, 0.U, deqPtr + 1.U)
        count := count - 1.U
        validReg := true.B
    }
}