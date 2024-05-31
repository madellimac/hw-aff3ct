# Définir les variables du projet
set project_name "my_project"
set top_module "Top_Level"
# set part_name "xc7z020clg484-1"  # Modifier selon votre FPGA
set part_name "xc7a100tcsg324-1"

# Créer un nouveau projet
create_project $project_name ./project_dir -part $part_name

# Ajouter des fichiers Verilog au projet
add_files [glob ../VERILOG/generated/Incrementer/*.v]

# Spécifier le module top
set_property top $top_module [current_fileset]

# Lancer la synthèse
synth_design -top $top_module

# Lancer l'implémentation (placement et routage)
opt_design
place_design
route_design

# Générer le bitstream
write_bitstream -force ./project_dir/$project_name.bit

# Sauvegarder le projet
save_project_as ./project_dir/$project_name

# Fermer Vivado
close_project