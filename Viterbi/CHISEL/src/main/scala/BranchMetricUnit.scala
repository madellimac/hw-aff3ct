package Viterbi

import chisel3._
import chisel3.util._

class BranchMetricUnit( 
    param : Viterbi_Param) extends Module {

    val io = IO(new Bundle {
    val i_valid = Input(Bool())
    val i_y     = Input(Vec(log2Ceil(param.N_BM), SInt(param.Q_LLR.W)))
    val o_BM    = Output(Vec(param.N_BM, SInt(param.Q_BM.W)))
    val o_valid = Output(Bool())
})

    // Fully combinational block => no delay between input and ouput
    io.o_valid := io.i_valid

    val N_BM = param.N_BM
    val Q_BM = param.Q_BM
    val Q_LLR = param.Q_LLR

    // Sign extension of i_y from Q_LLR to Q_BM
    val y = Wire(Vec(log2Ceil(N_BM), SInt(Q_BM.W)))
    y := io.i_y.map(x => Cat(Fill(Q_BM-Q_LLR, x(Q_LLR-1)), x).asSInt)

    // Create a 2D vector to store yi / -yi on two rows
    val y_mat = Wire(Vec(2, Vec(log2Ceil(N_BM), SInt(Q_BM.W))))

    for(i <- 0 until log2Ceil(N_BM)) {
        y_mat(0)(i) := y(i)
        y_mat(1)(i) := -(y(i))
    }

    // Create a natural binary map to select either yi or -yi for each metric
    val natural_bin = VecInit((0 until N_BM).map(_.U(log2Ceil(N_BM).W)))

    // For each metric, we accumulate either yi or -yi
    for(i <- 0 until N_BM) {
        var sum = 0.S
        for(j <- 0 until log2Ceil(N_BM)){
            sum = sum + y_mat(natural_bin(i)(j))(j)
        }
        io.o_BM(i) := sum
    }

}