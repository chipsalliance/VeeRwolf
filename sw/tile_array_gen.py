#!/usr/bin/python3
from fusesoc.capi2.generator import Generator
import os
import shutil
import subprocess

from verilogwriter import Instance, ModulePort, Parameter, Port, VerilogWriter, Wire, Assign


class CoreArrayGenerator(Generator):
    def run(self):
        files = [{'veerwolf_array.v': {'file_type': 'verilogSource'}}]
        count = self.config.get('count')
        self.gen_veerwolf_array(count)
        self.add_files(files)
        print(f'Generating {count} tiles')

    def gen_veerwolf_array(self, count):
        veerwolf_array = VerilogWriter('veerwolf_array')

        veerwolf_array.add(ModulePort('clk_core', 'input'))
        veerwolf_array.add(ModulePort('rst_core', 'input'))
        veerwolf_array.add(ModulePort('i_uart_rx', 'input'))
        veerwolf_array.add(ModulePort('o_uart_tx', 'output'))
        veerwolf_array.add(ModulePort('i_sw', 'input', 16))
        veerwolf_array.add(ModulePort('o_led', 'output', 16))
        veerwolf_array.add(Parameter('array_code', '"bootloader.vh"'))

        for idx in range(count+1):
            veerwolf_array.add(Wire('gpio'+str(idx), 16))
            veerwolf_array.add(Wire('uart'+str(idx)))
            
        veerwolf_array.add(Assign('gpio0', 'i_sw'))
        veerwolf_array.add(Assign('o_led', 'gpio'+str(count)))
        veerwolf_array.add(Assign('uart0', 'i_uart_rx'))
        veerwolf_array.add(Assign('o_uart_tx', 'uart'+str(count)))

        for idx in range(count):
            veerwolf_array.add(Instance('veerwolf_tile', 'tile'+str(idx),
                                       [Parameter('bootrom_file', 'array_code')],
                                       [Port('clk_core', 'clk_core'),
                                        Port('rst_core', 'rst_core'),
                                        Port('i_uart_rx', 'uart'+str(idx)),
                                        Port('o_uart_tx', 'uart'+str(idx+1)),
                                        Port('i_sw', 'gpio'+str(idx)),
                                        Port('o_led', 'gpio'+str(idx+1)) ]))
            
        veerwolf_array.write('veerwolf_array.v')


g = CoreArrayGenerator()
g.run()
g.write()
