///////////////////////////////////////////////////////////////////////////////
//  File name : s25fl128s.v
///////////////////////////////////////////////////////////////////////////////
//  Copyright (C) 2009-2019 Free Model Foundry; http://www.FreeModelFoundry.com
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License version 2 as
//  published by the Free Software Foundation.
//
//  MODIFICATION HISTORY :
//
//  version: | author:       |   mod date:  | changes made:
//    V1.0      V.Mancev        23 Nov 09      Initial
//            R.Prokopovic
//    V1.1      V.Mancev        24 Feb 10    addr_cnt for second read in
//                                           high performance read continuous
//                                           mode can change its value only
//                                           when CSNeg = '0'
//    V1.2      V.Mancev        23 Mar 10    During read operations read_out
//                                           signal changes its value in
//                                           shorter interval
//    V1.3      V.Mancev        13 Apr 10    HOLD mode corrected
//                                           Condition for PP operation
//                                           corrected
//    V1.4      V.Mancev        19 May 10    SRWD bit assignment is corrected
//                                           Condition for WRR command in
//                                           write_cycle _decode section is
//                                           corrected
//                                           Blocking assignments for signals
//                                           WSTART and PSTART are replaced
//                                           with nonblocking assignments
//                                           Conditions in Page Program
//                                           section are fixed
//    V1.5      V.Mancev        26 May 10    Conditions in programming
//                                           sections are fixed
//                                           Timing control sections for
//                                           Program and Erase operation are
//                                           changed
//    V1.6      V.Mancev        03 June 10   bus_cycle_state section for
//                                           PGSP command is fixed
//    V1.7      V.Mancev        29 July 10   During the QUAD mode HOLD# input
//                                           is not monitored for its normal
//                                           function
//    V1.8     B.Colakovic      24 Aug 10    All redundant signals are removed
//                                           from BusCycle process
//    V1.9     V. Mancev        08 Oct 10    Latest datasheet aligned
//             B.Colakovic
//             R. Prokopovic
//    V1.10    V. Mancev        01 Nov 10    Read Configuration register added
//             B.Colakovic                   for any state. Hybrid configuration
//             R. Prokopovic                 added
//    V1.11    S.Petrovic       08 Apr 11    Corrected timing in always block
//                                           that generates
//                                           rising_edge_CSNeg_ipd
//    V1.12    V. Mancev        11 May 11    Condition for CS# High Time
//                                           (Program/Erase) is fixed
//    V1.13    V. Mancev        01 July 11   Latest datasheet aligned
//    V1.14    B.Colakovic      14 July 11   Optimization issue is fixed
//    V1.15    V.Mancev         22 July 11   Timing check issue is fixed
//    V1.16    V. Mancev        16 Nov 11    Time tHO is changed to 1 ns
//                                           (customer's request)
//                                           BRWR instruction is corrected
//    V1.17    S.Petrovic       28 Aug 12    QPP Instruction is allowed on
//                                           previously programmed page
//    V1.18    S.Petrovic       30 Aug 12    Wrong code corrected
//    V1.19    V. Mancev        13 Feb 13    Reverted restriction for QPP
//                                           on programmed page and
//                                           added clearing with sector erase
//   V1.20     S.Petrovic       13 Nov 28    Corrected state transitions
//                                           initiated by Power-Up and HW
//                                           Reset in StateGen process
//   V1.21     S.Petrovic       13 Dec 16    Corrected Read DLP.
//                                           Corrected Autoboot reg decoding
//   V1.22     M.Stojanovic     15 May 15    Ignored upper address bits for RD4
//   V1.23     M.Stojanovic     15 May 29    Ignored upper address bits for all
//                                           commands in QUAD mode
//   V1.24     M.Stojanovic     16 May 11    During QPP and QPP4 commands
//                                           the same page must not be
//                                           programmed more than once. However
//                                           do not generate P_ERR if this
//                                           occurs.
//   V1.25     M.Dinic          19 Feb 12    Updated according rev *P
//             B.Barac                       (QPP and QPP4 commands changed,
//                                            ECCRD command added,
//                                            LOCK bit removed)
//
///////////////////////////////////////////////////////////////////////////////
//  PART DESCRIPTION:
//
//  Library:    FLASH
//  Technology: FLASH MEMORY
//  Part:       S25FL128S
//
//  Description: 128 Megabit Serial Flash Memory
//
//////////////////////////////////////////////////////////////////////////////
//  Comments :
//      For correct simulation, simulator resolution should be set to 1 ps
//      A device ordering (trim) option determines whether a feature is enabled
//      or not, or provide relevant parameters:
//        -15th character in TimingModel determines if enhanced high
//         performance option is available
//            (0,2,3,R,A,B,C,D) EHPLC
//            (Y,Z,S,T,K,L)     Security EHPLC
//            (4,6,7,8,9,Q)     HPLC
//        -15th character in TimingModel determines if RESET# input
//         is available
//            (R,A,B,C,D,Q.6,7,K,L,S,T,M,N,U,V)  RESET# is available
//            (0,2,3,4,8,9,Y.Z.W,X)              RESET# is tied to the inactive
//                                               state,inside the package.
//        -16th character in TimingModel determines Sector and Page Size:
//            (0) Sector Size = 64 kB;  Page Size = 256 bytes
//                Hybrid Top/Bottom sector size architecture
//            (1) Sector Size = 256 kB; Page Size = 512 bytes
//                Uniform sector size architecture
//////////////////////////////////////////////////////////////////////////////
//  Known Bugs:
//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// MODULE DECLARATION                                                       //
//////////////////////////////////////////////////////////////////////////////
`timescale 1 ps/1 ps

module s25fl128s
    (
        // Data Inputs/Outputs
        SI     ,
        SO     ,
        // Controls
        SCK    ,
        CSNeg  ,
        RSTNeg ,
        WPNeg  ,
        HOLDNeg

);

///////////////////////////////////////////////////////////////////////////////
// Port / Part Pin Declarations
///////////////////////////////////////////////////////////////////////////////

    inout   SI            ;
    inout   SO            ;

    input   SCK           ;
    input   CSNeg         ;
    input   RSTNeg        ;
    inout   HOLDNeg       ;
    inout   WPNeg         ;

    // interconnect path delay signals
    wire   SCK_ipd        ;
    wire   SI_ipd         ;
    wire   SO_ipd         ;

    wire SI_in            ;
    assign SI_in = SI_ipd ;

    wire SI_out           ;
    assign SI_out = SI    ;

    wire SO_in            ;
    assign SO_in = SO_ipd ;

    wire SO_out           ;
    assign SO_out = SO    ;

    wire   CSNeg_ipd      ;
    wire   HOLDNeg_ipd    ;
    wire   WPNeg_ipd      ;
    wire   RSTNeg_ipd     ;

    wire HOLDNeg_in                 ;
    //Internal pull-up
    assign HOLDNeg_in = (HOLDNeg_ipd === 1'bx) ? 1'b1 : HOLDNeg_ipd;

    wire HOLDNeg_out                ;
    assign HOLDNeg_out = HOLDNeg    ;

    wire   WPNeg_in                 ;
    //Internal pull-up
    assign WPNeg_in = (WPNeg_ipd === 1'bx) ? 1'b1 : WPNeg_ipd;

    wire   WPNeg_out                ;
    assign WPNeg_out = WPNeg        ;

    wire   RSTNeg_in                 ;
    //Internal pull-up
    assign RSTNeg_in = (RSTNeg_ipd === 1'bx) ? 1'b1 : RSTNeg_ipd;

    // internal delays
    reg PP_in       ;
    reg PP_out      ;
    reg BP_in       ;
    reg BP_out      ;
    reg SE_in       ;
    reg SE_out      ;
    reg BE_in       ;
    reg BE_out      ;
    reg WRR_in      ;
    reg WRR_out     ;
    reg ERSSUSP_in  ;
    reg ERSSUSP_out ;
    reg PRGSUSP_in  ;
    reg PRGSUSP_out ;
    reg PU_in       ;
    reg PU_out      ;
    reg RST_in      ;
    reg RST_out     ;
    reg PPBERASE_in ;
    reg PPBERASE_out;
    reg PASSULCK_in ;
    reg PASSULCK_out;
    reg PASSACC_in ;
    reg PASSACC_out;

    // event control registers
    reg PRGSUSP_out_event;
    reg ERSSUSP_out_event;
    reg Reseted_event;
    reg SCK_ipd_event;
    reg next_state_event;

    reg rising_edge_PoweredUp   = 1'b0;
    reg rising_edge_Reseted     = 1'b0;
    reg rising_edge_PASSULCK_in = 1'b0;
    reg rising_edge_RES_out     = 1'b0;
    reg rising_edge_PSTART      = 1'b0;
    reg rising_edge_WSTART      = 1'b0;
    reg rising_edge_ESTART      = 1'b0;
    reg rising_edge_RSTNeg      = 1'b0;
    reg rising_edge_RST         = 1'b0;
    reg falling_edge_RSTNeg     = 1'b0;
    reg falling_edge_RST        = 1'b0;
    reg rising_edge_RST_out     = 1'b0;
    reg rising_edge_CSNeg_ipd   = 1'b0;
    reg falling_edge_CSNeg_ipd  = 1'b0;
    reg rising_edge_SCK_ipd     = 1'b0;
    reg falling_edge_SCK_ipd    = 1'b0;

    reg RST                ;

    reg  SOut_zd = 1'bZ     ;
    reg  SOut_z  = 1'bZ     ;

    wire SI_z                ;
    wire SO_z                ;

    reg  SIOut_zd = 1'bZ     ;
    reg  SIOut_z  = 1'bZ     ;

    reg  WPNegOut_zd   = 1'bZ  ;
    reg  HOLDNegOut_zd = 1'bZ  ;

    assign SI_z = SIOut_z;
    assign SO_z = SOut_z;

    parameter UserPreload       = 1;
    parameter mem_file_name     = "none";//"s25fl128s.mem";
    parameter otp_file_name     = "s25fl128sOTP.mem";//"none";

    parameter TimingModel       = "DefaultTimingModel";

    parameter  PartID           = "s25fl128s";
    parameter  MaxData          = 255;
    parameter  MemSize          = 24'hFFFFFF;
    parameter  SecSize256       = 20'h3FFFF;
    parameter  SecSize64        = 16'hFFFF;
    parameter  SecSize4         = 12'hFFF;
    parameter  SecNum64         = 285;
    parameter  SecNum256        = 63;
    parameter  PageNum64        = 20'h1FFFF;
    parameter  PageNum256       = 16'h7FFF;
    parameter  AddrRANGE        = 24'hFFFFFF;
    parameter  HiAddrBit        = 31;
    parameter  OTPSize          = 1023;
    parameter  OTPLoAddr        = 12'h000;
    parameter  OTPHiAddr        = 12'h3FF;
    parameter  BYTE             = 8;

    // Manufacturer Identification
    parameter  Manuf_ID       = 8'h01;
    parameter  DeviceID       = 8'h17;
    // Electronic Signature
    parameter  ESignature     = 8'h17;
    //  Device ID
    //Manufacturer Identification && Memory Type && Memory Capacity
    parameter  Jedec_ID       = 8'h01;
    parameter  DeviceID1      = 8'h20;
    parameter  DeviceID2      = 8'h18;
    parameter  ExtendedBytes  = 8'h4D;
    parameter  ExtendedID64   = 8'h01;
    parameter  ExtendedID256  = 8'h00;
    parameter  DieRev         = 8'h03;
    parameter  MaskRev        = 8'h00;

    integer    PageSize;
    integer    PageNum;
    integer    SecSize;
    integer    b_act = 0;

    integer    ASP_ProtSE = 0;
    integer    Sec_ProtSE = 0;

    integer    EHP; //Enhanced High Performance Mode active

    integer    BAR_ACC = 0; //Bank Register Access active

    //varaibles to resolve architecture used
    reg [24*8-1:0] tmp_timing;//stores copy of TimingModel
    reg [7:0] tmp_char1;//Define EHPLC or HPLC Mode
    reg [7:0] tmp_char2;//stores "0" or "1" character defining sector/page size
    integer found = 1'b0;

    // If speedsimulation is needed uncomment following line

       `define SPEEDSIM;

    // powerup
    reg PoweredUp;

    // Memory Array Configuration
    reg BottomBoot          = 1'b0;
    reg TopBoot             = 1'b0;
    reg UniformSec          = 1'b0;

    // FSM control signals
    reg PDONE     ;
    reg PSTART    ;
    reg PGSUSP    ;
    reg PGRES     ;

    reg TSU       ;

    reg RES_TO_SUSP_MIN_TIME;
    reg RES_TO_SUSP_TYP_TIME;

    reg WDONE     ;
    reg WSTART    ;

    reg EDONE     ;
    reg ESTART    ;
    reg ESUSP     ;
    reg ERES      ;
    reg ERS_SUSP_PG_SUSP_ACT;

    reg Reseted   ;

    reg PARAM_REGION      = 1'b0;

    // Lock Bit is enabled for customer programming
    reg WRLOCKENABLE      = 1'b1;
    // Flag that mark if ASP Register is allready programmed
    reg ASPOTPFLAG        = 1'b0;

    //Flag for Password unlock command
    reg PASS_UNLOCKED     = 1'b0;
    reg [63:0] PASS_TEMP  = 64'hFFFFFFFFFFFFFFFF;

    reg QUADRD            = 1'b0;
    reg INITIAL_CONFIG    = 1'b0;
    reg CHECK_FREQ        = 1'b0;

    // Programming buffer
    integer WByte[0:511];
    // CFI array
    integer CFI_array[8'h00:8'h50];
    // OTP Memory Array
    integer OTPMem[OTPLoAddr:OTPHiAddr];
    // Flash Memory Array
    integer Mem[0:AddrRANGE];

    // Registers
    // VDLR Register
    reg[7:0] VDLR_reg          = 8'h00;
    reg[7:0] VDLR_reg_in       = 8'h00;
    // NVDLR Register
    reg[7:0] NVDLR_reg         = 8'h00;
    reg[7:0] NVDLR_reg_in      = 8'h00;
    reg start_dlp              = 1'b0;

    // Status Register 1
    reg[7:0] Status_reg1       = 8'h00;
    reg[7:0] Status_reg1_in    = 8'h00;

    wire SRWD ;
    wire P_ERR;
    wire E_ERR;
    wire [2:0]BP;
    wire WEL;
    wire WIP;
    assign SRWD   = Status_reg1[7];
    assign P_ERR  = Status_reg1[6];
    assign E_ERR  = Status_reg1[5];
    assign BP     = Status_reg1[4:2];
    assign WEL    = Status_reg1[1];
    assign WIP    = Status_reg1[0];

    // Status Register 2
    reg[7:0] Status_reg2       = 8'h00;
    reg[7:0] Status_reg2_in    = 8'h00;

    wire ES ;
    wire PS ;
    assign ES   = Status_reg2[1];
    assign PS   = Status_reg2[0];

    // Configuration Register 1
    reg[7:0] Config_reg1       = 8'h00;
    reg[7:0] Config_reg1_in    = 8'h00;

    wire   LC1                     ;
    wire   LC0                     ;
    wire   TBPROT                  ;
//     wire   LOCK                    ;
    wire   BPNV                    ;
    wire   TBPARM                  ;
    wire   QUAD                    ;
    wire   FREEZE                  ;
    assign LC1     = Config_reg1[7];
    assign LC0     = Config_reg1[6];
    assign TBPROT  = Config_reg1[5];
