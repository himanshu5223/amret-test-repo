* @ValidationCode : Mjo2NjU2MzExNDQ6Q3AxMjUyOjE2MTM0NDc1OTk0OTA6bmFyYS5zb2s6LTE6LTE6MDowOmZhbHNlOk4vQTpSMThfU1AzMi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 16 Feb 2021 10:53:19
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : nara.sok
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R18_SP32.0

SUBROUTINE AMR.EXTRACT.AA.SCHEDULE.ALL(ARR.ID)

    $USING AA.PaymentSchedule
    $USING AA.ProductFramework
    $USING EB.Reports
    $USING AA.Framework
	$INSERT I_AMR.EXTRACT.AA.SCHEDULE.COMMON
    
*-------------------------------------------------------
*Created by : Sok Nara
*Purpose    : To Extract AA schedule detail
*Created on : 27 July 2020
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
    GOSUB INITIALISE          ;* Initialise Variables here
    GOSUB BUILD.BASIC.DATA    ;* Build the Schedule Details by calling the Projection Routine
    GOSUB BUILD.ARRAY.DETAILS ;* Format the Details according to Enquiry requirements

RETURN

INITIALISE:

    DUE.DATES = ''  ;* Holds the list of Schedule due dates
    DUE.TYPES = ''  ;* Holds the list of Payment Types for the above dates
    DUE.TYPE.AMTS = ''        ;* Holds the Payment Type amounts
    DUE.PROPS = ''  ;* Holds the Properties due for the above type
    DUE.PROP.AMTS = ''        ;* Holds the Property Amounts for the Properties above
    DUE.OUTS = ''   ;* Outstanding Bal for the date
    DUE.METHODS = ""
    PRODUCT.LINE = ""
    SCHED.ARR = ''
	PRODUCT.GROUP = ''

    DATE.REQD = '' ; CYCLE.DATE = ''
    SIM.REF = ''
    

    AA.Framework.GetArrangement(ARR.ID, R.ARRANGEMENT, ARR.ERROR) ;* Get the arrangement details using ARR.ID
    PRODUCT.LINE = R.ARRANGEMENT<AA.Framework.Arrangement.ArrProductLine> ;*Get the product line from the arrangement details
	PRODUCT.GROUP = R.ARRANGEMENT<AA.Framework.Arrangement.ArrProductGroup> ;*Get the product group from the arrangement details

RETURN

BUILD.BASIC.DATA:

    AA.PaymentSchedule.ScheduleProjector(ARR.ID, SIM.REF, "",CYCLE.DATE, TOT.PAYMENT, DUE.DATES, DEFER.DATES, DUE.TYPES, DUE.METHODS, DUE.TYPE.AMTS, DUE.PROPS, DUE.PROP.AMTS, DUE.OUTS)      ;* Routine to Project complete schedules
RETURN

BUILD.ARRAY.DETAILS:

    TOT.DTES = DCOUNT(DUE.DATES,@FM)     ;* Total Number of Schedule dates
    FOR DCNT = 1 TO TOT.DTES
        DUE.DATE = DUE.DATES<DCNT>      ;* Pick each date
        DEFER.DATE = DEFER.DATES<DCNT>
        GOSUB SPLIT.AMOUNT    ;*EN_10003652 -S/E
        TOT.PAYM = TOT.PAYMENT<DCNT>    ;* Total Payment for this date
        CURRENT.OS = DUE.OUTS<DCNT>     ;* O/S on this date
      
        
		SCHED.ARR = ARR.ID:'|':DUE.DATE:'|'TOT.DUE.PAYM:'|':TOT.CAP.PAYM:'|':TOT.PRIN.PAYM:'|':TOT.INT.PAYM:'|':TOT.CHG.PAYM:'|':TOT.TAX.PAYM:'|':CURRENT.OS
        SCHED.ARR = EREPLACE(SCHED.ARR,' ','')

		IF PRODUCT.LINE EQ 'DEPOSITS' THEN
            IF PRODUCT.GROUP EQ 'AMRBorrow' THEN
				WRITESEQ SCHED.ARR TO F.DEBT.FILE ELSE
					TEXT='WRIETTING FAILED'
					CALL REM
					RETURN
				END
			END ELSE
				WRITESEQ SCHED.ARR TO F.DEP.FILE ELSE
					TEXT='WRIETTING FAILED'
					CALL REM
					RETURN
                END
			END
        END ELSE
			WRITESEQ SCHED.ARR TO F.LOAN.FILE ELSE
				TEXT='WRIETTING FAILED'
				CALL REM
				RETURN
            END
		END
		        
    NEXT DCNT

RETURN

SPLIT.AMOUNT:

    TOT.DUE.PAYM = ''
    TOT.CAP.PAYM = ''
    TOT.INT.PAYM = ''
    TOT.PRIN.PAYM = ''
    TOT.CHG.PAYM = ''
    TOT.TAX.PAYM = ''
    TOT.PAY.PAYM = ''
    PROP.CLS.LIST = ''
    TOT.PAY.TYPE = DCOUNT(DUE.TYPES<DCNT>,@VM)
    STORE.PAY.TYPE = DUE.TYPES<DCNT> ;* Fetching the exact payment type
    FOR PAY.CNT = 1 TO TOT.PAY.TYPE
        GOSUB PROCESS.PAY.TYPE
    NEXT PAY.CNT

RETURN

PROCESS.PAY.TYPE:

    PROP.LIST = DUE.PROPS<DCNT,PAY.CNT>
    PROP.LIST = RAISE(PROP.LIST)
    AA.ProductFramework.GetPropertyClass(PROP.LIST,PROP.CLS.LIST)
    TOT.PROP = DCOUNT(PROP.LIST,@VM)
    FOR PROP.CNT = 1 TO TOT.PROP
        PROP.CLS = ''         ;*Used to save the PC of property for which current tax amt is raised
        TAX.SIGN = 1
        PROP.AMT = DUE.PROP.AMTS<DCNT,PAY.CNT,PROP.CNT>
        TAX.PROP.POS = ''
        IF PROP.CLS.LIST<1,PROP.CNT> EQ '' THEN   ;*May be for Tax amount
            LOCATE PROP.LIST<1,PROP.CNT>['-',1,1] IN PROP.LIST<1,1> SETTING TAX.PROP.POS THEN
                PROP.CLS = PROP.CLS.LIST<1,TAX.PROP.POS>    ;*Store the main property for which tax is raised
                TAX.SIGN = -1 ;* Tax sign to be updated.
            END ELSE
                TAX.PROP.POS = ''
            END
        END

        BEGIN CASE
            CASE (PROP.CLS.LIST<1,PROP.CNT> EQ 'ACCOUNT' AND (DUE.METHODS<DCNT,PAY.CNT,PROP.CNT> EQ 'DUE' OR DUE.METHODS<DCNT,PAY.CNT,PROP.CNT> EQ 'PAY' OR DUE.METHODS<DCNT,PAY.CNT,PROP.CNT> EQ 'INFO'))  ;*Add to Principal for DUE and PAY payment Methods
                TOT.PRIN.PAYM += PROP.AMT

            CASE PROP.CLS.LIST<1,PROP.CNT> EQ 'INTEREST'        ;*Add to Interest
                TOT.INT.PAYM += PROP.AMT

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

RETURN
END

