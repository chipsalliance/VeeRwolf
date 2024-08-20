#!/bin/bash

sed 's/VERSION_DIRTY=True/VERSION_DIRTY=1/' -i veerwolf_0.7.5.tcl
sed 's/VERSION_DIRTY=False/VERSION_DIRTY=0/' -i veerwolf_0.7.5.tcl
sed '4iprj_set_impl_opt VerilogStandard "System Verilog"' -i veerwolf_0.7.5.tcl
sed 's/.*el2_pdef.vh.*//' -i veerwolf_0.7.5.tcl
sed "s/unsigned'/uint'/" -i src/pulp-platform.org__common_cells_1.20.0/src/rr_arb_tree.sv
sed "1itypedef int unsigned uint;" -i src/pulp-platform.org__common_cells_1.20.0/src/rr_arb_tree.sv
sed "s/unsigned'/uint'/" -i src/pulp-platform.org__common_cells_1.20.0/src/stream_omega_net.sv

incl_path='src/pulp-platform.org__common_cells_1.20.0/include;src/pulp-platform.org__axi_0.25.0/include;src/uart16550_1.5.5-r1/rtl/verilog;src/wb_common_1.0.3;src/veerwolf-intercon_0.7.5'

if test -d 'src/veerwolf-veer_el2_pack_config_0.7.5' ; then
    incl_path='src/veerwolf-veer_el2_pack_config_0.7.5;src/veerwolf-wb_nospi_intercon_0.7.5;'$incl_path
    sed "1s/.*/parameter el2_pkg::el2_param_t pt = \'{/" -i src/veerwolf-veer_el2_pack_config_0.7.5/el2_param.vh 
    sed '/package el2_pkg;/a`include "el2_pdef.vh"' -i src/chipsalliance.org_cores_VeeR_EL2_1.4/design/include/el2_def.sv
elif test -d 'src/veerwolf-veer_el2_default_config_0.7.5' ; then
    incl_path='src/veerwolf-veer_el2_default_config_0.7.5;src/veerwolf-wb_intercon_0.7.5;'$incl_path
    sed "1s/.*/parameter el2_pkg::el2_param_t pt = \'{/" -i src/veerwolf-veer_el2_default_config_0.7.5/el2_param.vh
    sed '/package el2_pkg;/a`include "el2_pdef.vh"' -i src/chipsalliance.org_cores_VeeR_EL2_1.4/design/include/el2_def.sv
else
    incl_path='src/veerwolf-veer_eh1_default_config_0.7.5;src/veerwolf-wb_intercon_0.7.5;src/chipsalliance.org_cores_VeeR_EH1_1.9/design/include;config;'$incl_path
fi
sed 's@.*include path.*@prj_set_impl_opt -impl "impl" "include path" '"\"$incl_path\"@" -i veerwolf_0.7.5.tcl

sed '/prj_open veerwolf_0_7_5.rdf/a prj_set_strategy "Area" \nprj_save' -i veerwolf_0.7.5_run.tcl
