
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

  The XMS API has to be extended. See XMS35.txt for details.

  In v86 mode, the XMM needs support from the v86-monitor program to access
  extended memory, since it cannot run the privileged code required for the
  memory access. Currently only Jemm386 provides this support.


  3. Restrictions

  - The maximum amount of memory that the XMS API can handle is 4 TB (42
    physical address lines). However, since HimemSX currently uses 32-bit 
    paging with PSE-36 inside its block-move function, the effective limit
    is 1 TB (40 address lines).
  - The 'move extended memory' function 0Bh understands 32-bit offsets only.
    So if a memory block is larger than 4 GB, you can't use this function to
    copy memory beyond a 4 GB offset.
     Since version 3.53, there's an additional block move function available,
    that overcomes this limitation. See XMS35.txt for details.
  - if no super-extended memory is found, or the CPU doesn't support PSE-36
    paging, HimemSX will still load and behave like a v3 XMM. However, it
    searches for extended memory via Int 15h, ax=e820h only, without trying to
    fall back to older detection strategies if this call fails.


  4. License
  
  Since HimemSX is a fork of HimemX and HimemX is derived from FD Himem, the
  FD Himem copyrights do apply. FD Himem is copyright Till Gerken and Tom 
  Ehlert, with GPL and/or Artistic license.

  Japheth