//     assign LOCK    = Config_reg1[4];
    assign BPNV    = Config_reg1[3];
    assign TBPARM  = Config_reg1[2];
    assign QUAD    = Config_reg1[1];
    assign FREEZE  = Config_reg1[0];

    // Autoboot Register
    reg[31:0] AutoBoot_reg     = 32'h00000000;
    reg[31:0] AutoBoot_reg_in  = 32'h00000000;

    wire ABE;
    assign ABE     = AutoBoot_reg[0];

    // Bank Address Register
    reg [7:0] Bank_Addr_reg    = 8'h00;
    reg [7:0] Bank_Addr_reg_in = 8'h00;

    wire   EXTADD;
    assign EXTADD  = Bank_Addr_reg[7];
    
    // ECC Status Register
    reg[7:0] ECCSR      = 8'h00;
    
    wire   EECC;
    wire   EECCD;
    wire   ECCDI;
    
    assign EECC   = ECCSR[2];
    assign EECCD  = ECCSR[1];
    assign ECCDI  = ECCSR[0];

    // ASP Register
    reg[15:0] ASP_reg   ;
    reg[15:0] ASP_reg_in;

    wire    RPME         ;
    wire    PPBOTP       ;
    wire    PWDMLB       ;
    wire    PSTMLB       ;
    assign  RPME     = ASP_reg[5];
    assign  PPBOTP   = ASP_reg[3];
    assign  PWDMLB   = ASP_reg[2];
    assign  PSTMLB   = ASP_reg[1];

    // Password register
    reg[63:0] Password_reg     = 64'hFFFFFFFFFFFFFFFF;
    reg[63:0] Password_reg_in  = 64'hFFFFFFFFFFFFFFFF;

    // PPB Lock Register
    reg[7:0] PPBL              = 8'h00;
    reg[7:0] PPBL_in           = 8'h00;

    wire   PPB_LOCK              ;
    assign PPB_LOCK     = PPBL[0];

    // PPB Access Register
    reg[7:0] PPBAR             = 8'hFF;
    reg[7:0] PPBAR_in          = 8'hFF;

    reg[SecNum64:0] PPB_bits     = {286{1'b1}};

    // DYB Access Register
    reg[7:0] DYBAR             = 8'hFF;
    reg[7:0] DYBAR_in          = 8'hFF;

    reg[SecNum64:0] DYB_bits     = {286{1'b1}};

    //The Lock Protection Registers for OTP Memory space
    reg[7:0] LOCK_BYTE1;
    reg[7:0] LOCK_BYTE2;
    reg[7:0] LOCK_BYTE3;
    reg[7:0] LOCK_BYTE4;

    // Command Register
    reg write;
    reg cfg_write;
    reg read_out;
    reg dual          = 1'b0;
    reg rd_fast       = 1'b1;
    reg rd_slow       = 1'b0;
    reg ddr           = 1'b0;
    reg ddr80         = 1'b0;
    reg ddr_fast      = 1'b0;
    reg hold_mode     = 1'b0;
    reg any_read      = 1'b0;
    reg quad_pg       = 1'b0;

    wire rd ;
    wire fast_rd ;
    wire ddrd ;
    wire fast_ddr ;
    wire ddrd80 ;

    wire quadpg ;
    assign quadpg = quad_pg;

    wire RD_EQU_1;
    assign RD_EQU_1 = any_read;

    wire RD_EQU_0;
    assign RD_EQU_0 = ~any_read;

    reg  change_TBPARM = 0;

    reg  change_BP = 0;
    reg [2:0] BP_bits   = 3'b0;

    reg DOUBLE          = 1'b0; //Double Data Rate (DDR) flag

    reg RdPswdProtMode    = 1'b0;//Read Password Protection Mode Active flag
    reg RdPswdProtEnable  = 1'b0;//Read Password Protection Mode Support flag

    integer Byte_number = 0;

    reg oe   = 1'b0;
    reg oe_z = 1'b0;

    reg [647:0] CFI_array_tmp ;
    reg [7:0] CFI_tmp;

    integer start_delay;
    reg start_autoboot;
    integer ABSD;

    reg  change_addr ;
    integer Address = 0;
    integer SectorSuspend = 0;

    //Sector and subsector addresses
    integer SA        = 0;

    // Sector is protect if Sec_Prot(SecNum) = '1'
    reg [SecNum64:0] Sec_Prot  = {286{1'b0}};

    // timing check violation
    reg Viol = 1'b0;

    integer WOTPByte;
    integer AddrLo;
    integer AddrHi;

    reg[7:0]  old_bit, new_bit;
    integer old_int, new_int;
    reg[63:0] old_pass;
    reg[63:0] new_pass;
    integer wr_cnt;
    integer cnt;

    integer read_cnt = 0;
    integer byte_cnt = 1;
    integer read_addr = 0;
    integer read_addr_tmp = 0;
    integer Sec_addr = 0;
    integer SecAddr = 0;
    integer Page_addr = 0;
    integer pgm_page = 0;

    reg[7:0] data_out;
    reg[647:0] ident_out;

    time SCK_cycle = 0;
    time prev_SCK;
    time start_ddr;
    time out_time;
    time SCK_SO_DDR;
///////////////////////////////////////////////////////////////////////////////
//Interconnect Path Delay Section
///////////////////////////////////////////////////////////////////////////////
 buf   (SCK_ipd, SCK);
 buf   (SI_ipd, SI);

 buf   (SO_ipd, SO);
 buf   (CSNeg_ipd, CSNeg);
 buf   (HOLDNeg_ipd, HOLDNeg);
 buf   (WPNeg_ipd, WPNeg);
 buf   (RSTNeg_ipd, RSTNeg);

///////////////////////////////////////////////////////////////////////////////
// Propagation  delay Section
///////////////////////////////////////////////////////////////////////////////
    nmos   (SI,   SI_z , 1);

    nmos   (SO,   SO_z , 1);
    nmos   (HOLDNeg,   HOLDNegOut_zd , 1);
    nmos   (WPNeg,   WPNegOut_zd , 1);

    wire deg_pin;
    wire deg_sin;
    wire deg_holdin;
    wire deh_pin;
    wire deh_sout;
    wire deh_ddr_sout;
    wire deh_holdin;
    //VHDL VITAL CheckEnable equivalents
    wire quad_rd;
    assign quad_rd = deg_holdin && ~QUAD && (SIOut_z != 1'bz);
    wire wr_prot;
    assign wr_prot = SRWD && WEL && ~QUAD;
    wire dual_rd;
    assign dual_rd = dual ;
    wire ddro;
    assign ddro = ddr && ~ddr80 && ~dual ;
    wire ddro80;
    assign ddro80 = ddr && ddr80 && ~dual ;
    wire ddr_rd;
    assign ddr_rd = PoweredUp && ddr;
    wire sdr_rd;
    assign sdr_rd = PoweredUp && ~ddr;
specify
        // tipd delays: interconnect path delays , mapped to input port delays.
        // In Verilog is not necessary to declare any tipd_ delay variables,
        // they can be taken from SDF file
        // With all the other delays real delays would be taken from SDF file

    // tpd delays
    specparam        tpd_SCK_SO_normal             =1;
    specparam        tpd_CSNeg_SO                  =1;
    specparam        tpd_HOLDNeg_SO                =1;
    specparam        tpd_RSTNeg_SO                 =1;
    //DDR operation values
    specparam        tpd_SCK_SO_DDR                =1;

    //tsetup values: setup times
    specparam        tsetup_CSNeg_SCK              =1;
    specparam        tsetup_SI_SCK_normal          =1;
    specparam        tsetup_WPNeg_CSNeg            =1;
    specparam        tsetup_HOLDNeg_SCK            =1;
    specparam        tsetup_RSTNeg_CSNeg           =1;
    // DDR operation values
    specparam        tsetup_SI_SCK_DDR             =1;
    specparam        tsetup_SI_SCK_DDR_fast        =1;
    specparam        tsetup_CSNeg_SCK_DDR          =1;

    //thold values: hold times
    specparam        thold_CSNeg_SCK               =1;
    specparam        thold_SI_SCK_normal           =1;
    specparam        thold_SO_SCK_normal           =1;
    specparam        thold_WPNeg_CSNeg             =1;
    specparam        thold_HOLDNeg_SCK             =1;
    specparam        thold_CSNeg_RSTNeg            =1;
    // DDR operation values
    specparam        thold_SI_SCK_DDR              =1;
    specparam        thold_SI_SCK_DDR_fast         =1;
    specparam        thold_CSNeg_SCK_DDR           =1;

    // tpw values: pulse width
    specparam        tpw_SCK_serial_posedge        =1;
    specparam        tpw_SCK_dual_posedge          =1;
    specparam        tpw_SCK_fast_posedge          =1;
    specparam        tpw_SCK_quadpg_posedge        =1;
    specparam        tpw_SCK_serial_negedge        =1;
    specparam        tpw_SCK_dual_negedge          =1;
    specparam        tpw_SCK_fast_negedge          =1;
    specparam        tpw_SCK_quadpg_negedge        =1;
    specparam        tpw_CSNeg_read_posedge        =1;
    specparam        tpw_CSNeg_pgers_posedge       =1;
    specparam        tpw_RSTNeg_negedge            =1;
    specparam        tpw_RSTNeg_posedge            =1;
    // DDR operation values
    specparam        tpw_SCK_DDR_posedge           =1;
    specparam        tpw_SCK_DDR_negedge           =1;
    specparam        tpw_SCK_DDR80_posedge         =1;
    specparam        tpw_SCK_DDR80_negedge         =1;

    // tperiod min (calculated as 1/max freq)
    specparam        tperiod_SCK_serial_rd         =1;// 50 MHz
    specparam        tperiod_SCK_fast_rd           =1;//133 MHz
    specparam        tperiod_SCK_dual_rd           =1;//104 MHz
    specparam        tperiod_SCK_quadpg            =1;// 80 MHz
    // DDR operation values
    specparam        tperiod_SCK_DDR_rd            =1;// 66 MHz
    specparam        tperiod_SCK_DDR80_rd          =1;// 80 MHz

    `ifdef SPEEDSIM
        // Page Program Operation
        specparam        tdevice_PP_256            = 75e7;//tPP
        // Page Program Operation
        specparam        tdevice_PP_512            = 75e7;//tPP
        // Typical Byte Programming Time
        specparam        tdevice_BP                = 4e8;//tBP
        // Sector Erase Operation
        specparam        tdevice_SE64              = 650e7;//tSE
        // Sector Erase Operation
        specparam        tdevice_SE256             = 1875e7;//tSE
        // Bulk Erase Operation
        specparam        tdevice_BE                = 165e9;//tBE
        // WRR Cycle Time
        specparam        tdevice_WRR               = 2e9;//tW
        // Erase Suspend/Erase Resume Time
        specparam        tdevice_ERSSUSP           = 40e6;//tESL
        // Program Suspend/Program Resume Time
        specparam        tdevice_PRGSUSP           = 40e6;//
        // VCC (min) to CS# Low
        specparam        tdevice_PU                = 3e8;//tPU
        // PPB Erase Time
        specparam        tdevice_PPBERASE          = 15e9;//
        // Password Unlock Time
        specparam        tdevice_PASSULCK          = 1e6;//
        // Password Unlock to Password Unlock Time
        specparam        tdevice_PASSACC           = 100e6;
        // Data In Setup Max time
        specparam        tdevice_TSU               = 300e3;
    `else
        // Page Program Operation
        specparam        tdevice_PP_256            = 75e7;//tPP
        // Page Program Operation
        specparam        tdevice_PP_512            = 75e7;//tPP
        // Typical Byte Programming Time
        specparam        tdevice_BP                = 4e8;//tBP
        // Sector Erase Operation
        specparam        tdevice_SE64              = 650e9;//tSE
        // Sector Erase Operation
        specparam        tdevice_SE256             = 1875e9;//tSE
        // Bulk Erase Operation
        specparam        tdevice_BE                = 165e12;//tBE
        // WRR Cycle Time
        specparam        tdevice_WRR               = 2e11;//tW
        // Erase Suspend/Erase Resume Time
        specparam        tdevice_ERSSUSP           = 40e6;//tESL
        // Program Suspend/Program Resume Time
        specparam        tdevice_PRGSUSP           = 40e6;//
        // VCC (min) to CS# Low
        specparam        tdevice_PU                = 3e8;//tPU
        // PPB Erase Time
        specparam        tdevice_PPBERASE          = 15e9;//
        // Password Unlock Time
        specparam        tdevice_PASSULCK          = 1e6;//
        // Password Unlock to Password Unlock Time
        specparam        tdevice_PASSACC           = 100e6;
        // Data In Setup Max time
        specparam        tdevice_TSU               = 300e3;
    `endif // SPEEDSIM

///////////////////////////////////////////////////////////////////////////////
// Input Port  Delays  don't require Verilog description
///////////////////////////////////////////////////////////////////////////////
// Path delays                                                               //
///////////////////////////////////////////////////////////////////////////////
  if (~ddr)           (SCK => SO) = tpd_SCK_SO_normal;
  if (ddr || rd_fast) (SCK => SO) = tpd_SCK_SO_DDR;

  if (~ddr && dual) (SCK => SI) = tpd_SCK_SO_normal;
  if ( ddr && dual) (SCK => SI) = tpd_SCK_SO_DDR;

  if (~ddr && QUAD)(SCK => HOLDNeg) = tpd_SCK_SO_normal;
  if ( ddr && QUAD)(SCK => HOLDNeg) = tpd_SCK_SO_DDR;
  if (~ddr && QUAD)(SCK => WPNeg)   = tpd_SCK_SO_normal;
  if ( ddr && QUAD)(SCK => WPNeg)   = tpd_SCK_SO_DDR;

  if (CSNeg)         (CSNeg => SO) = tpd_CSNeg_SO;
  if (CSNeg && dual) (CSNeg => SI) = tpd_CSNeg_SO;

  if (CSNeg && QUAD) (CSNeg => HOLDNeg) = tpd_CSNeg_SO;
  if (CSNeg && QUAD) (CSNeg => WPNeg)   = tpd_CSNeg_SO;

  if (~QUAD)          (HOLDNeg => SO) = tpd_HOLDNeg_SO;
  if (~QUAD && dual)  (HOLDNeg => SI) = tpd_HOLDNeg_SO;

   (RSTNeg => SO) = tpd_RSTNeg_SO;
///////////////////////////////////////////////////////////////////////////////
// Timing Violation                                                          //
///////////////////////////////////////////////////////////////////////////////
        $setup ( CSNeg          , posedge SCK &&& sdr_rd,
                                                tsetup_CSNeg_SCK,       Viol);
        $setup ( CSNeg          , posedge SCK &&& ddr_rd,
                                                tsetup_CSNeg_SCK_DDR,   Viol);
        $setup ( SI             , posedge SCK &&& deg_sin,
                                                tsetup_SI_SCK_normal,   Viol);
        $setup ( WPNeg          , negedge CSNeg &&& wr_prot,
                                                tsetup_WPNeg_CSNeg,     Viol);
        $setup ( HOLDNeg        , posedge SCK &&& quad_rd,
                                                tsetup_HOLDNeg_SCK,     Viol);
        $setup ( SI             , posedge SCK &&& ddro,
                                                tsetup_SI_SCK_DDR,      Viol);
        $setup ( SI             , negedge SCK &&& ddro,
                                                tsetup_SI_SCK_DDR,      Viol);
        $setup ( SI             , posedge SCK &&& ddro80,
                                                tsetup_SI_SCK_DDR,      Viol);
        $setup ( SI             , negedge SCK &&& ddro80,
                                                tsetup_SI_SCK_DDR,      Viol);

        $setup ( RSTNeg         , negedge CSNeg,
                                                tsetup_RSTNeg_CSNeg,    Viol);

        $hold  ( posedge SCK &&& sdr_rd   , CSNeg,
                                                thold_CSNeg_SCK,        Viol);
        $hold  ( posedge SCK &&& ddr_rd   , CSNeg,
                                                thold_CSNeg_SCK_DDR,    Viol);
        $hold  ( posedge SCK &&& deg_sin     , SI ,
                                                thold_SI_SCK_normal,    Viol);
        $hold  ( negedge SCK &&& deh_sout    , SO ,
                                                thold_SO_SCK_normal,    Viol);
        $hold  ( negedge SCK &&& deh_ddr_sout        , SO ,
                                                thold_SO_SCK_normal,    Viol);
        $hold  ( posedge SCK &&& deh_ddr_sout        , SO ,
                                                thold_SO_SCK_normal,    Viol);
        $hold  ( posedge CSNeg &&& wr_prot , WPNeg ,
                                                thold_WPNeg_CSNeg,      Viol);
        $hold  ( posedge SCK  &&& quad_rd  , HOLDNeg ,
                                                thold_HOLDNeg_SCK,      Viol);
        $hold  ( posedge SCK &&& ddro     , SI,
                                                thold_SI_SCK_DDR,       Viol);
        $hold  ( negedge SCK &&& ddro     , SI,
                                                thold_SI_SCK_DDR,       Viol);
        $hold  ( posedge SCK &&& ddro80     , SI,
                                                thold_SI_SCK_DDR,       Viol);
        $hold  ( negedge SCK &&& ddro80     , SI,
                                                thold_SI_SCK_DDR,       Viol);

        $hold  ( negedge RSTNeg  , CSNeg,
                                                thold_CSNeg_RSTNeg,     Viol);

        $width ( posedge SCK &&& rd        , tpw_SCK_serial_posedge);
        $width ( negedge SCK &&& rd        , tpw_SCK_serial_negedge);
        $width ( posedge SCK &&& dual_rd   , tpw_SCK_dual_posedge);
        $width ( negedge SCK &&& dual_rd   , tpw_SCK_dual_negedge);
        $width ( posedge SCK &&& fast_rd   , tpw_SCK_fast_posedge);
        $width ( negedge SCK &&& fast_rd   , tpw_SCK_fast_negedge);
        $width ( posedge SCK &&& ddrd      , tpw_SCK_DDR_posedge);
        $width ( negedge SCK &&& ddrd      , tpw_SCK_DDR_negedge);
        $width ( posedge SCK &&& ddrd80    , tpw_SCK_DDR80_posedge);
        $width ( negedge SCK &&& ddrd80    , tpw_SCK_DDR80_negedge);
        $width ( posedge SCK &&& quadpg    , tpw_SCK_quadpg_posedge);
        $width ( negedge SCK &&& quadpg    , tpw_SCK_quadpg_negedge);

        $width ( posedge CSNeg &&& RD_EQU_1, tpw_CSNeg_read_posedge);
        $width ( posedge CSNeg &&& RD_EQU_0, tpw_CSNeg_pgers_posedge);
        $width ( negedge RSTNeg            , tpw_RSTNeg_negedge);
        $width ( posedge RSTNeg            , tpw_RSTNeg_posedge);

        $period ( posedge SCK &&& rd       , tperiod_SCK_serial_rd);
        $period ( posedge SCK &&& fast_rd  , tperiod_SCK_fast_rd);
        $period ( posedge SCK &&& dual_rd  , tperiod_SCK_dual_rd);
        $period ( posedge SCK &&& quadpg   , tperiod_SCK_quadpg);
        $period ( posedge SCK &&& ddrd     , tperiod_SCK_DDR_rd);
        $period ( posedge SCK &&& ddrd80   , tperiod_SCK_DDR80_rd);

endspecify

///////////////////////////////////////////////////////////////////////////////
// Main Behavior Block                                                       //
///////////////////////////////////////////////////////////////////////////////
// FSM states
 parameter IDLE            = 5'd0;
 parameter RESET_STATE     = 5'd1;
 parameter AUTOBOOT        = 5'd2;
 parameter WRITE_SR        = 5'd3;
 parameter PAGE_PG         = 5'd4;
 parameter OTP_PG          = 5'd5;
 parameter PG_SUSP         = 5'd6;
 parameter SECTOR_ERS      = 5'd7;
 parameter BULK_ERS        = 5'd8;
 parameter ERS_SUSP        = 5'd9;
 parameter ERS_SUSP_PG     = 5'd10;
 parameter ERS_SUSP_PG_SUSP= 5'd11;
 parameter PASS_PG         = 5'd12;
 parameter PASS_UNLOCK     = 5'd13;
 parameter PPB_PG          = 5'd14;
 parameter PPB_ERS         = 5'd15;
 parameter AUTOBOOT_PG     = 5'd16;
 parameter ASP_PG          = 5'd17;
 parameter PLB_PG          = 5'd18;
 parameter DYB_PG          = 5'd19;
 parameter NVDLR_PG        = 5'd20;

 reg [4:0] current_state;
 reg [4:0] next_state;

// Instruction type
 parameter NONE            = 7'd0;
 parameter WRR             = 7'd1;
 parameter PP              = 7'd2;
 parameter READ            = 7'd3;
 parameter WRDI            = 7'd4;
 parameter RDSR            = 7'd5;
 parameter WREN            = 7'd6;
 parameter RDSR2           = 7'd7;
 parameter FSTRD           = 7'd8;
 parameter FSTRD4          = 7'd9;
 parameter DDRFR           = 7'd10;
 parameter DDRFR4          = 7'd11;
 parameter PP4             = 7'd12;
 parameter RD4             = 7'd13;
 parameter ABRD            = 7'd14;
 parameter ABWR            = 7'd15;
 parameter BRRD            = 7'd16;
 parameter BRWR            = 7'd17;
 parameter P4E             = 7'd19;
 parameter P4E4            = 7'd20;
 parameter ASPRD           = 7'd21;
 parameter ASPP            = 7'd22;
 parameter CLSR            = 7'd23;
 parameter QPP             = 7'd24;
 parameter QPP4            = 7'd25;
 parameter RDCR            = 7'd26;
 parameter DOR             = 7'd27;
 parameter DOR4            = 7'd28;
 parameter DLPRD           = 7'd29;
 parameter OTPP            = 7'd30;
 parameter PNVDLR          = 7'd31;
 parameter OTPR            = 7'd32;
 parameter WVDLR           = 7'd33;
 parameter BE              = 7'd34;
 parameter QOR             = 7'd35;
 parameter QOR4            = 7'd36;
 parameter ERSP            = 7'd37;
 parameter ERRS            = 7'd38;
 parameter PGSP            = 7'd39;
 parameter PGRS            = 7'd40;
 parameter REMS            = 7'd41;
 parameter RDID            = 7'd42;
 parameter MPM             = 7'd43;
 parameter PLBWR           = 7'd44;
 parameter PLBRD           = 7'd45;
 parameter RES             = 7'd46;
 parameter DIOR            = 7'd47;
 parameter DIOR4           = 7'd48;
 parameter DDRDIOR         = 7'd49;
 parameter DDRDIOR4        = 7'd50;
 parameter SE              = 7'd51;
 parameter SE4             = 7'd52;
 parameter DYBRD           = 7'd53;
 parameter DYBWR           = 7'd54;
 parameter PPBRD           = 7'd55;
 parameter PPBP            = 7'd56;
 parameter PPBERS          = 7'd57;
 parameter PASSRD          = 7'd58;
 parameter PASSP           = 7'd59;
 parameter PASSU           = 7'd60;
 parameter QIOR            = 7'd61;
 parameter QIOR4           = 7'd62;
 parameter DDRQIOR         = 7'd63;
 parameter DDRQIOR4        = 7'd64;
 parameter RESET           = 7'd65;
 parameter MBR             = 7'd66;
 parameter BRAC            = 7'd67;
 parameter ECCRD           = 7'd68;

 reg [6:0] Instruct;

//Bus cycle state
 parameter STAND_BY        = 3'd0;
 parameter OPCODE_BYTE     = 3'd1;
 parameter ADDRESS_BYTES   = 3'd2;
 parameter DUMMY_BYTES     = 3'd3;
 parameter MODE_BYTE       = 3'd4;
 parameter DATA_BYTES      = 3'd5;

 reg [2:0] bus_cycle_state;

 reg deq_pin;
    always @(SO_in, SO_z)
    begin
      if (SO_in==SO_z)
        deq_pin=1'b0;
      else
        deq_pin=1'b1;
    end
    // check when data is generated from model to avoid setuphold check in
    // this occasion
    assign deg_pin = deq_pin;
    assign deh_pin = (deq_pin == 1'b0) && (SO_z != 1'bz);
 reg deq_sin;
    always @(SI_in, SIOut_z)
    begin
      if (SI_in==SIOut_z)
        deq_sin=1'b0;
      else
        deq_sin=1'b1;
    end
    // check when data is generated from model to avoid setuphold check in
    // this occasion
    assign deg_sin=deq_sin
           && (ddr == 1'b0) && (Instruct !== DDRFR)
           && (Instruct !== DDRFR4) && (Instruct !== DDRDIOR)
           && (Instruct !== DDRDIOR4) && (Instruct !== DDRQIOR)
           && (Instruct !== DDRQIOR4) && (SIOut_z != 1'bz);
 reg deq_sout;
    always @(SO_out, SIOut_z)
    begin
      if (SO_out==SIOut_z)
        deq_sout=1'b0;
      else
        deq_sout=1'b1;
    end
    // check when data is generated from model
    assign deh_sout= (deq_sout == 1'b0)
           && (ddr == 1'b0) && (SOut_z != 1'bz);
    assign deh_ddr_sout= (deq_sout == 1'b0)
           && (ddr == 1'b1) && (SOut_z != 1'bz);

 reg deq_holdin;
    always @(HOLDNeg_ipd, HOLDNegOut_zd)
    begin
      if (HOLDNeg_ipd==HOLDNegOut_zd)
        deq_holdin=1'b0;
      else
        deq_holdin=1'b1;
    end
    // check when data is generated from model to avoid setuphold check in
    // this occasion
    assign deg_holdin=deq_holdin;
    assign deh_holdin=(deq_holdin == 1'b0) && (HOLDNegOut_zd != 1'bz);

    //Power Up time;
    initial
    begin
        PoweredUp = 1'b0;
        #tdevice_PU PoweredUp = 1'b1;
    end

    initial
    begin : Init
        write       = 1'b0;
        cfg_write   = 1'b0;
        read_out    = 1'b0;
        Address     = 0;
        change_addr = 1'b0;
        cnt         = 0;
        RST         = 1'b0;
        RST_in      = 1'b0;
        RST_out     = 1'b1;
        PDONE       = 1'b1;
        PSTART      = 1'b0;
        PGSUSP      = 1'b0;
        PGRES       = 1'b0;
        PRGSUSP_in  = 1'b0;
        ERSSUSP_in  = 1'b0;
        RES_TO_SUSP_MIN_TIME  = 1'b0;
        RES_TO_SUSP_TYP_TIME  = 1'b0;

        EDONE       = 1'b1;
        ESTART      = 1'b0;
        ESUSP       = 1'b0;
        ERES        = 1'b0;

        WDONE       = 1'b1;
        WSTART      = 1'b0;

        Reseted     = 1'b0;

        Instruct        = NONE;
        bus_cycle_state = STAND_BY;
        current_state   = RESET_STATE;
        next_state      = RESET_STATE;
    end

    // initialize memory and load preload files if any
    initial
    begin: InitMemory
        integer i;

        for (i=0;i<=AddrRANGE;i=i+1)
        begin
            Mem[i] = MaxData;
        end

        if ((UserPreload) && !(mem_file_name == "none"))
        begin
           // Memory Preload
           //s25fl128s.mem, memory preload file
           //  @aaaaaa - <aaaaaa> stands for address
           //  dd      - <dd> is byte to be written at Mem(aaaaaa++)
           // (aaaaaa is incremented at every load)
           $readmemh(mem_file_name,Mem);
        end

        for (i=OTPLoAddr;i<=OTPHiAddr;i=i+1)
        begin
            OTPMem[i] = MaxData;
        end

        if (UserPreload && !(otp_file_name == "none"))
        begin
        //s25fl128s_otp memory file
        //   /       - comment
        //   @aaaaaa     - <aaaaaa> stands for address within last defined
        //   sector
        //   dd      - <dd> is byte to be written at OTPMem(aaa++)
        //   (aa is incremented at every load)
        //   only first 1-4 columns are loaded. NO empty lines !!!!!!!!!!!!!!!!
           $readmemh(otp_file_name,OTPMem);
        end

        LOCK_BYTE1[7:0] = OTPMem[16];
        LOCK_BYTE2[7:0] = OTPMem[17];
        LOCK_BYTE3[7:0] = OTPMem[18];
        LOCK_BYTE4[7:0] = OTPMem[19];
    end

    // initialize memory and load preload files if any
    initial
    begin: InitTimingModel
    integer i;
    integer j;
        //UNIFORM OR HYBRID arch model is used
        //assumptions:
        //1. TimingModel has format as S25FL128SXXXXXXXX_X_XXpF
        //it is important that 16-th character from first one is "0" or "1"
        //2. TimingModel does not have more then 24 characters
        tmp_timing = TimingModel;//copy of TimingModel

        i = 23;
        while ((i >= 0) && (found != 1'b1))//search for first non null character
        begin        //i keeps position of first non null character
            j = 7;
            while ((j >= 0) && (found != 1'b1))
            begin
                if (tmp_timing[i*8+j] != 1'd0)
                    found = 1'b1;
                else
                    j = j-1;
            end
            i = i - 1;
        end
        i = i +1;
        if (found)//if non null character is found
        begin
            for (j=0;j<=7;j=j+1)
            begin
            //EHPLC/HPLC character is 15
            tmp_char1[j] = TimingModel[(i-14)*8+j];
            //256B/512B Page character is 16
            tmp_char2[j] = TimingModel[(i-15)*8+j];
            end
        end
        if (tmp_char1 == "0" || tmp_char1 == "2" || tmp_char1 == "3" ||
            tmp_char1 == "R" || tmp_char1 == "A" || tmp_char1 == "B" ||
            tmp_char1 == "C" || tmp_char1 == "D" || tmp_char1 == "Y" ||
            tmp_char1 == "Z" || tmp_char1 == "S" || tmp_char1 == "T" ||
            tmp_char1 == "K" || tmp_char1 == "L")
        begin
            EHP = 1;
            if(tmp_char1 == "Z" || tmp_char1 == "S" || tmp_char1 == "T" ||
               tmp_char1 == "K" || tmp_char1 == "L" || tmp_char1 == "Y")
            begin
                RdPswdProtEnable = 1;
            end
        end
        else if (tmp_char1 == "4" || tmp_char1 == "6" || tmp_char1 == "7" ||
                 tmp_char1 == "8" || tmp_char1 == "9" || tmp_char1 == "Q")
        begin
            EHP = 0;
        end

        if (tmp_char1 == "0" || tmp_char1 == "2" || tmp_char1 == "3" ||
            tmp_char1 == "R" || tmp_char1 == "A" || tmp_char1 == "B" ||
            tmp_char1 == "C" || tmp_char1 == "D" || tmp_char1 == "4" ||
            tmp_char1 == "6" || tmp_char1 == "7" || tmp_char1 == "8" ||
            tmp_char1 == "9" || tmp_char1 == "Q")
        begin
            ASP_reg    = 16'hFE7F;
            ASP_reg_in = 16'hFE7F;
        end
        else if (tmp_char1 == "Y" || tmp_char1 == "Z" || tmp_char1 == "S" ||
                 tmp_char1 == "T" || tmp_char1 == "K" || tmp_char1 == "L")
        begin
            ASP_reg    = 16'hFE4F;
            ASP_reg_in = 16'hFE4F;
        end

        if (tmp_char2 == "0")
        begin
            PageSize = 255;
            PageNum  = PageNum64;
            SecSize  = SecSize64;
        end
        else if (tmp_char2 == "1")
        begin
            PageSize = 511;
            PageNum  = PageNum256;
            SecSize  = SecSize256;
        end
    end

    //CFI
    initial
    begin: InitCFI
    integer i;
    integer j;
        ///////////////////////////////////////////////////////////////////////
        // ID-CFI array data
        ///////////////////////////////////////////////////////////////////////
        // Manufacturer and Device ID
        CFI_array[8'h00] = Jedec_ID;
        CFI_array[8'h01] = DeviceID1;
        CFI_array[8'h02] = DeviceID2;
        CFI_array[8'h03] = 8'h00;
        if (tmp_char2 == "0")
        // Uniform 64kB sectors
            CFI_array[8'h04] = ExtendedID64;
        else if (tmp_char2 == "1")
        // Uniform 256kB sectors
            CFI_array[8'h04] = ExtendedID256;
        CFI_array[8'h05] = 8'h80;
        CFI_array[8'h06] = 8'h00;
        CFI_array[8'h07] = 8'h00;
        CFI_array[8'h08] = 8'h00;
        CFI_array[8'h09] = 8'h00;
        CFI_array[8'h0A] = 8'h00;
        CFI_array[8'h0B] = 8'h00;
        CFI_array[8'h0C] = 8'h00;
        CFI_array[8'h0D] = 8'h00;
        CFI_array[8'h0E] = 8'h00;
        CFI_array[8'h0F] = 8'h00;
        // CFI Query Identification String
        CFI_array[8'h10] = 8'h51;
        CFI_array[8'h11] = 8'h52;
        CFI_array[8'h12] = 8'h59;
        CFI_array[8'h13] = 8'h02;
        CFI_array[8'h14] = 8'h00;
        CFI_array[8'h15] = 8'h40;
        CFI_array[8'h16] = 8'h00;
        CFI_array[8'h17] = 8'h53;
        CFI_array[8'h18] = 8'h46;
        CFI_array[8'h19] = 8'h51;
        CFI_array[8'h1A] = 8'h00;
        //CFI system interface string
        CFI_array[8'h1B] = 8'h27;
        CFI_array[8'h1C] = 8'h36;
        CFI_array[8'h1D] = 8'h00;
        CFI_array[8'h1E] = 8'h00;
        CFI_array[8'h1F] = 8'h06;
        if (tmp_char2 == "0")
        begin
        // 64kB sector and 256B page
            CFI_array[8'h20] = 8'h08;
            CFI_array[8'h21] = 8'h08;
        end
        else if (tmp_char2 == "1")
        begin
        // 256kB sector and 512B page
            CFI_array[8'h20] = 8'h09;
            CFI_array[8'h21] = 8'h09;
        end
        CFI_array[8'h22] = 8'h0F;
        CFI_array[8'h23] = 8'h02;
        CFI_array[8'h24] = 8'h02;
        CFI_array[8'h25] = 8'h03;
        CFI_array[8'h26] = 8'h03;
        // Device Geometry Definition(Uniform Sector Devices)
        CFI_array[8'h27] = 8'h18;
        CFI_array[8'h28] = 8'h02;
        CFI_array[8'h29] = 8'h01;

        if (tmp_char2 == "0")
        // 64kB sectors
            CFI_array[8'h2A] = 8'h08;
        else if (tmp_char2 == "1")
            CFI_array[8'h2A] = 8'h09;

        CFI_array[8'h2B] = 8'h00;
        if (tmp_char2 == "1")
        begin
            CFI_array[8'h2C] = 8'h01;
            CFI_array[8'h2D] = 8'h3F;
            CFI_array[8'h2E] = 8'h00;
            CFI_array[8'h2F] = 8'h00;
            CFI_array[8'h30] = 8'h04;
            CFI_array[8'h31] = 8'hFF;
            CFI_array[8'h32] = 8'hFF;
            CFI_array[8'h33] = 8'hFF;
            CFI_array[8'h34] = 8'hFF;
        end
        else
        begin
            CFI_array[8'h2C] = 8'h02;
            if (TBPARM)
            begin
            // 4KB physical sectors at top
                CFI_array[8'h2D] = 8'hFD;
                CFI_array[8'h2E] = 8'h00;
                CFI_array[8'h2F] = 8'h00;
                CFI_array[8'h30] = 8'h01;
                CFI_array[8'h31] = 8'h1F;
                CFI_array[8'h32] = 8'h00;
                CFI_array[8'h33] = 8'h10;
                CFI_array[8'h34] = 8'h00;
            end
            else
            begin
            // 4KB physical sectors at bottom
                CFI_array[8'h2D] = 8'h1F;
                CFI_array[8'h2E] = 8'h00;
                CFI_array[8'h2F] = 8'h10;
                CFI_array[8'h30] = 8'h00;
                CFI_array[8'h31] = 8'hFD;
                CFI_array[8'h32] = 8'h00;
                CFI_array[8'h33] = 8'h00;
                CFI_array[8'h34] = 8'h01;
            end
        end
        CFI_array[8'h35] = 8'hFF;
        CFI_array[8'h36] = 8'hFF;
        CFI_array[8'h37] = 8'hFF;
        CFI_array[8'h38] = 8'hFF;
        CFI_array[8'h39] = 8'hFF;
        CFI_array[8'h3A] = 8'hFF;
        CFI_array[8'h3B] = 8'hFF;
        CFI_array[8'h3C] = 8'hFF;
        CFI_array[8'h3D] = 8'hFF;
        CFI_array[8'h3E] = 8'hFF;
        CFI_array[8'h3F] = 8'hFF;
        // CFI Primary Vendor-Specific Extended Query
        CFI_array[8'h40] = 8'h50;
        CFI_array[8'h41] = 8'h52;
        CFI_array[8'h42] = 8'h49;
        CFI_array[8'h43] = 8'h31;
        CFI_array[8'h44] = 8'h33;
        CFI_array[8'h45] = 8'h21;
        CFI_array[8'h46] = 8'h02;
        CFI_array[8'h47] = 8'h01;
        CFI_array[8'h48] = 8'h00;
        CFI_array[8'h49] = 8'h08;
        CFI_array[8'h4A] = 8'h00;
        CFI_array[8'h4B] = 8'h01;
        CFI_array[8'h4C] = 8'h00;
        CFI_array[8'h4D] = 8'h00;
        CFI_array[8'h4E] = 8'h00;
        CFI_array[8'h4F] = 8'h07;
        CFI_array[8'h50] = 8'h01;

        begin
            for(i=80;i>=0;i=i-1)
            begin
                CFI_tmp = CFI_array[8'h00-i+80];
                for(j=7;j>=0;j=j-1)
                begin
                    CFI_array_tmp[8*i+j] = CFI_tmp[j];
                end
            end
        end

    end

    always @(next_state_event or PoweredUp or RST or RST_out or
            RSTNeg_in or rising_edge_RSTNeg or falling_edge_RST)
    begin: StateTransition
        if (PoweredUp)
        begin
            if ((RSTNeg_in == 1'b1) && (RST_out == 1'b1))
                current_state = #(1000) next_state;
            else if ((~RSTNeg_in || rising_edge_RSTNeg) && falling_edge_RST)
            begin
            // no state transition while RESET# low
                current_state = RESET_STATE;
                RST_in = 1'b1;
                #1000 RST_in = 1'b0;
            end
        end
    end

    always @(posedge RST_in)
    begin:Threset
        RST_out = 1'b0;
        #(35000000-200000) RST_out = 1'b1;
    end

    always @(negedge CSNeg_ipd)
    begin:CheckCEOnPowerUP
        if (~PoweredUp)
            $display ("Device is selected during Power Up");
    end

    ///////////////////////////////////////////////////////////////////////////
    //// Internal Delays
    ///////////////////////////////////////////////////////////////////////////

    always @(posedge PRGSUSP_in)
    begin:PRGSuspend
        PRGSUSP_out = 1'b0;
        #tdevice_PRGSUSP PRGSUSP_out = 1'b1;
    end

    always @(posedge PPBERASE_in)
    begin:PPBErs
        PPBERASE_out = 1'b0;
        #tdevice_PPBERASE PPBERASE_out = 1'b1;
    end

    always @(posedge ERSSUSP_in)
    begin:ERSSuspend
        ERSSUSP_out = 1'b0;
        #tdevice_ERSSUSP ERSSUSP_out = 1'b1;
    end

    always @(posedge PASSULCK_in)
    begin:PASSULock
        PASSULCK_out = 1'b0;
        #tdevice_PASSULCK PASSULCK_out = 1'b1;
    end

    always @(posedge PASSACC_in)
    begin:PASSAcc
        PASSACC_out = 1'b0;
        #tdevice_PASSACC PASSACC_out = 1'b1;
    end

///////////////////////////////////////////////////////////////////////////////
// write cycle decode
///////////////////////////////////////////////////////////////////////////////
    integer opcode_cnt = 0;
    integer addr_cnt   = 0;
    integer mode_cnt   = 0;
    integer dummy_cnt  = 0;
    integer data_cnt   = 0;
    integer bit_cnt    = 0;

    reg [4095:0] Data_in = 4096'b0;
    reg [7:0] opcode;
    reg [7:0] opcode_in;
    reg [7:0] opcode_tmp;
    reg [31:0] addr_bytes;
    reg [31:0] hiaddr_bytes;
    reg [31:0] Address_in;
    reg [7:0] mode_bytes;
    reg [7:0] mode_in;
    integer Latency_code;
    integer quad_data_in [0:1023];
    reg [3:0] quad_nybble = 4'b0;
    reg [3:0] Quad_slv;
    reg [7:0] Byte_slv;

   always @(rising_edge_CSNeg_ipd or falling_edge_CSNeg_ipd or
            rising_edge_SCK_ipd or falling_edge_SCK_ipd or
            current_state)
   begin: Buscycle
        integer i;
        integer j;
        integer k;
        time CLK_PER;
        time LAST_CLK;

        if (current_state == RESET_STATE)
            bus_cycle_state = STAND_BY;
        else
        begin
            if (falling_edge_CSNeg_ipd)
            begin
                if (bus_cycle_state==STAND_BY)
                begin
                    Instruct = NONE;
                    write = 1'b1;
                    cfg_write  = 0;
                    opcode_cnt = 0;
                    addr_cnt   = 0;
                    mode_cnt   = 0;
                    dummy_cnt  = 0;
                    data_cnt   = 0;
                    opcode_tmp = 0;
                    start_dlp  = 0;
                    DOUBLE     = 1'b0;
                    QUADRD     = 1'b0;
                    CLK_PER    = 1'b0;
                    LAST_CLK   = 1'b0;
                    if (current_state == AUTOBOOT)
                    begin
                        bus_cycle_state = DATA_BYTES;
                    end
                    else
                    begin
                        bus_cycle_state = OPCODE_BYTE;
                    end
                end
            end

            if (rising_edge_SCK_ipd) // Instructions, addresses or data present
            begin                    // at SI are latched on the rising edge of SCK

                CLK_PER = $time - LAST_CLK;
                LAST_CLK = $time;
                if (CHECK_FREQ)
                begin
                    if ((CLK_PER < 20000 && Latency_code == 3) ||
                    (CLK_PER < 12500 && Latency_code == 0) ||
                    (CLK_PER < 11100 && Latency_code == 1) ||
                    (CLK_PER < 9600 && Latency_code == 2))
                    begin
                        $display ("More wait states are required for");
                        $display ("this clock frequency value");
                    end
                    if (Instruct == DDRFR || Instruct == DDRFR4 || Instruct == DDRDIOR ||
                        Instruct == DDRDIOR4 || Instruct == DDRQIOR || Instruct == DDRQIOR4)
                    begin
                       if   (CLK_PER < 12500)
                       begin
                           ddr80 = 1'b1;
                       end
                       else
                       begin
                           ddr80 = 1'b0;
                       end
                    end
                    CHECK_FREQ = 0;
                end

                if (~CSNeg_ipd)
                begin
                    case (bus_cycle_state)
                        OPCODE_BYTE:
                        begin
                            if ((HOLDNeg_in && ~QUAD) || QUAD)
                            begin
                                opcode_in[opcode_cnt] = SI_in;
                                opcode_cnt = opcode_cnt + 1;
                                Latency_code = Config_reg1[7:6];
                                if (opcode_cnt == BYTE)
                                begin
                                    for(i=7;i>=0;i=i-1)
                                    begin
                                        opcode[i] = opcode_in[7-i];
                                    end
                                    case (opcode)
                                        8'b00000110 : // 06h
                                        begin
                                            Instruct = WREN;
                                            bus_cycle_state = DATA_BYTES;
                                        end
                                        8'b00000100 : // 04h
                                        begin
                                            Instruct = WRDI;
                                            bus_cycle_state = DATA_BYTES;
                                        end
                                        8'b00000001 : // 01h
                                        begin
                                            Instruct = WRR;
                                            bus_cycle_state = DATA_BYTES;
                                        end
                                        8'b00000011 : // 03h
                                        begin
                                            Instruct = READ;
                                            bus_cycle_state = ADDRESS_BYTES;
                                        end
                                        8'b00010011 : // 13h
                                        begin
                                            Instruct = RD4;
                                            bus_cycle_state = ADDRESS_BYTES;
                                        end
                                        8'b01001011 : // 4Bh
                                        begin
                                            Instruct = OTPR;
                                            bus_cycle_state = ADDRESS_BYTES;
                                        end
                                        8'b00000101 : // 05h
                                        begin
                                            Instruct = RDSR;
                                            bus_cycle_state = DATA_BYTES;
                                        end
                                        8'b00000111 : // 07h
                                        begin
                                            Instruct = RDSR2;
                                            bus_cycle_state = DATA_BYTES;
                                        end
                                        8'b00110101 : // 35h
                                        begin
                                            Instruct = RDCR;
                                            bus_cycle_state = DATA_BYTES;
                                        end
                                        8'b10010000 : // 90h
                                        begin
                                            Instruct = REMS;
                                            bus_cycle_state = ADDRESS_BYTES;
                                        end
                                        8'b10011111 : // 9Fh
                                        begin
                                            Instruct = RDID;
                                            bus_cycle_state = DATA_BYTES;
                                        end
                                        8'b10101011 : // ABh
                                        begin
                                            Instruct = RES;
                                            bus_cycle_state = DUMMY_BYTES;
                                        end
                                        8'b00001011 : // 0Bh
                                        begin
                                            Instruct = FSTRD;
                                            bus_cycle_state = ADDRESS_BYTES;
                                            CHECK_FREQ = 1'b1;
                                        end
                                        8'b00001100 : // 0Ch
                                        begin
                                            Instruct = FSTRD4;
                                            bus_cycle_state = ADDRESS_BYTES;
                                            CHECK_FREQ = 1'b1;
                                        end
                                        8'b00001101 : // 0Dh
                                        begin
                                            Instruct = DDRFR;
                                            bus_cycle_state = ADDRESS_BYTES;
                                            CHECK_FREQ = 1'b1;
                                        end
                                        8'b00001110 : // 0Eh
                                        begin
                                            Instruct = DDRFR4;
                                            bus_cycle_state = ADDRESS_BYTES;
                                            CHECK_FREQ = 1'b1;
                                        end
                                        8'b00111011 : // 3Bh
                                        begin
                                            Instruct = DOR;
                                            bus_cycle_state = ADDRESS_BYTES;
                                            CHECK_FREQ = 1'b1;
                                        end
                                        8'b00111100 : // 3Ch
                                        begin
                                            Instruct = DOR4;
                                            bus_cycle_state = ADDRESS_BYTES;
                                            CHECK_FREQ = 1'b1;
                                        end
                                        8'b10111011 : // BBh
                                        begin
                                            Instruct = DIOR;
                                            bus_cycle_state = ADDRESS_BYTES;
                                            CHECK_FREQ = 1'b1;
                                        end
                                        8'b10111100 : // BCh
                                        begin
                                            Instruct = DIOR4;
                                            bus_cycle_state = ADDRESS_BYTES;
                                            CHECK_FREQ = 1'b1;
                                        end
                                        8'b10111101 : // BDh
                                        begin
                                            Instruct = DDRDIOR;
                                            bus_cycle_state = ADDRESS_BYTES;
                                            CHECK_FREQ = 1'b1;
                                        end
                                        8'b10111110 : // BEh
                                        begin
                                            Instruct = DDRDIOR4;
                                            bus_cycle_state = ADDRESS_BYTES;
                                            CHECK_FREQ = 1'b1;
                                        end
                                        8'b01101011 : // 6Bh
                                        begin
                                            Instruct = QOR;
                                            bus_cycle_state = ADDRESS_BYTES;
                                            CHECK_FREQ = 1'b1;
                                        end
                                        8'b01101100 : // 6Ch
                                        begin
                                            Instruct = QOR4;
                                            bus_cycle_state = ADDRESS_BYTES;
                                            CHECK_FREQ = 1'b1;
                                        end
                                        8'b11101011 : // EBh
                                        begin
                                            Instruct = QIOR;
                                            bus_cycle_state = ADDRESS_BYTES;
                                            CHECK_FREQ = 1'b1;
                                        end
                                        8'b11101100 : // ECh
                                        begin
                                            Instruct = QIOR4;
                                            bus_cycle_state = ADDRESS_BYTES;
                                            CHECK_FREQ = 1'b1;
                                        end
                                        8'b11101101 : // EDh
                                        begin
                                            Instruct = DDRQIOR;
                                            bus_cycle_state = ADDRESS_BYTES;
                                            CHECK_FREQ = 1'b1;
                                        end
                                        8'b11101110 : // EEh
                                        begin
                                            Instruct = DDRQIOR4;
                                            bus_cycle_state = ADDRESS_BYTES;
                                            CHECK_FREQ = 1'b1;
                                        end
                                        8'b00000010 : // 02h
                                        begin
                                            Instruct = PP;
                                            bus_cycle_state = ADDRESS_BYTES;
                                        end
                                        8'b00010010 : // 12h
                                        begin
                                            Instruct = PP4;
                                            bus_cycle_state = ADDRESS_BYTES;
                                        end
                                        8'b00110010: // 32h
                                        begin
                                            Instruct = QPP;
                                            bus_cycle_state = ADDRESS_BYTES;
                                            quad_pg = 1'b1;
                                        end
                                        8'b00111000: // 38h
                                        begin
                                            Instruct = QPP;
                                            bus_cycle_state = ADDRESS_BYTES;
                                            quad_pg = 1'b1;
                                        end
                                        8'b00110100 : // 34h
                                        begin
                                            Instruct = QPP4;
                                            bus_cycle_state = ADDRESS_BYTES;
                                            quad_pg = 1'b1;
                                        end
                                        8'b01000010 : // 42h
                                        begin
                                            Instruct = OTPP;
                                            bus_cycle_state = ADDRESS_BYTES;
                                        end
                                        8'b10000101 : // 85h
                                        begin
                                            Instruct = PGSP;
                                            bus_cycle_state = DATA_BYTES;
                                        end
                                        8'b10001010 : // 8Ah
                                        begin
                                            Instruct = PGRS;
                                            bus_cycle_state = DATA_BYTES;
                                        end
                                        8'b11000111 : // C7h
                                        begin
                                            Instruct = BE;
                                            bus_cycle_state = DATA_BYTES;
                                        end
                                        8'b01100000 : // 60h
                                        begin
                                            Instruct = BE;
                                            bus_cycle_state = DATA_BYTES;
                                        end
                                        8'b11011000 : // D8h
                                        begin
                                            Instruct = SE;
                                            bus_cycle_state = ADDRESS_BYTES;
                                        end
                                        8'b11011100 : // DCh
                                        begin
                                            Instruct = SE4;
                                            bus_cycle_state = ADDRESS_BYTES;
                                        end
                                        8'b01110101 : // 75h
                                        begin
                                            Instruct = ERSP;
                                            bus_cycle_state = DATA_BYTES;
                                        end
                                        8'b01111010 : // 7Ah
                                        begin
                                            Instruct = ERRS;
                                            bus_cycle_state = DATA_BYTES;
                                        end
                                        8'b00010100 : // 14h
                                        begin
                                            Instruct = ABRD;
                                            bus_cycle_state = DATA_BYTES;
                                        end
                                        8'b00010101 : // 15h
                                        begin
                                            Instruct = ABWR;
                                            bus_cycle_state = DATA_BYTES;
                                        end
                                        8'b00010110 : // 16h
                                        begin
                                            Instruct = BRRD;
                                            bus_cycle_state = DATA_BYTES;
                                        end
                                        8'b00010111 : // 17h
                                        begin
                                            Instruct = BRWR;
                                            bus_cycle_state = DATA_BYTES;
                                        end
                                        8'b00101011 : // 2Bh
                                        begin
                                            Instruct = ASPRD;
                                            bus_cycle_state = DATA_BYTES;
                                        end
                                        8'b00101111 : // 2Fh
                                        begin
                                            Instruct = ASPP;
                                            bus_cycle_state = DATA_BYTES;
                                        end
                                        8'b11100000 : // E0h
                                        begin
                                            Instruct = DYBRD;
                                            bus_cycle_state = ADDRESS_BYTES;
                                        end
                                        8'b11100001 : // E1h
                                        begin
                                            Instruct = DYBWR;
                                            bus_cycle_state = ADDRESS_BYTES;
                                        end
                                        8'b11100010 : // E2h
                                        begin
                                            Instruct = PPBRD;
                                            bus_cycle_state = ADDRESS_BYTES;
                                        end
                                        8'b11100011 : // E3h
                                        begin
                                            Instruct = PPBP;
                                            bus_cycle_state = ADDRESS_BYTES;
                                        end
                                        8'b11100100 : // E4h
                                        begin
                                            Instruct = PPBERS;
                                            bus_cycle_state = DATA_BYTES;
                                        end
                                        8'b10100110 : // A6h
                                        begin
                                            Instruct = PLBWR;
                                            bus_cycle_state = DATA_BYTES;
                                        end
                                        8'b10100111 : // A7h
                                        begin
                                            Instruct = PLBRD;
                                            bus_cycle_state = DATA_BYTES;
                                        end
                                        8'b11100111 : // E7h
                                        begin
                                            Instruct = PASSRD;
                                            bus_cycle_state = DATA_BYTES;
                                        end
                                        8'b11101000 : // E8h
                                        begin
                                            Instruct = PASSP;
                                            bus_cycle_state = DATA_BYTES;
                                        end
                                        8'b11101001 : // E9h
                                        begin
                                            Instruct = PASSU;
                                            bus_cycle_state = DATA_BYTES;
                                        end
                                        8'b11110000 : // F0h
                                        begin
                                            Instruct = RESET;
                                            bus_cycle_state = DATA_BYTES;
                                        end
                                        8'b00110000 : // 30h
                                        begin
                                            Instruct = CLSR;
                                            bus_cycle_state = DATA_BYTES;
                                        end
                                        8'b00100000 : // 20h
                                        begin
                                            Instruct = P4E;
                                            bus_cycle_state = ADDRESS_BYTES;
                                        end
                                        8'b00100001 : // 21h
                                        begin
                                            Instruct = P4E4;
                                            bus_cycle_state = ADDRESS_BYTES;
                                        end
                                        8'b01000001 : // 41h
                                        begin
                                            Instruct = DLPRD;
                                            bus_cycle_state = DATA_BYTES;
                                        end
                                        8'b01000011 : // 43h
                                        begin
                                            Instruct = PNVDLR;
                                            bus_cycle_state = DATA_BYTES;
                                        end
                                        8'b01001010 : // 4Ah
                                        begin
                                            Instruct = WVDLR;
                                            bus_cycle_state = DATA_BYTES;
                                        end
                                        8'b10111001 : // B9h
                                        begin
                                            Instruct = BRAC;
                                            bus_cycle_state = DATA_BYTES;
                                        end
                                        8'b11111111 : // FFh
                                        begin
                                            Instruct = MBR;
                                            bus_cycle_state = MODE_BYTE;
                                        end
                                        8'b00011000 : // 18h
                                        begin
                                            Instruct = ECCRD;
                                            bus_cycle_state = ADDRESS_BYTES;
                                        end
                                    endcase
                                end
                            end
                        end //end of OPCODE BYTE

                        ADDRESS_BYTES :
                        begin
                            if ((Instruct == DDRFR)  || (Instruct == DDRFR4)  ||
                                (Instruct == DDRDIOR) || (Instruct == DDRDIOR4) ||
                                (Instruct == DDRQIOR) || (Instruct == DDRQIOR4))
                                DOUBLE = 1'b1;
                            else
                                DOUBLE = 1'b0;
                            if ((Instruct == QOR)  || (Instruct == QOR4)  ||
                                (Instruct == QIOR) || (Instruct == QIOR4) ||
                                (Instruct == DDRQIOR) || (Instruct == DDRQIOR4))
                                QUADRD = 1'b1;
                            else
                                QUADRD = 1'b0;
                            if (DOUBLE == 1'b0)
                            begin
                                if (((((Instruct == FSTRD) && (~EXTADD)) ||
                                ((Instruct == DOR)  && (~EXTADD)) ||
                                (Instruct == OTPR)) &&
                                ((HOLDNeg_in && ~QUAD) || QUAD)) ||
                                ((Instruct == QOR) && QUAD && (~EXTADD)))
                                begin
                                //Instruction + 3 Bytes Address + Dummy Byte
                                    Address_in[addr_cnt] = SI_in;
                                    addr_cnt = addr_cnt + 1;
                                    if (addr_cnt == 3*BYTE)
                                    begin
                                        for(i=23;i>=0;i=i-1)
                                        begin
                                            addr_bytes[23-i] = Address_in[i];
                                        end
                                        addr_bytes[31:24] = 8'b00000000;
                                        Address = addr_bytes ;
                                        change_addr = 1'b1;
                                        #1 change_addr = 1'b0;
                                        if (Instruct==FSTRD || Instruct==DOR ||
                                            Instruct == QOR)
                                        begin
                                            if (Latency_code == 3)
                                                bus_cycle_state = DATA_BYTES;
                                            else
                                                bus_cycle_state = DUMMY_BYTES;
                                        end
                                        else
                                            bus_cycle_state = DUMMY_BYTES;
                                    end
                                end
                                else if (Instruct==ECCRD)
                                begin
                                //Instruction + 4 Bytes Address + Dummy Byte
                                    Address_in[addr_cnt] = SI_in;
                                    addr_cnt = addr_cnt + 1;
                                    if (addr_cnt == 4*BYTE)
                                    begin
                                        for(i=31;i>=0;i=i-1)
                                        begin
                                            hiaddr_bytes[31-i] = Address_in[i];
                                        end
                                        //High order address bits are ignored
                                        Address = {hiaddr_bytes[31:4],4'b0000};
                                        change_addr = 1'b1;
                                        #1 change_addr = 1'b0;
                                        bus_cycle_state = DUMMY_BYTES;
                                    end
                                end
                                else if ((((Instruct==FSTRD4) ||
                                        (Instruct==DOR4) ||
                                        ((Instruct==FSTRD) && EXTADD) ||
                                        ((Instruct==DOR) && EXTADD)) &&
                                        ((HOLDNeg_in && ~QUAD) || QUAD)) ||
                                        ((Instruct==QOR4) && QUAD) ||
                                        ((Instruct==QOR) && QUAD && EXTADD))
                                begin
                                //Instruction + 4 Bytes Address + Dummy Byte
                                    Address_in[addr_cnt] = SI_in;
                                    addr_cnt = addr_cnt + 1;
                                    if (addr_cnt == 4*BYTE)
                                    begin
                                        for(i=31;i>=0;i=i-1)
                                        begin
                                            hiaddr_bytes[31-i] = Address_in[i];
                                        end
                                        //High order address bits are ignored
                                        Address = {8'b00000000,hiaddr_bytes[23:0]};
                                        change_addr = 1'b1;
                                        #1 change_addr = 1'b0;
                                        if (Latency_code == 3)
                                            bus_cycle_state = DATA_BYTES;
                                        else
                                        begin
                                            bus_cycle_state = DUMMY_BYTES;
                                        end
                                    end
                                end
                                else if ((Instruct==DIOR) && (~EXTADD) &&
                                            ((HOLDNeg_in && ~QUAD) || QUAD))
                                begin
                                //DUAL I/O High Performance Read(3 Bytes Addr)
                                    Address_in[2*addr_cnt]     = SO_in;
                                    Address_in[2*addr_cnt + 1] = SI_in;
                                    read_cnt = 0;
                                    addr_cnt = addr_cnt + 1;
                                    if (addr_cnt == 3*BYTE/2)
                                    begin
                                        addr_cnt = 0;
                                        for(i=23;i>=0;i=i-1)
                                        begin
                                            addr_bytes[23-i]=Address_in[i];
                                        end
                                        addr_bytes[31:24] = 8'b00000000;
                                        Address = addr_bytes;
                                        change_addr = 1'b1;
                                        #1 change_addr = 1'b0;
                                        if (EHP)
                                            bus_cycle_state = MODE_BYTE;
                                        else
                                            bus_cycle_state = DUMMY_BYTES;
                                    end
                                end
                                else if (((Instruct==DIOR4) ||
                                        ((Instruct==DIOR) && EXTADD)) &&
                                        ((HOLDNeg_in && ~QUAD) || QUAD))
                                begin //DUAL I/O High Performance Read(4Bytes Addr)
                                    Address_in[2*addr_cnt]     = SO_in;
                                    Address_in[2*addr_cnt + 1] = SI_in;
                                    read_cnt = 0;
                                    addr_cnt = addr_cnt + 1;
                                    if (addr_cnt == 4*BYTE/2)
                                    begin
                                        addr_cnt = 0;
                                        for(i=31;i>=0;i=i-1)
                                        begin
                                            addr_bytes[31-i] = Address_in[i];
                                        end
                                        Address = {8'b00000000,addr_bytes[23:0]};
                                        change_addr = 1'b1;
                                        #1 change_addr = 1'b0;
                                        if (EHP)
                                            bus_cycle_state = MODE_BYTE;
                                        else
                                            bus_cycle_state = DUMMY_BYTES;
                                    end
                                end
                                else if ((Instruct == QIOR) && (~EXTADD))
                                begin
                                //QUAD I/O High Performance Read (3Bytes Address)
                                    if (QUAD)
                                    begin
                                        Address_in[4*addr_cnt] = HOLDNeg_in;
                                        Address_in[4*addr_cnt+1] = WPNeg_in;
                                        Address_in[4*addr_cnt+2] = SO_in;
                                        Address_in[4*addr_cnt+3] = SI_in;
                                        read_cnt = 0;
                                        addr_cnt = addr_cnt + 1;
                                        if (addr_cnt == 3*BYTE/4)
                                        begin
                                            addr_cnt = 0;
                                            for(i=23;i>=0;i=i-1)
                                            begin
                                                addr_bytes[23-i] = Address_in[i];
                                            end
                                            addr_bytes[31:24] = 8'b00000000;
                                            Address = addr_bytes;
                                            change_addr = 1'b1;
                                            #1 change_addr = 1'b0;
                                            bus_cycle_state = MODE_BYTE;
                                        end
                                    end
                                    else
                                        bus_cycle_state = STAND_BY;
                                end
                                else if ((Instruct==QIOR4) || ((Instruct==QIOR)
                                        && EXTADD))
                                begin
                                    //QUAD I/O High Performance Read (4Bytes Addr)
                                    if (QUAD)
                                    begin
                                        Address_in[4*addr_cnt] = HOLDNeg_in;
                                        Address_in[4*addr_cnt+1] = WPNeg_in;
                                        Address_in[4*addr_cnt+2] = SO_in;
                                        Address_in[4*addr_cnt+3] = SI_in;
                                        read_cnt = 0;
                                        addr_cnt = addr_cnt +1;
                                        if (addr_cnt == 4*BYTE/4)
                                        begin
                                            addr_cnt =0;
                                            for(i=31;i>=0;i=i-1)
                                            begin
                                                hiaddr_bytes[31-i] = Address_in[i];
                                            end
                                            //High order address bits are ignored
                                            Address = {8'b00000000,hiaddr_bytes[23:0]};
                                            change_addr = 1'b1;
                                            #1 change_addr = 1'b0;
                                            bus_cycle_state = MODE_BYTE;
                                        end
                                    end
                                    else
                                        bus_cycle_state = STAND_BY;
                                end
                                else if ((((Instruct==RD4) || (Instruct==PP4) ||
                                        (Instruct==SE4) ||(Instruct==PPBRD) ||
                                        (Instruct==DYBRD) ||(Instruct==DYBWR) ||
                                        (Instruct==PPBP) || (Instruct==P4E4) ||
                                        ((Instruct==READ) && EXTADD) ||
                                        ((Instruct==PP) && EXTADD) ||
                                        ((Instruct==P4E) && EXTADD) ||
                                        ((Instruct==SE) && EXTADD)) &&
                                        ((HOLDNeg_in && ~QUAD) || QUAD)) ||
                                        (QUAD && (Instruct==QPP4 ||
                                        ((Instruct==QPP) && EXTADD))))
                                begin
                                    Address_in[addr_cnt] = SI_in;
                                    addr_cnt = addr_cnt + 1;
                                    if (addr_cnt == 4*BYTE)
                                    begin
                                        for(i=31;i>=0;i=i-1)
                                        begin
                                            hiaddr_bytes[31-i] = Address_in[i];
                                        end
                                        //High order address bits are ignored
                                        Address = {8'b00000000,hiaddr_bytes[23:0]};
                                        change_addr = 1'b1;
                                        #1 change_addr = 1'b0;
                                        bus_cycle_state = DATA_BYTES;
                                    end
                                end
                                else if (((HOLDNeg_in && ~QUAD) || QUAD) &&
                                        (~EXTADD))
                                begin
                                    Address_in[addr_cnt] = SI_in;
                                    addr_cnt = addr_cnt + 1;
                                    if (addr_cnt == 3*BYTE)
                                    begin
                                        for(i=23;i>=0;i=i-1)
                                        begin
                                            addr_bytes[23-i] = Address_in[i];
                                        end
                                        addr_bytes[31:24] = 8'b00000000;
                                        Address = addr_bytes;
                                        change_addr = 1'b1;
                                        #1 change_addr = 1'b0;
                                        bus_cycle_state = DATA_BYTES;
                                    end
                                end
                            end
                            else
                            begin
                                if ((Instruct==DDRFR) && (~EXTADD))
                                //Fast DDR Read Mode
                                begin
                                    Address_in[addr_cnt] = SI_in;
                                    if ((addr_cnt/2) <= 16)
                                    begin
                                        opcode_tmp[addr_cnt/2] = SI_in;
                                    end
                                    addr_cnt = addr_cnt + 1;
                                    read_cnt = 0;
                                end
                                else if ((Instruct==DDRFR4) ||
                                        ((Instruct==DDRFR) && EXTADD))
                                begin
                                    Address_in[addr_cnt] = SI_in;
                                    if ((addr_cnt/2) <= 16)
                                    begin
                                        opcode_tmp[addr_cnt/2] = SI_in;
                                    end
                                    addr_cnt = addr_cnt + 1;
                                    read_cnt = 0;
                                end
                                else if ((Instruct == DDRDIOR) && (~EXTADD))
                                begin    //Dual I/O DDR Read Mode
                                    Address_in[2*addr_cnt] = SO_in;
                                    Address_in[2*addr_cnt+1]= SI_in;
                                    if ((addr_cnt/2) <= 16)
                                    begin
                                        opcode_tmp[addr_cnt/2] = SI_in;
                                    end
                                    addr_cnt = addr_cnt + 1;
                                    read_cnt = 0;
                                end
                                else if ((Instruct==DDRDIOR4) ||
                                        ((Instruct==DDRDIOR) && EXTADD))
                                begin    //Dual I/O DDR Read Mode
                                    Address_in[2*addr_cnt]   = SO_in;
                                    Address_in[2*addr_cnt+1] = SI_in;
                                    if ((addr_cnt/2) <= 16)
                                    begin
                                        opcode_tmp[addr_cnt/2] = SI_in;
                                    end
                                    addr_cnt = addr_cnt + 1;
                                    read_cnt = 0;
                                end
                                else if ((Instruct==DDRQIOR) && (~EXTADD) && QUAD)
                                begin    //Quad I/O DDR Read Mode
                                    Address_in[4*addr_cnt] = HOLDNeg_in;
                                    Address_in[4*addr_cnt+1] = WPNeg_in;
                                    Address_in[4*addr_cnt+2] = SO_in;
                                    Address_in[4*addr_cnt+3] = SI_in;
                                    opcode_tmp[addr_cnt/2] = SI_in;
                                    addr_cnt = addr_cnt +1;
                                    read_cnt = 0;
                                end
                                else if (QUAD && ((Instruct==DDRQIOR4) ||
                                        ((Instruct==DDRQIOR) && EXTADD)))
                                begin
                                    Address_in[4*addr_cnt] = HOLDNeg_in;
                                    Address_in[4*addr_cnt+1] = WPNeg_in;
                                    Address_in[4*addr_cnt+2] = SO_in;
                                    Address_in[4*addr_cnt+3] = SI_in;
                                    opcode_tmp[addr_cnt/2] = SI_in;
                                    addr_cnt = addr_cnt +1;
                                    read_cnt = 0;
                                end
                            end
                        end

                        MODE_BYTE :
                        begin
                            if (((Instruct==DIOR) || (Instruct == DIOR4))
                                && ((HOLDNeg_in && ~QUAD) || QUAD))
                            begin
                                mode_in[2*mode_cnt] = SO_in;
                                mode_in[2*mode_cnt+1] = SI_in;
                                mode_cnt = mode_cnt + 1;
                                if (mode_cnt == BYTE/2)
                                begin
                                    mode_cnt = 0;
                                    for(i=7;i>=0;i=i-1)
                                    begin
                                        mode_bytes[i] = mode_in[7-i];
                                    end
                                    if (Latency_code == 0 || Latency_code == 3)
                                        bus_cycle_state = DATA_BYTES;
                                    else
                                        bus_cycle_state = DUMMY_BYTES;
                                end
                            end
                            else if (((Instruct==QIOR) || (Instruct == QIOR4))
                                    && QUAD)
                            begin
                                mode_in[4*mode_cnt] = HOLDNeg_in;
                                mode_in[4*mode_cnt+1] = WPNeg_in;
                                mode_in[4*mode_cnt+2] = SO_in;
                                mode_in[4*mode_cnt+3] = SI_in;
                                mode_cnt = mode_cnt + 1;
                                if (mode_cnt == BYTE/4)
                                begin
                                    mode_cnt = 0;
                                    for(i=7;i>=0;i=i-1)
                                    begin
                                        mode_bytes[i] = mode_in[7-i];
                                    end
                                    bus_cycle_state = DUMMY_BYTES;
                                end
                            end
                            else if ((Instruct == DDRFR) || (Instruct == DDRFR4))
                                mode_in[2*mode_cnt] = SI_in;
                            else if ((Instruct==DDRDIOR) || (Instruct==DDRDIOR4))
                            begin
                                mode_in[4*mode_cnt]   = SO_in;
                                mode_in[4*mode_cnt+1] = SI_in;
                            end
                            else if (((Instruct==DDRQIOR) || (Instruct == DDRQIOR4))
                                    && QUAD)
                            begin
                                mode_in[0] = HOLDNeg_in;
                                mode_in[1] = WPNeg_in;
                                mode_in[2] = SO_in;
                                mode_in[3] = SI_in;
                            end
                            dummy_cnt = 0;
                        end

                        DUMMY_BYTES :
                        begin
                            Return_DLP(Instruct, EHP, Latency_code,
                                       dummy_cnt, start_dlp);
                            if (DOUBLE == 1'b1 && (hold_mode==0) &&
                               (VDLR_reg != 8'b00000000) && start_dlp)
                            begin
                                read_out = 1'b1;
                                #10 read_out = 1'b0;
                            end
                            if ((((Instruct==FSTRD) || (Instruct==FSTRD4) ||
                            (Instruct==DOR)  || (Instruct==DOR4)  ||
                            (Instruct==OTPR)) &&
                            ((HOLDNeg_in && ~QUAD) || QUAD)) ||
                            (((Instruct==QOR)||(Instruct==QOR4)) && QUAD))
                            begin
                                dummy_cnt = dummy_cnt + 1;
                                if (dummy_cnt == BYTE)
                                begin
                                    bus_cycle_state = DATA_BYTES;
                                end
                            end

                            else if ((Instruct==DDRFR) || (Instruct==DDRFR4))
                            begin
                                dummy_cnt = dummy_cnt + 1;
                                if (EHP)
                                begin
                                    if (((Latency_code == 3) && (dummy_cnt==1)) ||
                                        ((Latency_code == 0) && (dummy_cnt==2)) ||
                                        ((Latency_code == 1) && (dummy_cnt==4)) ||
                                        ((Latency_code == 2) && (dummy_cnt==5)))
                                    begin
                                        bus_cycle_state = DATA_BYTES;
                                    end
                                end
                                else
                                begin
                                    if (((Latency_code == 3) && (dummy_cnt==4)) ||
                                        ((Latency_code == 0) && (dummy_cnt==5)) ||
                                        ((Latency_code == 1) && (dummy_cnt==6)) ||
                                        ((Latency_code == 2) && (dummy_cnt==7)))
                                    begin
                                        bus_cycle_state = DATA_BYTES;
                                    end
                                end
                            end
                            else if (Instruct==RES)
                            begin
                                dummy_cnt = dummy_cnt + 1;
                                if (dummy_cnt == 3*BYTE)
                                bus_cycle_state = DATA_BYTES;
                            end
                            else if (Instruct==ECCRD)
                            begin
                                dummy_cnt = dummy_cnt + 1;
                                if (dummy_cnt == BYTE)
                                bus_cycle_state = DATA_BYTES;
                            end
                            else if ((Instruct == DIOR) || (Instruct == DIOR4)
                                    && ((HOLDNeg_in && ~QUAD) || QUAD))
                            begin
                                dummy_cnt = dummy_cnt + 1;
                                if (EHP)
                                begin
                                    if (((Latency_code == 1) && (dummy_cnt==1)) ||
                                        ((Latency_code == 2) && (dummy_cnt==2)))
                                        bus_cycle_state = DATA_BYTES;
                                end
                                else
                                begin
                                    if (((Latency_code == 3) && (dummy_cnt==4)) ||
                                        ((Latency_code == 0) && (dummy_cnt==4)) ||
                                        ((Latency_code == 1) && (dummy_cnt==5)) ||
                                        ((Latency_code == 2) && (dummy_cnt==6)))
                                        bus_cycle_state = DATA_BYTES;
                                end
                            end
                            else if ((Instruct==DDRDIOR) || (Instruct==DDRDIOR4))
                            begin
                                dummy_cnt = dummy_cnt + 1;
                                if (EHP)
                                begin
                                    if (((Latency_code == 3) && (dummy_cnt==2)) ||
                                        ((Latency_code == 0) && (dummy_cnt==4)) ||
                                        ((Latency_code == 1) && (dummy_cnt==5)) ||
                                        ((Latency_code == 2) && (dummy_cnt==6)))
                                    begin
                                        bus_cycle_state = DATA_BYTES;
                                    end
                                end
                                else
                                begin
                                    if (((Latency_code == 3) && (dummy_cnt==4)) ||
                                        ((Latency_code == 0) && (dummy_cnt==6)) ||
                                        ((Latency_code == 1) && (dummy_cnt==7)) ||
                                        ((Latency_code == 2) && (dummy_cnt==8)))
                                    begin
                                        bus_cycle_state = DATA_BYTES;
                                    end
                                end
                            end
                            else if (((Instruct == QIOR) || (Instruct == QIOR4))
                                    && QUAD)
                            begin
                                dummy_cnt = dummy_cnt + 1;
                                if (((Latency_code == 3) && (dummy_cnt==1)) ||
                                    ((Latency_code == 0) && (dummy_cnt==4)) ||
                                    ((Latency_code == 1) && (dummy_cnt==4)) ||
                                    ((Latency_code == 2) && (dummy_cnt==5)))
                                begin
                                    bus_cycle_state = DATA_BYTES;
                                end
                            end
                            else if (((Instruct==DDRQIOR) || (Instruct==DDRQIOR4))
                                    && QUAD)
                            begin
                                dummy_cnt = dummy_cnt + 1;

                                if (((Latency_code == 3) && (dummy_cnt==3)) ||
                                    ((Latency_code == 0) && (dummy_cnt==6)) ||
                                    ((Latency_code == 1) && (dummy_cnt==7)) ||
                                    ((Latency_code == 2) && (dummy_cnt==8)))
                                begin
                                    bus_cycle_state = DATA_BYTES;
                                end
                            end
                        end

                        DATA_BYTES :
                        begin

                            if (DOUBLE == 1'b1 && (hold_mode==0))
                            begin
                                read_out = 1'b1;
                                #10 read_out = 1'b0;
                            end

                            if ((QUAD) && ((Instruct==QPP) || (Instruct == QPP4)))
                            begin
                                quad_nybble = {HOLDNeg_in, WPNeg_in, SO_in, SI_in};
                                if (data_cnt > ((PageSize+1)*2-1))
                                begin
                                //In case of quad mode and QPP,
                                //if more than 512 bytes are sent to the device
                                    for(i=0;i<=(PageSize*2-1);i=i+1)
                                    begin
                                        quad_data_in[i] = quad_data_in[i+1];
                                    end
                                    quad_data_in[(PageSize+1)*2-1] = quad_nybble;
                                    data_cnt = data_cnt +1;
                                end
                                else
                                begin
                                    if (quad_nybble !== 4'bZZZZ)
                                    begin
                                        quad_data_in[data_cnt] = quad_nybble;
                                    end
                                    data_cnt = data_cnt +1;
                                end
                            end
                            else if ((~QUADRD) && ((HOLDNeg_in && ~QUAD) || QUAD))
                            begin
                                if (data_cnt > ((PageSize+1)*8-1))
                                begin
                                //In case of serial mode and PP,
                                //if more than PageSize are sent to the device
                                //previously latched data are discarded and last
                                //256/512 data bytes are guaranteed to be programmed
                                //correctly within the same page.
                                    if (bit_cnt == 0)
                                    begin
                                        for(i=0;i<=(PageSize*BYTE-1);i=i+1)
                                        begin
                                            Data_in[i] = Data_in[i+8];
                                        end
                                    end
                                    Data_in[PageSize*BYTE + bit_cnt] = SI_in;
                                    bit_cnt = bit_cnt + 1;
                                    if (bit_cnt == 8)
                                    begin
                                        bit_cnt = 0;
                                    end
                                    data_cnt = data_cnt + 1;
                                end
                                else
                                begin
                                    Data_in[data_cnt] = SI_in;
                                    data_cnt = data_cnt + 1;
                                    bit_cnt = 0;
                                end
                            end
                        end
                    endcase
                end
            end

            if (falling_edge_SCK_ipd)
            begin
                if (~CSNeg_ipd)
                begin
                    case (bus_cycle_state)
                        ADDRESS_BYTES :
                        begin
                            if (DOUBLE == 1'b1)
                            begin
                                if ((Instruct==DDRFR) && (~EXTADD))
                                //Fast DDR Read Mode
                                begin
                                    Address_in[addr_cnt] = SI_in;
                                    if (addr_cnt != 0)
                                    begin
                                        addr_cnt = addr_cnt + 1;
                                    end
                                    read_cnt = 0;
                                    if (addr_cnt == 3*BYTE)
                                    begin
                                        addr_cnt = 0;
                                        for(i=23;i>=0;i=i-1)
                                        begin
                                            addr_bytes[23-i] = Address_in[i];
                                        end
                                        addr_bytes[31:24] = 8'b00000000;
                                        Address = addr_bytes;
                                        change_addr = 1'b1;
                                        #1 change_addr = 1'b0;
                                        if (EHP)
                                            bus_cycle_state = MODE_BYTE;
                                        else
                                            bus_cycle_state = DUMMY_BYTES;
                                    end
                                end
                                else if ((Instruct==DDRFR4) ||
                                        ((Instruct==DDRFR) && EXTADD))
                                begin
                                    Address_in[addr_cnt] = SI_in;
                                    if (addr_cnt != 0)
                                    begin
                                        addr_cnt = addr_cnt + 1;
                                    end
                                    read_cnt = 0;
                                    if (addr_cnt == 4*BYTE)
                                    begin
                                        addr_cnt = 0;
                                        for(i=31;i>=0;i=i-1)
                                        begin
                                            addr_bytes[31-i] = Address_in[i];
                                        end
                                        Address = {8'b00000000,addr_bytes[23:0]};
                                        change_addr = 1'b1;
                                        #1 change_addr = 1'b0;
                                        if (EHP)
                                            bus_cycle_state = MODE_BYTE;
                                        else
                                        begin
                                            bus_cycle_state = DUMMY_BYTES;
                                            if (DOUBLE == 1'b1 && (hold_mode==0)
                                            && VDLR_reg != 8'b00000000)
                                            begin
                                                read_out = 1'b1;
                                                #10 read_out = 1'b0;
                                            end
                                        end
                                    end
                                end
                                else if ((Instruct == DDRDIOR) && (~EXTADD))
                                begin    //Dual I/O DDR Read Mode
                                    Address_in[2*addr_cnt] = SO_in;
                                    Address_in[2*addr_cnt+1]= SI_in;
                                    if (addr_cnt != 0)
                                    begin
                                        addr_cnt = addr_cnt + 1;
                                    end
                                    read_cnt = 0;
                                    if (addr_cnt == 3*BYTE/2)
                                    begin
                                        addr_cnt = 0;
                                        for(i=23;i>=0;i=i-1)
                                        begin
                                            addr_bytes[23-i] = Address_in[i];
                                        end
                                        addr_bytes[31:24] = 8'b00000000;
                                        Address = addr_bytes;
                                        change_addr = 1'b1;
                                        #1 change_addr = 1'b0;
                                        if (EHP)
                                            bus_cycle_state = MODE_BYTE;
                                        else
                                            bus_cycle_state = DUMMY_BYTES;
                                    end
                                end
                                else if ((Instruct==DDRDIOR4) ||
                                        ((Instruct==DDRDIOR) && EXTADD))
                                begin    //Dual I/O DDR Read Mode
                                    Address_in[2*addr_cnt]   = SO_in;
                                    Address_in[2*addr_cnt+1] = SI_in;
                                    if (addr_cnt != 0)
                                    begin
                                        addr_cnt = addr_cnt + 1;
                                    end
                                    read_cnt = 0;
                                    if (addr_cnt == 4*BYTE/2)
                                    begin
                                        addr_cnt = 0;
                                        for(i=31;i>=0;i=i-1)
                                        begin
                                            addr_bytes[31-i] = Address_in[i];
                                        end
                                        Address = {8'b00000000,addr_bytes[23:0]};
                                        change_addr = 1'b1;
                                        #1 change_addr = 1'b0;
                                        if (EHP)
                                            bus_cycle_state = MODE_BYTE;
                                        else
                                        begin
                                            bus_cycle_state = DUMMY_BYTES;
                                            if (DOUBLE == 1'b1 && (hold_mode==0)
                                            && VDLR_reg != 8'b00000000)
                                            begin
                                                read_out = 1'b1;
                                                #10 read_out = 1'b0;
                                            end
                                        end
                                    end
                                end
                                else if ((Instruct==DDRQIOR) && (~EXTADD) && QUAD)
                                begin    //Quad I/O DDR Read Mode
                                    Address_in[4*addr_cnt] = HOLDNeg_in;
                                    Address_in[4*addr_cnt+1] = WPNeg_in;
                                    Address_in[4*addr_cnt+2] = SO_in;
                                    Address_in[4*addr_cnt+3] = SI_in;
                                    if (addr_cnt != 0)
                                    begin
                                        addr_cnt = addr_cnt + 1;
                                    end
                                    read_cnt = 0;
                                    if (addr_cnt == 3*BYTE/4)
                                    begin
                                        addr_cnt = 0;
                                        for(i=23;i>=0;i=i-1)
                                        begin
                                            addr_bytes[23-i] = Address_in[i];
                                        end
                                        addr_bytes[31:24] = 8'b00000000;
                                        Address = addr_bytes;
                                        change_addr = 1'b1;
                                    #1 change_addr = 1'b0;
                                        bus_cycle_state = MODE_BYTE;
                                    end
                                end
                                else if (QUAD && ((Instruct==DDRQIOR4) ||
                                        ((Instruct==DDRQIOR) && EXTADD)))
                                begin
                                    Address_in[4*addr_cnt] = HOLDNeg_in;
                                    Address_in[4*addr_cnt+1] = WPNeg_in;
                                    Address_in[4*addr_cnt+2] = SO_in;
                                    Address_in[4*addr_cnt+3] = SI_in;
                                    if (addr_cnt != 0)
                                    begin
                                        addr_cnt = addr_cnt + 1;
                                    end
                                    read_cnt = 0;
                                    if (addr_cnt == 4*BYTE/4)
                                    begin
                                        addr_cnt = 0;
                                        for(i=31;i>=0;i=i-1)
                                        begin
                                            addr_bytes[31-i] = Address_in[i];
                                        end
                                        Address = {8'b00000000,addr_bytes[23:0]};
                                        change_addr = 1'b1;
                                        #1 change_addr = 1'b0;
                                        bus_cycle_state = MODE_BYTE;
                                    end
                                end
                            end
                        end

                        MODE_BYTE :
                        begin
                            if ((Instruct == DDRFR) || (Instruct == DDRFR4))
                            begin
                                mode_in[2*mode_cnt+1] = SI_in;
                                mode_cnt = mode_cnt + 1;
                                if (mode_cnt == BYTE/2)
                                begin
                                    mode_cnt = 0;
                                    for(i=7;i>=0;i=i-1)
                                    begin
                                        mode_bytes[i] = mode_in[7-i];
                                    end
                                    bus_cycle_state = DUMMY_BYTES;
                                    Return_DLP(Instruct, EHP, Latency_code,
                                               dummy_cnt, start_dlp);
                                    if (DOUBLE == 1'b1 && (hold_mode==0) &&
                                       (VDLR_reg != 8'b00000000) && start_dlp)
                                    begin
                                        read_out = 1'b1;
                                        #10 read_out = 1'b0;
                                    end
                                end
                            end
                            else if ((Instruct==DDRDIOR) || (Instruct==DDRDIOR4))
                            begin
                                mode_in[4*mode_cnt+2] = SO_in;
                                mode_in[4*mode_cnt+3] = SI_in;
                                mode_cnt = mode_cnt + 1;
                                if (mode_cnt == BYTE/4)
                                begin
                                    mode_cnt = 0;
                                    for(i=7;i>=0;i=i-1)
                                    begin
                                        mode_bytes[i] = mode_in[7-i];
                                    end
                                    bus_cycle_state = DUMMY_BYTES;
                                    Return_DLP(Instruct, EHP, Latency_code,
                                               dummy_cnt, start_dlp);
                                    if (DOUBLE == 1'b1 && (hold_mode==0) &&
                                       (VDLR_reg != 8'b00000000) && start_dlp)
                                    begin
                                        read_out = 1'b1;
                                        #10 read_out = 1'b0;
                                    end
                                end
                            end
                            else if ((Instruct==DDRQIOR) || (Instruct==DDRQIOR4))
                            begin
                                mode_in[4] = HOLDNeg_in;
                                mode_in[5] = WPNeg_in;
                                mode_in[6] = SO_in;
                                mode_in[7] = SI_in;
                                for(i=7;i>=0;i=i-1)
                                begin
                                    mode_bytes[i] = mode_in[7-i];
                                end
                                bus_cycle_state = DUMMY_BYTES;
                                Return_DLP(Instruct, EHP, Latency_code,
                                               dummy_cnt, start_dlp);
                                if (DOUBLE == 1'b1 && (hold_mode==0) &&
                                    (VDLR_reg != 8'b00000000) && start_dlp)
                                begin

                                    read_out = 1'b1;
                                    #10 read_out = 1'b0;
                                end
                            end
                        end

                        DATA_BYTES:
                        begin
                            if (hold_mode==0)
                            begin
                                if (DOUBLE == 1'b1 )
                                begin
                                    read_out = 1'b1;
                                    #10 read_out = 1'b0;

                                end
                                else
                                begin
                                    if ((Instruct==READ) || (Instruct==RD4)   ||
                                        (Instruct==FSTRD)|| (Instruct==FSTRD4)||
                                        (Instruct==RDSR) || (Instruct==RDSR2) ||
                                        (Instruct==RDCR) || (Instruct==OTPR)  ||
                                        (Instruct==DOR) || (Instruct==DOR4) ||
                                        (Instruct==DIOR)|| (Instruct==DIOR4)||
                                        (Instruct==ABRD) || (Instruct==BRRD)  ||
                                        (Instruct==ASPRD)|| (Instruct==DYBRD) ||
                                        (Instruct==PPBRD)|| (Instruct == ECCRD) ||
                                        (Instruct==PASSRD)|| (Instruct==RDID)||
                                        (Instruct==RES) || (Instruct==REMS)  ||
                                        (Instruct==PLBRD)|| (Instruct==DLPRD) ||
                                        (current_state == AUTOBOOT &&
                                        start_delay == 0) ||
                                        (((Instruct==QOR) || (Instruct==QIOR) ||
                                        (Instruct==QOR4) ||
                                        (Instruct==QIOR4)) && QUAD))
                                    begin
                                        read_out = 1'b1;
                                        #10 read_out = 1'b0;
                                    end
                                end
                            end
                        end

                        DUMMY_BYTES:
                        begin
                            if (hold_mode==0)
                            begin
                                Return_DLP(Instruct, EHP, Latency_code,
                                           dummy_cnt, start_dlp);

                                if (DOUBLE == 1'b1 && VDLR_reg != 8'b00000000 &&
                                    start_dlp)
                                begin
                                    read_out = 1'b1;
                                    #10 read_out = 1'b0;
                                end
                            end
                        end

                    endcase
                end
            end

            if (rising_edge_CSNeg_ipd)
            begin
                if (bus_cycle_state != DATA_BYTES)
                begin
                    if (bus_cycle_state == ADDRESS_BYTES && opcode_tmp == 8'hFF)
                    begin
                        Instruct = MBR;
                    end
                    bus_cycle_state = STAND_BY;
                end
                else
                begin
                    if (bus_cycle_state == DATA_BYTES)
                    begin
                        if (((mode_bytes[7:4] == 4'b1010) &&
                            (Instruct==DIOR || Instruct==DIOR4 ||
                            Instruct==QIOR || Instruct==QIOR4)) ||
                            ((mode_bytes[7:4] == ~mode_bytes[3:0]) &&
                            (Instruct == DDRFR  || Instruct == DDRFR4  ||
                            Instruct == DDRDIOR || Instruct == DDRDIOR4 ||
                            Instruct == DDRQIOR || Instruct == DDRQIOR4)))
                            bus_cycle_state = ADDRESS_BYTES;
                        else
                            bus_cycle_state = STAND_BY;

                        case (Instruct)
                            WREN,
                            WRDI,
                            BE,
                            SE,
                            SE4,
                            P4E,
                            P4E4,
                            CLSR,
                            BRAC,
                            RESET,
                            PPBERS,
                            PPBP,
                            PLBWR,
                            PGSP,
                            PGRS,
                            ERSP,
                            ERRS:
                            begin
                                if ((HOLDNeg_in && ~QUAD) || QUAD)
                                begin
                                    if (data_cnt == 0)
                                        write = 1'b0;
                                end
                            end

                            WRR:
                            begin
                                if ((HOLDNeg_in && ~QUAD) || QUAD)
                                begin
                                    if (data_cnt == 8)
                                    //If CS# is driven high after eight
                                    //cycle,only the Status Register is
                                    //written to.
                                    begin
                                        write = 1'b0;
                                        for(i=0;i<=7;i=i+1)
                                        begin
                                            Status_reg1_in[i]=
                                            Data_in[7-i];
                                        end
                                    end
                                    else if (data_cnt == 16)
                                    //After the 16th cycle both the
                                    //Status and Configuration Registers
                                    //are written to.
                                    begin
                                        write = 1'b0;
                                        cfg_write = 1'b1;
                                        for(i=0;i<=7;i=i+1)
                                        begin
                                            Status_reg1_in[i]=
                                            Data_in[7-i];
                                            Config_reg1_in[i]=
                                            Data_in[15-i];
                                        end
                                    end
                                end
                            end

                            PP,
                            PP4,
                            OTPP:
                            begin
                                if ((HOLDNeg_in && ~QUAD) || QUAD)
                                begin
                                    if (data_cnt > 0)
                                    begin
                                        if ((data_cnt % 8) == 0)
                                        begin
                                            write = 1'b0;
                                            for(i=0;i<=PageSize;i=i+1)
                                            begin
                                                for(j=7;j>=0;j=j-1)
                                                begin
                                                    if ((Data_in[(i*8)+(7-j)])
                                                        !== 1'bX)
                                                    begin
                                                        Byte_slv[j] =
                                                        Data_in[(i*8)+(7-j)];
                                                    end
                                                end
                                                WByte[i] = Byte_slv;
                                            end

                                            if (data_cnt > (PageSize+1)*BYTE)
                                                Byte_number = PageSize;
                                            else
                                                Byte_number =
                                                    ((data_cnt/8) - 1);
                                        end
                                    end
                                end
                            end

                            QPP,
                            QPP4:
                            begin
                                if (data_cnt >0)
                                begin
                                    if ((data_cnt % 2) == 0)
                                    begin
                                        write = 1'b0;
                                        quad_pg = 1'b0;
                                        for(i=0;i<=PageSize;i=i+1)
                                        begin
                                            for(j=1;j>=0;j=j-1)
                                            begin
                                                Quad_slv =
                                                quad_data_in[(i*2)+(1-j)];
                                                if (j==1)
                                                    Byte_slv[7:4] = Quad_slv;
                                                else if (j==0)
                                                    Byte_slv[3:0] = Quad_slv;
                                            end
                                            WByte[i] = Byte_slv;
                                        end
                                        if (data_cnt > (PageSize+1)*2)
                                            Byte_number = PageSize;
                                        else
                                            Byte_number = ((data_cnt/2)-1);
                                    end
                                end
                            end

                            ABWR:
                            begin
                                if ((HOLDNeg_in && ~QUAD) || QUAD)
                                begin
                                    if (data_cnt == 32)
                                    begin
                                        write = 1'b0;
                                        for(j=0;j<=31;j=j+1)
                                        begin
                                            AutoBoot_reg_in[j] = Data_in[31-j];
                                        end
                                    end
                                end
                            end

                            BRWR:
                            begin
                                if ((HOLDNeg_in && ~QUAD) || QUAD)
                                begin
                                    if (data_cnt == 8)
                                    begin
                                        write = 1'b0;
                                        for(j=0;j<=7;j=j+1)
                                        begin
                                            Bank_Addr_reg_in[j] = Data_in[7-j];
                                        end
                                    end
                                end
                            end

                            ASPP:
                            begin
                                if ((HOLDNeg_in && ~QUAD) || QUAD)
                                begin
                                    if (data_cnt == 16)
                                    begin
                                        write = 1'b0;
                                        for(j=0;j<=15;j=j+1)
                                        begin
                                            ASP_reg_in[j] = Data_in[15-j];
                                        end
                                    end
                                end
                            end

                            DYBWR:
                            begin
                                if ((HOLDNeg_in && ~QUAD) || QUAD)
                                begin
                                    if (data_cnt == 8)
                                    begin
                                        write = 1'b0;
                                        for(j=0;j<=7;j=j+1)
                                        begin
                                            DYBAR_in[j] = Data_in[7-j];
                                        end
                                    end
                                end
                            end

                            PNVDLR:
                            begin
                                if ((HOLDNeg_in && ~QUAD) || QUAD)
                                begin
                                    if (data_cnt == 8)
                                    begin
                                        write = 1'b0;
                                        for(j=0;j<=7;j=j+1)
                                        begin
                                            NVDLR_reg_in[j] = Data_in[7-j];
                                        end
                                    end
                                end
                            end

                            WVDLR:
                            begin
                                if ((HOLDNeg_in && ~QUAD) || QUAD)
                                begin
                                    if (data_cnt == 8)
                                    begin
                                        write = 1'b0;
                                        for(j=0;j<=7;j=j+1)
                                        begin
                                            VDLR_reg_in[j] = Data_in[7-j];
                                        end
                                    end
                                end
                            end

                            PASSP:
                            begin
                                if ((HOLDNeg_in && ~QUAD) || QUAD)
                                begin
                                    if (data_cnt == 64)
                                    begin
                                        write = 1'b0;
                                        for(j=1;j<=8;j=j+1)
                                        begin
                                            for(k=1;k<=8;k=k+1)
                                            begin
                                                Password_reg_in[j*8-k] =
                                                            Data_in[8*(j-1)+k-1];
                                            end
                                        end
                                    end
                                end
                            end

                            PASSU:
                            begin
                                if ((HOLDNeg_in && ~QUAD) || QUAD)
                                begin
                                    if (data_cnt == 64)
                                    begin
                                        write = 1'b0;
                                        for(j=1;j<=8;j=j+1)
                                        begin
                                            for(k=1;k<=8;k=k+1)
                                            begin
                                                PASS_TEMP[j*8-k] =
                                                            Data_in[8*(j-1)+k-1];
                                            end
                                        end
                                    end
                                end
                            end
                        endcase
                    end
                end
            end
        end
    end

///////////////////////////////////////////////////////////////////////////////
// Timing control for the Page Program
///////////////////////////////////////////////////////////////////////////////
    time pob;
    time elapsed_pgm;
    time elapsed_tsu;
    time start_pgm;
    time start_tsu;
    time duration_pgm;
    time duration_tsu;
    event pdone_event;

    always @(rising_edge_PSTART)
    begin
        if ((Instruct == PP) || (Instruct == PP4) || (Instruct == OTPP) ||
           (Instruct == QPP) || (Instruct == QPP4))
            if (PageSize == 255)
            begin
                pob = tdevice_PP_256;
            end
            else
            begin
                pob = tdevice_PP_512;
            end
        else
            pob = tdevice_BP;
        if ((rising_edge_PSTART) && PDONE)
        begin
            elapsed_pgm = 0;
            duration_pgm = pob;
            PDONE = 1'b0;
            ->pdone_event;
            start_pgm = $time;
        end
    end

    always @(posedge PGSUSP)
    begin
        if (PGSUSP && (~PDONE))
        begin
            disable pdone_process;
            elapsed_pgm = $time - start_pgm;
            duration_pgm = pob - elapsed_pgm;
            PDONE = 1'b0;
        end
    end

    always @(posedge PGRES)
    begin
        start_pgm = $time;
        ->pdone_event;
    end

    always @(pdone_event)
    begin:pdone_process
        PDONE = 1'b0;
        #duration_pgm PDONE = 1'b1;
    end

    always @(SI)
    begin
        if ((Instruct == PGSP) || (Instruct == PGRS) ||
           (Instruct == ERSP) || (Instruct == ERRS))
        begin
            start_tsu = $time;
        end
    end

    always @(posedge SCK)
    begin
        if ((Instruct == PGSP) || (Instruct == PGRS) ||
           (Instruct == ERSP) || (Instruct == ERRS))
        begin
            elapsed_tsu = $time - start_tsu;
            duration_tsu = tdevice_TSU - elapsed_tsu;
            if (duration_tsu > 0)
            begin
                TSU = 1'b0;
            end
            else
            begin
                TSU = 1'b1;
                $display("Warning at", $time);
                $display("tSU max time violation");
            end
        end
    end
///////////////////////////////////////////////////////////////////////////////
// Timing control for the Write Status Register
///////////////////////////////////////////////////////////////////////////////
    time wob;
    always @(posedge WSTART)
    begin:wdone_process
        wob = tdevice_WRR;
        if (WSTART && WDONE)
        begin
            WDONE = 1'b0;
            #wob WDONE = 1'b1;
        end
    end

///////////////////////////////////////////////////////////////////////////////
// Reset Timing
///////////////////////////////////////////////////////////////////////////////

    time startlo;
    time starthi;
    time durationlo;
    time durationhi;

    always @(negedge RSTNeg_in or Instruct)
    begin
        if (~RSTNeg_in)
        begin
            RST = 1'b1;
            #200000 RST = 1'b0;  // 200 ns
        end
        else if (Instruct == RESET)
        begin
            Reseted = 1'b0;
            #10000 Reseted = 1'b1;   //  10 ns
        end
    end

    always @(RST_in or rising_edge_Reseted) // Reset done,program terminated
    begin
        if ((RST_in && ~RST) || (rising_edge_Reseted))
            disable pdone_process;
            disable edone_process;
            disable wdone_process;
            PDONE = 1'b1;
            EDONE = 1'b1;
            WDONE = 1'b1;
    end

///////////////////////////////////////////////////////////////////////////////
// Timing control for the Bulk Erase
///////////////////////////////////////////////////////////////////////////////
    time seo;
    time beo;
    event edone_event;
    time elapsed_ers;
    time start_ers;
    time duration_ers;

    always @(rising_edge_ESTART)
    begin
        if (UniformSec)
        begin
            seo = tdevice_SE256;
        end
        else
        begin
            seo = tdevice_SE64;
        end
        beo = tdevice_BE;
        if ((rising_edge_ESTART) && EDONE)
        begin
            if (Instruct == BE)
            begin
                duration_ers = beo;
            end
            else
            begin
                duration_ers = seo;
            end
            elapsed_ers = 0;
            EDONE = 1'b0;
            ->edone_event;
            start_ers = $time;
        end
    end

    always @(posedge ESUSP)
    begin
        if (ESUSP && (~EDONE))
        begin
            disable edone_process;
            elapsed_ers = $time - start_ers;
            duration_ers = seo - elapsed_ers;
            EDONE = 1'b0;
        end
    end

    always @(posedge ERES)
    begin
        if  (ERES && (~EDONE))
        begin
            start_ers = $time;
            ->edone_event;
        end
    end

    always @(edone_event)
    begin : edone_process
        EDONE = 1'b0;
        #duration_ers EDONE = 1'b1;
    end

    ///////////////////////////////////////////////////////////////////
    // Process for clock frequency determination
    ///////////////////////////////////////////////////////////////////
    always @(posedge SCK_ipd)
    begin : clock_period
        if (SCK_ipd)
        begin
            SCK_cycle = $time - prev_SCK;
            prev_SCK = $time;
        end
    end

//    /////////////////////////////////////////////////////////////////////////
//    // Main Behavior Process
//    // combinational process for next state generation
//    /////////////////////////////////////////////////////////////////////////

    reg rising_edge_PDONE = 1'b0;
    reg rising_edge_EDONE = 1'b0;
    reg rising_edge_WDONE = 1'b0;
    reg falling_edge_write = 1'b0;
    reg falling_edge_PPBERASE_in = 1'b0;
    reg falling_edge_PASSULCK_in = 1'b0;

    integer i;
    integer j;

    always @(rising_edge_PoweredUp or falling_edge_write or
             falling_edge_RSTNeg or rising_edge_PDONE or rising_edge_WDONE or
             rising_edge_EDONE or ERSSUSP_out_event or rising_edge_RSTNeg or
             PRGSUSP_out_event or rising_edge_CSNeg_ipd or rising_edge_RST_out
             or falling_edge_PPBERASE_in or falling_edge_PASSULCK_in or RST_out)
    begin: StateGen1

        integer sect;

        if (rising_edge_PoweredUp && RSTNeg_in && RST_out)
        begin
            if (ABE == 1 && RPME !== 0 )
            begin
                next_state     = AUTOBOOT;
                read_cnt       = 0;
                byte_cnt       = 1;
                read_addr      = {AutoBoot_reg[31:9], 9'b0};
                start_delay    = AutoBoot_reg[8:1];
                start_autoboot = 0;
                ABSD           = AutoBoot_reg[8:1];
            end
            else
                next_state = IDLE;
        end
        else if (PoweredUp)
        begin
            if (RST_out == 1'b0)
                next_state = current_state;
            else if (falling_edge_write && Instruct == RESET)
            begin
                if (ABE == 1 && RPME !== 0)
                begin
                    read_cnt       = 0;
                    byte_cnt       = 1;
                    read_addr      = {AutoBoot_reg[31:9], 9'b0};
                    start_delay    = AutoBoot_reg[8:1];
                    ABSD           = AutoBoot_reg[8:1];
                    start_autoboot = 0;
                    next_state     = AUTOBOOT;
                end
                else
                    next_state = IDLE;
            end
            else 
            begin
                case (current_state)
                    RESET_STATE :
                    begin
                        if ((rising_edge_RST_out && RSTNeg_in) ||
                        (rising_edge_RSTNeg && RST_out))
                        begin
                            if (ABE == 1 && RPME!== 0)
                            begin
                                next_state = AUTOBOOT;
                                read_cnt       = 0;
                                byte_cnt       = 1;
                                read_addr      = {AutoBoot_reg[31:9],9'b0};
                                start_delay    = AutoBoot_reg[8:1];
                                start_autoboot = 0;
                                ABSD           = AutoBoot_reg[8:1];
                            end
                            else
                                next_state = IDLE;
                        end
                    end

                    IDLE :
                    begin
                        if (falling_edge_write && RdPswdProtMode == 0)
                        begin
                            if (Instruct == WRR && WEL == 1 && BAR_ACC == 0
                            && (((~(SRWD == 1 && ~WPNeg_in))&& ~QUAD) || QUAD))
                            // can not execute if HPM is entered or
                            // if WEL bit is zero
                                if (((TBPROT==1 && Config_reg1_in[5]==1'b0) ||
                                     (TBPARM==1 && Config_reg1_in[2]==1'b0) ||
                                     (BPNV  ==1 && Config_reg1_in[3]==1'b0)) &&
                                     cfg_write)
                                begin
                                    $display ("WARNING: Changing value of ");
                                    $display ("Configuration Register OTP ");
                                    $display ("bit from 1 to 0 is not");
                                    $display ("allowed!!!");
                                end
                                else
                                begin
                                    next_state = WRITE_SR;
                                end
                            else if (Instruct == WRR && BAR_ACC == 1)
                            begin
                            // Write to the lower address bits of the BAR
                                if (P_ERR == 0 && E_ERR == 0)
                                begin
                                    $display ("WARNING: Changing values of ");
                                    $display ("Bank Address Register");
                                    $display ("RFU bits are not allowed!!!");
                                end
                            end
                            else if ((Instruct == PP || Instruct == QPP ||
                                      Instruct == PP4 || Instruct == QPP4) &&
                                      WEL == 1)
                            begin
                                ReturnSectorID(sect,Address);
                                pgm_page = Address / (PageSize+1);
                                if (Sec_Prot[sect]== 0 && PPB_bits[sect]== 1 &&
                                    DYB_bits[sect]== 1)
                                begin
                                    next_state = PAGE_PG;
                                end
                            end
                            else if (Instruct==OTPP && WEL==1 && FREEZE==0)
                            begin
                                if (((((Address>=16'h0010 && Address<=16'h0013)
                                    ||(Address>=16'h0020 && Address<=16'h00FF))
                                    && LOCK_BYTE1[Address/32] == 1) ||
                                    ((Address>=16'h0100 && Address<=16'h01FF)
                                    && LOCK_BYTE2[(Address-16'h0100)/32]==1) ||
                                    ((Address>=16'h0200 && Address<=16'h02FF)
                                    && LOCK_BYTE3[(Address-16'h0200)/32]==1) ||
                                    ((Address>=16'h0300 && Address<=16'h03FF)
                                    && LOCK_BYTE4[(Address-16'h0300)/32] == 1))
                                    && (Address + Byte_number <= OTPHiAddr))
                                next_state =  OTP_PG;
                            end
                            else if ((Instruct == SE || Instruct == SE4)
                                    && WEL == 1)
                            begin
                                ReturnSectorID(sect,Address);
                                if (UniformSec || (TopBoot && sect < 254) ||
                                   (BottomBoot && sect > 31))
                                begin
                                    if (Sec_Prot[sect]== 0 && PPB_bits[sect]== 1
                                         && DYB_bits[sect]== 1)
                                        next_state =  SECTOR_ERS;
                                end
                                else if ((TopBoot && sect >= 254) ||
                                        (BottomBoot && sect <= 31))
                                begin
                                    if (Sec_ProtSE == 32 && ASP_ProtSE == 32)
                                    //Sector erase command is applied to a
                                    //64 KB range that includes 4 KB sectors.
                                        next_state =  SECTOR_ERS;
                                end
                            end
                            else if ((Instruct == P4E || Instruct == P4E4)
                                    && WEL == 1)
                            begin
                                if (UniformSec || (TopBoot && sect < 254) ||
                                   (BottomBoot && sect > 31))
                                begin
                                    $display("The instruction is applied to");
                                    $display("a sector that is larger than");
                                    $display("4 KB.");
                                    $display("Instruction is ignored!!!");
                                end
                                else
                                begin
                                     if (Sec_Prot[sect]== 0 &&
                                      PPB_bits[sect]== 1 && DYB_bits[sect]== 1)
                                        next_state =  SECTOR_ERS;
                                end
                            end
                            else if (Instruct == BE && WEL == 1 &&
                                (Status_reg1[4]== 0 && Status_reg1[3]== 0 &&
                                    Status_reg1[2]== 0))
                                next_state = BULK_ERS;
                            else if (Instruct == ABWR && WEL == 1)
                                //Autoboot Register Write Command
                                next_state = AUTOBOOT_PG;
                            else if (Instruct == BRWR)
                                //Bank Register Write Command
                                next_state = IDLE;
                            else if (Instruct == ASPP && WEL == 1)
                            begin
                                //ASP Register Program Command
                                if (~(ASPOTPFLAG))
                                    next_state = ASP_PG;
                            end
                            else if (Instruct == PLBWR && WEL == 1 &&
                                     RdPswdProtEnable == 0)
                                next_state = PLB_PG;
                            else if (Instruct == PASSP && WEL == 1)
                            begin
                                if (~(PWDMLB== 0 && PSTMLB== 1))
                                    next_state = PASS_PG;
                            end
                            else if (Instruct == PASSU && WEL && ~WIP)
                                next_state = PASS_UNLOCK;
                            else if (Instruct == PPBP && WEL == 1)
                                next_state <= PPB_PG;
                            else if (Instruct == PPBERS && WEL && PPBOTP)
                                next_state <= PPB_ERS;
                            else if (Instruct == DYBWR && WEL == 1)
                                next_state = DYB_PG;
                            else if (Instruct == PNVDLR && WEL == 1)
                                next_state = NVDLR_PG;
                            else
                                next_state = IDLE;
                        end
                        if (falling_edge_write && RdPswdProtMode == 1 && ~WIP)
                        begin
                            if (Instruct == PASSU)
                                next_state = PASS_UNLOCK;
                        end
                    end

                    AUTOBOOT :
                    begin
                        if (rising_edge_CSNeg_ipd)
                            next_state = IDLE;
                    end

                    WRITE_SR :
                    begin
                        if (rising_edge_WDONE)
                            next_state = IDLE;
                    end

                    PAGE_PG :
                    begin
                        if (PRGSUSP_out_event && PRGSUSP_out == 1)
                            next_state = PG_SUSP;
                        else if (rising_edge_PDONE)
                            next_state = IDLE;
                    end

                    PG_SUSP :
                    begin
                        if (falling_edge_write)
                        begin
                            if (Instruct == BRWR)
                                //Bank Register Write Command
                                next_state = PG_SUSP;
                            else if (Instruct == PGRS)
                                next_state = PAGE_PG;
                        end
                    end

                    OTP_PG :
                    begin
                        if (rising_edge_PDONE)
                            next_state = IDLE;
                    end

                    BULK_ERS :
                    begin
                        if (rising_edge_EDONE)
                            next_state = IDLE;
                    end

                    SECTOR_ERS :
                    begin
                        if (ERSSUSP_out_event && ERSSUSP_out == 1)
                            next_state = ERS_SUSP;
                        else if (rising_edge_EDONE)
                            next_state = IDLE;
                    end

                    ERS_SUSP :
                    begin
                        if (falling_edge_write)
                        begin
                            if ((Instruct == PP || Instruct == QPP ||
                                 Instruct == PP4 || Instruct == QPP4) &&
                                 WEL == 1)
                            begin
                                if ((PARAM_REGION &&
                                     SectorSuspend != Address/(SecSize+1)) ||
                                   (~PARAM_REGION && SectorSuspend !=
                                     Address/(SecSize+1)+30*b_act))
                                begin
                                    ReturnSectorID(sect,Address);
                                    pgm_page = Address / (PageSize+1);
                                    if (PPB_bits[sect]== 1 &&
                                        DYB_bits[sect]== 1)
                                    begin
                                        next_state = ERS_SUSP_PG;
                                    end
                                end
                            end
                            else if (Instruct == BRWR)
                            begin
                                //Bank Register Write Command
                                next_state = ERS_SUSP;
                            end
                            else if (Instruct == DYBWR && WEL == 1)
                                next_state = DYB_PG;
                            else if  (Instruct == ERRS)
                                next_state = SECTOR_ERS;
                        end
                    end

                    ERS_SUSP_PG :
                    begin
                        if (rising_edge_PDONE)
                            next_state = ERS_SUSP;
                        else if (PRGSUSP_out_event && PRGSUSP_out == 1)
                            next_state = ERS_SUSP_PG_SUSP;
                    end

                    ERS_SUSP_PG_SUSP :
                    begin
                        if (rising_edge_PDONE)
                            next_state = ERS_SUSP;
                        if (falling_edge_write)
                        begin
                            if (Instruct == BRWR)
                            begin
                                next_state =  ERS_SUSP_PG_SUSP;
                            end
                            else if (Instruct == PGRS)
                            begin
                                next_state =  ERS_SUSP_PG;
                            end
                        end
                    end

                    PASS_PG :
                    begin
                    if (rising_edge_PDONE)
                        next_state = IDLE;
                    end

                    PASS_UNLOCK :
                    begin
                    if (falling_edge_PASSULCK_in)
                        next_state = IDLE;
                    end

                    PPB_PG :
                    begin
                    if (rising_edge_PDONE)
                        next_state = IDLE;
                    end

                    PPB_ERS :
                    begin
                    if (falling_edge_PPBERASE_in)
                        next_state = IDLE;
                    end

                    AUTOBOOT_PG :
                    begin
                    if (rising_edge_PDONE)
                        next_state = IDLE;
                    end

                    PLB_PG :
                    begin
                    if (rising_edge_PDONE)
                        next_state = IDLE;
                    end

                    DYB_PG :
                    begin
                    if (rising_edge_PDONE)
                        if (ES)
                            next_state = ERS_SUSP;
                        else
                            next_state = IDLE;
                    end

                    ASP_PG :
                    begin
                    if (rising_edge_PDONE)
                        next_state = IDLE;
                    end
                                        
                    NVDLR_PG :
                    begin
                    if (rising_edge_PDONE)
                        next_state = IDLE;
                    end

                endcase
            end
        end
    end

    ///////////////////////////////////////////////////////////////////////////
    //FSM Output generation and general functionality
    ///////////////////////////////////////////////////////////////////////////
    reg rising_edge_read_out = 1'b0;
    reg Instruct_event       = 1'b0;
    reg change_addr_event    = 1'b0;
    reg current_state_event  = 1'b0;
    reg rising_edge_DP_out   = 1'b0;

    integer WData [0:511];
    integer WOTPData;
    integer Addr;
    integer Addr_tmp;

    always @(Instruct_event)
    begin
        read_cnt = 0;
        byte_cnt = 1;
        rd_fast  = 1'b1;
        dual     = 1'b0;
        rd_slow  = 1'b0;
        any_read = 1'b0;
    end

    always @(rising_edge_read_out)
    begin
        if (rising_edge_read_out == 1'b1)
        begin
            if (PoweredUp == 1'b1)
            begin
                oe_z = 1'b1;
                #1000 oe_z = 1'b0;
                oe = 1'b1;
                #1000 oe = 1'b0;
            end
        end
    end

    always @(change_addr_event)
    begin
        if (change_addr_event)
        begin
            read_addr = Address;
        end
    end

    always @(posedge PASSACC_out)
    begin
        Status_reg1[0] = 1'b0; //WIP
        PASSACC_in = 1'b0;
    end

    always @(Instruct or posedge start_autoboot or oe or current_state_event or
             falling_edge_write or posedge PDONE or posedge WDONE or oe_z or
             posedge EDONE or ERSSUSP_out or rising_edge_Reseted or
             rising_edge_PoweredUp or rising_edge_CSNeg_ipd or PRGSUSP_out or
             Address)
    begin: Functionality
    integer i,j;
    integer sect;

        if (rising_edge_PoweredUp)
        begin
            //the default condition after power-up
            //The Bank Address Register is loaded to all zeroes
            Bank_Addr_reg = 8'h0;
            //The Configuration Register FREEZE bit is cleared.
            Config_reg1[0] = 0;
            //The WEL bit is cleared.
            Status_reg1[1] = 0;
            //When BPNV is set to '1'. the BP2-0 bits in Status Register are
            //volatile and will be reset binary 111 after power-on reset
            if (BPNV == 1  && FREEZE == 0 ) //&& LOCK == 0
            begin
                Status_reg1[4] = 1'b0;// BP2
                Status_reg1[3] = 1'b0;// BP1
                Status_reg1[2] = 1'b0;// BP0
                BP_bits = {Status_reg1[4],Status_reg1[3],Status_reg1[2]};
                change_BP = 1'b1;
                #1000 change_BP = 1'b0;
            end

            //As shipped from the factory, all devices default ASP to the
            //Persistent Protection mode, with all sectors unprotected,
            //when power is applied. The device programmer or host system must
            //then choose which sector protection method to use.
            //For Persistent Protection mode, PPBLOCK defaults to "1"
            PPBL[0] = 1'b1;

            //All the DYB power-up in the unprotected state
            DYB_bits = {286{1'b1}};
        end

        if (Instruct == RESET)
        begin
            //EXTADD is cleared to “0”
            Bank_Addr_reg[7] = 1'b0;
            //P_ERR bit is cleared
            Status_reg1[6] = 1'b0;
            //E_ERR bit is cleared
            Status_reg1[5] = 1'b0;
            //The WEL bit is cleared.
            Status_reg1[1] = 1'b0;
            //The WIP bit is cleared.
            Status_reg1[0] = 1'b0;
            //The ES bit is cleared.
            Status_reg2[1] = 1'b0;
            //The PS bit is cleared.
            Status_reg2[0] = 1'b0;
            //When BPNV is set to '1'. the BP2-0 bits in Status
            //Register are volatile and will be reseted after
            //reset command
            if (BPNV == 1  && FREEZE == 0) //&& LOCK== 0
            begin
                Status_reg1[4] = 1'b1;
                Status_reg1[3] = 1'b1;
                Status_reg1[2] = 1'b1;

                BP_bits = {Status_reg1[4],Status_reg1[3],
                        Status_reg1[2]};
                change_BP = 1'b1;
                #1000 change_BP = 1'b0;
            end
        end

        case (current_state)
            IDLE :
            begin
                rd_fast = 1'b1;
                rd_slow = 1'b0;
                dual    = 1'b0;
                ddr     = 1'b0;
                ASP_ProtSE = 0;
                Sec_ProtSE = 0;

                if (BottomBoot)
                begin
                    for (j=31;j>=0;j=j-1)
                    begin
                        if (PPB_bits[j] == 1 && DYB_bits[j] == 1)
                        begin
                            ASP_ProtSE = ASP_ProtSE + 1;
                        end
                        if (Sec_Prot[j] == 0)
                        begin
                            Sec_ProtSE = Sec_ProtSE + 1;
                        end
                    end
                end
                else if (TopBoot)
                begin
                    for (j=285;j>=254;j=j-1)
                    begin
                        if (PPB_bits[j] == 1 && DYB_bits[j] == 1)
                        begin
                            ASP_ProtSE = ASP_ProtSE + 1;
                        end
                        if (Sec_Prot[j] == 0)
                        begin
                            Sec_ProtSE = Sec_ProtSE + 1;
                        end
                    end
                end

                if (falling_edge_write && RdPswdProtMode == 1)
                begin
                    if(Instruct == PASSU)
                    begin
                        if (~WIP)
                        begin
                            PASSULCK_in = 1;
                            Status_reg1[0] = 1'b1; //WIP
                        end
                        else
                        begin
                            $display ("The PASSU command cannot be accepted");
                            $display (" any faster than once every 100us");
                        end
                    end
                    else if (Instruct == CLSR)
                    begin
                    //The Clear Status Register Command resets bit SR1[5]
                    //(Erase Fail Flag) and bit SR1[6] (Program Fail Flag)
                        Status_reg1[5] = 0;
                        Status_reg1[6] = 0;
                    end
                end

                if (falling_edge_write && RdPswdProtMode == 0)
                begin
                    read_cnt = 0;
                    byte_cnt = 1;
                    if (Instruct == WREN)
                        Status_reg1[1] = 1'b1;
                    else if (Instruct == WRDI)
                        Status_reg1[1] = 0;
                    else if ((Instruct == WRR) && WEL == 1 && WDONE == 1 &&
                              BAR_ACC == 0)
                    begin
                        if (((~(SRWD == 1 && ~WPNeg_in))&& ~QUAD) || QUAD)
                        begin
                            if (((TBPROT==1 && Config_reg1_in[5]==1'b0) ||
                                 (TBPARM==1 && Config_reg1_in[2]==1'b0) ||
                                 (BPNV  ==1 && Config_reg1_in[3]==1'b0)) &&
                                 cfg_write)
                            begin
                                // P_ERR bit is set to 1
                                Status_reg1[6] = 1'b1;
                            end
                            else
                            begin
                            // can not execute if Hardware Protection Mode
                            // is entered or if WEL bit is zero
                                WSTART = 1'b1;
                                WSTART <= #5 1'b0;
                                Status_reg1[0] = 1'b1;
                            end
                        end
                        else
                            Status_reg1[1] = 0;
                    end
                    else if ((Instruct == PP || Instruct == PP4) && WEL ==1 &&
                              PDONE == 1 )
                    begin
                        ReturnSectorID(sect,Address);
                        if (Sec_Prot[sect] == 0 &&
                            PPB_bits[sect]== 1 && DYB_bits[sect]== 1)
                        begin
                            PSTART  = 1'b1;
                            PSTART <= #5 1'b0;
                            PGSUSP  = 0;
                            PGRES   = 0;
                            INITIAL_CONFIG = 1;
                            Status_reg1[0] = 1'b1;
                            SA      = sect;
                            Addr    = Address;
                            Addr_tmp= Address;
                            wr_cnt  = Byte_number;
                            for (i=wr_cnt;i>=0;i=i-1)
                            begin
                                if (Viol != 0)
                                    WData[i] = -1;
                                else
                                    WData[i] = WByte[i];
                            end
                        end
                        else
                        begin
                        //P_ERR bit will be set when the user attempts to
                        //to program within a protected main memory sector
                            Status_reg1[6] = 1'b1; //P_ERR
                            Status_reg1[1] = 1'b0; //WEL
                        end
                    end
                    else if ((Instruct == QPP || Instruct == QPP4) && WEL ==1 &&
                              PDONE == 1 )
                    begin
                        ReturnSectorID(sect,Address);
                        pgm_page = Address / (PageSize+1);
                        if (Sec_Prot[sect] == 0 &&
                            PPB_bits[sect]== 1 && DYB_bits[sect]== 1)
                        begin
                            PSTART  = 1'b1;
                            PSTART <= #5 1'b0;
                            PGSUSP  = 0;
                            PGRES   = 0;
                            INITIAL_CONFIG = 1;
                            Status_reg1[0] = 1'b1;
                            SA      = sect;
                            Addr    = Address;
                            Addr_tmp= Address;
                            wr_cnt  = Byte_number;
                            for (i=wr_cnt;i>=0;i=i-1)
                            begin
                                if (Viol != 0)
                                    WData[i] = -1;
                                else
                                    WData[i] = WByte[i];
                            end
                        end
                        else
                        begin
                        //P_ERR bit will be set when the user attempts to
                        //to program within a protected main memory sector
                            Status_reg1[6] = 1'b1; //P_ERR
                            Status_reg1[1] = 1'b0; //WEL
                        end
                    end
                    else if (Instruct == OTPP && WEL == 1)
                    begin
                        // As long as the FREEZE bit remains cleared to a logic
                        // '0' the OTP address space is programmable.
                        if (FREEZE == 0)
                        begin
                            if (((((Address>= 16'h0010 && Address<= 16'h0013) ||
                                (Address >= 16'h0020 && Address <= 16'h00FF))
                                && LOCK_BYTE1[Address/32] == 1) ||
                                ((Address >= 16'h0100 && Address <= 16'h01FF)
                                && LOCK_BYTE2[(Address-16'h0100)/32] == 1) ||
                                ((Address >= 16'h0200 && Address <= 16'h02FF)
                                && LOCK_BYTE3[(Address-16'h0200)/32] == 1) ||
                                ((Address >= 16'h0300 && Address <= 16'h03FF)
                                && LOCK_BYTE4[(Address-16'h0300)/32] == 1)) &&
                                (Address + Byte_number <= OTPHiAddr))
                            begin
                                PSTART = 1'b1;
                                PSTART <= #5 1'b0;
                                Status_reg1[0] = 1'b1;
                                Addr    = Address;
                                Addr_tmp= Address;
                                wr_cnt  = Byte_number;
                                for (i=wr_cnt;i>=0;i=i-1)
                                begin
                                    if (Viol != 0)
                                        WData[i] = -1;
                                    else
                                        WData[i] = WByte[i];
                                end
                            end
                            else if ((Address < 8'h10 || (Address > 8'h13 &&
                                    Address < 8'h20) || Address > 12'h3FF ))
                            begin
                                Status_reg1[6] = 1'b1;//P_ERR
                                Status_reg1[1] = 1'b0;//WEL
                                if (Address < 8'h20)
                                begin
                                    $display ("Given  address is ");
                                    $display ("in reserved address range");
                                end
                                else if (Address > 12'h3FF)
                                begin
                                    $display ("Given  address is ");
                                    $display ("out of OTP address range");
                                end
                            end
                            else
                            begin
                            //P_ERR bit will be set when the user attempts to
                            // to program within locked OTP region
                                Status_reg1[6] = 1'b1;//P_ERR
                                Status_reg1[1] = 1'b0;//WEL
                            end
                        end
                        else
                        begin
                        //P_ERR bit will be set when the user attempts to
                        //to program within locked OTP region
                            Status_reg1[6] = 1'b1;//P_ERR
                            Status_reg1[1] = 1'b0;//WEL
                        end
                    end
                    else if ((Instruct == SE || Instruct == SE4) && WEL == 1)
                    begin
                        ReturnSectorID(sect,Address);
                        if (UniformSec || (TopBoot && sect < 254) ||
                           (BottomBoot && sect > 31))
                        begin
                            SectorSuspend = sect;
                            PARAM_REGION  = 0;
                            if (Sec_Prot[sect] == 0 &&
                               PPB_bits[sect]== 1 && DYB_bits[sect]== 1)
                            begin
                                ESTART = 1'b1;
                                ESTART <= #5 1'b0;
                                ESUSP     = 0;
                                ERES      = 0;
                                INITIAL_CONFIG = 1;
                                Status_reg1[0] = 1'b1;
                                Addr = Address;
                            end
                            else
                            begin
                            //E_ERR bit will be set when the user attempts to
                            //erase an individual protected main memory sector
                                Status_reg1[5] = 1'b1;//E_ERR
                                Status_reg1[1] = 1'b0;//WEL
                            end
                        end
                        else if ((TopBoot && sect >= 254) ||
                                (BottomBoot && sect <= 31))
                        begin
                            if (Sec_ProtSE == 32 && ASP_ProtSE == 32)
                            //Sector erase command is applied to a 64 KB range
                            //that includes 4 KB sectors
                            begin
                                if (TopBoot)
                                begin
                                    SectorSuspend = 254 + (285 - sect)/16;
                                end
                                else
                                begin
                                    SectorSuspend = sect/16;
                                end
                                PARAM_REGION  = 1;
                                ESTART = 1'b1;
                                ESTART <= #5 1'b0;
                                ESUSP     = 0;
                                ERES      = 0;
                                INITIAL_CONFIG = 1;
                                Status_reg1[0] = 1'b1;
                                Addr = Address;
                            end
                            else
                            begin
                            //E_ERR bit will be set when the user attempts to
                            //erase an individual protected main memory sector
                                Status_reg1[5] = 1'b1;//E_ERR
                                Status_reg1[1] = 1'b0;//WEL
                            end
                        end
                    end
                    else if ((Instruct == P4E || Instruct == P4E4) && WEL == 1)
                    begin
                        ReturnSectorID(sect,Address);
                        if (UniformSec || (TopBoot && sect < 254) ||
                           (BottomBoot && sect > 31))
                        begin
                            Status_reg1[1] = 1'b0;//WEL
                        end
                        else
                        begin
                            if (Sec_Prot[sect] == 0 &&
                                PPB_bits[sect]== 1 && DYB_bits[sect]== 1)
                            //A P4E instruction applied to a sector
                            //that has been Write Protected through the
                            //Block Protect Bits or ASP will not be
                            //executed and will set the E_ERR status
                            begin
                                ESTART = 1'b1;
                                ESTART <= #5 1'b0;
                                ESUSP     = 0;
                                ERES      = 0;
                                INITIAL_CONFIG = 1;
                                Status_reg1[0] = 1'b1;
                                Addr = Address;
                            end
                            else
                            begin
                            //E_ERR bit will be set when the user attempts to
                            //erase an individual protected main memory sector
                                Status_reg1[5] = 1'b1;//E_ERR
                                Status_reg1[1] = 1'b0;//WEL
                            end
                        end
                    end
                    else if (Instruct == BE && WEL == 1)
                    begin
                        if (Status_reg1[4]== 0 && Status_reg1[3]== 0 &&
                            Status_reg1[2]== 0)
                        begin
                            ESTART = 1'b1;
                            ESTART <= #5 1'b0;
                            ESUSP  = 0;
                            ERES   = 0;
                            INITIAL_CONFIG = 1;
                            Status_reg1[0] = 1'b1;
                        end
                        else
                        begin
                        //The Bulk Erase command will not set E_ERR if a
                        //protected sector is found during the command
                        //execution.
                            Status_reg1[1] = 1'b0;//WEL
                        end
                    end
                    else if (Instruct == PASSP && WEL == 1)
                    begin
                        if (~(PWDMLB== 0 && PSTMLB== 1))
                        begin
                            PSTART = 1'b1;
                            PSTART <= #5 1'b0;
                            Status_reg1[0] = 1'b1;
                        end
                        else
                        begin
                            $display ("Password programming is not allowed");
                            $display (" in Password Protection Mode.");
                        end
                    end
                    else if (Instruct == PASSU  && WEL)
                    begin
                        if (~WIP)
                        begin
                            PASSULCK_in = 1;
                            Status_reg1[0] = 1'b1; //WIP
                        end
                        else
                        begin
                            $display ("The PASSU command cannot be accepted");
                            $display (" any faster than once every 100us");
                        end
                    end
                    else if (Instruct == BRWR)
                    begin
                        Bank_Addr_reg[7] = Bank_Addr_reg_in[7];
                    end
                    else if (Instruct == ASPP  && WEL == 1)
                    begin
                        if (~(ASPOTPFLAG))
                        begin
                            PSTART = 1'b1;
                            PSTART <= #5 1'b0;
                            Status_reg1[0]    = 1'b1;
                        end
                        else
                        begin
                            Status_reg1[1]   = 1'b0;
                            Status_reg1[6] = 1'b1;
                            $display ("Once the Protection Mode is selected,");
                            $display ("no further changes to the ASP ");
                            $display ("register is allowed.");
                        end
                    end
                    else if (Instruct == ABWR  && WEL == 1)
                    begin
                        PSTART = 1'b1;
                        PSTART <= #5 1'b0;
                        Status_reg1[0] = 1'b1;
                    end
                    else if (Instruct == PPBP  && WEL == 1)
                    begin
                        ReturnSectorID(sect,Address);
                        PSTART = 1'b1;
                        PSTART <= #5 1'b0;
                        Status_reg1[0] = 1'b1;
                    end
                    else if (Instruct == PPBERS  && WEL == 1)
                    begin
                        if (PPBOTP)
                        begin
                            PPBERASE_in = 1'b1;
                            Status_reg1[0] = 1'b1;
                        end
                        else
                        begin
                             Status_reg1[5] = 1'b1;
                        end
                    end
                    else if (Instruct == PLBWR  && WEL == 1 &&
                             RdPswdProtEnable == 0)
                    begin
                        PSTART = 1'b1;
                        PSTART <= #5 1'b0;
                        Status_reg1[0] = 1'b1;
                    end
                    else if (Instruct == DYBWR  && WEL == 1)
                    begin
                        ReturnSectorID(sect,Address);
                        pgm_page = Address / (PageSize+1);
                        PSTART = 1'b1;
                        PSTART <= #5 1'b0;
                        Status_reg1[0]    = 1'b1;
                    end
                    else if (Instruct == PNVDLR  && WEL == 1)
                    begin
                        PSTART = 1'b1;
                        PSTART <= #5 1'b0;
                        Status_reg1[0]    = 1'b1;
                    end
                    else if (Instruct == WVDLR  && WEL == 1)
                    begin
                        VDLR_reg = VDLR_reg_in;
                        Status_reg1[1] = 1'b0;
                    end
                    else if (Instruct == CLSR)
                    begin
                    //The Clear Status Register Command resets bit SR1[5]
                    //(Erase Fail Flag) and bit SR1[6] (Program Fail Flag)
                        Status_reg1[5] = 0;
                        Status_reg1[6] = 0;
                    end

                    if (Instruct == BRAC && P_ERR == 0 && E_ERR == 0)
                    begin
                        BAR_ACC = 1;
                    end
                    else
                    begin
                        BAR_ACC = 0;
                    end
                end
                else if (oe_z)
                begin
                    if (Instruct == READ || Instruct == RD4 ||
                        Instruct == RES  ||
                       (Instruct == DLPRD && RdPswdProtMode == 0))
                    begin
                        rd_fast = 1'b0;
                        rd_slow = 1'b1;
                        dual    = 1'b0;
                        ddr     = 1'b0;
                    end
                    else if (Instruct == DDRFR || Instruct == DDRFR4)
                    begin
                        rd_fast = 1'b0;
                        rd_slow = 1'b0;
                        dual    = 1'b0;
                        ddr     = 1'b1;
                    end
                    else if (Instruct == DDRDIOR || Instruct == DDRDIOR4 ||
                           ((Instruct == DDRQIOR || Instruct == DDRQIOR4)
                             && QUAD))
                    begin
                        rd_fast = 1'b0;
                        rd_slow = 1'b0;
                        dual    = 1'b1;
                        ddr     = 1'b1;
                    end
                    else if (Instruct == DOR  || Instruct == DOR4  ||
                             Instruct == DIOR || Instruct == DIOR4 ||
                           ((Instruct == QOR  || Instruct == QOR4  ||
                             Instruct == QIOR || Instruct == QIOR4)
                             && QUAD))
                    begin
                        rd_fast = 1'b0;
                        rd_slow = 1'b0;
                        dual    = 1'b1;
                        ddr     = 1'b0;
                    end
                    else
                    begin
                        rd_fast = 1'b1;
                        rd_slow = 1'b0;
                        dual    = 1'b0;
                        ddr     = 1'b0;
                    end
                    HOLDNegOut_zd = 1'bZ;
                    WPNegOut_zd   = 1'bZ;
                    SOut_zd       = 1'bZ;
                    SIOut_zd      = 1'bZ;
                end
                else if (oe)
                begin
                    any_read = 1'b1;
                    if (Instruct == RDSR)
                    begin
                    //Read Status Register
                        SOut_zd = Status_reg1[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDSR2)
                    begin
                    //Read Status Register
                        SOut_zd = Status_reg2[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDCR)
                    begin
                        //Read Configuration Register 1
                        SOut_zd = Config_reg1[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == ECCRD)
                    begin
                        //Read ECC Register
                        SOut_zd = ECCSR[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == READ || Instruct == RD4 ||
                            Instruct == FSTRD || Instruct == FSTRD4 ||
                            Instruct == DDRFR || Instruct == DDRFR4 )
                    begin
                        //Read Memory array
                        if (Instruct == READ || Instruct == RD4)
                        begin
                            rd_fast = 1'b0;
                            rd_slow = 1'b1;
                            dual    = 1'b0;
                            ddr     = 1'b0;
                        end
                        else if (Instruct == DDRFR || Instruct == DDRFR4)
                        begin
                            rd_fast = 1'b0;
                            rd_slow = 1'b0;
                            dual    = 1'b0;
                            ddr     = 1'b1;
                        end
                        else
                        begin
                            rd_fast = 1'b1;
                            rd_slow = 1'b0;
                            dual    = 1'b0;
                            ddr     = 1'b0;
                        end
                        if ((Instruct == DDRFR || Instruct == DDRFR4) &&
                            (VDLR_reg != 8'b00000000) && start_dlp)
                        begin
                            // Data Learning Pattern (DLP) is enabled
                            // Optional DLP
                            data_out[7:0] = VDLR_reg;
                            SOut_zd  = data_out[7-read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 8)
                            begin
                                read_cnt  = 0;
                                start_dlp = 1'b0;
                            end

                        end
                        else
                        begin
                            read_addr_tmp = read_addr;
                            SecAddr = read_addr/(SecSize+1) ;
                            Sec_addr = read_addr - SecAddr*(SecSize+1);
                            SecAddr = ReturnSectorIDRdPswdMd(TBPROT);
                            read_addr = Sec_addr + SecAddr*(SecSize+1);
                            if (RdPswdProtMode == 0)
                            begin
                                read_addr = read_addr_tmp;
                            end
                            if (Mem[read_addr] !== -1)
                            begin
                                data_out[7:0] = Mem[read_addr];
                                SOut_zd  = data_out[7-read_cnt];
                            end
                            else
                            begin
                                SOut_zd  = 8'bx;
                            end
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 8)
                            begin
                                read_cnt = 0;
                                if (read_addr == AddrRANGE)
                                    read_addr = 0;
                                else
                                    read_addr = read_addr + 1;
                            end
                        end
                    end
                    else if (Instruct == DOR  || Instruct == DOR4  ||
                            Instruct == DIOR || Instruct == DIOR4 ||
                            Instruct == DDRDIOR || Instruct == DDRDIOR4 )
                    begin
                        //Read Memory array
                        if (Instruct == DDRDIOR || Instruct == DDRDIOR4)
                        begin
                            rd_fast = 1'b0;
                            rd_slow = 1'b0;
                            dual    = 1'b1;
                            ddr     = 1'b1;
                        end
                        else
                        begin
                            rd_fast = 1'b0;
                            rd_slow = 1'b0;
                            dual    = 1'b1;
                            ddr     = 1'b0;
                        end
                        if ((Instruct == DDRDIOR || Instruct == DDRDIOR4) &&
                            (VDLR_reg != 8'b00000000) && start_dlp)
                        begin

                            data_out[7:0] = VDLR_reg;
                            SOut_zd  = data_out[7-read_cnt];
                            SIOut_zd = data_out[7-read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 8)
                            begin
                                read_cnt  = 0;
                                start_dlp = 0;
                            end
                        end
                        else
                        begin
                            read_addr_tmp = read_addr;
                            SecAddr = read_addr/(SecSize+1) ;
                            Sec_addr = read_addr - SecAddr*(SecSize+1);
                            SecAddr = ReturnSectorIDRdPswdMd(TBPROT);
                            read_addr = Sec_addr + SecAddr*(SecSize+1);
                            if (RdPswdProtMode == 0)
                                read_addr = read_addr_tmp;

                            data_out[7:0] = Mem[read_addr];
                            SOut_zd = data_out[7-2*read_cnt];
                            SIOut_zd = data_out[6-2*read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 4)
                            begin
                                read_cnt = 0;
                                if (read_addr == AddrRANGE)
                                    read_addr = 0;
                                else
                                    read_addr = read_addr + 1;
                            end
                        end
                    end
                    else if ((Instruct == QOR  || Instruct == QOR4 ||
                            Instruct == QIOR || Instruct == QIOR4 ||
                            Instruct == DDRQIOR || Instruct == DDRQIOR4 )
                            && QUAD)
                    begin
                        //Read Memory array
                        if (Instruct == DDRQIOR || Instruct == DDRQIOR4)
                        begin
                            rd_fast = 1'b0;
                            rd_slow = 1'b0;
                            dual    = 1'b1;
                            ddr     = 1'b1;
                        end
                        else
                        begin
                            rd_fast = 1'b0;
                            rd_slow = 1'b0;
                            dual    = 1'b1;
                            ddr     = 1'b0;
                        end
                        if ((Instruct == DDRQIOR || Instruct == DDRQIOR4) &&
                            (VDLR_reg != 8'b00000000) && start_dlp)
                        begin
                            // Data Learning Pattern (DLP) is enabled
                            // Optional DLP
                            data_out[7:0] = VDLR_reg;
                            HOLDNegOut_zd = data_out[7-read_cnt];
                            WPNegOut_zd   = data_out[7-read_cnt];
                            SOut_zd   = data_out[7-read_cnt];
                            SIOut_zd   = data_out[7-read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 8)
                            begin
                                read_cnt  = 0;
                                start_dlp = 1'b0;
                            end
                        end
                        else
                        begin
                            read_addr_tmp = read_addr;
                            SecAddr = read_addr/(SecSize+1) ;
                            Sec_addr = read_addr - SecAddr*(SecSize+1);
                            SecAddr = ReturnSectorIDRdPswdMd(TBPROT);
                            read_addr = Sec_addr + SecAddr*(SecSize+1);
                            if (RdPswdProtMode == 0)
                                read_addr = read_addr_tmp;

                            data_out[7:0] = Mem[read_addr];
                            HOLDNegOut_zd = data_out[7-4*read_cnt];
                            WPNegOut_zd   = data_out[6-4*read_cnt];
                            SOut_zd   = data_out[5-4*read_cnt];
                            SIOut_zd   = data_out[4-4*read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 2)
                            begin
                                read_cnt = 0;
                                if (read_addr == AddrRANGE)
                                    read_addr = 0;
                                else
                                    read_addr = read_addr + 1;
                            end
                        end
                    end
                    else if (Instruct == OTPR)
                    begin
                        if(read_addr>=OTPLoAddr && read_addr<=OTPHiAddr
                        && RdPswdProtMode == 0)
                        begin
                        //Read OTP Memory array
                            rd_fast = 1'b1;
                            rd_slow = 1'b0;
                            data_out[7:0] = OTPMem[read_addr];
                            SOut_zd  = data_out[7-read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 8)
                            begin
                                read_cnt = 0;
                                read_addr = read_addr + 1;
                            end
                        end
                        else if ((read_addr > OTPHiAddr)||(RdPswdProtMode==1))
                        begin
                        //OTP Read operation will not wrap to the
                        //starting address after the OTP address is at
                        //its maximum or Read Password Protection Mode
                        //is selected instead, the data beyond the
                        //maximum OTP address will be undefined.
                            SOut_zd = 1'bX;
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 8)
                                read_cnt = 0;
                        end
                    end
                    else if (Instruct == REMS)
                    begin
                        //Read Manufacturer and Device ID
                        if (read_addr % 2 == 0)
                        begin
                            data_out[7:0] = Manuf_ID;
                            SOut_zd = data_out[7-read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 8)
                            begin
                                read_cnt = 0;
                                read_addr = read_addr + 1;
                            end
                        end
                        else
                        begin
                            data_out[7:0] = DeviceID;
                            SOut_zd = data_out[7-read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 8)
                            begin
                                read_cnt = 0;
                                read_addr = 0;
                            end
                        end
                    end
                    else if (Instruct == RDID)
                    begin
                        ident_out = CFI_array_tmp;
                        if(read_cnt < 648)
                        begin
                            SOut_zd = ident_out[647-read_cnt];
                            read_cnt  = read_cnt + 1;
                        end
                        else
                        begin
                        //Continued shifting of output beyond the end of
                        //the defined ID-CFI address space will
                        //provide undefined data.
                            SOut_zd = 1'bX;
                        end
                    end
                    else if (Instruct == RES)
                    begin
                        rd_fast = 1'b0;
                        rd_slow = 1'b1;
                        dual    = 1'b0;
                        ddr     = 1'b0;
                        data_out = ESignature;
                        SOut_zd = data_out[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == DLPRD && RdPswdProtMode == 0)
                    begin
                    //Read DLP
                        rd_fast = 1'b0;
                        rd_slow = 1'b1;
                        dual    = 1'b0;
                        ddr     = 1'b0;
                        SOut_zd = VDLR_reg[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == ABRD && RdPswdProtMode == 0)
                    begin
                    //Read AutoBoot register
                        rd_fast = 1'b1;
                        rd_slow = 1'b0;
                        dual    = 1'b0;
                        ddr     = 1'b0;
                        SOut_zd = AutoBoot_reg_in[31-read_cnt];
                        read_cnt  = read_cnt + 1;
                        if (read_cnt == 32)
                            read_cnt = 0;
                    end
                    else if (Instruct == BRRD && RdPswdProtMode == 0)
                    begin
                    //Read Bank Address Register
                        rd_fast = 1'b1;
                        rd_slow = 1'b0;
                        dual    = 1'b0;
                        ddr     = 1'b0;
                        SOut_zd = Bank_Addr_reg[7-read_cnt];
                        read_cnt  = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == ASPRD && RdPswdProtMode == 0)
                    begin
                    //Read ASP Register
                        rd_fast = 1'b1;
                        rd_slow = 1'b0;
                        dual    = 1'b0;
                        ddr     = 1'b0;
                        SOut_zd = ASP_reg[15-read_cnt];
                        read_cnt  = read_cnt + 1;
                        if (read_cnt == 16)
                            read_cnt = 0;
                    end
                    else if (Instruct == PASSRD && RdPswdProtMode == 0)
                    begin
                    //Read Password Register
                        if (~(PWDMLB == 0 && PSTMLB == 1))
                        begin
                            rd_fast = 1'b1;
                            rd_slow = 1'b0;
                            dual    = 1'b0;
                            ddr     = 1'b0;
                            SOut_zd =
                                        Password_reg[(8*byte_cnt-1)-read_cnt];
                            read_cnt  = read_cnt + 1;
                            if (read_cnt == 8)
                            begin
                                read_cnt = 0;
                                byte_cnt = byte_cnt + 1;
                                if (byte_cnt == 9)
                                    byte_cnt = 1;
                            end
                        end
                    end
                    else if (Instruct == PLBRD)
                    begin
                    //Read PPB Lock Register
                        rd_fast = 1'b1;
                        rd_slow = 1'b0;
                        dual    = 1'b0;
                        ddr     = 1'b0;
                        SOut_zd = PPBL[7-read_cnt];
                        read_cnt  = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == DYBRD)
                    begin
                    //Read DYB Access Register
                        ReturnSectorID(sect,Address);
                        pgm_page = Address / (PageSize+1);
                        rd_fast = 1'b1;
                        rd_slow = 1'b0;
                        dual    = 1'b0;
                        ddr     = 1'b0;
                        DYBAR[7:0] = 8'bXXXXXXXX;

                        if (RdPswdProtMode == 0)
                        begin
                            if (DYB_bits[sect] == 1)
                                DYBAR[7:0] = 8'hFF;
                            else
                            begin
                                DYBAR[7:0] = 8'h0;
                            end
                        end
                        SOut_zd = DYBAR[7-read_cnt];
                        read_cnt  = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == PPBRD)
                    begin
                    //Read PPB Access Register
                        ReturnSectorID(sect,Address);
                        rd_fast = 1'b1;
                        rd_slow = 1'b0;
                        dual    = 1'b0;
                        ddr     = 1'b0;
                        PPBAR[7:0] = 8'bXXXXXXXX;
                        if (RdPswdProtMode == 0)
                        begin
                            if (PPB_bits[sect] == 1)
                                PPBAR[7:0] = 8'hFF;
                            else
                            begin
                                PPBAR[7:0] = 8'h0;
                            end
                        end
                        SOut_zd = PPBAR[7-read_cnt];
                        read_cnt  = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                end
            end

            AUTOBOOT:
            begin
                if (start_autoboot == 1)
                begin
                    if (oe)
                    begin
                        any_read = 1'b1;
                        if (QUAD == 1)
                        begin
                            if (ABSD > 0)      //If ABSD > 0,
                            begin              //max SCK frequency is 104MHz
                                rd_fast = 1'b0;
                                rd_slow = 1'b0;
                                dual    = 1'b1;
                                ddr     = 1'b0;
                            end
                            else // If ABSD = 0, max SCK frequency is 50 MHz
                            begin
                                rd_fast = 1'b0;
                                rd_slow = 1'b1;
                                dual    = 1'b0;
                                ddr     = 1'b0;
                            end
                            data_out[7:0] = Mem[read_addr];
                            HOLDNegOut_zd = data_out[7-4*read_cnt];
                            WPNegOut_zd   = data_out[6-4*read_cnt];
                            SOut_zd   = data_out[5-4*read_cnt];
                            SIOut_zd   = data_out[4-4*read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 2)
                            begin
                                read_cnt = 0;
                                read_addr = read_addr + 1;
                            end
                        end
                        else
                        begin
                            if (ABSD > 0)      //If ABSD > 0,
                            begin              //max SCK frequency is 133MHz
                                rd_fast = 1'b1;
                                rd_slow = 1'b0;
                                dual    = 1'b0;
                                ddr     = 1'b0;
                            end
                            else // If ABSD = 0, max SCK frequency is 50 MHz
                            begin
                                rd_fast = 1'b0;
                                rd_slow = 1'b1;
                                dual    = 1'b0;
                                ddr     = 1'b0;
                            end
                            data_out[7:0] = Mem[read_addr];
                            SOut_zd = data_out[7-read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 8)
                            begin
                                read_cnt = 0;
                                read_addr = read_addr + 1;
                            end
                        end
                    end
                    else if (oe_z)
                    begin
                        if (QUAD == 1)
                        begin
                            if (ABSD > 0)      //If ABSD > 0,
                            begin              //max SCK frequency is 104MHz
                                rd_fast = 1'b0;
                                rd_slow = 1'b0;
                                dual    = 1'b1;
                                ddr     = 1'b0;
                            end
                            else // If ABSD = 0, max SCK frequency is 50 MHz
                            begin
                                rd_fast = 1'b0;
                                rd_slow = 1'b1;
                                dual    = 1'b0;
                                ddr     = 1'b0;
                            end
                        end
                        else
                        begin
                            if (ABSD > 0)      //If ABSD > 0,
                            begin              //max SCK frequency is 133MHz
                                rd_fast = 1'b1;
                                rd_slow = 1'b0;
                                dual    = 1'b0;
                                ddr     = 1'b0;
                            end
                            else // If ABSD = 0, max SCK frequency is 50 MHz
                            begin
                                rd_fast = 1'b0;
                                rd_slow = 1'b1;
                                dual    = 1'b0;
                                ddr     = 1'b0;
                            end
                        end
                        HOLDNegOut_zd = 1'bZ;
                        WPNegOut_zd   = 1'bZ;
                        SOut_zd       = 1'bZ;
                        SIOut_zd      = 1'bZ;
                    end
                end
            end

            WRITE_SR:
            begin
                rd_fast = 1'b1;
                rd_slow = 1'b0;
                dual    = 1'b0;
                ddr     = 1'b0;
                if (oe)
                begin
                    any_read = 1'b1;
                    if (Instruct == RDSR)
                    begin
                    //Read Status Register 1
                        SOut_zd = Status_reg1[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDSR2)
                    begin
                    //Read Status Register 2
                        SOut_zd = Status_reg2[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDCR)
                    begin
                        //Read Configuration Register 1
                        SOut_zd = Config_reg1[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                end
                else if (oe_z)
                begin
                    HOLDNegOut_zd = 1'bZ;
                    WPNegOut_zd   = 1'bZ;
                    SOut_zd       = 1'bZ;
                    SIOut_zd      = 1'bZ;
                end

                if (WDONE == 1)
                begin
                    Status_reg1[0] = 1'b0; //WIP
                    Status_reg1[1] = 1'b0; //WEL
                    //SRWD bit
                    Status_reg1[7] = Status_reg1_in[7]; //MSB first

//                     if (LOCK == 0)
//                     begin
                        if (FREEZE == 0)
                        //The Freeze Bit, when set to 1, locks the current
                        //state of the BP2-0 bits in Status Register,
                        //the TBPROT and TBPARM bits in the Config Register
                        //As long as the FREEZE bit remains cleared to logic
                        //'0', the other bits of the Configuration register
                        //including FREEZE are writeable.
                        begin
                            Status_reg1[4] = Status_reg1_in[4];//BP2
                            Status_reg1[3] = Status_reg1_in[3];//BP1
                            Status_reg1[2] = Status_reg1_in[2];//BP0

                            BP_bits = {Status_reg1[4],Status_reg1[3],
                                       Status_reg1[2]};
                            if (TBPROT == 1'b0 && INITIAL_CONFIG == 1'b0)
                            begin
                                Config_reg1[5] = Config_reg1_in[5];//TBPROT
                            end
                            if (TBPARM == 1'b0 && INITIAL_CONFIG == 1'b0 &&
                                tmp_char2 == "0")
                            begin
                                Config_reg1[2] = Config_reg1_in[2];//TBPARM
                                change_TBPARM = 1'b1;
                                #1000 change_TBPARM = 1'b0;
                            end
                            change_BP = 1'b1;
                            #1000 change_BP = 1'b0;
                        end
//                     end

                    Config_reg1[7] = Config_reg1_in[7];//LC1
                    Config_reg1[6] = Config_reg1_in[6];//LC0
                    Config_reg1[1] = Config_reg1_in[1];//QUAD

                    if (FREEZE == 1'b0)
                    begin
                        Config_reg1[0] = Config_reg1_in[0];//FREEZE
                    end

//                     if (WRLOCKENABLE== 1'b1 && LOCK == 1'b0)
//                     begin
//                         Config_reg1[4] = Config_reg1_in[4];//LOCK
//                         WRLOCKENABLE = 1'b0;
//                     end
                    if (BPNV == 1'b0)
                    begin
                        Config_reg1[3] = Config_reg1_in[3];//BPNV
                    end
                end
            end

            PAGE_PG :
            begin
                rd_fast = 1'b1;
                rd_slow = 1'b0;
                dual    = 1'b0;
                ddr     = 1'b0;
                if (oe)
                begin
                    any_read = 1'b1;
                    if (Instruct == RDSR)
                    begin
                    //Read Status Register 1
                        SOut_zd = Status_reg1[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDSR2)
                    begin
                    //Read Status Register 2
                        SOut_zd = Status_reg2[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDCR)
                    begin
                        //Read Configuration Register 1
                        SOut_zd = Config_reg1[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                end
                else if (oe_z)
                begin
                    HOLDNegOut_zd = 1'bZ;
                    WPNegOut_zd   = 1'bZ;
                    SOut_zd       = 1'bZ;
                    SIOut_zd      = 1'bZ;
                end

                if(current_state_event && current_state == PAGE_PG)
                begin
                    if (~PDONE)
                    begin
                        ADDRHILO_PG(AddrLo, AddrHi, Addr);
                        cnt = 0;

                        for (i=0;i<=wr_cnt;i=i+1)
                        begin
                            new_int = WData[i];
                            old_int = Mem[Addr + i - cnt];
                            if (new_int > -1)
                            begin
                                new_bit = new_int;
                                if (old_int > -1)
                                begin
                                    old_bit = old_int;
                                    for(j=0;j<=7;j=j+1)
                                    begin
                                        if (~old_bit[j])
                                            new_bit[j]=1'b0;
                                    end
                                    new_int=new_bit;
                                end
                                WData[i]= new_int;
                            end
                            else
                            begin
                                WData[i] = -1;
                            end

                            Mem[Addr + i - cnt] = - 1;
                            if ((Addr + i) == AddrHi)
                            begin

                                Addr = AddrLo;
                                cnt = i + 1;
                            end
                        end
                    end
                    cnt = 0;
                end

                if (PDONE)
                begin
                    Status_reg1[0] = 1'b0;
                    Status_reg1[1] = 1'b0;
                    quad_pg        = 0;
                    for (i=0;i<=wr_cnt;i=i+1)
                    begin
                        Mem[Addr_tmp + i - cnt] = WData[i];
                        if ((Addr_tmp + i) == AddrHi)
                        begin
                            Addr_tmp = AddrLo;
                            cnt = i + 1;
                        end
                    end
                end

                if (Instruct)
                begin
                    if (Instruct == PGSP && ~PRGSUSP_in)
                    begin
                        if (~RES_TO_SUSP_MIN_TIME)
                        begin
                            PGSUSP = 1'b1;
                            PGSUSP <= #5 1'b0;
                            PRGSUSP_in = 1'b1;
                            if (RES_TO_SUSP_TYP_TIME)
                            begin
                                $display("Typical periods are needed for ",
                                         "Program to progress to completion");
                            end
                        end
                        else
                        begin
                            $display("Minimum for tPRS is not satisfied! ",
                                     "PGSP command is ignored");
                        end
                    end
                end
            end

            PG_SUSP:
            begin
                rd_fast = 1'b1;
                rd_slow = 1'b0;
                dual    = 1'b0;
                ddr     = 1'b0;

                if (PRGSUSP_out && PRGSUSP_in)
                begin
                    PRGSUSP_in = 1'b0;
                    //The RDY/BSY bit in the Status Register will indicate that
                    //the device is ready for another operation.
                    Status_reg1[0] = 1'b0;
                    //The Program Suspend (PS) bit in the Status Register will
                    //be set to the logical “1” state to indicate that the
                    //program operation has been suspended.
                    Status_reg2[0] = 1'b1;
                    PDONE = 1'b1;
                end

                if (oe)
                begin
                    any_read = 1'b1;
                    if (Instruct == RDSR)
                    begin
                    //Read Status Register 1
                        SOut_zd = Status_reg1[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDSR2)
                    begin
                    //Read Status Register 2
                        SOut_zd = Status_reg2[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDCR)
                    begin
                        //Read Configuration Register 1
                        SOut_zd = Config_reg1[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == BRRD)
                    begin
                    //Read Bank Address Register
                        rd_fast = 1'b1;
                        rd_slow = 1'b0;
                        dual    = 1'b0;
                        ddr     = 1'b0;
                        SOut_zd = Bank_Addr_reg[7-read_cnt];
                        read_cnt  = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    //Read Array Operations
                    else if (Instruct == READ || Instruct == RD4 ||
                            Instruct == FSTRD || Instruct == FSTRD4 ||
                            Instruct == DDRFR || Instruct == DDRFR4 )
                    begin
                        //Read Memory array
                        if (Instruct == READ || Instruct == RD4)
                        begin
                            rd_fast = 1'b0;
                            rd_slow = 1'b1;
                            dual    = 1'b0;
                            ddr     = 1'b0;
                        end
                        else if (Instruct == DDRFR || Instruct == DDRFR4)
                        begin
                            rd_fast = 1'b0;
                            rd_slow = 1'b0;
                            dual    = 1'b0;
                            ddr     = 1'b1;
                        end
                        else
                        begin
                            rd_fast = 1'b1;
                            rd_slow = 1'b0;
                            dual    = 1'b0;
                            ddr     = 1'b0;
                        end
                        if (pgm_page != read_addr / (PageSize+1))
                        begin
                            if ((Instruct == DDRFR || Instruct == DDRFR4) &&
                                (VDLR_reg != 8'b00000000) && start_dlp)
                            begin
                                data_out[7:0] = VDLR_reg;
                                SOut_zd  = data_out[7-read_cnt];
                                read_cnt = read_cnt + 1;
                                if (read_cnt == 8)
                                begin
                                    read_cnt  = 0;
                                    start_dlp = 1'b0;
                                end
                            end
                            else
                            begin
                                data_out[7:0] = Mem[read_addr];
                                SOut_zd  = data_out[7-read_cnt];
                                read_cnt = read_cnt + 1;
                                if (read_cnt == 8)
                                begin
                                    read_cnt = 0;
                                    if (read_addr == AddrRANGE)
                                        read_addr = 0;
                                    else
                                        read_addr = read_addr + 1;
                                end

                            end
                        end
                        else
                        begin
                            SOut_zd  = 8'bxxxxxxxx;
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 8)
                            begin
                                read_cnt = 0;
                                if (read_addr == AddrRANGE)
                                    read_addr = 0;
                                else
                                    read_addr = read_addr + 1;
                            end
                        end
                    end
                    else if (Instruct == DOR || Instruct == DOR4  ||
                            Instruct == DIOR || Instruct == DIOR4 ||
                            Instruct == DDRDIOR || Instruct == DDRDIOR4 )
                    begin
                        //Read Memory array
                        if (Instruct == DDRDIOR || Instruct == DDRDIOR4)
                        begin
                            rd_fast = 1'b0;
                            rd_slow = 1'b0;
                            dual    = 1'b1;
                            ddr     = 1'b1;
                        end
                        else
                        begin
                            rd_fast = 1'b0;
                            rd_slow = 1'b0;
                            dual    = 1'b1;
                            ddr     = 1'b0;
                        end
                        if (pgm_page != read_addr / (PageSize+1))
                        begin
                            if ((Instruct == DDRDIOR || Instruct == DDRDIOR4) &&
                               (VDLR_reg != 8'b00000000) && start_dlp)
                            begin
                                data_out[7:0] = VDLR_reg;
                                SOut_zd = data_out[7-read_cnt];
                                SIOut_zd = data_out[7-read_cnt];
                                read_cnt = read_cnt + 1;
                                if (read_cnt == 8)
                                begin
                                    read_cnt  = 0;
                                    start_dlp = 1'b0;
                                end
                            end
                            else
                            begin
                                data_out[7:0] = Mem[read_addr];
                                SOut_zd = data_out[7-2*read_cnt];
                                SIOut_zd = data_out[6-2*read_cnt];
                                read_cnt = read_cnt + 1;
                                if (read_cnt == 4)
                                begin
                                    read_cnt = 0;
                                    if (read_addr == AddrRANGE)
                                        read_addr = 0;
                                    else
                                        read_addr = read_addr + 1;
                                end
                            end
                        end
                        else
                        begin
                            SOut_zd = 1'bx;
                            SIOut_zd = 1'bx;
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 4)
                            begin
                                read_cnt = 0;
                                if (read_addr == AddrRANGE)
                                    read_addr = 0;
                                else
                                    read_addr = read_addr + 1;
                            end
                        end
                    end
                    else if (Instruct == QOR || Instruct == QOR4  ||
                            Instruct == QIOR || Instruct == QIOR4 ||
                            Instruct == DDRQIOR || Instruct == DDRQIOR4 )
                    begin
                        //Read Memory array
                        if (Instruct == DDRQIOR || Instruct == DDRQIOR4)
                        begin
                            rd_fast = 1'b0;
                            rd_slow = 1'b0;
                            dual    = 1'b1;
                            ddr     = 1'b1;
                        end
                        else
                        begin
                            rd_fast = 1'b0;
                            rd_slow = 1'b0;
                            dual    = 1'b1;
                            ddr     = 1'b0;
                        end
                        if (pgm_page != read_addr / (PageSize+1))
                        begin
                            if ((Instruct == DDRQIOR || Instruct == DDRQIOR4) &&
                                (VDLR_reg != 8'b00000000) && start_dlp)
                            begin
                                // Data Learning Pattern (DLP)
                                // is enabled Optional DLP
                                data_out[7:0] = VDLR_reg;
                                HOLDNegOut_zd= data_out[7-read_cnt];
                                WPNegOut_zd  = data_out[7-read_cnt];
                                SOut_zd  = data_out[7-read_cnt];
                                SIOut_zd  = data_out[7-read_cnt];
                                read_cnt = read_cnt + 1;
                                if (read_cnt == 8)
                                begin
                                    read_cnt  = 0;
                                    start_dlp = 1'b0;
                                end
                            end
                            else
                            begin
                                data_out[7:0] = Mem[read_addr];
                                HOLDNegOut_zd = data_out[7-4*read_cnt];
                                WPNegOut_zd   = data_out[6-4*read_cnt];
                                SOut_zd   = data_out[5-4*read_cnt];
                                SIOut_zd   = data_out[4-4*read_cnt];
                                read_cnt = read_cnt + 1;
                                if (read_cnt == 2)
                                begin
                                    read_cnt = 0;
                                    if (read_addr == AddrRANGE)
                                        read_addr = 0;
                                    else
                                        read_addr = read_addr + 1;
                                end
                            end
                        end
                        else
                        begin
                            HOLDNegOut_zd = 1'bx;
                            WPNegOut_zd   = 1'bx;
                            SOut_zd   = 1'bx;
                            SIOut_zd   = 1'bx;
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 2)
                            begin
                                read_cnt = 0;
                                if (read_addr == AddrRANGE)
                                    read_addr = 0;
                                else
                                    read_addr = read_addr + 1;
                            end
                        end
                    end
                end
                else if (oe_z)
                begin
                    if (Instruct == READ || Instruct == RD4)
                    begin
                        rd_fast = 1'b0;
                        rd_slow = 1'b1;
                        dual    = 1'b0;
                        ddr     = 1'b0;
                    end
                    else if (Instruct == DDRFR || Instruct == DDRFR4)
                    begin
                        rd_fast = 1'b0;
                        rd_slow = 1'b0;
                        dual    = 1'b0;
                        ddr     = 1'b1;
                    end
                    else if (Instruct == DDRDIOR || Instruct == DDRDIOR4)
                    begin
                        rd_fast = 1'b0;
                        rd_slow = 1'b0;
                        dual    = 1'b1;
                        ddr     = 1'b1;
                    end
                    else if (Instruct == DOR || Instruct == DOR4  ||
                             Instruct == DIOR || Instruct == DIOR4 ||
                             Instruct == QOR || Instruct == QOR4  ||
                             Instruct == QIOR || Instruct == QIOR4)
                    begin
                        rd_fast = 1'b0;
                        rd_slow = 1'b0;
                        dual    = 1'b1;
                        ddr     = 1'b0;
                    end
                    else if (Instruct == DDRQIOR || Instruct == DDRQIOR4)
                    begin
                        rd_fast = 1'b0;
                        rd_slow = 1'b0;
                        dual    = 1'b1;
                        ddr     = 1'b1;
                    end
                    else
                    begin
                        rd_fast = 1'b1;
                        rd_slow = 1'b0;
                        dual    = 1'b0;
                        ddr     = 1'b0;
                    end
                    HOLDNegOut_zd = 1'bZ;
                    WPNegOut_zd   = 1'bZ;
                    SOut_zd       = 1'bZ;
                    SIOut_zd      = 1'bZ;
                end

                if (falling_edge_write)
                begin
                    if (Instruct == BRWR)
                    begin
                        Bank_Addr_reg[7] = Bank_Addr_reg_in[7];
                    end
                    else if (Instruct == WRR && BAR_ACC == 1)
                    begin
                    // Write to the lower address bits of the BAR
                        if (P_ERR == 0 && E_ERR == 0)
                        begin
                            $display ("WARNING: Changing values of ");
                            $display ("Bank Address Register");
                            $display ("RFU bits are not allowed!!!");
                        end
                    end
                    else if (Instruct == PGRS)
                    begin
                        Status_reg2[0] = 1'b0;
                        Status_reg1[0] = 1'b1;
                        PGRES = 1'b1;
                        PGRES <= #5 1'b0;
                        RES_TO_SUSP_MIN_TIME = 1'b1;
                        RES_TO_SUSP_MIN_TIME <= #60000 1'b0;//60 ns 3000000 ns = 3 us
                        RES_TO_SUSP_TYP_TIME = 1'b1;
                        RES_TO_SUSP_TYP_TIME <= #100000000 1'b0;//100us
                    end

                    if (Instruct == BRAC && P_ERR == 0 && E_ERR == 0 &&
                        RdPswdProtMode == 0)
                    begin
                        BAR_ACC = 1;
                    end
                    else
                    begin
                        BAR_ACC = 0;
                    end
                end
            end

            ERS_SUSP_PG_SUSP:
            begin
                rd_fast = 1'b1;
                rd_slow = 1'b0;
                dual    = 1'b0;
                ddr     = 1'b0;

                if (PRGSUSP_out && PRGSUSP_in)
                begin
                    PRGSUSP_in = 1'b0;
                    //The RDY/BSY bit in the Status Register will indicate that
                    //the device is ready for another operation.
                    Status_reg1[0] = 1'b0;
                    //The Program Suspend (PS) bit in the Status Register will
                    //be set to the logical “1” state to indicate that the
                    //program operation has been suspended.
                    Status_reg2[0] = 1'b1;
                end

                if (oe)
                begin
                    any_read = 1'b1;
                    if (Instruct == RDSR)
                    begin
                    //Read Status Register 1
                        SOut_zd = Status_reg1[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDSR2)
                    begin
                    //Read Status Register 2
                        SOut_zd = Status_reg2[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDCR)
                    begin
                        //Read Configuration Register 1
                        SOut_zd = Config_reg1[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == BRRD)
                    begin
                    //Read Bank Address Register
                        rd_fast = 1'b1;
                        rd_slow = 1'b0;
                        dual    = 1'b0;
                        ddr     = 1'b0;
                        SOut_zd = Bank_Addr_reg[7-read_cnt];
                        read_cnt  = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    //Read Array Operations
                    else if (Instruct == READ || Instruct == RD4 ||
                            Instruct == FSTRD || Instruct == FSTRD4 ||
                            Instruct == DDRFR || Instruct == DDRFR4 )
                    begin
                        //Read Memory array
                        if (Instruct == READ || Instruct == RD4)
                        begin
                            rd_fast = 1'b0;
                            rd_slow = 1'b1;
                            dual    = 1'b0;
                            ddr     = 1'b0;
                        end
                        else if (Instruct == DDRFR || Instruct == DDRFR4)
                        begin
                            rd_fast = 1'b0;
                            rd_slow = 1'b0;
                            dual    = 1'b0;
                            ddr     = 1'b1;
                        end
                        else
                        begin
                            rd_fast = 1'b1;
                            rd_slow = 1'b0;
                            dual    = 1'b0;
                            ddr     = 1'b0;
                        end
                        if ((SectorSuspend != read_addr/(SecSize+1)) &&
                        (pgm_page != read_addr / (PageSize+1)))
                        begin
                            if ((Instruct == DDRFR || Instruct == DDRFR4) &&
                                (VDLR_reg != 8'b00000000) && start_dlp)
                            begin
                                data_out[7:0] = VDLR_reg;
                                SOut_zd  = data_out[7-read_cnt];
                                read_cnt = read_cnt + 1;
                                if (read_cnt == 8)
                                begin
                                    read_cnt  = 0;
                                    start_dlp = 1'b0;
                                end
                            end
                            else
                            begin
                                data_out[7:0] = Mem[read_addr];
                                SOut_zd  = data_out[7-read_cnt];
                                read_cnt = read_cnt + 1;
                                if (read_cnt == 8)
                                begin
                                    read_cnt = 0;
                                    if (read_addr == AddrRANGE)
                                        read_addr = 0;
                                    else
                                        read_addr = read_addr + 1;
                                end

                            end
                        end
                        else
                        begin
                            SOut_zd  = 8'bxxxxxxxx;
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 8)
                            begin
                                read_cnt = 0;
                                if (read_addr == AddrRANGE)
                                    read_addr = 0;
                                else
                                    read_addr = read_addr + 1;
                            end
                        end
                    end
                    else if (Instruct == DOR || Instruct == DOR4  ||
                            Instruct == DIOR || Instruct == DIOR4 ||
                            Instruct == DDRDIOR || Instruct == DDRDIOR4 )
                    begin
                        //Read Memory array
                        if (Instruct == DDRDIOR || Instruct == DDRDIOR4)
                        begin
                            rd_fast = 1'b0;
                            rd_slow = 1'b0;
                            dual    = 1'b1;
                            ddr     = 1'b1;
                        end
                        else
                        begin
                            rd_fast = 1'b0;
                            rd_slow = 1'b0;
                            dual    = 1'b1;
                            ddr     = 1'b0;
                        end
                        if ((SectorSuspend != read_addr/(SecSize+1)) &&
                        (pgm_page != read_addr / (PageSize+1)))
                        begin
                            if ((Instruct == DDRDIOR || Instruct == DDRDIOR4) &&
                                (VDLR_reg != 8'b00000000) && start_dlp)
                            begin
                                // Data Learning Pattern (DLP)
                                // is enabled Optional DLP
                                data_out[7:0] = VDLR_reg;
                                SOut_zd = data_out[7-read_cnt];
                                SIOut_zd = data_out[7-read_cnt];
                                read_cnt = read_cnt + 1;
                                if (read_cnt == 8)
                                begin
                                    read_cnt  = 0;
                                    start_dlp = 1'b0;
                                end
                            end
                            else
                            begin
                                data_out[7:0] = Mem[read_addr];
                                SOut_zd = data_out[7-2*read_cnt];
                                SIOut_zd = data_out[6-2*read_cnt];
                                read_cnt = read_cnt + 1;
                                if (read_cnt == 4)
                                begin
                                    read_cnt = 0;
                                    if (read_addr == AddrRANGE)
                                        read_addr = 0;
                                    else
                                        read_addr = read_addr + 1;
                                end
                            end
                        end
                        else
                        begin
                            SOut_zd = 1'bx;
                            SIOut_zd = 1'bx;
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 4)
                            begin
                                read_cnt = 0;
                                if (read_addr == AddrRANGE)
                                    read_addr = 0;
                                else
                                    read_addr = read_addr + 1;
                            end
                        end
                    end
                    else if (Instruct == QOR || Instruct == QOR4  ||
                            Instruct == QIOR || Instruct == QIOR4 ||
                            Instruct == DDRQIOR || Instruct == DDRQIOR4 )
                    begin
                        //Read Memory array
                        if (Instruct == DDRQIOR || Instruct == DDRQIOR4)
                        begin
                            rd_fast = 1'b0;
                            rd_slow = 1'b0;
                            dual    = 1'b1;
                            ddr     = 1'b1;
                        end
                        else
                        begin
                            rd_fast = 1'b0;
                            rd_slow = 1'b0;
                            dual    = 1'b1;
                            ddr     = 1'b0;
                        end
                        if ((SectorSuspend != read_addr/(SecSize+1)) &&
                        (pgm_page != read_addr / (PageSize+1)))
                        begin
                            if ((Instruct == DDRQIOR || Instruct == DDRQIOR4) &&
                                (VDLR_reg != 8'b00000000) && start_dlp)
                            begin
                                // Data Learning Pattern (DLP)
                                // is enabled Optional DLP
                                data_out[7:0] = VDLR_reg;
                                HOLDNegOut_zd =data_out[7-read_cnt];
                                WPNegOut_zd = data_out[7-read_cnt];
                                SOut_zd = data_out[7-read_cnt];
                                SIOut_zd = data_out[7-read_cnt];
                                read_cnt = read_cnt + 1;
                                if (read_cnt == 8)
                                begin
                                    read_cnt = 0;
                                    start_dlp = 1'b0;
                                end
                            end
                            else
                            begin
                                data_out[7:0] = Mem[read_addr];
                                HOLDNegOut_zd = data_out[7-4*read_cnt];
                                WPNegOut_zd   = data_out[6-4*read_cnt];
                                SOut_zd   = data_out[5-4*read_cnt];
                                SIOut_zd   = data_out[4-4*read_cnt];
                                read_cnt = read_cnt + 1;
                                if (read_cnt == 2)
                                begin
                                    read_cnt = 0;
                                    if (read_addr == AddrRANGE)
                                        read_addr = 0;
                                    else
                                        read_addr = read_addr + 1;
                                end
                            end
                        end
                        else
                        begin
                            HOLDNegOut_zd = 1'bx;
                            WPNegOut_zd   = 1'bx;
                            SOut_zd   = 1'bx;
                            SIOut_zd   = 1'bx;
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 2)
                            begin
                                read_cnt = 0;
                                if (read_addr == AddrRANGE)
                                    read_addr = 0;
                                else
                                    read_addr = read_addr + 1;
                            end
                        end
                    end
                end
                else if (oe_z)
                begin
                    if (Instruct == READ || Instruct == RD4)
                    begin
                        rd_fast = 1'b0;
                        rd_slow = 1'b1;
                        dual    = 1'b0;
                        ddr     = 1'b0;
                    end
                    else if (Instruct == DDRFR || Instruct == DDRFR4)
                    begin
                        rd_fast = 1'b0;
                        rd_slow = 1'b0;
                        dual    = 1'b0;
                        ddr     = 1'b1;
                    end
                    else if (Instruct == DDRDIOR || Instruct == DDRDIOR4)
                    begin
                        rd_fast = 1'b0;
                        rd_slow = 1'b0;
                        dual    = 1'b1;
                        ddr     = 1'b1;
                    end
                    else if (Instruct == DOR || Instruct == DOR4  ||
                             Instruct == DIOR || Instruct == DIOR4 ||
                             Instruct == QOR || Instruct == QOR4  ||
                             Instruct == QIOR || Instruct == QIOR4)
                    begin
                        rd_fast = 1'b0;
                        rd_slow = 1'b0;
                        dual    = 1'b1;
                        ddr     = 1'b0;
                    end
                    else if (Instruct == DDRQIOR || Instruct == DDRQIOR4)
                    begin
                        rd_fast = 1'b0;
                        rd_slow = 1'b0;
                        dual    = 1'b1;
                        ddr     = 1'b1;
                    end
                    else
                    begin
                        rd_fast = 1'b1;
                        rd_slow = 1'b0;
                        dual    = 1'b0;
                        ddr     = 1'b0;
                    end
                    HOLDNegOut_zd = 1'bZ;
                    WPNegOut_zd   = 1'bZ;
                    SOut_zd       = 1'bZ;
                    SIOut_zd      = 1'bZ;
                end

                if (falling_edge_write)
                begin
                    if (Instruct == BRWR)
                    begin
                        Bank_Addr_reg[7] = Bank_Addr_reg_in[7];
                    end
                    else if (Instruct == WRR && BAR_ACC == 1)
                    begin
                    // Write to the lower address bits of the BAR
                        if (P_ERR == 0 && E_ERR == 0)
                        begin
                            $display ("WARNING: Changing values of ");
                            $display ("Bank Address Register");
                            $display ("RFU bits are not allowed!!!");
                        end
                    end
                    else if (Instruct == PGRS)
                    begin
                        Status_reg2[0] = 1'b0;
                        Status_reg1[0] = 1'b1;
                        PGRES = 1'b1;
                        PGRES <= #5 1'b0;
                        RES_TO_SUSP_MIN_TIME = 1'b1;
                        RES_TO_SUSP_MIN_TIME <= #60000 1'b0;//60 ns
                        RES_TO_SUSP_TYP_TIME = 1'b1;
                        RES_TO_SUSP_TYP_TIME <= #100000000 1'b0;//100us
                    end

                    if (Instruct == BRAC && P_ERR == 0 && E_ERR == 0 &&
                        RdPswdProtMode == 0)
                    begin
                        BAR_ACC = 1;
                    end
                    else
                    begin
                        BAR_ACC = 0;
                    end
                end
            end

            OTP_PG:
            begin
                rd_fast = 1'b1;
                rd_slow = 1'b0;
                dual    = 1'b0;
                ddr     = 1'b0;
                if (oe)
                begin
                    any_read = 1'b1;
                    if (Instruct == RDSR)
                    begin
                    //Read Status Register 1
                        SOut_zd = Status_reg1[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDSR2)
                    begin
                    //Read Status Register 2
                        SOut_zd = Status_reg2[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDCR)
                    begin
                        //Read Configuration Register 1
                        SOut_zd = Config_reg1[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                end
                else if (oe_z)
                begin
                    HOLDNegOut_zd = 1'bZ;
                    WPNegOut_zd   = 1'bZ;
                    SOut_zd       = 1'bZ;
                    SIOut_zd      = 1'bZ;
                end

                if(current_state_event && current_state == OTP_PG)
                begin
                    if (~PDONE)
                    begin
                        if (Address + wr_cnt <= OTPHiAddr)
                        begin
                            for (i=0;i<=wr_cnt;i=i+1)
                            begin
                                new_int = WData[i];
                                old_int = OTPMem[Addr + i];
                                if (new_int > -1)
                                begin
                                    new_bit = new_int;
                                    if (old_int > -1)
                                    begin
                                        old_bit = old_int;
                                        for(j=0;j<=7;j=j+1)
                                        begin
                                            if (~old_bit[j])
                                                new_bit[j] = 1'b0;
                                        end
                                        new_int = new_bit;
                                    end
                                    WData[i] = new_int;
                                end
                                else
                                begin
                                    WData[i] = -1;
                                end
                                OTPMem[Addr + i] =  -1;
                            end
                        end
                        else
                        begin
                            $display ("Programming will reach over ");
                            $display ("address limit of OTP array");
                        end
                    end
                end

                if (PDONE)
                begin
                    Status_reg1[0] = 1'b0;
                    Status_reg1[1] = 1'b0;
                    for (i=0;i<=wr_cnt;i=i+1)
                    begin
                        OTPMem[Addr + i] = WData[i];
                    end
                    LOCK_BYTE1 = OTPMem[16];
                    LOCK_BYTE2 = OTPMem[17];
                    LOCK_BYTE3 = OTPMem[18];
                    LOCK_BYTE4 = OTPMem[19];
                end
            end

            SECTOR_ERS:
            begin
                rd_fast = 1'b1;
                rd_slow = 1'b0;
                dual    = 1'b0;
                ddr     = 1'b0;
                if (oe)
                begin
                    any_read = 1'b1;
                    if (Instruct == RDSR)
                    begin
                    //Read Status Register 1
                        SOut_zd = Status_reg1[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDSR2)
                    begin
                    //Read Status Register 2
                        SOut_zd = Status_reg2[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDCR)
                    begin
                        //Read Configuration Register 1
                        SOut_zd = Config_reg1[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                end
                else if (oe_z)
                begin
                    HOLDNegOut_zd = 1'bZ;
                    WPNegOut_zd   = 1'bZ;
                    SOut_zd       = 1'bZ;
                    SIOut_zd      = 1'bZ;
                end

                if(current_state_event && current_state == SECTOR_ERS)
                begin
                    if (~EDONE)
                    begin
                        ADDRHILO_SEC(AddrLo, AddrHi, Addr);
                        for (i=AddrLo;i<=AddrHi;i=i+1)
                        begin
                            Mem[i] = -1;
                        end
                    end
                end

                if (EDONE == 1)
                begin
                    Status_reg1[0] = 1'b0;
                    Status_reg1[1] = 1'b0;
                    for (i=AddrLo;i<=AddrHi;i=i+1)
                    begin
                        Mem[i] = MaxData;

                        pgm_page = i / (PageSize+1);
                    end
                end
                else if (Instruct == ERSP && ~ERSSUSP_in)
                begin
                    ESUSP = 1'b1;
                    ESUSP <= #5 1'b0;
                    ERSSUSP_in = 1'b1;
                    if (RES_TO_SUSP_TYP_TIME)
                    begin
                        $display("Typical periods are needed for ",
                                 "Program to progress to completion");
                    end
                end
            end

            BULK_ERS:
            begin
                rd_fast = 1'b1;
                rd_slow = 1'b0;
                dual    = 1'b0;
                ddr     = 1'b0;
                if (oe)
                begin
                    any_read = 1'b1;
                    if (Instruct == RDSR)
                    begin
                    //Read Status Register 1
                        SOut_zd = Status_reg1[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDSR2)
                    begin
                    //Read Status Register 2
                        SOut_zd = Status_reg2[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDCR)
                    begin
                        //Read Configuration Register 1
                        SOut_zd = Config_reg1[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                end
                else if (oe_z)
                begin
                    HOLDNegOut_zd = 1'bZ;
                    WPNegOut_zd   = 1'bZ;
                    SOut_zd       = 1'bZ;
                    SIOut_zd      = 1'bZ;
                end

                if(current_state_event && current_state == BULK_ERS)
                begin
                    if (~EDONE)
                    begin
                        for (i=0;i<=AddrRANGE;i=i+1)
                        begin
                            ReturnSectorID(sect,i);
                            if (PPB_bits[sect] == 1 && DYB_bits[sect] == 1)
                            begin
                                Mem[i] = -1;
                            end
                        end
                    end
                end

                if (EDONE == 1)
                begin
                    Status_reg1[0] = 1'b0;
                    Status_reg1[1] = 1'b0;
                    for (i=0;i<=AddrRANGE;i=i+1)
                    begin
                        ReturnSectorID(sect,i);
                        if (PPB_bits[sect] == 1 && DYB_bits[sect] == 1)
                        begin
                            Mem[i] = MaxData;

                            pgm_page = i / (PageSize+1);
                        end
                    end
                end
            end

            ERS_SUSP:
            begin
                rd_fast = 1'b1;
                rd_slow = 1'b0;
                dual    = 1'b0;
                ddr     = 1'b0;
                if (ERSSUSP_out == 1)
                begin
                    ERSSUSP_in = 0;
                    //The Erase Suspend (ES) bit in the Status Register will
                    //be set to the logical “1” state to indicate that the
                    //erase operation has been suspended.
                    Status_reg2[1] = 1'b1;
                    //The WIP bit in the Status Register will indicate that
                    //the device is ready for another operation.
                    Status_reg1[0] = 1'b0;
                end

                if (oe)
                begin
                    any_read = 1'b1;
                    if (Instruct == RDSR)
                    begin
                    //Read Status Register 1
                        SOut_zd = Status_reg1[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDSR2)
                    begin
                    //Read Status Register 2
                        SOut_zd = Status_reg2[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDCR)
                    begin
                        //Read Configuration Register 1
                        SOut_zd = Config_reg1[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == DYBRD)
                    begin
                    //Read DYB Access Register
                        ReturnSectorID(sect,Address);
                        rd_fast = 1'b1;
                        rd_slow = 1'b0;
                        dual    = 1'b0;
                        ddr     = 1'b0;
                        if (DYB_bits[sect] == 1)
                            DYBAR[7:0] = 8'hFF;
                        else
                        begin
                            DYBAR[7:0] = 8'h0;
                        end
                        SOut_zd = DYBAR[7-read_cnt];
                        read_cnt  = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == BRRD)
                    begin
                    //Read Bank Address Register
                        rd_fast = 1'b1;
                        rd_slow = 1'b0;
                        dual    = 1'b0;
                        ddr     = 1'b0;
                        SOut_zd = Bank_Addr_reg[7-read_cnt];
                        read_cnt  = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == PPBRD)
                    begin
                    //Read PPB Access Register
                        ReturnSectorID(sect,Address);
                        rd_fast = 1'b1;
                        rd_slow = 1'b0;
                        dual    = 1'b0;
                        ddr     = 1'b0;
                        PPBAR[7:0] = 8'bXXXXXXXX;
                        if (RdPswdProtMode == 0)
                        begin
                            if (PPB_bits[sect] == 1)
                                PPBAR[7:0] = 8'hFF;
                            else
                            begin
                                PPBAR[7:0] = 8'h0;
                            end
                        end
                        SOut_zd = PPBAR[7-read_cnt];
                        read_cnt  = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == READ || Instruct == RD4 ||
                            Instruct == FSTRD || Instruct == FSTRD4 ||
                            Instruct == DDRFR || Instruct == DDRFR4 )
                    begin
                        //Read Memory array
                        if (Instruct == READ || Instruct == RD4)
                        begin
                            rd_fast = 1'b0;
                            rd_slow = 1'b1;
                            dual    = 1'b0;
                            ddr     = 1'b0;
                        end
                        else if (Instruct == DDRFR || Instruct == DDRFR4)
                        begin
                            rd_fast = 1'b0;
                            rd_slow = 1'b0;
                            dual    = 1'b0;
                            ddr     = 1'b1;
                        end
                        else
                        begin
                            rd_fast = 1'b1;
                            rd_slow = 1'b0;
                            dual    = 1'b0;
                            ddr     = 1'b0;
                        end
                        if ((PARAM_REGION &&
                             SectorSuspend != read_addr/(SecSize+1)) ||
                            (~PARAM_REGION &&
                             SectorSuspend != read_addr/(SecSize+1)+30*b_act))
                        begin
                            if ((Instruct == DDRFR || Instruct == DDRFR4) &&
                                (VDLR_reg != 8'b00000000) && start_dlp)
                            begin
                                // Data Learning Pattern (DLP)
                                // is enabled Optional DLP
                                data_out[7:0] = VDLR_reg;
                                SOut_zd  = data_out[7-read_cnt];
                                read_cnt = read_cnt + 1;
                                if (read_cnt == 8)
                                begin
                                    read_cnt  = 0;
                                    start_dlp = 1'b0;
                                end
                            end
                            else
                            begin
                                data_out[7:0] = Mem[read_addr];
                                SOut_zd  = data_out[7-read_cnt];
                                read_cnt = read_cnt + 1;
                                if (read_cnt == 8)
                                begin
                                    read_cnt = 0;
                                    if (read_addr == AddrRANGE)
                                        read_addr = 0;
                                    else
                                        read_addr = read_addr + 1;
                                end
                            end
                        end
                        else
                        begin
                            SOut_zd  = 1'bx;
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 8)
                            begin
                                read_cnt = 0;
                                if (read_addr == AddrRANGE)
                                    read_addr = 0;
                                else
                                    read_addr = read_addr + 1;
                            end
                        end
                    end
                    else if (Instruct == DOR || Instruct == DOR4  ||
                            Instruct == DIOR || Instruct == DIOR4 ||
                            Instruct == DDRDIOR || Instruct == DDRDIOR4 )
                    begin
                        //Read Memory array
                        if (Instruct == DDRDIOR || Instruct == DDRDIOR4)
                        begin
                            rd_fast = 1'b0;
                            rd_slow = 1'b0;
                            dual    = 1'b1;
                            ddr     = 1'b1;
                        end
                        else
                        begin
                            rd_fast = 1'b0;
                            rd_slow = 1'b0;
                            dual    = 1'b1;
                            ddr     = 1'b0;
                        end
                        if ((PARAM_REGION &&
                             SectorSuspend != read_addr/(SecSize+1)) ||
                            (~PARAM_REGION &&
                             SectorSuspend != read_addr/(SecSize+1)+30*b_act))
                        begin
                            if ((Instruct == DDRDIOR || Instruct == DDRDIOR4) &&
                                (VDLR_reg != 8'b00000000) && start_dlp)
                            begin
                                // Data Learning Pattern (DLP)
                                // is enabled Optional DLP
                                data_out[7:0] = VDLR_reg;
                                SOut_zd = data_out[7-read_cnt];
                                SIOut_zd = data_out[7-read_cnt];
                                read_cnt = read_cnt + 1;
                                if (read_cnt == 8)
                                begin
                                    read_cnt  = 0;
                                    start_dlp = 1'b0;
                                end
                            end
                            else
                            begin
                                data_out[7:0] = Mem[read_addr];
                                SOut_zd = data_out[7-2*read_cnt];
                                SIOut_zd = data_out[6-2*read_cnt];
                                read_cnt = read_cnt + 1;
                                if (read_cnt == 4)
                                begin
                                    read_cnt = 0;
                                    if (read_addr == AddrRANGE)
                                        read_addr = 0;
                                    else
                                        read_addr = read_addr + 1;
                                end
                            end
                        end
                        else
                        begin
                            SOut_zd = 1'bx;
                            SIOut_zd = 1'bx;
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 4)
                            begin
                                read_cnt = 0;
                                if (read_addr == AddrRANGE)
                                    read_addr = 0;
                                else
                                    read_addr = read_addr + 1;
                            end
                        end
                    end
                    else if (Instruct == QOR  || Instruct == QOR4  ||
                            Instruct == QIOR || Instruct == QIOR4 ||
                            Instruct == DDRQIOR || Instruct == DDRQIOR4 )
                    begin
                        //Read Memory array
                        if (Instruct == DDRQIOR || Instruct == DDRQIOR4)
                        begin
                            rd_fast = 1'b0;
                            rd_slow = 1'b0;
                            dual    = 1'b1;
                            ddr     = 1'b1;
                        end
                        else
                        begin
                            rd_fast = 1'b0;
                            rd_slow = 1'b0;
                            dual    = 1'b1;
                            ddr     = 1'b0;
                        end
                        if ((PARAM_REGION &&
                             SectorSuspend != read_addr/(SecSize+1)) ||
                            (~PARAM_REGION &&
                             SectorSuspend != read_addr/(SecSize+1)+30*b_act))
                        begin
                            if ((Instruct == DDRQIOR || Instruct == DDRQIOR4) &&
                                (VDLR_reg != 8'b00000000) && start_dlp)
                            begin
                                // Data Learning Pattern (DLP)
                                // is enabled Optional DLP
                                data_out[7:0] = VDLR_reg;
                                HOLDNegOut_zd= data_out[7-read_cnt];
                                WPNegOut_zd  = data_out[7-read_cnt];
                                SOut_zd  = data_out[7-read_cnt];
                                SIOut_zd  = data_out[7-read_cnt];
                                read_cnt = read_cnt + 1;
                                if (read_cnt == 8)
                                begin
                                    read_cnt  = 0;
                                    start_dlp = 1'b0;
                                end
                            end
                            else
                            begin
                                data_out[7:0] = Mem[read_addr];
                                HOLDNegOut_zd = data_out[7-4*read_cnt];
                                WPNegOut_zd   = data_out[6-4*read_cnt];
                                SOut_zd   = data_out[5-4*read_cnt];
                                SIOut_zd   = data_out[4-4*read_cnt];
                                read_cnt = read_cnt + 1;
                                if (read_cnt == 2)
                                begin
                                    read_cnt = 0;
                                    if (read_addr == AddrRANGE)
                                        read_addr = 0;
                                    else
                                        read_addr = read_addr + 1;
                                end
                            end
                        end
                        else
                        begin
                            HOLDNegOut_zd = 1'bx;
                            WPNegOut_zd   = 1'bx;
                            SOut_zd   = 1'bx;
                            SIOut_zd   = 1'bx;
                            if (read_cnt == 2)
                            begin
                                read_cnt = 0;
                                if (read_addr == AddrRANGE)
                                    read_addr = 0;
                                else
                                    read_addr = read_addr + 1;
                            end
                        end
                    end
                end
                else if (oe_z)
                begin
                    if (Instruct == READ || Instruct == RD4)
                    begin
                        rd_fast = 1'b0;
                        rd_slow = 1'b1;
                        dual    = 1'b0;
                        ddr     = 1'b0;
                    end
                    else if (Instruct == DDRFR || Instruct == DDRFR4)
                    begin
                        rd_fast = 1'b0;
                        rd_slow = 1'b0;
                        dual    = 1'b0;
                        ddr     = 1'b1;
                    end
                    else if (Instruct == DDRDIOR || Instruct == DDRDIOR4)
                    begin
                        rd_fast = 1'b0;
                        rd_slow = 1'b0;
                        dual    = 1'b1;
                        ddr     = 1'b1;
                    end
                    else if (Instruct == DOR || Instruct == DOR4  ||
                             Instruct == DIOR || Instruct == DIOR4 ||
                             Instruct == QOR || Instruct == QOR4  ||
                             Instruct == QIOR || Instruct == QIOR4)
                    begin
                        rd_fast = 1'b0;
                        rd_slow = 1'b0;
                        dual    = 1'b1;
                        ddr     = 1'b0;
                    end
                    else if (Instruct == DDRQIOR || Instruct == DDRQIOR4)
                    begin
                        rd_fast = 1'b0;
                        rd_slow = 1'b0;
                        dual    = 1'b1;
                        ddr     = 1'b1;
                    end
                    else
                    begin
                        rd_fast = 1'b1;
                        rd_slow = 1'b0;
                        dual    = 1'b0;
                        ddr     = 1'b0;
                    end
                    HOLDNegOut_zd = 1'bZ;
                    WPNegOut_zd   = 1'bZ;
                    SOut_zd       = 1'bZ;
                    SIOut_zd      = 1'bZ;
                end

                if (falling_edge_write)
                begin
                    if ((Instruct == PP || Instruct == PP4) && WEL == 1)
                    begin
                        if ((PARAM_REGION &&
                             SectorSuspend != Address/(SecSize+1)) ||
                            (~PARAM_REGION &&
                             SectorSuspend != Address/(SecSize+1)+30*b_act))
                        begin
                            ReturnSectorID(sect,Address);
                            if (Sec_Prot[sect] == 0 &&
                                PPB_bits[sect]== 1 && DYB_bits[sect]== 1)
                            begin
                                PSTART = 1'b1;
                                PSTART <= #5 1'b0;
                                PGSUSP  = 0;
                                PGRES   = 0;
                                Status_reg1[0] = 1'b1;
                                SA      = sect;
                                Addr    = Address;
                                Addr_tmp= Address;
                                wr_cnt  = Byte_number;
                                for (i=wr_cnt;i>=0;i=i-1)
                                begin
                                    if (Viol != 0)
                                        WData[i] = -1;
                                    else
                                        WData[i] = WByte[i];
                                end
                            end
                            else
                            begin
                                Status_reg1[1] = 1'b0;
                                Status_reg1[6] = 1'b1;
                            end
                        end
                        else
                        begin
                            Status_reg1[1] = 1'b0;
                            Status_reg1[6] = 1'b1;
                        end
                    end
                    else if ((Instruct == QPP || Instruct == QPP4) && WEL == 1)
                    begin
                        if ((PARAM_REGION &&
                             SectorSuspend != Address/(SecSize+1)) ||
                            (~PARAM_REGION &&
                             SectorSuspend != Address/(SecSize+1)+30*b_act))
                        begin
                            ReturnSectorID(sect,Address);
                            pgm_page = Address / (PageSize+1);

                            if (Sec_Prot[sect] == 0 &&
                                PPB_bits[sect]== 1 && DYB_bits[sect]== 1)
                            begin
                                PSTART = 1'b1;
                                PSTART <= #5 1'b0;
                                PGSUSP  = 0;
                                PGRES   = 0;
                                Status_reg1[0] = 1'b1;
                                SA      = sect;
                                Addr    = Address;
                                Addr_tmp= Address;
                                wr_cnt  = Byte_number;
                                for (i=wr_cnt;i>=0;i=i-1)
                                begin
                                    if (Viol != 0)
                                        WData[i] = -1;
                                    else
                                        WData[i] = WByte[i];
                                end
                            end
                            else
                            begin
                                Status_reg1[1] = 1'b0;
                                Status_reg1[6] = 1'b1;
                            end
                        end
                        else
                        begin
                            Status_reg1[1] = 1'b0;
                            Status_reg1[6] = 1'b1;
                        end
                    end
                    else if (Instruct == WREN)
                        Status_reg1[1] = 1'b1;
                    else if (Instruct == CLSR)
                    begin
                    //The Clear Status Register Command resets bit SR1[5]
                    //(Erase Fail Flag) and bit SR1[6] (Program Fail Flag)
                        Status_reg1[5] = 0;
                        Status_reg1[6] = 0;
                    end
                    else if (Instruct == BRWR)
                    begin
                        Bank_Addr_reg[7] = Bank_Addr_reg_in[7];
                    end
                    else if (Instruct == WRR && BAR_ACC == 1)
                    begin
                    // Write to the lower address bits of the BAR
                        if (P_ERR == 0 && E_ERR == 0)
                        begin
                            $display ("WARNING: Changing values of ");
                            $display ("Bank Address Register");
                            $display ("RFU bits are not allowed!!!");
                        end
                    end
                    else if (Instruct == DYBWR  && WEL == 1)
                    begin
                        ReturnSectorID(sect,Address);
                        pgm_page = Address / (PageSize+1);
                        PSTART = 1'b1;
                        PSTART <= #5 1'b0;
                        Status_reg1[0]    = 1'b1;
                    end
                    else if (Instruct == ERRS)
                    begin
                        Status_reg2[1]  = 1'b0;
                        Status_reg1[0] = 1'b1;
                        if (BottomBoot)
                        begin
                            if (PARAM_REGION)
                            begin
                                Addr = SectorSuspend*(SecSize+1);
                            end
                            else
                            begin
                                Addr = (SectorSuspend-30)*(SecSize+1);
                            end
                        end
                        else
                        begin
                            Addr = SectorSuspend*(SecSize+1);
                        end
                        ADDRHILO_SEC(AddrLo, AddrHi, Addr);
                        ERES = 1'b1;
                        ERES <= #5 1'b0;
                        RES_TO_SUSP_TYP_TIME = 1'b1;
                        RES_TO_SUSP_TYP_TIME <= #100000000 1'b0;//100us
                    end

                    if (Instruct == BRAC && P_ERR == 0 && E_ERR == 0 &&
                        RdPswdProtMode == 0)
                    begin
                        BAR_ACC = 1;
                    end
                    else
                    begin
                        BAR_ACC = 0;
                    end
                end
            end

            ERS_SUSP_PG:
            begin
                rd_fast = 1'b1;
                rd_slow = 1'b0;
                dual    = 1'b0;
                ddr     = 1'b0;
                if (oe)
                begin
                    any_read = 1'b1;
                    if (Instruct == RDSR)
                    begin
                    //Read Status Register 1
                        SOut_zd = Status_reg1[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDSR2)
                    begin
                    //Read Status Register 2
                        SOut_zd = Status_reg2[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDCR)
                    begin
                        //Read Configuration Register 1
                        SOut_zd = Config_reg1[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                end
                else if (oe_z)
                begin
                    HOLDNegOut_zd = 1'bZ;
                    WPNegOut_zd   = 1'bZ;
                    SOut_zd       = 1'bZ;
                    SIOut_zd      = 1'bZ;
                end

                if(current_state_event && current_state == ERS_SUSP_PG)
                begin
                    if (~PDONE)
                    begin
                        ADDRHILO_PG(AddrLo, AddrHi, Addr);
                        cnt = 0;
                        for (i=0;i<=wr_cnt;i=i+1)
                        begin
                            new_int = WData[i];
                            old_int = Mem[Addr + i - cnt];
                            if (new_int > -1)
                            begin
                                new_bit = new_int;
                                if (old_int > -1)
                                begin
                                    old_bit = old_int;
                                    for(j=0;j<=7;j=j+1)
                                    begin
                                        if (~old_bit[j])
                                            new_bit[j] = 1'b0;
                                    end
                                    new_int = new_bit;
                                end
                                WData[i] = new_int;
                            end
                            else
                            begin
                                WData[i] = -1;
                            end

                            if ((Addr + i) == AddrHi)
                            begin
                                Addr = AddrLo;
                                cnt = i + 1;
                            end
                        end
                    end
                    cnt =0;
                end

                if(PDONE == 1)
                begin
                    Status_reg1[0] = 1'b0;//WIP
                    Status_reg1[1] = 1'b0;//WEL
                    for (i=0;i<=wr_cnt;i=i+1)
                    begin
                        Mem[Addr_tmp + i - cnt] = WData[i];
                        if ((Addr_tmp + i) == AddrHi )
                        begin
                            Addr_tmp = AddrLo;
                            cnt = i + 1;
                        end
                    end
                end

                if (Instruct)
                begin
                    if (Instruct == PGSP && ~PRGSUSP_in)
                    begin
                        if (~RES_TO_SUSP_MIN_TIME)
                        begin
                            PGSUSP = 1'b1;
                            PGSUSP <= #5 1'b0;
                            PRGSUSP_in = 1'b1;
                            if (RES_TO_SUSP_TYP_TIME)
                            begin
                                $display("Typical periods are needed for ",
                                         "Program to progress to completion");
                            end
                        end
                        else
                        begin
                            $display("Minimum for tPRS is not satisfied! ",
                                     "PGSP command is ignored");
                        end
                    end
                end
            end

            PASS_PG:
            begin
                rd_fast = 1'b1;
                rd_slow = 1'b0;
                dual    = 1'b0;
                ddr     = 1'b0;
                if (oe)
                begin
                    any_read = 1'b1;
                    if (Instruct == RDSR)
                    begin
                    //Read Status Register 1
                        SOut_zd = Status_reg1[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDSR2)
                    begin
                    //Read Status Register
                        SOut_zd = Status_reg2[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDCR)
                    begin
                        //Read Configuration Register 1
                        SOut_zd = Config_reg1[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                end
                else if (oe_z)
                begin
                    HOLDNegOut_zd = 1'bZ;
                    WPNegOut_zd   = 1'bZ;
                    SOut_zd       = 1'bZ;
                    SIOut_zd      = 1'bZ;
                end

                new_pass = Password_reg_in;
                old_pass = Password_reg;
                for (i=0;i<=63;i=i+1)
                begin
                    if (old_pass[j] == 0)
                        new_pass[j] = 0;
                end

                if (PDONE == 1)
                begin
                    Password_reg = new_pass;
                    Status_reg1[0] = 1'b0;
                    Status_reg1[1] = 1'b0;
                end
            end

            PASS_UNLOCK:
            begin
                rd_fast = 1'b1;
                rd_slow = 1'b0;
                dual    = 1'b0;
                ddr     = 1'b0;
                if (oe)
                begin
                    any_read = 1'b1;
                    if (Instruct == RDSR)
                    begin
                    //Read Status Register 1
                        SOut_zd = Status_reg1[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDSR2)
                    begin
                    //Read Status Register
                        SOut_zd = Status_reg2[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDCR)
                    begin
                        //Read Configuration Register 1
                        SOut_zd = Config_reg1[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                end
                else if (oe_z)
                begin
                    HOLDNegOut_zd = 1'bZ;
                    WPNegOut_zd   = 1'bZ;
                    SOut_zd       = 1'bZ;
                    SIOut_zd      = 1'bZ;
                end

                if (PASS_TEMP == Password_reg)
                begin
                    PASS_UNLOCKED = 1'b1;
                end
                else
                begin
                    PASS_UNLOCKED = 1'b0;
                end
                if (PASSULCK_out == 1'b1)
                begin
                    if ((PASS_UNLOCKED == 1'b1) && (~PWDMLB))
                    begin
                        PPBL[0] = 1'b1;
                        Status_reg1[0] = 1'b0; //WIP
                    end
                    else
                    begin
                        Status_reg1[6] = 1'b1;
                        $display ("Incorrect Password");
                        PASSACC_in = 1'b1;
                    end
                    Status_reg1[1] = 1'b0;
                    PASSULCK_in = 1'b0;
                end
            end

            PPB_PG:
            begin
                rd_fast = 1'b1;
                rd_slow = 1'b0;
                dual    = 1'b0;
                ddr     = 1'b0;
                if (oe)
                begin
                    any_read = 1'b1;
                    if (Instruct == RDSR)
                    begin
                    //Read Status Register 1
                        SOut_zd = Status_reg1[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDSR2)
                    begin
                    //Read Status Register
                        SOut_zd = Status_reg2[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDCR)
                    begin
                        //Read Configuration Register 1
                        SOut_zd = Config_reg1[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                end
                else if (oe_z)
                begin
                    HOLDNegOut_zd = 1'bZ;
                    WPNegOut_zd   = 1'bZ;
                    SOut_zd       = 1'bZ;
                    SIOut_zd      = 1'bZ;
                end

                if (PDONE)
                begin
                    if (PPB_LOCK !== 0)
                    begin
                        PPB_bits[sect]= 1'b0;
                        Status_reg1[0] = 1'b0;
                        Status_reg1[1] = 1'b0;
                    end
                    else
                    begin
                        Status_reg1[5] = 1'b0;
                        Status_reg1[0] = 1'b0;
                        Status_reg1[1] = 1'b0;
                    end
                end
            end

            PPB_ERS:
            begin
                rd_fast = 1'b1;
                rd_slow = 1'b0;
                dual    = 1'b0;
                ddr     = 1'b0;
                if (oe)
                begin
                    any_read = 1'b1;
                    if (Instruct == RDSR)
                    begin
                    //Read Status Register 1
                        SOut_zd = Status_reg1[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDSR2)
                    begin
                    //Read Status Register
                        SOut_zd = Status_reg2[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDCR)
                    begin
                        //Read Configuration Register 1
                        SOut_zd = Config_reg1[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                end
                else if (oe_z)
                begin
                    HOLDNegOut_zd = 1'bZ;
                    WPNegOut_zd   = 1'bZ;
                    SOut_zd       = 1'bZ;
                    SIOut_zd      = 1'bZ;
                end

                if (PPBERASE_out == 1'b1)
                begin
                    if ((PPB_LOCK !== 0) && PPBOTP)
                    begin
                        PPB_bits = {286{1'b1}};
                    end
                    else
                    begin
                        Status_reg1[5] = 1'b1;
                    end
                    Status_reg1[0] = 1'b0;
                    Status_reg1[1] = 1'b0;
                    PPBERASE_in = 1'b0;
                end
            end

            AUTOBOOT_PG:
            begin
                rd_fast = 1'b1;
                rd_slow = 1'b0;
                dual    = 1'b0;
                ddr     = 1'b0;
                if (oe)
                begin
                    any_read = 1'b1;
                    if (Instruct == RDSR)
                    begin
                    //Read Status Register 1
                        SOut_zd = Status_reg1[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDSR2)
                    begin
                    //Read Status Register 2
                        SOut_zd = Status_reg2[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDCR)
                    begin
                        //Read Configuration Register 1
                        SOut_zd = Config_reg1[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                end
                else if (oe_z)
                begin
                    HOLDNegOut_zd = 1'bZ;
                    WPNegOut_zd   = 1'bZ;
                    SOut_zd       = 1'bZ;
                    SIOut_zd      = 1'bZ;
                end

                if (PDONE)
                begin
                    for(i=0;i<=3;i=i+1)
                        for(j=0;j<=7;j=j+1)
                            AutoBoot_reg[i*8+j] =
                            AutoBoot_reg_in[(3-i)*8+j];
                    Status_reg1[0] = 1'b0;
                    Status_reg1[1] = 1'b0;
                end
            end

            PLB_PG:
            begin
                rd_fast = 1'b1;
                rd_slow = 1'b0;
                dual    = 1'b0;
                ddr     = 1'b0;
                if (oe)
                begin
                    any_read = 1'b1;
                    if (Instruct == RDSR)
                    begin
                    //Read Status Register 1
                        SOut_zd = Status_reg1[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDSR2)
                    begin
                    //Read Status Register
                        SOut_zd = Status_reg2[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDCR)
                    begin
                        //Read Configuration Register 1
                        SOut_zd = Config_reg1[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                end
                else if (oe_z)
                begin
                    HOLDNegOut_zd = 1'bZ;
                    WPNegOut_zd   = 1'bZ;
                    SOut_zd       = 1'bZ;
                    SIOut_zd      = 1'bZ;
                end

                if (PDONE)
                begin
                    PPBL[0] = 1'b0;
                    Status_reg1[0] = 1'b0;
                    Status_reg1[1] = 1'b0;
                end
            end

            DYB_PG:
            begin
                rd_fast = 1'b1;
                rd_slow = 1'b0;
                dual    = 1'b0;
                ddr     = 1'b0;
                if (oe)
                begin
                    any_read = 1'b1;
                    if (Instruct == RDSR)
                    begin
                    //Read Status Register 1
                        SOut_zd = Status_reg1[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDSR2)
                    begin
                    //Read Status Register
                        SOut_zd = Status_reg2[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDCR)
                    begin
                        //Read Configuration Register 1
                        SOut_zd = Config_reg1[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                end
                else if (oe_z)
                begin
                    HOLDNegOut_zd = 1'bZ;
                    WPNegOut_zd   = 1'bZ;
                    SOut_zd       = 1'bZ;
                    SIOut_zd      = 1'bZ;
                end

                if (PDONE)
                begin
                    DYBAR = DYBAR_in;
                    if (DYBAR == 8'hFF)
                    begin
                        DYB_bits[sect]= 1'b1;
                    end
                    else if (DYBAR == 8'h00)
                    begin
                        DYB_bits[sect]= 1'b0;
                    end
                    else
                    begin
                        Status_reg1[6] = 1'b1;
                    end
                    Status_reg1[0] = 1'b0;
                    Status_reg1[1] = 1'b0;
                end
            end

            ASP_PG:
            begin
                rd_fast = 1'b1;
                rd_slow = 1'b0;
                dual    = 1'b0;
                ddr     = 1'b0;
                if (oe)
                begin
                    any_read = 1'b1;
                    if (Instruct == RDSR)
                    begin
                    //Read Status Register 1
                        SOut_zd = Status_reg1[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDSR2)
                    begin
                    //Read Status Register
                        SOut_zd = Status_reg2[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDCR)
                    begin
                        //Read Configuration Register 1
                        SOut_zd = Config_reg1[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                end
                else if (oe_z)
                begin
                    HOLDNegOut_zd = 1'bZ;
                    WPNegOut_zd   = 1'bZ;
                    SOut_zd       = 1'bZ;
                    SIOut_zd      = 1'bZ;
                end

                if (PDONE)
                begin

                    if (RPME == 1'b0 && ASP_reg_in[5] == 1'b1)
                    begin
                       Status_reg1[6] = 1'b1; //P_ERR
                       $display("RPME bit is allready programmed");
                    end
                    else
                    begin
                        ASP_reg[5] = ASP_reg_in[5];//RPME
                    end

                    if (PPBOTP == 1'b0 && ASP_reg_in[3] == 1'b1)
                    begin
                       Status_reg1[6] = 1'b1; //P_ERR
                       $display("PPBOTP bit is allready programmed");
                    end
                    else
                    begin
                        ASP_reg[3] = ASP_reg_in[3];//PPBOTP
                    end

                    if (PWDMLB == 1'b1 && PSTMLB == 1'b1)
                    begin
                        if (ASP_reg_in[2] == 1'b0 && ASP_reg_in[1] == 1'b0)
                        begin
                            $display("ASPR[2:1] = 00  Illegal condition");
                            Status_reg1[6] = 1'b1; //P_ERR
                        end
                        else
                        begin
                            if (ASP_reg_in[2]!==1'b1 || ASP_reg_in[1]!==1'b1)
                            begin
                                ASPOTPFLAG = 1'b1;
                            end
                            ASP_reg[2] = ASP_reg_in[2];//PWDMLB
                            ASP_reg[1] = ASP_reg_in[1];//PSTMLB
                        end
                    end

                    Status_reg1[0] = 1'b0;
                    Status_reg1[1] = 1'b0;
                end
            end

            NVDLR_PG:
            begin
                rd_fast = 1'b1;
                rd_slow = 1'b0;
                dual    = 1'b0;
                ddr     = 1'b0;
                if (oe)
                begin
                    any_read = 1'b1;
                    if (Instruct == RDSR)
                    begin
                    //Read Status Register 1
                        SOut_zd = Status_reg1[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDSR2)
                    begin
                    //Read Status Register
                        SOut_zd = Status_reg2[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDCR)
                    begin
                        //Read Configuration Register 1
                        SOut_zd = Config_reg1[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                end
                else if (oe_z)
                begin
                    HOLDNegOut_zd = 1'bZ;
                    WPNegOut_zd   = 1'bZ;
                    SOut_zd       = 1'bZ;
                    SIOut_zd      = 1'bZ;
                end

                if (PDONE)
                begin
                    if (NVDLR_reg == 0)
                    begin
                        NVDLR_reg = NVDLR_reg_in;
                        VDLR_reg = NVDLR_reg_in;
                        Status_reg1[0] = 1'b0;
                        Status_reg1[1] = 1'b0;
                    end
                    else
                    begin
                        Status_reg1[0] = 1'b0;
                        Status_reg1[1] = 1'b0;
                        Status_reg1[6] = 1'b1; //P_ERR
                        $display("NVDLR bits allready programmed");
                    end
                end
            end

            RESET_STATE:
            begin
            //the default condition hardware reset
            //The Bank Address Register is loaded to all zeroes
                Bank_Addr_reg = 8'h0;
                if (BPNV && ~FREEZE) //&& ~LOCK 
                begin
                    Status_reg1[2] = 1'b1;// BP0
                    Status_reg1[3] = 1'b1;// BP1
                    Status_reg1[4] = 1'b1;// BP2
                    BP_bits = 3'b111;
                    change_BP = 1'b1;
                    #1000 change_BP = 1'b0;
                end
                //Resets the volatile bits in the Status register 1
                Status_reg1[6] = 1'b0;
                Status_reg1[5] = 1'b0;
                Status_reg1[1] = 1'b0;
                Status_reg1[0] = 1'b0;
                //Resets the volatile bits in the Status register 2
                Status_reg2[1] = 1'b0;
                Status_reg2[0] = 1'b0;
                //Resets the volatile bits in the Configuration register 1
                Config_reg1[0] = 1'b0;
                //On reset cycles the data pattern reverts back
                //to what is in the NVDLR
                VDLR_reg = NVDLR_reg;
                start_dlp = 1'b0;
                //Loads the Program Buffer with all ones
                for(i=0;i<=511;i=i+1)
                begin
                    WData[i] = MaxData;
                end
                if (~PWDMLB)
                    PPBL[0] = 1'b0;
                else
                    PPBL[0] = 1'b1;
            end

        endcase

        //Output Disable Control
        if (CSNeg_ipd )
        begin
            SOut_zd = 1'bZ;
            SIOut_zd = 1'bZ;
            HOLDNegOut_zd = 1'bZ;
            WPNegOut_zd = 1'bZ;
        end
    end

    assign fast_rd = rd_fast;
    assign rd = rd_slow;
    assign ddrd = ddr && ~ddr80;
    assign ddrd80 = ddr && ddr80;
    assign fast_ddr = ddr_fast;

    always @(change_TBPARM, posedge PoweredUp)
    begin
        if (tmp_char2 == "0")
        begin
            if (TBPARM == 0)
            begin
                BottomBoot = 1;
                b_act = 1;
            end
            else
            begin
                TopBoot     = 1;
                BottomBoot  = 0;
                b_act = 0;
            end
        end
        else if (tmp_char2 == "1")
        begin
            UniformSec = 1;
        end
    end

    always @(posedge change_BP)
    begin
        case (Status_reg1[4:2])

            3'b000:
                Sec_Prot[285:0] = {286{1'b0}};

            3'b001:
            begin
                if (tmp_char2 == "1")
                begin
                    if (~TBPROT)
                    begin
                        Sec_Prot[SecNum256:(SecNum256+1)*63/64] = 1'b1;
                        Sec_Prot[(SecNum256+1)*63/64-1 : 0] = {63{1'b0}};
                    end
                    else
                    begin
                        Sec_Prot[(SecNum256+1)/64-1 : 0] = 1'b1;
                        Sec_Prot[SecNum256 : (SecNum256+1)/64] = {63{1'b0}};
                    end
                end
                else if (tmp_char2 == "0" && TBPARM == 1)
                begin
                    if (~TBPROT)
                    begin
                        Sec_Prot[SecNum64:(SecNum64-29)*63/64] = {34{1'b1}};
                        Sec_Prot[(SecNum64-29)*63/64-1 : 0]    = {252{1'b0}};
                    end
                    else
                    begin
                        Sec_Prot[(SecNum64-29)/64-1 : 0] = {4{1'b1}};
                        Sec_Prot[SecNum64 : (SecNum64-29)/64] = {282{1'b0}};
                    end
                end
                else
                begin
                    if (~TBPROT)
                    begin
                        Sec_Prot[SecNum64:(SecNum64-29)*63/64+30] = {4{1'b1}};
                        Sec_Prot[(SecNum64-29)*63/64+29 : 0] = {282{1'b0}};
                    end
                    else
                    begin
                        Sec_Prot[(SecNum64-29)/64+29 : 0]        = {34{1'b1}};
                        Sec_Prot[SecNum64 : (SecNum64-29)/64+30] = {252{1'b0}};
                    end
                end
            end

            3'b010:
            begin
                if (tmp_char2 == "1")
                begin
                    if (~TBPROT)
                    begin
                        Sec_Prot[SecNum256 : (SecNum256+1)*31/32] = {2{1'b1}};
                        Sec_Prot[(SecNum256+1)*31/32-1 : 0] = {62{1'b0}};
                    end
                    else
                    begin
                        Sec_Prot[(SecNum256+1)/32-1 : 0] = {2{1'b1}};
                        Sec_Prot[SecNum256 : (SecNum256+1)/32] = {62{1'b0}};
                    end
                end
                else if (tmp_char2 == "0" && TBPARM == 1)
                begin
                    if (~TBPROT)
                    begin
                        Sec_Prot[SecNum64 : (SecNum64-29)*31/32] = {38{1'b1}};
                        Sec_Prot[(SecNum64-29)*31/32-1 : 0] = {248{1'b0}};
                    end
                    else
                    begin
                        Sec_Prot[(SecNum64-29)/32-1 : 0] = {8{1'b1}};
                        Sec_Prot[SecNum64 : (SecNum64-29)/32] = {278{1'b0}};
                    end
                end
                else
                begin
                    if (~TBPROT)
                    begin
                        Sec_Prot[SecNum64:(SecNum64-29)*31/32+30] = {8{1'b1}};
                        Sec_Prot[(SecNum64-29)*31/32+29 : 0] = {278{1'b0}};
                    end
                    else
                    begin
                        Sec_Prot[(SecNum64-29)/32+29 : 0] = {38{1'b1}};
                        Sec_Prot[SecNum64 : (SecNum64-29)/32+30] = {248{1'b0}};
                    end
                end
            end

            3'b011:
            begin
                if (tmp_char2 == "1")
                begin
                    if (~TBPROT)
                    begin
                        Sec_Prot[SecNum256 : (SecNum256+1)*15/16] = 4'b1111;
                        Sec_Prot[(SecNum256+1)*15/16-1 : 0] = {60{1'b0}};
                    end
                    else
                    begin
                        Sec_Prot[(SecNum256+1)/16-1 : 0] = 4'b1111;
                        Sec_Prot[SecNum256 : (SecNum256+1)/16] = {60{1'b0}};
                    end
                end
                else if (tmp_char2 == "0" && TBPARM == 1)
                begin
                    if (~TBPROT)
                    begin
                        Sec_Prot[SecNum64 : (SecNum64-29)*15/16] = {46{1'b1}};
                        Sec_Prot[(SecNum64-29)*15/16-1 : 0] = {240{1'b0}};
                    end
                    else
                    begin
                        Sec_Prot[(SecNum64-29)/16-1 : 0] = {16{1'b1}};
                        Sec_Prot[SecNum64 : (SecNum64-29)/16] = {270{1'b0}};
                    end
                end
                else
                begin
                    if (~TBPROT)
                    begin
                        Sec_Prot[SecNum64 : (SecNum64-29)*15/16+30] ={16{1'b1}};
                        Sec_Prot[(SecNum64-29)*15/16+29 : 0] = {270{1'b0}};
                    end
                    else
                    begin
                        Sec_Prot[(SecNum64-29)/16+29 : 0] ={46{1'b1}};
                        Sec_Prot[SecNum64 : (SecNum64-29)/16+30] = {240{1'b0}};
                    end
                end
            end

            3'b100:
            begin
                if (tmp_char2 == "1")
                begin
                    if (~TBPROT)
                    begin
                        Sec_Prot[SecNum256 : (SecNum256+1)*7/8] = {8{1'b1}};
                        Sec_Prot[(SecNum256+1)*7/8-1 : 0] = {278{1'b0}};
                    end
                    else
                    begin
                        Sec_Prot[(SecNum256+1)/8-1 : 0] = {8{1'b1}};
                        Sec_Prot[SecNum256 : (SecNum256+1)/8] = {278{1'b0}};
                    end
                end
                else if (tmp_char2 == "0" && TBPARM == 1)
                begin
                    if (~TBPROT)
                    begin
                        Sec_Prot[SecNum64 : (SecNum64-29)*7/8] = {62{1'b1}};
                        Sec_Prot[(SecNum64-29)*7/8-1 : 0] = {224{1'b0}};
                    end
                    else
                    begin
                        Sec_Prot[(SecNum64-29)/8-1 : 0] = {32{1'b1}};
                        Sec_Prot[SecNum64 : (SecNum64-29)/8] = {254{1'b0}};
                    end
                end
                else
                begin
                    if (~TBPROT)
                    begin
                        Sec_Prot[SecNum64 : (SecNum64-29)*7/8+30] ={32{1'b1}};
                        Sec_Prot[(SecNum64-29)*7/8+29 : 0] = {254{1'b0}};
                    end
                    else
                    begin
                        Sec_Prot[(SecNum64-29)/8+29 : 0] = {62{1'b1}};
                        Sec_Prot[SecNum64 : (SecNum64-29)/8+30] = {224{1'b0}};
                    end
                end
            end

            3'b101:
            begin
                if (tmp_char2 == "1")
                begin
                    if (~TBPROT)
                    begin
                        Sec_Prot[SecNum256 : (SecNum256+1)*3/4] = {16{1'b1}};
                        Sec_Prot[(SecNum256+1)*3/4-1 : 0] = {270{1'b0}};
                    end
                    else
                    begin
                        Sec_Prot[(SecNum256+1)/4-1 : 0] = {16{1'b1}};
                        Sec_Prot[SecNum256 : (SecNum256+1)/4] = {270{1'b0}};
                    end
                end
                else if (tmp_char2 == "0" && TBPARM == 1)
                begin
                    if (~TBPROT)
                    begin
                        Sec_Prot[SecNum64 : (SecNum64-29)*3/4] = {94{1'b1}};
                        Sec_Prot[(SecNum64-29)*3/4-1 : 0] = {192{1'b0}};
                    end
                    else
                    begin
                        Sec_Prot[(SecNum64-29)/4-1 : 0] = {64{1'b1}};
                        Sec_Prot[SecNum64 : (SecNum64-29)/4] = {222{1'b0}};
                    end
                end
                else
                begin
                    if (~TBPROT)
                    begin
                        Sec_Prot[SecNum64 : (SecNum64-29)*3/4+30] = {64{1'b1}};
                        Sec_Prot[(SecNum64-29)*3/4+29 : 0] = {222{1'b0}};
                    end
                    else
                    begin
                        Sec_Prot[(SecNum64-29)/4+29 : 0] = {94{1'b1}};
                        Sec_Prot[SecNum64 : (SecNum64-29)/4+30] = {192{1'b0}};
                    end
                end
            end

            3'b110:
            begin
                if (tmp_char2 == "1")
                begin
                    if (~TBPROT)
                    begin
                        Sec_Prot[SecNum256 : (SecNum256+1)/2] = {32{1'b1}};
                        Sec_Prot[(SecNum256+1)/2-1 : 0] = {32{1'b0}};
                    end
                    else
                    begin
                        Sec_Prot[(SecNum256+1)/2-1 : 0] = {32{1'b1}};
                        Sec_Prot[SecNum256 : (SecNum256+1)/2] = {32{1'b0}};
                    end
                end
                else if (tmp_char2 == "0" && TBPARM == 1)
                begin
                    if (~TBPROT)
                    begin
                        Sec_Prot[SecNum64 : (SecNum64-29)/2] = {158{1'b1}};
                        Sec_Prot[(SecNum64-29)/2-1 : 0] = {128{1'b0}};
                    end
                    else
                    begin
                        Sec_Prot[(SecNum64-29)/2-1 : 0] = {128{1'b1}};
                        Sec_Prot[SecNum64 : (SecNum64-29)/2] = {158{1'b0}};
                    end
                end
                else
                begin
                    if (~TBPROT)
                    begin
                        Sec_Prot[SecNum64 : (SecNum64-29)/2+30] = {128{1'b1}};
                        Sec_Prot[(SecNum64-29)/2+29 : 0] = {158{1'b0}};
                    end
                    else
                    begin
                        Sec_Prot[(SecNum64-29)/2+29 : 0] = {158{1'b1}};
                        Sec_Prot[SecNum64 : (SecNum64-29)/2+30] = {128{1'b0}};
                    end
                end
            end

            3'b111:
            begin
                Sec_Prot[SecNum64:0] =  {286{1'b1}};
            end
        endcase
    end

    always @(SOut_zd or HOLDNeg_in or SIOut_zd)
    begin
        if (HOLDNeg_in == 0 && ~QUAD)
        begin
            hold_mode = 1'b1;
            SIOut_z   = 1'bZ;
            SOut_z    = 1'bZ;
        end
        else
        begin
            if (hold_mode == 1)
            begin
                SIOut_z <= #(tpd_HOLDNeg_SO) SIOut_zd;
                SOut_z  <= #(tpd_HOLDNeg_SO) SOut_zd;
                hold_mode = #(tpd_HOLDNeg_SO) 1'b0;
            end
            else
            begin
                SIOut_z = SIOut_zd;
                SOut_z  = SOut_zd;
                hold_mode = 1'b0;
            end
        end
    end

    ////////////////////////////////////////////////////////////////////////
    // autoboot control logic
    ////////////////////////////////////////////////////////////////////////
    always @(rising_edge_SCK_ipd or current_state_event)
    begin
        if(current_state == AUTOBOOT)
        begin
            if (rising_edge_SCK_ipd)
            begin
                if (start_delay > 0)
                    start_delay = start_delay - 1;
            end

            if (start_delay == 0)
            begin
                start_autoboot = 1;
            end
        end
    end

    ////////////////////////////////////////////////////////////////////////
    // functions & tasks
    ////////////////////////////////////////////////////////////////////////
    // Procedure FDDR_DPL
task Return_DLP;
    input integer Instruct;
    input integer EHP;
    input integer Latency_code;
    input integer dummy_cnt;
    inout start_dlp;
    begin
        if (Instruct == DDRFR || Instruct == DDRFR4)
        begin
            if (EHP)
            begin
                if (Latency_code == 1)
                    start_dlp = 1'b1;
                else if (Latency_code == 2 && dummy_cnt >= 1)
                    start_dlp = 1'b1;
                else if(Latency_code == 3 || Latency_code == 0)
                begin
                    start_dlp = 1'b0;
                    $display("Warning at", $time);
                    $display("Inappropriate latency is set during DPL mode");
                end
            end
            else
            begin

                if (Latency_code == 3)
                    start_dlp = 1'b1;
                else if (Latency_code == 0 && dummy_cnt >= 1)
                    start_dlp = 1'b1;
                else if(Latency_code == 1 && dummy_cnt >= 2)
                    start_dlp = 1'b1;
                else if(Latency_code == 2 && dummy_cnt >= 3)
                    start_dlp = 1'b1;
                else
                    start_dlp = 1'b0;
            end
        end
        if (Instruct == DDRDIOR || Instruct == DDRDIOR4)
        begin
            if (EHP)
            begin
                if (Latency_code == 1 && dummy_cnt >= 1)
                    start_dlp = 1'b1;
                else if (Latency_code == 2 && dummy_cnt >= 2)
                    start_dlp = 1'b1;
                else if( Latency_code == 3 || Latency_code == 0)
                begin
                    start_dlp = 1'b0;
                    $display("Warning at", $time);
                    $display("Inappropriate latency is set during DPL mode");
                end
                else
                    start_dlp = 1'b0;
            end
            else
            begin
                if (Latency_code == 0 && dummy_cnt >= 2)
                    start_dlp = 1'b1;
                else if (Latency_code == 1 && dummy_cnt >= 3)
                    start_dlp = 1'b1;
                else if(Latency_code == 2 && dummy_cnt >= 4)
                    start_dlp = 1'b1;
                else
                    start_dlp = 1'b0;
            end
        end
        if ((Instruct == DDRQIOR || Instruct == DDRQIOR4) && QUAD)
        begin
            if (EHP)
            begin
                if (Latency_code == 0 && dummy_cnt >= 2)
                    start_dlp = 1'b1;
                else if (Latency_code == 1 && dummy_cnt >= 3)
                    start_dlp = 1'b1;
                else if (Latency_code == 2 && dummy_cnt >= 4)
                    start_dlp = 1'b1;
                else if( Latency_code == 3)
                begin
                    start_dlp = 1'b0;
                    $display("Warning at", $time);
                    $display("Inappropriate latency is");
                    $display("set during DPL mode");
                end
                else
                    start_dlp  = 1'b0;

            end
            else
            begin
                if (Latency_code == 0 && dummy_cnt >= 2)
                    start_dlp = 1'b1;
                else if (Latency_code == 1 && dummy_cnt >= 3)
                    start_dlp = 1'b1;
                else if (Latency_code == 2 && dummy_cnt >= 4)
                    start_dlp = 1'b1;
                else if( Latency_code == 3)
                begin
                    start_dlp = 1'b0;
                    $display("Warning at", $time);
                    $display("Inappropriate latency is");
                    $display("set during DPL mode");
                end
                else
                    start_dlp = 1'b0;
            end
        end
    end
    endtask

    function integer ReturnSectorIDRdPswdMd;
        input reg TBPROT;
    begin
        if(TBPROT == 0)
        begin
            ReturnSectorIDRdPswdMd = 0;
        end
        else
        begin
            if (UniformSec)
            begin
                ReturnSectorIDRdPswdMd = SecNum256;
            end
            else
            begin
                ReturnSectorIDRdPswdMd = 255;
            end
        end
    end
    endfunction

    // Procedure ADDRHILO_SEC
    task ADDRHILO_SEC;
    inout  AddrLOW;
    inout  AddrHIGH;
    input   Addr;
    integer AddrLOW;
    integer AddrHIGH;
    integer Addr;
    integer sector;
    begin
        if (tmp_char2 == "0")
        begin
            if (TBPARM == 0)
            begin
                if (Addr/(SecSize64+1) <= 1 &&
                   (Instruct == P4E || Instruct == P4E4))  //4KB Sectors
                begin
                    sector   = Addr/(SecSize4+1);
                    AddrLOW  = sector*(SecSize4+1);
                    AddrHIGH = sector*(SecSize4+1) + SecSize4;
                end
                else
                begin
                    sector   = Addr/(SecSize64+1);
                    AddrLOW  = sector*(SecSize64+1);
                    AddrHIGH = sector*(SecSize64+1) + SecSize64;
                end
            end
            else
            begin
                if (Addr/(SecSize64+1) >= 254 &&
                   (Instruct == P4E || Instruct == P4E4)) //4KB Sectors
                begin
                    sector   = 254 + (Addr-(SecSize64+1)*254)/(SecSize4+1);
                    AddrLOW  = 254*(SecSize64+1)+(sector-254)*(SecSize4+1);
                    AddrHIGH = 254*(SecSize64+1)+(sector-254)*(SecSize4+1)
                                                                     + SecSize4;
                end
                else
                begin
                    sector   = Addr/(SecSize64+1);
                    AddrLOW  = sector*(SecSize64+1);
                    AddrHIGH = sector*(SecSize64+1) + SecSize64;
                end
            end
        end
        else if (tmp_char2 == "1")
        begin
            sector   = Addr/(SecSize256+1);
            AddrLOW  = sector*(SecSize256+1);
            AddrHIGH = sector*(SecSize256+1) + SecSize256;
        end
    end
    endtask

    // Procedure ADDRHILO_PG
    task ADDRHILO_PG;
    inout  AddrLOW;
    inout  AddrHIGH;
    input   Addr;
    integer AddrLOW;
    integer AddrHIGH;
    integer Addr;
    integer page;
    begin
        page = Addr / (PageSize + 1);
        AddrLOW = page * (PageSize + 1);
        AddrHIGH = page * (PageSize + 1) + PageSize ;
    end
    endtask

    // Procedure ReturnSectorID
    task ReturnSectorID;
    inout   sect;
    input   Address;
    integer sect;
    integer Address;
    integer conv;
    begin
        if (tmp_char2 == "0")
        begin
            conv = Address / (SecSize64+1);
            if (BottomBoot)
            begin
                if (conv <= 1)      //4KB Sectors
                begin
                    sect = Address/(SecSize4+1);
                end
                else
                begin
                    sect = conv + 30;
                end
            end
            else if (TopBoot)
            begin
                if (conv >= 254)       //4KB Sectors
                begin
                    sect = 254 + (Address-(SecSize64+1)*254)/(SecSize4+1);
                end
                else
                begin
                    sect = conv;
                end
            end
        end
        else
        begin
            sect = Address/(SecSize256+1);
        end
    end
    endtask

    always @(PPBL[0], ASP_reg)
    begin
        if (PPBL[0] == 0 && PWDMLB == 0 && RPME == 0 && RdPswdProtEnable)
        begin
            RdPswdProtMode = 1;
            AutoBoot_reg[0] = 0;//AUTOBOOT is disabled when Read Password
        end                     //Protection is enabled
        else
        begin
            RdPswdProtMode = 0;
        end
    end

    ///////////////////////////////////////////////////////////////////////////
    // edge controll processes
    ///////////////////////////////////////////////////////////////////////////

    always @(posedge PoweredUp)
    begin
        rising_edge_PoweredUp = 1;
        #1000 rising_edge_PoweredUp = 0;
    end

    always @(posedge SCK_ipd)
    begin
       rising_edge_SCK_ipd = 1'b1;
       #1000 rising_edge_SCK_ipd = 1'b0;
    end

    always @(negedge SCK_ipd)
    begin
       falling_edge_SCK_ipd = 1'b1;
       #1000 falling_edge_SCK_ipd = 1'b0;
    end

    always @(posedge read_out)
    begin
        rising_edge_read_out = 1'b1;
        #1000 rising_edge_read_out = 1'b0;
    end

    always @(negedge write)
    begin
        falling_edge_write = 1;
        #1000 falling_edge_write = 0;
    end

    always @(posedge PRGSUSP_out)
    begin
        PRGSUSP_out_event = 1;
        #1000 PRGSUSP_out_event = 0;
    end

    always @(posedge ERSSUSP_out)
    begin
        ERSSUSP_out_event = 1;
        #1000 ERSSUSP_out_event = 0;
    end

    always @(posedge CSNeg_ipd)
    begin
        rising_edge_CSNeg_ipd = 1'b1;
        #1000 rising_edge_CSNeg_ipd = 1'b0;
    end

    always @(negedge CSNeg_ipd)
    begin
        falling_edge_CSNeg_ipd = 1'b1;
        #1000 falling_edge_CSNeg_ipd = 1'b0;
    end

    always @(negedge RSTNeg_in)
    begin
        falling_edge_RSTNeg = 1'b1;
        #50000 falling_edge_RSTNeg = 1'b0;
    end

    always @(posedge RSTNeg_in)
    begin
        rising_edge_RSTNeg = 1'b1;
        #10000 rising_edge_RSTNeg = 1'b0;
    end

    always @(negedge RST)
    begin
        falling_edge_RST = 1'b1;
        #10000 falling_edge_RST = 1'b0;
    end

    always @(posedge RST)
    begin
        rising_edge_RST = 1'b1;
        #1000 rising_edge_RST = 1'b0;
    end

    always @(posedge PDONE)
    begin
        rising_edge_PDONE = 1'b1;
        #1000 rising_edge_PDONE = 1'b0;
    end

    always @(posedge WDONE)
    begin
        rising_edge_WDONE = 1'b1;
        #1000 rising_edge_WDONE = 1'b0;
    end

    always @(posedge WSTART)
    begin
        rising_edge_WSTART = 1'b1;
        #1000 rising_edge_WSTART = 1'b0;
    end

    always @(posedge EDONE)
    begin
        rising_edge_EDONE = 1'b1;
        #1000 rising_edge_EDONE = 1'b0;
    end

    always @(posedge ESTART)
    begin
        rising_edge_ESTART = 1'b1;
        #1000 rising_edge_ESTART = 1'b0;
    end

    always @(posedge PSTART)
    begin
        rising_edge_PSTART = 1'b1;
        #1000 rising_edge_PSTART = 1'b0;
    end

    always @(posedge Reseted)
    begin
        rising_edge_Reseted = 1'b1;
        #1000 rising_edge_Reseted = 1'b0;
    end

    always @(negedge PASSULCK_in)
    begin
        falling_edge_PASSULCK_in = 1'b1;
        #1000 falling_edge_PASSULCK_in = 1'b0;
    end

    always @(negedge PPBERASE_in)
    begin
        falling_edge_PPBERASE_in = 1'b1;
        #1000 falling_edge_PPBERASE_in = 1'b0;
    end

    always @(Instruct)
    begin
        Instruct_event = 1'b1;
        #1000 Instruct_event = 1'b0;
    end

    always @(change_addr)
    begin
        change_addr_event = 1'b1;
        #1000 change_addr_event = 1'b0;
    end

    always @(next_state)
    begin
        next_state_event = 1'b1;
        #1000 next_state_event = 1'b0;
    end

    always @(current_state)
    begin
        current_state_event = 1'b1;
        #1000 current_state_event = 1'b0;
    end

    always @(posedge RST_out)
    begin
        rising_edge_RST_out = 1'b1;
        #1000 rising_edge_RST_out = 1'b0;
    end

endmodule
