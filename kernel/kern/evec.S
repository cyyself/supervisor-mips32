#include <regdef.h>
#include <mipsregs.h> 


    .set noreorder
    .set noat
    .p2align 2
    .section .text.init
    .global INITLOCATE
INITLOCATE:                         // 定位启动程序
#ifdef MACH_FPGA
    //拷贝例外处理代码到0xa0001000段
    //不拷贝到0x80001000段，是避免Cache一致性问题
    la  t0, _text_ebase_begin
    la  t1, _text_ebase_end
    li  t2, 0xa0000000
    or  t0, t0, t2
    or  t1, t1, t2
    li  t2, 0xbfc00000
    or  t2, t2, t0
1:
    lw    t3, 0(t2)
    addiu t2, t2, 4
    sw    t3, 0(t0)
    addiu t0, t0, 4
    bne   t0, t1, 1b
    nop

    //拷贝监控程序代码到0xa0002000段
    la  t0, _text_code_begin
    la  t1, _text_code_end
    li  t2, 0xa0000000
    or  t0, t0, t2
    or  t1, t1, t2
    li  t2, 0xbfc00000
    or  t2, t2, t0
1:
    lw    t3, 0(t2)
    addiu t2, t2, 4
    sw    t3, 0(t0)
    addiu t0, t0, 4
    bne   t0, t1, 1b
    nop
    
    //拷贝测试程序代码
    la  t0, _text_test_begin
    la  t1, _text_test_end
    li  t2, 0xa0000000
    or  t0, t0, t2
    or  t1, t1, t2
    li  t2, 0xbfc00000
    or  t2, t2, t0
1:
    lw    t3, 0(t2)
    addiu t2, t2, 4
    sw    t3, 0(t0)
    addiu t0, t0, 4
    bne   t0, t1, 1b
    nop
#endif
    
    //跳转到START
    lui k0, %hi(START)
    addiu k0, %lo(START)
    jr k0
    nop
#ifdef MACH_FPGA
#ifdef ENABLE_INT
    .org 0x380
EHANDLERLOCATE_380:                 // 定位普通中断处理程序, 0xbfc00380
    lui k0, %hi(EXCEPTIONHANDLER)
    addiu k0, %lo(EXCEPTIONHANDLER)
    jr k0
    nop
#endif
#endif

// 以下是异常处理的代码

#ifdef ENABLE_INT
    .section .text.ebase180
EHANDLERLOCATE:                     // 定位普通中断处理程序, 0x80001180
    lui k0, %hi(EXCEPTIONHANDLER)
    addiu k0, %lo(EXCEPTIONHANDLER)
    jr k0
    nop
#endif

#ifdef ENABLE_TLB
    .section .text.ebase
TLBREFILL:                          // TLB快速重填
    mfc0 k1, CP0_CONTEXT
    lw k0, 0x0(k1)
    lw k1, 0x8(k1)
    mtc0 k0, CP0_ENTRYLO0
    mtc0 k1, CP0_ENTRYLO1
    nop
    tlbwr
    eret
    nop
#endif


    .set reorder
    .set at
