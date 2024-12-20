package stream_PU

import chisel3._
import chisel3.util._

class FIFO[T <: Data](dataType : T, pFrameSize: Int) extends Module {
  val io = IO(new Bundle {
    val enq = Flipped(Decoupled(dataType))
    val deq = Decoupled(dataType)
  })

    val width = io.enq.bits.getWidth
    val read_counter = RegInit(0.U(log2Ceil(pFrameSize+1).W))
    val write_counter = RegInit(0.U(log2Ceil(pFrameSize+1).W))

    // FSM

    // State definition
    val st_write :: st_read :: Nil = Enum(2)
    val stateReg = RegInit(st_write)
    
    // Transition
    stateReg := st_write
    switch(stateReg) {
        is(st_write) {
            when(write_counter === (pFrameSize-1).U && io.enq.valid) {
                stateReg := st_read
            }.otherwise {
                stateReg := st_write
            }
        }
        is(st_read) {
            when(read_counter === (pFrameSize-1).U && io.deq.ready) {
                stateReg := st_write
            }.otherwise {
                stateReg := st_read
            }
        }
    }

    val mem = Mem(pFrameSize, dataType)

    io.deq.bits := mem.read(read_counter)

    when (io.enq.valid && io.enq.ready && stateReg === st_write) {
        mem.write(write_counter, io.enq.bits)
        when(write_counter === (pFrameSize-1).U){
           write_counter := 0.U
        }.otherwise{
            write_counter := write_counter + 1.U 
        }
    }

    when (io.deq.valid && io.deq.ready && stateReg === st_read) {
        when(read_counter === (pFrameSize-1).U){
           read_counter := 0.U
        }.otherwise{
            read_counter := read_counter + 1.U 
        }
    }

    when (write_counter < pFrameSize.U && stateReg === st_write) {
        io.enq.ready := true.B
    }.otherwise{
        io.enq.ready := false.B
    }

    when (read_counter < pFrameSize.U && stateReg === st_read) {
        io.deq.valid := true.B
    }.otherwise{
        io.deq.valid := false.B
    }

}