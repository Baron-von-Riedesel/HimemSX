
  1. About

  HimemSX is a fork of HimemX. Its main feature is that it's able to manage
  more than 4 GB of memory. The memory beyond the 4 GB limit is called
  "super-extended" in this document.


  2. Technical Details
  
  To access extended memory below the 4 GB barrier HimemSX uses the so-called
  "unreal" mode, like most other XMMs.

  Memory beyond the 4 GB barrier can only be accessed thru special paging
  mechanisms. HimemSX uses the PSE-36 variant. PSE stands for Page Size
  Extension, the 36 refers to the original 36 bit address extension (64 GB),
  which was later extended to 40 bit (1 TB).

  HimemSX adds a few functions to the standard XMS v3 API:
  
  AH=0C8h: query free super-extended memory. Returns in EAX largest free block
           in kB, in EDX the total amount (in kB) of free super-extended memory.
           AX=0 indicates an error.
  
  AH=0C9h: allocate block of super-extended memory. Expects in EDX the
           requested amount of memory in kB. Returns AX=0 if an error occured,
           else AX is 1 and the handle of the block is in DX.

  AH=0CCh: lock a super-extended memory block. Expects handle in DX. Returns
           64-bit physical address of locked block in EDX:EBX. Returns AX=0
           if an error occured.

  XMS function 00 (Get Version) will return ax=0350h, that is version 3.50.

  HimemSX wants to manage super-extended memory exclusively. To achieve this,
  Int 15h, ax=E820h is intercepted and any memory block beyond the 4 GB
  barrier, which is marked as "available", will be changed to "reserved".

  In V86 mode, XMS function 0Bh ('move extended memory') needs to call the
  Expanded Memory Manager's (EMM) emulation of Int 15h, ah=87h, since the move
  needs to execute privileged code, which isn't possible in v86. The only
  EMM that currently supports to access memory beyond 4 GB is Jemm386 v5.80+.
  The Int 15h, ah=87h API has been exhanced for this functionality.


  3. Restrictions

  - The maximum amount of memory that the XMS API can handle is 4 TB (42
    physical address lines). However, since HimemSX currently uses 32-bit 
    paging with PSE-36 inside its block-move function, the effective limit
    is 1 TB (40 address lines).
  - The 'move extended memory' function 0Bh understands 32-bit offsets only.
    So if a memory block is larger than 4 GB, you can't use this function to
    copy memory beyond a 4 GB offset.
  - if no super-extended memory is found, or the CPU doesn't support PSE-36
    paging, HimemSX will still load and behave like a v3 XMM. However, it
    searches for extended memory via Int 15h, ax=e820h only, without trying to
    fall back to older detection strategies if this call fails.


  4. License
  
  Since HimemSX is a fork of HimemX and HimemX is derived from FD Himem, the
  FD Himem copyrights do apply. FD Himem is copyright Till Gerken and Tom 
  Ehlert, with GPL and/or Artistic license.

  Japheth
