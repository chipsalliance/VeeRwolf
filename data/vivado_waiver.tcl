#LiteDRAM warnings
set_msg_config -id "Synth 8-350" -string "OSERDESE2 litedram_core" -suppress
set_msg_config -id "Synth 8-350" -string "litedram_core.v ISERDESE2" -suppress
set_msg_config -id "Synth 8-350" -string "litedram_core.v IDELAYCTRL" -suppress
set_msg_config -id "Synth 8-350" -string "litedram_core.v IDELAYE2" -suppress
set_msg_config -id "Synth 8-350" -string "litedram_core.v PLLE2_ADV" -suppress
set_msg_config -id "Synth 8-4446" -string "litedram_core.v" -suppress
set_msg_config -id "Synth 8-6014" -string "litedram_core.v" -suppress
set_msg_config -id "Synth 8-3936"  -string "memdat_2_reg" -suppress
set_msg_config -id "Synth 8-3936"  -string "memdat_4_reg" -suppress
set_msg_config -id "Synth 8-3936"  -string "memdat_18_reg" -suppress
set_msg_config -id "Synth 8-7023" -string "litedram_core.v IDELAYE2" -suppress
set_msg_config -id "Synth 8-7023" -string "litedram_core.v IDELAYCTRL" -suppress
set_msg_config -id "Synth 8-7023" -string "litedram_core.v ISERDESE2" -suppress
set_msg_config -id "Synth 8-7023" -string "litedram_core.v OSERDESE2" -suppress
set_msg_config -id "Synth 8-7023" -string "litedram_core.v PLLE2_ADV" -suppress
set_msg_config -id "DRC REQP-1839" -string "ddr2/ldc/storage" -suppress
set_msg_config -id "DRC REQP-1840" -string "ddr2/ldc/storage" -suppress

#VexRiscv warnings
set_msg_config -id "Synth 8-6014" -string "VexRiscv.v" -suppress
set_msg_config -id "Synth 8-3936" -string "memory_to_writeBack_MUL_HH_reg" -suppress

#SweRV warnings
set_msg_config -id "DRC REQP-1840" -string "rvtop/mem/Gen_dccm_enable.dccm/mem_bank" -suppress

#SweRVolf warning
set_msg_config -id "Synth 8-4446" -string "swervolf_nexys.v STARTUPE2" -suppress
