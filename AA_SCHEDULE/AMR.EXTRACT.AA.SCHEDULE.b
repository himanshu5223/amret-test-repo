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
* VERSION             : 4
* DATE CREATED        : 27-07-2022
* CREATED BY          : Seit Lyheang
* DESCRIPTION         : INC0031765-issue data field TOT_DUE_PAYM in table AA_DEP_SCHEDULE has record with special charater
* ATTACHED TO         : BNK/AMR.EXTRACT.AA.SCHEDULE
* ATTACHED AS         : BATCH ROUTINE
*-----------------------------------------------------------------------------------------

********************************************
SUBROUTINE AMR.EXTRACT.AA.SCHEDULE(ARR.ID)
********************************************

    $USING AA.PaymentSchedule
    $USING AA.ProductFramework
    $USING AA.Framework

	$INSERT I_COMMON
    $INSERT I_EQUATE
	$INSERT I_F.AA.ACTIVITY.HISTORY
	$INSERT I_AA.LOCAL.COMMON
	$INSERT I_AMR.EXTRACT.AA.SCHEDULE.COMMON 
	$INSERT I_F.AA.PAYMENT.SCHEDULE

    GOSUB INITIALISE 					;* Initialise Variables here
	GOSUB CHECK.DAY						;* CHG0034209 find last last working date
	
	*Start-CHG0034878
	IF PRODUCT.GROUP EQ "AmrSaveDep" THEN 
		GOSUB CHECK.KC.NOT.PAY
		*IF VAR.ACT.DATE.COUNT GE V.LWDAY OR VAR.ACT.DATE.AMOUNT GE V.LWDAY OR VAR.ACT.DATE.COUNT EQ '' OR VAR.ACT.DATE.AMOUNT EQ '' THEN 
		 IF VAR.ACT.DATE.COUNT GE V.LWDAY OR VAR.ACT.DATE.AMOUNT GE V.LWDAY THEN 
			VAR.FLG = 1
		END
	END ELSE
		IF AMR.DT LT V.LWDAY THEN RETURN
		VAR.FLG = 1
	END
	IF VAR.FLG EQ 1 THEN 
		GOSUB BUILD.BASIC.DATA    			;* Build the Schedule Details by calling the Projection Routine
		GOSUB BUILD.ARRAY.DETAILS 			;* Format the Details according to Enquiry requirements
	END 
	*End-CHG0034878

	
***********
RETURN
***********

***********
INITIALISE:
***********

    AA.Framework.GetArrangement(ARR.ID, R.ARRANGEMENT, ARR.ERROR) 			;*Get the arrangement details using ARR.ID
    PRODUCT.LINE = R.ARRANGEMENT<AA.Framework.Arrangement.ArrProductLine> 	;*Get the product line from the arrangement details
	PRODUCT.GROUP = R.ARRANGEMENT<AA.Framework.Arrangement.ArrProductGroup> ;*Get the product group from the arrangement details
	
	PROPERTY.CLASS = ''
	PROPERTY = 'SCHEDULE'
	RETURNCONDS = ''

	CALL AA.GET.ARRANGEMENT.CONDITIONS(ARR.ID,PROPERTY.CLASS,PROPERTY,'',RETURNID,RETURNCONDS,RETERR) ;* when we want to call AA.ARR... ex AA.ARR.ACCOUNT
	SCH.ACC.REC = RAISE(RETURNCONDS)
	AMR.DT = '20':SCH.ACC.REC<AA.PS.DATE.TIME><1,1,1>[1,6] ;* Date has taken from the AA Schedule
	
    DUE.DATES = ''  			;* Holds the list of Schedule due dates
    DUE.TYPES = ''  			;* Holds the list of Payment Types for the above dates
    DUE.TYPE.AMTS = ''        	;* Holds the Payment Type amounts
    DUE.PROPS = ''  			;* Holds the Properties due for the above type
    DUE.PROP.AMTS = ''        	;* Holds the Property Amounts for the Properties above
    DUE.OUTS = ''   			;* Outstanding Bal for the date
    DUE.METHODS = ""
    *PRODUCT.LINE = "" 			;*CHG0034878
    SCHED.ARR = ''
	*PRODUCT.GROUP = '' 		;*CHG0034878
    DATE.REQD = '' ; CYCLE.DATE = ''
    SIM.REF = ''
    
	
***********
RETURN
***********

*Start-CHG0034878

