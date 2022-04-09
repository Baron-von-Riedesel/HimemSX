
  Patch for Smartdrv v5.02 ( MS-DOS 7.1, supplied with Windows 98 )
  
  This patch makes smartdrv use a super-extended memory block instead of a
  standard EMB.


  Benefits

  1. memory beyond the 4 GB border is more difficult to access. This makes it
     "harder" for protected-mode applications to inadvertently modify extended
     memory that is owned by smartdrv.

  2. The DOS/16M and DOS/4G extender (rational, tenberry) may cause a system
     crash if the address of its extended memory block is beyond the 16MB
     barrier. This will most likely happen if the unmodified smartdrv is
     loaded with a huge cache size (max is 32 MB). The patched version will
     avoid this.

  Be aware that the modified smartdrv won't work anymore with a XMM 3.0 host,
  so it's a good idea to NOT overwrite the unmodified version.


  Details
  
  Modify 7 bytes of file smartdrv.exe (45379 bytes) with a hex editor:

  072C4: 09 2E FF 1E 72 0E C3    ;old
  072C4: C9 66 0F B7 D2 EB 02    ;new

  The modification changes the code in this way:

  old:
    mov ah,09
    call far cs:[0E72h]
    ret
    mov ah,08
    call far cs:[0E72h]
    ret

  new:
    mov ah,0c9h
    movzx edx,dx
    jmp @F
    mov ah,08
@@:
    call far cs:[0E72h]
    ret
