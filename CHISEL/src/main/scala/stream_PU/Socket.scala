
package stream_PU

import chisel3._
import chisel3.util._

class Socket[T <: Data](dataType : T, pFrameSize: Int) extends Module {
    val io = IO(new Bundle {
        val enq = Flipped(Decoupled(dataType))
        val deq = Decoupled(dataType)
    })
    
    val fifo = Module(new FIFO(dataType, pFrameSize))

    fifo.io.enq <> io.enq
    io.deq <> fifo.io.deq    

}