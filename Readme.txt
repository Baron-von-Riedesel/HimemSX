
  1. About

  HimemSX is a fork of HimemX. Its main feature is that it's able to manage
  more than 4 GB of memory. The memory beyond the 4 GB limit is called
  "super-extended" in this document.


  2. Technical Details
  
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


  3. Restrictions

  - The maximum amount of memory that the XMS API can handle is 4 TB (42
    physical address lines). However, since HimemSX currently uses 32-bit 
    paging with PSE-36 inside its block-move function, the effective limit
    is 1 TB (40 address lines).
  - The 'move extended memory' function 0Bh will fail if cpu is in v86-mode
    and source or destination address is beyond 4 GB. Currently HimemSX is
    intended for real-mode only. It's planned to extend Jemm386 so that
    HimemSX's function 0Bh will fully work together with Jemm386 in the future.
  - The 'move extended memory' function 0Bh understands 32-bit offsets only.
    So if a memory block is larger than 4 GB, you can't use this function to
    copy memory beyond a 4 GB offset.


  4. License
  
  Since HimemSX is a fork of HimemX and HimemX is derived from FD Himem, the
  FD Himem copyrights do apply. FD Himem is copyright Till Gerken and Tom 
  Ehlert, with GPL and/or Artistic license.

  Japheth
