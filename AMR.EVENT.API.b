*----------------------------------------
SUBROUTINE AMR.EVENT.API(TEC.ITEM,SUB.ID,METRICS.VALUE,AFTER.IMG.REC,DYN.LINKED.VALUE,UNAUTH.OR.AUTH,TEC.API.CHECK)
*----------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE

    IF LEN(SUB.ID) GE 6 THEN
        TEC.API.CHECK = 1     ;*record the event
    END

RETURN

END