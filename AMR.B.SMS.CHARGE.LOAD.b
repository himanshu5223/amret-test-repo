*-----------------------------------------------------------------------------
	SUBROUTINE AMR.B.SMS.CHARGE.LOAD
*-----------------------------------------------------------------------------
* VERSION             : 1.0
* DATE CREATED        : 04/04/2020
* CREATED BY          : SWETHA S
* DESCRIPTION         : ROUTINE TO COLLECT SMS CHARGES
*                     :
* ATTACHED TO         : BATCH>BNK/AMR.B.SMS.CHARGE 
*                     :
* ATTACHED AS         : BATCH ROUTINE
* IN/OUT ARGUMENTS    : N/A
*-----------------------------------------------------------------------------
* VERSION             : 1.1
* DATE MODIFIED       : 30/08/2021
* MODIFIED BY         : RASY
* MODIFICATION DETAIL : CHG0033780 - REVIEW
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AMR.B.SMS.CHARGE.COMMON

    GOSUB OPEN.FILE
	RETURN

*-----------------------------------------------------------------------------
OPEN.FILE:
*-----------------------------------------------------------------------------
    FN.AMR.SMS.SUBS = 'F.AMR.SMS.SUBS'
    F.AMR.SMS.SUBS = ''
    CALL OPF(FN.AMR.SMS.SUBS,F.AMR.SMS.SUBS)
    
    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)
    
    FN.DE.PRODUCT = 'F.DE.PRODUCT'
    F.DE.PRODUCT = ''
    CALL OPF(FN.DE.PRODUCT,F.DE.PRODUCT)

    FN.PARAM = 'F.AMR.H.INTF.PARAM'
    F.PARAM = ''
    CALL OPF(FN.PARAM,F.PARAM)
	RETURN
END