******************
CHECK.KC.NOT.PAY:
******************

	ACT.HIS.REC = ''
	ACT.HIS.ERR = ''
	CALL F.READ(FN.AA.ACTIVITY.HISTORY,ARR.ID,ACT.HIS.REC,F.AA.ACTIVITY.HISTORY,ACT.HIS.ERR)
	VAR.ACTIVITY.CON.REF = ACT.HIS.REC<AA.AH.ACTIVITY.CON.REF>
	VAR.DEPOSIT.MAKEUSE = 'DEPOSITS-MAKEDUE-SCHEDULE#@#COUNT'
	CHANGE @VM TO @FM IN VAR.ACTIVITY.CON.REF
	LOCATE VAR.DEPOSIT.MAKEUSE IN VAR.ACTIVITY.CON.REF SETTING POS THEN 
		VAR.ACT.DATE.COUNT = ACT.HIS.REC<AA.AH.ACT.DATE,POS,1> ;* or we can write like this VAR.ACT.DATE = ACT.HIS.REC<AA.AH.ACT.DATE><1,POS,1>	
	END
	VAR.DEPOSIT.APPLYMENT = 'DEPOSITS-APPLYPAYMENT-PR.DEPOSIT#@#TXN.AMOUNT'
	LOCATE VAR.DEPOSIT.APPLYMENT IN VAR.ACTIVITY.CON.REF SETTING POS THEN 
		VAR.ACT.DATE.AMOUNT = ACT.HIS.REC<AA.AH.ACT.DATE,POS,1>
	END
	
***********
RETURN
***********

*End-CHG0034878

***********
CHECK.DAY:
***********

	VAR.TODAY.DATE = TODAY
    LOOP
    WHILE V.LWDAY LT VAR.TODAY.DATE
		DAY.COUNT = "-1C"
		CALL CDT('',V.LWDAY,DAY.COUNT)	;*CDT is function that allow to mnus across month from 01 to 29
		CALL AWD('',V.LWDAY,Y.VAL)		;*AWD is function to find the day is holiday or Working day	
		IF Y.VAL EQ 'W' THEN
			DAY.COUNT = "+1C"
			CALL CDT('',V.LWDAY,DAY.COUNT)
			BREAK
		END
    REPEAT
	
***********
RETURN
***********

*******************
BUILD.BASIC.DATA:
*******************
AA.PaymentSchedule.ScheduleProjector(ARR.ID, SIM.REF, "",CYCLE.DATE, TOT.PAYMENT, DUE.DATES, DEFER.DATES, DUE.TYPES, DUE.METHODS, DUE.TYPE.AMTS, DUE.PROPS, DUE.PROP.AMTS, DUE.OUTS);* Routine to Project complete schedules
*******************	
RETURN
*******************

***********************
BUILD.ARRAY.DETAILS:
***********************
	
    TOT.DTES = DCOUNT(DUE.DATES,@FM)    ;*Total Number of Schedule dates
    FOR DCNT = 1 TO TOT.DTES
        DUE.DATE = DUE.DATES<DCNT>      ;*Pick each date
        DEFER.DATE = DEFER.DATES<DCNT>
        GOSUB SPLIT.AMOUNT    			;*EN_10003652 -S/E
        TOT.PAYM = TOT.PAYMENT<DCNT>    ;*Total Payment for this date
        CURRENT.OS = DUE.OUTS<DCNT>     ;* O/S on this date
      
		SCHED.ARR = ARR.ID:'|':DUE.DATE:'|':TOT.DUE.PAYM:'|':TOT.CAP.PAYM:'|':TOT.PRIN.PAYM:'|':TOT.INT.PAYM:'|':TOT.CHG.PAYM:'|':TOT.TAX.PAYM:'|':CURRENT.OS ;*INC0031765
        SCHED.ARR = EREPLACE(SCHED.ARR,' ','') ;* EREPLACE mean to replace ' ' (speace) to '' (blank)

		IF PRODUCT.LINE EQ 'DEPOSITS' THEN
            IF PRODUCT.GROUP EQ 'AMRBorrow' THEN
				WRITESEQ SCHED.ARR TO F.DEBT.FILE ELSE
					TEXT = 'WRIETTING FAILED'
					CALL REM
					RETURN
				END
			END ELSE
				WRITESEQ SCHED.ARR TO F.DEP.FILE ELSE
					TEXT = 'WRIETTING FAILED'
					CALL REM
					RETURN
                END
			END
        END ELSE
			WRITESEQ SCHED.ARR TO F.LOAN.FILE ELSE
				TEXT = 'WRIETTING FAILED'
				CALL REM
				RETURN
            END
		END
		        
    NEXT DCNT
***********************
RETURN
***********************

