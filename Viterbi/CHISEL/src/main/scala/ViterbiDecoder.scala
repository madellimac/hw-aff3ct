package Viterbi

import chisel3._
import chisel3.util._

class ViterbiDecoder(
    param : Viterbi_Param) extends Module{

  val io = IO(new Bundle {
    val enq = Flipped(Decoupled(SInt(param.Q_IN.W)))
    val deq = Decoupled(SInt(1.W))
    val debug = Output(new Debug_Bundle(param))
  })

    //io.enq <> io.deq
    
    io.enq.ready := io.deq.ready

    val bmu = Module(new BranchMetricUnit(param))
    val smu = Module(new StateMetricUnit(param)) 
    val spu = Module(new SurvivorPath(param))

    // Compteur de cycles
    val cycleCounter = RegInit(0.U(log2Ceil(param.K).W))

    when(io.enq.valid) {
        cycleCounter := cycleCounter + 1.U
        when(cycleCounter === (param.K - 1).U) {
            cycleCounter := 0.U
        }
    }

    dontTouch(cycleCounter)

    val init = Wire(Bool())
    init := (cycleCounter === (param.K - 1).U)

    dontTouch(init)
    // smu.io.i_init := false.B
    smu.io.i_init := init

    bmu.io.i_valid := io.enq.valid

    // Assign BMU inputs
    for (i <- 0 until log2Ceil(param.N_BM)){
        bmu.io.i_y(i) := io.enq.bits(i*param.Q_LLR+param.Q_LLR-1, i*param.Q_LLR).asSInt
    }
    // Debug
    for (i <- 0 until param.N_BM){
        io.debug.BM(i) := bmu.io.o_BM(i)
    }

    // io.deq.bits := 0.S
    // io.deq.valid := bmu.io.o_valid

    smu.io.i_valid := bmu.io.o_valid
    smu.io.i_BM := bmu.io.o_BM

    dontTouch(smu.io.o_decision)
    dontTouch(smu.io.o_valid)

    spu.io.i_decision := smu.io.o_decision
    spu.io.i_valid := smu.io.o_valid

    io.deq.bits := spu.io.o_data
    io.deq.valid := spu.io.o_valid
    // io.deq.valid := smu.io.o_valid

    // val cat_BMU = Cat(bmu.io.o_MB(3), bmu.io.o_MB(2), bmu.io.o_MB(1), bmu.io.o_MB(0))
    

    // io.deq.bits(15, 12) := bmu.io.o_MB(3)
    // io.deq.bits(11, 8) := bmu.io.o_MB(2)
    // io.deq.bits(7, 4)  := bmu.io.o_MB(1)
    // io.deq.bits(3, 0)  := bmu.io.o_MB(0)
    // io.deq.bits := 0.U(pDataWidth.W)

    // io.deq.bits(11, 8) := 0.U(4.W)
    // io.deq.bits(7, 4)  := 0.U(4.W)
    // io.deq.bits(3, 0)  := 0.U(4.W)
   
}