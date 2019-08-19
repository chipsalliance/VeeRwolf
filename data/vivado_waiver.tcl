#LiteDRAM warnings
set_msg_config -id "Synth 8-350" -string "OSERDESE2 litedram_core" -suppress
set_msg_config -id "Synth 8-350" -string "litedram_core.v ISERDESE2" -suppress
set_msg_config -id "Synth 8-350" -string "litedram_core.v IDELAYCTRL" -suppress
set_msg_config -id "Synth 8-350" -string "litedram_core.v IDELAYE2" -suppress
set_msg_config -id "Synth 8-350" -string "litedram_core.v PLLE2_ADV" -suppress
set_msg_config -id "Synth 8-6014" -string "litedram_core.v" -suppress

#VexRiscv warnings
set_msg_config -id "Synth 8-6014" -string "VexRiscv.v" -suppress
