* @ValidationCode : MjotMTkwMTI2OTg2MDpDcDEyNTI6MTYxMzQ0NTk0MDg4MjpuYXJhLnNvazotMTotMTowOjA6ZmFsc2U6Ti9BOlIxOF9TUDMyLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 16 Feb 2021 10:25:40
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : nara.sok
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R18_SP32.0
SUBROUTINE AMR.EXTRACT.AA.SCHEDULE.ALL.LOAD
    
	$INSERT I_AMR.EXTRACT.AA.SCHEDULE.COMMON
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_GTS.COMMON

*--------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------

    FN.AA.ARRANGEMENT = 'FBNK.AA.ARRANGEMENT'
    FV.AA.ARRANGEMENT=''
    CALL OPF(FN.AA.ARRANGEMENT,FV.AA.ARRANGEMENT)

*SEL.CMD = 'SELECT EXTRACT.BP WITH @ID EQ AMR.EXT.DATA'
*EXECUTE SEL.CMD RTNLIST SEL.IDS

*IF SEL.IDS EQ '' THEN
*   EXECUTE 'CREATE-FILE EXTRACT.BP/AMR.EXT.DATA TYPE=UD'
*END
	
	Y.SEQ.NO = CHANGE(OCONV(DATE(),"DYMD"),' ',''):CHANGE(OCONV(MOD(TIME(),86400),"MTS"),':','')
	OUTPUT.DIR = 'EXTRACT.BP/AMR.EXT.DATA'
    WRITEFILE='AA.LOAN.SCHEDULE_':Y.SEQ.NO:'.':RND(Y.SEQ.NO):'.':RND(Y.SEQ.NO):'.TXT'

    OPENSEQ OUTPUT.DIR,WRITEFILE TO F.LOAN.FILE
    ELSE
        CREATE F.LOAN.FILE
        ELSE
            PRINT 'CANNOT CREATE O/P'
            STOP
        END
    END

	WRITEFILE='AA.DEP.SCHEDULE_':Y.SEQ.NO:'.':RND(Y.SEQ.NO):'.':RND(Y.SEQ.NO):'.TXT'
    OPENSEQ OUTPUT.DIR,WRITEFILE TO F.DEP.FILE
    ELSE
        CREATE F.DEP.FILE
        ELSE
            PRINT 'CANNOT CREATE O/P'
            STOP
        END
    END


    WRITEFILE='AA.DEBT.SCHEDULE_':Y.SEQ.NO:'.':RND(Y.SEQ.NO):'.':RND(Y.SEQ.NO):'.TXT'
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
