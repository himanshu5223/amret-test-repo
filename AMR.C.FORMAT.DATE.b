*------------------------------------------------------------------------------
SUBROUTINE AMR.C.FORMAT.DATE(DATA.IN, ARG2, ARG3, DATA.OUT, ARG5)
*------------------------------------------------------------------------------
* VERSION             : 1.0
* DATE CREATED        :
* CREATED BY          :
* DESCRIPTION         : This routine is format date.
* ATTACHED TO         : DE.FORMAT.XML>8990.1.2.GB,8990.1.3.GB
* ATTACHED AS         : CONVERSION ROUTINE
* IN/OUT ARGUMENTS    : DATA.IN,DATA.OUT
*-------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE

    GOSUB PROCESS
RETURN

*---------------------------
PROCESS:
*---------------------------

    Y.DATETIME.IN = DATA.IN
    
    Y.DATA.OUT = '20':Y.DATETIME.IN[1,2]:'-':Y.DATETIME.IN[3,2]:'-':Y.DATETIME.IN[5,2]:' ':Y.DATETIME.IN[7,2]:':':Y.DATETIME.IN[9,2]
    
    DATA.OUT = Y.DATA.OUT
    
RETURN

END