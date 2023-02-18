*Created by : Sok Nara
*Purpose    : To Extract AA schedule detail
*Created on : 27 July 2020
*-----------------------------------------------------------------------------
* VERSION             : 1
* DATE CREATED        : 05-05-2021
* CREATED BY          : Mork Pin
* DESCRIPTION         : CHG0033265 APA- Issue Collect SC Wrong interest (Printing Tool)
* ATTACHED TO         : 
* ATTACHED AS         : BATCH ROUTINE
*---------------------------------------------------------------------------------
* VERSION             : 2
* DATE CREATED        : 24-11-2021
* CREATED BY          : Seit Lyheang
* DESCRIPTION         : CHG0034209 Update loan schedule extraction to extract over holiday and add special interest for borrowing PMT
* ATTACHED TO         : 
* ATTACHED AS         : BATCH ROUTINE
*-----------------------------------------------------------------------------------------
* VERSION             : 3
* DATE CREATED        : 11-14-2021
* CREATED BY          : Seit Lyheang
* DESCRIPTION         : CHG0034878 Enhance Deposits schedule extraction tool
* ATTACHED TO         : BNK/AMR.EXTRACT.AA.SCHEDULE
* ATTACHED AS         : BATCH ROUTINE
*-----------------------------------------------------------------------------------------

SUBROUTINE AMR.EXTRACT.AA.SCHEDULE.LOAD
    
	$INSERT I_AMR.EXTRACT.AA.SCHEDULE.COMMON
	$INSERT I_COMMON
    $INSERT I_EQUATE
	$INSERT I_F.DATES
	*Start-CHG0034878
	
	FN.DATE = 'F.DATES'
    F.DATE = ''
    CALL OPF(FN.DATE,F.DATE)
    DATE.ID = 'KH0010001'
    CALL F.READ(FN.DATE, DATE.ID, DATE.REC, F.DATE,ER)
    V.LWDAY = DATE.REC<EB.DAT.LAST.WORKING.DAY>
	
	FN.AA.ACTIVITY.HISTORY = 'F.AA.ACTIVITY.HISTORY'
	F.AA.ACTIVITY.HISTORY = ''
	CALL OPF(FN.AA.ACTIVITY.HISTORY,F.AA.ACTIVITY.HISTORY)
	
	*End-CHG0034878
	
	Y.SEQ.NO = CHANGE(OCONV(DATE(),"DYMD"),' ',''):CHANGE(OCONV(MOD(TIME(),86400),"MTS"),':','')
	OUTPUT.DIR = '/Temenos/T24/bnk/UD/EXTRACT.BP/AMR.EXT.DATA'
    WRITEFILE = 'AA.LOAN.SCHEDULE_':Y.SEQ.NO:'.':RND(Y.SEQ.NO):'.':RND(Y.SEQ.NO):'.TXT'

    OPENSEQ OUTPUT.DIR,WRITEFILE TO F.LOAN.FILE
    ELSE
        CREATE F.LOAN.FILE
        ELSE
            PRINT 'CANNOT CREATE O/P'
            STOP
        END
    END

	WRITEFILE = 'AA.DEP.SCHEDULE_':Y.SEQ.NO:'.':RND(Y.SEQ.NO):'.':RND(Y.SEQ.NO):'.TXT'
    OPENSEQ OUTPUT.DIR,WRITEFILE TO F.DEP.FILE
    ELSE
        CREATE F.DEP.FILE
        ELSE
            PRINT 'CANNOT CREATE O/P'
            STOP
        END
    END


    WRITEFILE = 'AA.DEBT.SCHEDULE_':Y.SEQ.NO:'.':RND(Y.SEQ.NO):'.':RND(Y.SEQ.NO):'.TXT'
    OPENSEQ OUTPUT.DIR,WRITEFILE TO F.DEBT.FILE
    ELSE
        CREATE F.DEBT.FILE
        ELSE
            PRINT 'CANNOT CREATE O/P'
            STOP
        END
    END
	
RETURN

END
