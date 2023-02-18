*-----------------------------------------------------------------------------
	SUBROUTINE AMR.B.SMS.CHARGE.SELECT
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
* VERSION             : 1.0
* DATE MODIFIED       : 24-05-2021
* MODIFIED BY         : ITD-Boy Sothymeak
* MODIFICATION DETAIL : INC0019843 - issue not deduct sms & mail monthly fee charge
*-----------------------------------------------------------------------------
* VERSION             : 1.2
* DATE MODIFIED       : 30/08/2021
* MODIFIED BY         : RASY
* MODIFICATION DETAIL : CHG0033780 - REVIEW
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.DATES
    $INSERT I_AMR.B.SMS.CHARGE.COMMON
    
    GOSUB BUILD.LIST
	RETURN

*-----------------------------------------------------------------------------
BUILD.LIST:
*-----------------------------------------------------------------------------
    SEL.CMD = 'SELECT ':FN.AMR.SMS.SUBS:' WITH SMS.SUBS.INDICATOR EQ YES AND FREQ.DATE LE ':TODAY ;* INC0019843 ( Change condition FREQ.DATE EQ to FREQ.DATE LE)
    CALL EB.READLIST(SEL.CMD,Y.AC.LIST,'',NO.REC,RET.CODE)
    CALL BATCH.BUILD.LIST('',Y.AC.LIST)
	RETURN
END
