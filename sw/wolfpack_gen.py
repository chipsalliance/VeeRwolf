#!/usr/bin/python3
from fusesoc.capi2.generator import Generator
import os
import shutil
import subprocess

from verilogwriter import Instance, ModulePort, Parameter, Port, VerilogWriter, Wire, Assign


class WolfPackGenerator(Generator):
    def run(self):
        files = [{'veerwolf_pack.v': {'file_type': 'verilogSource'}}]
        count = self.config.get('count')
        self.gen_veerwolf_pack(count)
        self.add_files(files)
        print(f'Generating {count} tiles')

    def gen_veerwolf_pack(self, count):
        veerwolf_pack = VerilogWriter('veerwolf_pack')

        veerwolf_pack.add(ModulePort('clk_core', 'input'))
        veerwolf_pack.add(ModulePort('rst_core', 'input'))
        veerwolf_pack.add(ModulePort('i_uart_rx', 'input'))
        veerwolf_pack.add(ModulePort('o_uart_tx', 'output'))
        veerwolf_pack.add(ModulePort('i_sw', 'input', 16))
        veerwolf_pack.add(ModulePort('o_led', 'output', 16))
        veerwolf_pack.add(Parameter('pack_code', '"bootloader.vh"'))

        for idx in range(count+1):
            veerwolf_pack.add(Wire('gpio'+str(idx), 16))
            veerwolf_pack.add(Wire('uart'+str(idx)))
            
        veerwolf_pack.add(Assign('gpio0', 'i_sw'))
        veerwolf_pack.add(Assign('o_led', 'gpio'+str(count)))
        veerwolf_pack.add(Assign('uart0', 'i_uart_rx'))
        veerwolf_pack.add(Assign('o_uart_tx', 'uart'+str(count)))

        for idx in range(count):
            veerwolf_pack.add(Instance('veerwolf_tile', 'tile'+str(idx),
                                       [Parameter('bootrom_file', 'pack_code')],
                                       [Port('clk_core', 'clk_core'),
                                        Port('rst_core', 'rst_core'),
                                        Port('i_uart_rx', 'uart'+str(idx)),
                                        Port('o_uart_tx', 'uart'+str(idx+1)),
                                        Port('i_sw', 'gpio'+str(idx)),
                                        Port('o_led', 'gpio'+str(idx+1)) ]))
            
        veerwolf_pack.write('veerwolf_pack.v')


g = WolfPackGenerator()
g.run()
g.write()
