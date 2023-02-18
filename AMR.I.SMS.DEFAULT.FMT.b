*-----------------------------------------------------------------------------
SUBROUTINE AMR.I.SMS.DEFAULT.FMT
*-----------------------------------------------------------------------------
* VERSION             : 1.0
* DATE CREATED        : 03/04/2020
* CREATED BY          :
* DESCRIPTION         :
*                     :
* ATTACHED TO         :
*                     :
* ATTACHED AS         : ROUTINE
* IN/OUT ARGUMENTS    : N/A
*-----------------------------------------------------------------------------
* VERSION             :
* DATE MODIFIED       :
* MODIFIED BY         :
* MODIFICATION DETAIL :
*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.DE.CUSTOMER.PREFERENCES
    $INSERT I_F.DE.PRODUCT
    $INSERT I_F.AMR.SMS.SUBS
    
    GOSUB OPEN.FILE
    
    IF APPLICATION EQ 'DE.CUSTOMER.PREFERENCES' THEN
        GOSUB DEFAULT.FOR.CUS
    END ELSE
        GOSUB DEFAULT.FOR.ACC
    END

    GOSUB HANDLE.EXCEPTION
                
RETURN

*-----------------------------
OPEN.FILE:
*-----------------------------

    FN.AMR.SMS.SUBS = 'F.AMR.SMS.SUBS'
    F.AMR.SMS.SUBS = ''
    CALL OPF(FN.AMR.SMS.SUBS,F.AMR.SMS.SUBS)
    
RETURN

*-----------------------------
DEFAULT.FOR.CUS:
*-----------------------------

    Y.FORMAT.DETS = R.NEW(DE.CUSPR.ADDRESS) * 0
    Y.SEL.CMD = 'SELECT ':FN.AMR.SMS.SUBS:' WITH CUSTOMER EQ ':ID.NEW
    CALL EB.READLIST(Y.SEL.CMD,Y.SEL.LIST,'',NO.REC,RET.CODE)

    CALL F.READ(FN.AMR.SMS.SUBS,Y.SEL.LIST<1,1>,R.AMR.SMS.SUBS,F.AMR.SMS.SUBS,E.AMR.SMS.SUBS)
    Y.FORMAT = LEN(R.AMR.SMS.SUBS<AMR.SMS.VIP.CLIENT>)
    CHANGE '0' TO Y.FORMAT IN Y.FORMAT.DETS
    R.NEW(DE.CUSPR.FORMAT) = Y.FORMAT.DETS

RETURN

*-----------------------------
DEFAULT.FOR.ACC:
*-----------------------------

    Y.FORMAT.DETS = R.NEW(DE.PRD.CARR.ADD.NO) * 0
    Y.ACCOUNT.NO = FIELD(FIELD(ID.NEW,'.',2),'-',2)
 
    CALL F.READ(FN.AMR.SMS.SUBS,Y.ACCOUNT.NO,R.AMR.SMS.SUBS,F.AMR.SMS.SUBS,E.AMR.SMS.SUBS)
    Y.FORMAT = LEN(R.AMR.SMS.SUBS<AMR.SMS.VIP.CLIENT>)
    CHANGE '0' TO Y.FORMAT IN Y.FORMAT.DETS
    
    Y.DE.MESSAGE = FIELD(ID.NEW,'.',3)
    IF Y.DE.MESSAGE NE '8980' AND Y.DE.MESSAGE NE '8990' THEN
        R.NEW(DE.PRD.FORMAT) = Y.FORMAT.DETS
    END ELSE
        R.NEW(DE.PRD.FORMAT) = '2'
        Y.FORMAT = 'SUBS'
    END

RETURN

*-----------------------------
HANDLE.EXCEPTION:
*-----------------------------

    IF Y.FORMAT EQ ''  THEN
        ETEXT = 'EB-AMR.NOT.SUBSCRIBED'
        CALL STORE.END.ERROR
    END

RETURN

END
