# vivado -mode batch -source gen_bit_stream.tcl my_project

# Définir les variables du projet

set top_module "Top_FPGA"
set project_name [lindex $argv 0]
set verilog_path [lindex $argv 1]
set xdc_path  [lindex $argv 2]

set part_name "xc7a100tcsg324-1"
set_part $part_name

# Ajouter des fichiers Verilog au projet
read_verilog [glob $verilog_path/*.v]

read_xdc $xdc_path/nexysA7.xdc

# Spécifier le module top
set_property top $top_module [current_fileset]

# Lancer la synthèse
synth_design -top $top_module

# Lancer l'implémentation (placement et routage)
opt_design
place_design
route_design

# Générer le bitstream
write_bitstream -force ./$project_name.bit