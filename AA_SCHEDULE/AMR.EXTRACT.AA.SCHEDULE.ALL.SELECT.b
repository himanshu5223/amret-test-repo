* @ValidationCode : MjotNzQ5NzE2NjE4OkNwMTI1MjoxNjEzNDQ1OTU0NTc0Om5hcmEuc29rOi0xOi0xOjA6MDpmYWxzZTpOL0E6UjE4X1NQMzIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 16 Feb 2021 10:25:54
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : nara.sok
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R18_SP32.0
SUBROUTINE AMR.EXTRACT.AA.SCHEDULE.ALL.SELECT
    
    
    
    $USING AA.PaymentSchedule
    $USING AA.ProductFramework
    $USING EB.Reports
    $USING EB.Service
    $USING AA.Framework
    $INSERT I_AMR.EXTRACT.AA.SCHEDULE.COMMON
	$INSERT I_F.AA.ARRANGEMENT.ACTIVITY
    $INSERT I_F.DATES
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
    GOSUB INITAL
    GOSUB PROCESS.ARRAGEMENT

RETURN

*-----------------------------------------------------------------------------
INITAL:
*-----------------------------------------------------------------------------

    FN.ACTIVITY ='F.AA.ARRANGEMENT.ACTIVITY'
    F.ACTIVITY = ''
    CALL OPF(FN.ACTIVITY,F.ACTIVITY)
    FN.DATE = 'F.DATES'
    F.DATE = ''
    CALL OPF(FN.DATE,F.DATE)
    DATE.ID = 'KH0010001'
    CALL F.READ(FN.DATE, DATE.ID, DATE.REC, F.DATE,ER)
    V.LWDAY = DATE.REC<EB.DAT.LAST.WORKING.DAY>
RETURN

*-----------------------------------------------------------------------------
PROCESS.ARRAGEMENT:
*-----------------------------------------------------------------------------

*DEBUG

    AA.CMD = "SELECT FBNK.AA.ARRANGEMENT"
    CALL EB.READLIST(AA.CMD,SEL.LIST,'',CNT1,ER)
*CALL BATCH.BUILD.LIST('',SEL.LIST)
    EB.Service.BatchBuildList('',SEL.LIST)

RETURN
END
