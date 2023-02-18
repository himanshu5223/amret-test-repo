* @ValidationCode : MjoxMDE4MzY5MTQxOkNwMTI1MjoxNjEzMzgzMTM3ODcyOm5hcmEuc29rOi0xOi0xOjA6MDpmYWxzZTpOL0E6UjE4X1NQMzIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 15 Feb 2021 16:58:57
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : nara.sok
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R18_SP32.0
SUBROUTINE AMR.MERGE.FILE
    
    
    
    $USING EB.Reports
    $USING EB.Service
    $INSERT I_AMR.EXTRACT.AA.SCHEDULE.COMMON

    $INSERT I_F.DATES
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
  
    OUTPUT.DIR = 'EXTRACT.BP/AMR.EXT.DATA'
    WRITEFILE='success.txt'

    OPENSEQ OUTPUT.DIR,WRITEFILE TO F.LOAN.FILE
    ELSE
        CREATE F.LOAN.FILE
        ELSE
            PRINT 'CANNOT CREATE O/P'
            STOP
        END
    END

RETURN
END



