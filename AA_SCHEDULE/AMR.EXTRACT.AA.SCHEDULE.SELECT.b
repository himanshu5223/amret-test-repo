* @ValidationInfo : Timestamp         : 05 Apr 2021 14:02:48
* @ValidationInfo : User Name         : nara.sok,Mork Pin
*-----------------------------------------------------------------------------------------
* VERSION             : 3
* DATE CREATED        : 11-14-2021
* CREATED BY          : Seit Lyheang
* DESCRIPTION         : CHG0034878 Enhance Deposits schedule extraction tool
* ATTACHED TO         : BNK/AMR.EXTRACT.AA.SCHEDULE
* ATTACHED AS         : BATCH ROUTINE
*-----------------------------------------------------------------------------------------

	SUBROUTINE AMR.EXTRACT.AA.SCHEDULE.SELECT
	
    $USING EB.Service
    $INSERT I_AMR.EXTRACT.AA.SCHEDULE.COMMON

    AA.CMD = "SELECT FBNK.AA.ARRANGEMENT WITH ARR.STATUS NE 'CLOSE'"
    CALL EB.READLIST(AA.CMD,SEL.LIST,'',NO.REC,ER)
    EB.Service.BatchBuildList('',SEL.LIST)
	
*----------	
	RETURN
*----------
END
