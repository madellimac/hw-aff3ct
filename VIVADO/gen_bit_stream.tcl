# vivado -mode batch -source gen_bit_stream.tcl
# Définir les variables du projet
#set project_name "my_project"
set top_module "Top_FPGA"
# set part_name "xc7z020clg484-1"  # Modifier selon votre FPGA
set part_name "xc7a100tcsg324-1"

set_part $part_name
# Créer un nouveau projet
# create_project $project_name ./project_dir -part $part_name

# Ajouter des fichiers Verilog au projet
read_verilog [glob ../VERILOG/generated/Incrementer/*.v]
# add_files [glob ../VERILOG/generated/Incrementer/*.v]

read_xdc nexysA7.xdc

# Spécifier le module top
set_property top $top_module [current_fileset]

# Lancer la synthèse
synth_design -top $top_module

# Lancer l'implémentation (placement et routage)
opt_design
place_design
route_design

# Générer le bitstream
write_bitstream -force ./$top_module.bit