*------------------------------------------------------------------------------
SUBROUTINE AMR.C.FORMAT.AMT(DATA.IN, ARG2, ARG3, DATA.OUT, ARG5)
*------------------------------------------------------------------------------
* VERSION             : 1.0
* DATE CREATED        :
* CREATED BY          :
* DESCRIPTION         : This routine is remove minus sign from Amount.
* ATTACHED TO         : DE.FORMAT.XML>8230.1.2.GB,8240.1.3.GB
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

    Y.AMT.IN = DATA.IN
    
    IF Y.AMT.IN[1,1] EQ '-' THEN
        Y.AMT.IN[1,1] = ''
        Y.AMT.OUT = Y.AMT.IN
    END
    
    DATA.OUT = Y.AMT.OUT
    
RETURN

END