***********************
SPLIT.AMOUNT:
***********************

    TOT.DUE.PAYM = ''
    TOT.CAP.PAYM = ''
    TOT.INT.PAYM = ''
    TOT.PRIN.PAYM = ''
    TOT.CHG.PAYM = ''
    TOT.TAX.PAYM = ''
    TOT.PAY.PAYM = ''
    PROP.CLS.LIST = ''

    TOT.PAY.TYPE = DCOUNT(DUE.TYPES<DCNT>,@VM)
    STORE.PAY.TYPE = DUE.TYPES<DCNT> ;*Fetching the exact payment type
    FOR PAY.CNT = 1 TO TOT.PAY.TYPE
        GOSUB PROCESS.PAY.TYPE
    NEXT PAY.CNT

***********************
RETURN
***********************

***********************
PROCESS.PAY.TYPE:
***********************

    PROP.LIST = DUE.PROPS<DCNT,PAY.CNT>
    PROP.LIST = RAISE(PROP.LIST)
    AA.ProductFramework.GetPropertyClass(PROP.LIST,PROP.CLS.LIST)
    TOT.PROP = DCOUNT(PROP.LIST,@VM)
    FOR PROP.CNT = 1 TO TOT.PROP
        PROP.CLS = ''         ;*Used to save the PC of property for which current tax amt is raised
        TAX.SIGN = 1
        PROP.AMT = DUE.PROP.AMTS<DCNT,PAY.CNT,PROP.CNT>
        TAX.PROP.POS = ''
        IF PROP.CLS.LIST<1,PROP.CNT> EQ '' THEN   													;*May be for Tax amount
            LOCATE PROP.LIST<1,PROP.CNT>['-',1,1] IN PROP.LIST<1,1> SETTING TAX.PROP.POS THEN
                PROP.CLS = PROP.CLS.LIST<1,TAX.PROP.POS>   											;*Store the main property for which tax is raised
                TAX.SIGN = -1 																		;* Tax sign to be updated.
            END ELSE
                TAX.PROP.POS = ''
            END
        END

        BEGIN CASE
            CASE (PROP.CLS.LIST<1,PROP.CNT> EQ 'ACCOUNT' AND (DUE.METHODS<DCNT,PAY.CNT,PROP.CNT> EQ 'DUE' OR DUE.METHODS<DCNT,PAY.CNT,PROP.CNT> EQ 'PAY' OR DUE.METHODS<DCNT,PAY.CNT,PROP.CNT> EQ 'INFO'))  ;*Add to Principal for DUE and PAY payment Methods
                TOT.PRIN.PAYM += PROP.AMT
            CASE PROP.CLS.LIST<1,PROP.CNT> EQ 'INTEREST'        ;*Add to Interest
                TOT.INT.PAYM += PROP.AMT
			*Start CHG0034209
			CASE PROP.LIST<1,PROP.CNT> EQ 'DEBTSPECINT' AND DUE.METHODS<DCNT,PAY.CNT,PROP.CNT> EQ 'PAY' ;*Add to Interest
                TOT.INT.PAYM += PROP.AMT
			*End CHG0034209
            CASE ((PROP.CLS.LIST<1,PROP.CNT> MATCHES 'CHARGE':@VM:'PERIODIC.CHARGES') AND DUE.METHODS<DCNT,PAY.CNT,PROP.CNT> MATCHES 'DUE':@VM:'CAPITALISE')          ;*Add both Charge and Periodic Charge for DUE/CAPITALISE Type
                TOT.CHG.PAYM += PROP.AMT
            CASE PROP.CLS NE ''   ;*Add to Tax
                TOT.TAX.PAYM += PROP.AMT
        END CASE
        DUE.METHOD = DUE.METHODS<DCNT,PAY.CNT, PROP.CNT>
        IF PRODUCT.LINE MATCHES 'DEPOSITS':@VM:'LENDING' AND PROP.CLS.LIST<1,PROP.CNT> EQ 'CHARGE' AND DUE.METHOD EQ 'CAPITALISE' THEN ;*For Deposits,Lending the capitalized charge amount needs to be subtracted
            TOT.CAP.PAYM -= PROP.AMT * TAX.SIGN
            DUE.METHOD = ''
        END
        IF TAX.PROP.POS THEN
            DUE.METHOD = DUE.METHODS<DCNT,PAY.CNT,TAX.PROP.POS>
        END
        BEGIN CASE
            CASE DUE.METHOD MATCHES 'DUE':@VM:'INFO'
                TOT.DUE.PAYM += PROP.AMT
            CASE DUE.METHOD EQ 'CAPITALISE'
                TOT.CAP.PAYM += PROP.AMT * TAX.SIGN
            CASE DUE.METHOD EQ 'PAY'
                TOT.PAY.PAYM += PROP.AMT * TAX.SIGN
        END CASE
    NEXT PROP.CNT

***********************
RETURN
***********************
END

