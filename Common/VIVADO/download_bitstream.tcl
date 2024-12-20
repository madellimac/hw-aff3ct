# # vivado -mode batch -source download_bitstream.tcl

# # Vérifier le nombre d'arguments
# if { [llength $argv] != 1 } {
#     puts "Usage: vivado -mode batch -source download_bitstream.tcl -- <bitstream>"
#     exit 1
# }

# # Récupérer les arguments
# set bitstream [lindex $argv 0]

# open_hw_manager

# connect_hw_server

# open_hw_target

# set_property PROGRAM.FILE {} [current_hw_device]

# program_hw_devices [current_hw_device]




# Vérifier le nombre d'arguments
if { [llength $argv] != 1 } {
    puts "Usage: vivado -mode batch -source download_bitstream.tcl -tclargs <bitstream>"
    exit 1
}

# Récupérer l'argument
set bitstream [lindex $argv 0]
puts "Bit stream : $bitstream"
# Ouvrir l'environnement matériel
open_hw_manager

# Connecter au serveur matériel
# disconnect_hw_server
connect_hw_server

# Rafraîchir les cibles matérielles
# refresh_hw_target

# Lister les cibles matérielles disponibles
set hw_targets [get_hw_targets]
puts "Cibles matérielles disponibles : $hw_targets"

# Vérifier qu'il y a au moins une cible disponible
if {[llength $hw_targets] < 1} {
    puts "Erreur : Aucune cible matérielle détectée."
    exit 1
}

# Sélectionner la première carte
set target1 [lindex $hw_targets 0]
open_hw_target $target1
set hw_device1 [lindex [get_hw_devices -of $target1] 0]

# Définir le fichier bitstream pour la première carte
set_property PROGRAM.FILE $bitstream $hw_device1

# Programmer la première carte
program_hw_devices $hw_device1

# Fermer la cible matérielle
close_hw_target $target1

# Déconnecter du serveur matériel
disconnect_hw_server

# Fermer l'environnement matériel
close_hw_manager

puts "Bitstream programmé avec succès sur la carte FPGA."
