* @ValidationCode : MjotMTc3ODQ5MjY5MjpDcDEyNTI6MTYxNzcxNDkxODgwNjpuYXJhLnNvazotMTotMTowOjA6ZmFsc2U6Ti9BOlIxOF9TUDMyLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 06 Apr 2021 20:15:18
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : nara.sok
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R18_SP32.0
SUBROUTINE AMR.E.MB.STMT.BOOK.BUILD(STMT.ID.LIST)
    $INSERT I_EQUATE
    $INSERT I_COMMON
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_F.ACCOUNT
    $INSERT I_F.USER
    DEBUG
    LOCATE "ACCOUNT" IN D.FIELDS<1> SETTING CPOS THEN
        AC.ID =D.RANGE.AND.VALUE<CPOS>
        
	
    END ELSE AC.ID = ""
END

CALL E.STMT.ENQ.BY.CONCAT(STMT.ID.LIST)
CALL E.MB.STMT.BOOK.BUILD(STMT.ID.LIST)

RETURN

