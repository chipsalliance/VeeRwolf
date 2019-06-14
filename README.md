SweRVolf
========

SweRVolf is a FuseSoC-based SoC for the [SweRV](https://github.com/chipsalliance/Cores-SweRV) RISC-V core.

This can be used to run the [RISC-V compliance tests](https://github.com/riscv/riscv-compliance), Zephyr OS or other software in simulators or on FPGA boards. The SoC consists of the SweRV CPU with a boot ROM, on-chip RAM and GPIO.

# Memory map

| Core     | Address               |
| -------- | --------------------- |
| RAM      | 0x00000000-0x0000FFFF |
| Boot ROM | 0x80000000-0x80000FFF |
| GPIO     | 0x80001000-0x8000000F |

For simulation targets there are also two extra registers defined. Writing to 0x80001008 will print a character to stdout. Writing to 0x80001009 will end the simulation.

## How to use

### Prerequisites

1. Create a directory structure consisting of a workspace directory (from now on called `$WORKSPACE`) and a root directory for the SweRV SoC (from now on called `$CORES_ROOT`). All further commands will be run from `$WORKSPACE` unless otherwise stated. The structure will look like this
├──cores
└──workspace

2. Make sure you have [FuseSoC](https://github.com/olofk/fusesoc) installed or install it with `pip install fusesoc`
3. From `$CORES_ROOT`, clone the SweRVolf repository `git clone https://github.com/chipsalliance/Cores-SweRVolf`
4. Add the cores directory as a FuseSoC core library `fusesoc library add swervolf ../cores`
5. Make sure you have verilator installed to run the simulation

### Run a precompiled example in simulation

At this point we can now build the simulation model and run the bundled Zephyr Hello world example in a simulator. `fusesoc run --target=sim swervolf --ram_init_file=../cores/swervolf/sw/zephyr_hello.vh`.

After running the above command, the simulation model should be built and run. At the end it will output

    Releasing reset
    ***** Booting Zephyr OS zephyr-v1.14.0 *****
    Hello World! swervolf_nexys

At this point the simulation can be aborted with `Ctrl-C`.

*Note: To see all available options for the simulation target, run `fusesoc run --target=sim swervolf --help`*

Another example to run is the Zephyr philosophers demo.

    fusesoc run --target=sim swervolf --ram_init_file=../cores/swervolf/sw/zephyr_philosophers.vh

### Run RISC-V compliance tests

1. Build the simulation model, if that hasn't already been done, with `fusesoc run --target=sim --setup --build swervolf`
2. Download the RISC-V compliance tests somewhere. `git clone https://github.com/riscv/riscv-compliance` in a sibling directory to the workspace and work root. Your directory structure should now look like this
├──cores
├──riscv-compliance
└──workspace

3. Copy the compiled simulation model into the target directory `cp $WORKSPACE/build/swervolf_0/sim-verilator/Vswervolf_core_tb $CORES_ROOT/swervolf/riscv-target/swerv/`
4. Enter the riscv-compliance directory and run `make TARGETDIR=$CORES_ROOT/swervolf/riscv-target/swerv riscv-target $RISCV_TARGET=swerv RISCV_DEVICE=rv32i RISCV_ISA=rv32imc`

*Note: Other test suites can be run by replacing RISCV_ISA=rv32imc with rv32im or rv32i*

### Run on hardware

The SweRVolf SoC can be built for a Digilent Nexys A7 board. Programs can be preloaded to the on-chip RAM at compile time. In the example below we will embed the Zephyr blinky example program.

    fusesoc run --target=nexys_a7 swervolf --ram_init_file=../cores/swervolf/sw/zephyr_blinky.vh

If the board is connected, it will automatically be programmed when the FPGA image has been built. It can also be programmed manually afterwards by running `fusesoc run --target=nexys_a7 --run swervolf`

In case you wonder why the LED blinks so fast, the reason is that we want to be able to run the same thing in a simulator without having to wait for a second of simulated time. To run the same system in verilator, change the target to simulation by running `fusesoc run --target=nexys_a7 swervolf --ram_init_file=../cores/swervolf/sw/zephyr_blinky.vh`. Eventually it will output notifications that the GPIO pin have changed which will result in an output looking like

    Loading RAM contents from /home/olof/projects/swerv/cores/swervolf/sw/zephyr_blinky.vh
    Releasing reset
    5074080: gpio0 is on
    10090350: gpio0 is off
    15106420: gpio0 is on
    20122690: gpio0 is off
    25138760: gpio0 is on

To find all available targets, you can run `fusesoc core show swervolf`

### Build Zephyr applications

*Note: At this point only the Zephyr blinky application can be built with upstream Zephyr due to the lack of a real UART*

1. Download and install Zephyr according to the official guidelines at https://www.zephyrproject.org/
2. Enter the directory of the Zephyr blinky example
3. Build the code with
    mkdir build
    cd build
    cmake -GNinja -DBOARD=swervolf_nexys -DBOARD_ROOT=$CORES_ROOT/swervolf/zephyr -DSOC_ROOT=$CORES_ROOT/swervolf/zephyr ..
    ninja
4. There will now be a binary file in `zephyr/zephyr.bin`
5. Enter the FuseSoC workspace directory and convert the binary file into a suitable verilog hex file with
    python $CORES_ROOT/swervolf/sw/makehex.py $ZEPHYR_BASE/samples/basic/blinky/build/zephyr/zephyr.bin > blinky2.hex
6. The new hex file can now be embedded for a new FPGA build with

    fusesoc run --target=nexys_a7 swervolf --ram_init_file=blinky2.hex

or in a simulation with

    fusesoc run --target=sim swervolf --ram_init_file=blinky2.hex

Note that simulation will take a very long time unless the blink speed is changed by setting `SLEEP_TIME` to a lower value in `$ZEPHYR_BASE/samples/basic/blinky/src/main.c`
