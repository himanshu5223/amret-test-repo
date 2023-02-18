*-----------------------------------------------------------------------------
	SUBROUTINE AMR.SMS.SUBS.VALIDATE
*-----------------------------------------------------------------------------
* VERSION             : 1.0
* DATE CREATED        : 24/03/2020
* CREATED BY          : Swetha S
* DESCRIPTION         : Validation Routine for SMS Subscription Template
* ATTACHED TO         : N/A
* ATTACHED AS         : N/A
* IN/OUT ARGUMENTS    : N/A
*-----------------------------------------------------------------------------
* VERSION             : 1.1
* DATE MODIFIED       : 28/12/2020
* MODIFIED BY         : Swetha S
* MODIFICATION DETAIL : Code Review Changes
*-----------------------------------------------------------------------------
* 01/07/2021    KIRAN HS    1.2    REVIEW
*-----------------------------------------------------------------------------
* VERSION             : 1.3
* DATE MODIFIED       : 30/08/2021
* MODIFIED BY         : RASY
* MODIFICATION DETAIL : CHG0033780 - check if EB.CUS.SMS.1/EB.CUS.EMAIL.1 exist
*                       remove default second MV freq. date
*-----------------------------------------------------------------------------
*Desription Name      : CHG0034880 : CDD, CDT, EB.READLIST crash error
*						- Prevent SELECT statement with sigle qoute '' to avoid error 
*						- When variable is null
*Developer Name       : Chea Oengviseth
*Modify Date          : 08/04/2022
***********************************************************************************
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AMR.SMS.SUBS
    $INSERT I_F.EB.ALERT.REQUEST
    $INSERT I_F.ACCOUNT
    $INSERT I_F.CUSTOMER
    $INSERT I_F.AMR.H.INTF.PARAM
    
    GOSUB ASSIGN.CUST
    GOSUB CHECK.BAL
    GOSUB CHECK.DUP
    GOSUB CHECK.CAT.INACTIV
    GOSUB UPDATE.DATES
	RETURN

*-----------------------------------------------------------------------------
ASSIGN.CUST:
*-----------------------------------------------------------------------------
    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)
    
    FN.CUSTOMER = 'F.CUSTOMER'
    F.CUSTOMER = ''
    CALL OPF(FN.CUSTOMER,F.CUSTOMER)

    FN.AMR.INTF.PARAM = 'F.AMR.H.INTF.PARAM'
    Y.AMR.INTF.PARAM = 'SMSRESCAT'
    
    CALL CACHE.READ(FN.AMR.INTF.PARAM,Y.AMR.INTF.PARAM,R.AMR.INTF.PARAM,E.AMR.INTF.PARAM)
    Y.RES.CATEGORIES = RAISE(RAISE(R.AMR.INTF.PARAM<AIP.VALUE.FROM>))
    
    Y.ACCOUNT = ID.NEW

    CALL F.READ(FN.ACCOUNT,Y.ACCOUNT,R.ACCOUNT,F.ACCOUNT,E.ACCOUNT)
    Y.CUSTOMER = R.ACCOUNT<AC.CUSTOMER>

    R.NEW(AMR.SMS.CUSTOMER) = Y.CUSTOMER
    R.NEW(AMR.SMS.CURRENCY) = R.ACCOUNT<AC.CURRENCY>
    
    CALL F.READ(FN.CUSTOMER,Y.CUSTOMER,R.CUSTOMER,F.CUSTOMER,E.CUSTOMER)
    Y.CUS.SMS = R.CUSTOMER<EB.CUS.SMS.1> ;* add by RASY on ref. CHG0033780
	Y.CUS.EML = R.CUSTOMER<EB.CUS.EMAIL.1> ;* add by RASY on ref. CHG0033780
	
    R.NEW(AMR.SMS.CUS.COMPANY) = R.CUSTOMER<EB.CUS.CO.CODE>
	RETURN

*-----------------------------------------------------------------------------
CHECK.BAL:
*-----------------------------------------------------------------------------
    Y.WORKING.BALANCE = R.ACCOUNT<AC.WORKING.BALANCE>
*	Y.FEES = R.NEW(AMR.SMS.MONTHLY.SMS.FEE.PER.UNIT) + R.NEW(AMR.SMS.MONTHLY.EMAIL.FEE.PER.UNIT)
    Y.FEES = R.NEW(AMR.SMS.SUBSCRIPTION.FEE)
    Y.SUBS.INDICATOR = R.NEW(AMR.SMS.SMS.SUBS.INDICATOR)
    
    IF Y.WORKING.BALANCE LT Y.FEES AND Y.SUBS.INDICATOR EQ "YES" THEN
        AF = 0
        ETEXT = 'AC-NO.BAL.IN.AC'
        CALL STORE.END.ERROR
    END
	RETURN
	
*-----------------------------------------------------------------------------
CHECK.DUP:
*-----------------------------------------------------------------------------
    MATBUILD Y.BEFORE.IMG.REC FROM R.OLD
    MATBUILD Y.AFTER.IMG.REC FROM R.NEW
    
    Y.NOT.IND = TRIM(Y.AFTER.IMG.REC<AMR.SMS.SMS.NOTIFICATION.TYPE>,VM,'A')
    
	;* amend by RASY on ref. CHG0033780
    IF Y.NOT.IND EQ 'SMSEMAIL' OR Y.NOT.IND EQ 'EMAILSMS' OR Y.NOT.IND EQ 'SMS' OR Y.NOT.IND EQ 'EMAIL' OR Y.NOT.IND EQ '' THEN
		IF Y.NOT.IND EQ 'SMSEMAIL' OR Y.NOT.IND EQ 'EMAILSMS' THEN
			IF Y.CUS.SMS EQ "" AND Y.CUS.EML EQ "" THEN
				AF = 0
				ETEXT = "Cannot Subscribe - Either Mobile Phone/Email Address of CN is missing"
				CALL STORE.END.ERROR
			END
			ELSE
				IF Y.CUS.SMS EQ "" THEN
					AF = 0
					ETEXT = "Cannot Subscribe - Mobile Phone of CN is missing"
					CALL STORE.END.ERROR
				END
				IF Y.CUS.EML EQ "" THEN
					AF = 0
					ETEXT = "Cannot Subscribe - Email Address of CN is missing"
					CALL STORE.END.ERROR
				END
			END
		END
		ELSE
			IF Y.NOT.IND EQ 'SMS' THEN
				IF Y.CUS.SMS EQ "" THEN
					AF = 0
					ETEXT = "Cannot Subscribe - Mobile Phone of CN is missing"
					CALL STORE.END.ERROR
				END
			END
			ELSE IF Y.NOT.IND EQ 'EMAIL' THEN
				IF Y.CUS.EML EQ "" THEN
					AF = 0
					ETEXT = "Cannot Subscribe - Email Address of CN is missing"
					CALL STORE.END.ERROR
				END
			END
		END
	END
	ELSE
        AF = AMR.SMS.SMS.NOTIFICATION.TYPE
        AV = 1
        ETEXT = 'EB-INVALID.ENTRY'
        CALL STORE.END.ERROR
    END
	;* end amend
	RETURN

*-----------------------------------------------------------------------------
CHECK.CAT.INACTIV:
*-----------------------------------------------------------------------------
    Y.CATEGORY = R.ACCOUNT<AC.CATEGORY>
    
    LOCATE Y.CATEGORY IN Y.RES.CATEGORIES SETTING Y.C.POS THEN
        AF = 0
        ETEXT = 'AC-RESTRICTED.CATEGORY':FM:Y.CATEGORY
        CALL STORE.END.ERROR
    END

    Y.INACTIVE.MARKER = R.ACCOUNT<AC.INACTIV.MARKER>
    
    IF Y.INACTIVE.MARKER[1,1] EQ 'Y' THEN
        AF = 0
        ETEXT = 'EB-NOT.SUB.ACCT.INACTIVE'
        CALL STORE.END.ERROR
    END
	RETURN

*-----------------------------------------------------------------------------
UPDATE.DATES:
*-----------------------------------------------------------------------------
    Y.PROMOTION.PERIODS.OLD = Y.BEFORE.IMG.REC<AMR.SMS.PROMOTION.PERIOD>
    Y.PROMOTION.PERIODS.NEW = Y.AFTER.IMG.REC<AMR.SMS.PROMOTION.PERIOD>

    Y.NOTIFICATION.TYPE.OLD = Y.BEFORE.IMG.REC<AMR.SMS.SMS.NOTIFICATION.TYPE>
    Y.NOTIFICATION.TYPE.NEW = Y.AFTER.IMG.REC<AMR.SMS.SMS.NOTIFICATION.TYPE>
	
	Y.NTF.TYPE.CNT = DCOUNT(Y.NOTIFICATION.TYPE.NEW,VM) ;* add by RASY on ref. CHG0033780

    IF (Y.NOTIFICATION.TYPE.OLD NE Y.NOTIFICATION.TYPE.NEW) OR (Y.PROMOTION.PERIODS.OLD NE Y.PROMOTION.PERIODS.NEW) THEN
        ;* add by RASY on ref. CHG0033780
		FOR Y.I = 1 TO Y.NTF.TYPE.CNT
			GOSUB PROCESS.UPDATE.PROMOTION
		NEXT Y.I
		;* end add

		;* comment by RASY on ref. CHG0033780
*		 Y.I = 1
*        GOSUB PROCESS.UPDATE.PROMOTION
*        Y.I = 2
*        GOSUB PROCESS.UPDATE.PROMOTION
		;* end comment
    END
	RETURN

*-----------------------------------------------------------------------------
PROCESS.UPDATE.PROMOTION:
*-----------------------------------------------------------------------------
    Y.PROMOTION.PERIOD = R.NEW(AMR.SMS.PROMOTION.PERIOD)<1,Y.I>
    Y.NOT.TYPE = R.NEW(AMR.SMS.SMS.NOTIFICATION.TYPE)<1,Y.I>

*   Code Review Changes - Removing nesting and extending existing conditions in CASE Statements

    BEGIN CASE
        CASE Y.NOT.TYPE NE '' AND Y.PROMOTION.PERIOD EQ ''
            R.NEW(AMR.SMS.PROMOTION.START.DATE)<1,Y.I> = ''
            R.NEW(AMR.SMS.PROMOTION.END.DATE)<1,Y.I> = ''
*           R.NEW(AMR.SMS.FREQ.DATE)<1,Y.I> = TODAY

        CASE Y.NOT.TYPE NE '' AND Y.PROMOTION.PERIOD NE ''
            Y.PR.LEN = LEN(Y.PROMOTION.PERIOD)
            Y.TODAY = TODAY
            Y.PROMOTION.START.DATE = R.NEW(AMR.SMS.PROMOTION.START.DATE)<1,Y.I>
    
            IF Y.PROMOTION.START.DATE EQ '' THEN
                Y.PROMOTION.START.DATE = Y.TODAY
                R.NEW(AMR.SMS.PROMOTION.START.DATE)<1,Y.I> = Y.PROMOTION.START.DATE
            END
    
            Y.PROMOTION.DATE = Y.PROMOTION.START.DATE
            
*	Code Review Changes - Adding GOSUB to reduce paragraph size
            GOSUB UPDATE.PROMOTION
    END CASE
        
    Y.FREQ.DATE = R.NEW(AMR.SMS.FREQ.DATE)<1,Y.I>
        
    IF Y.FREQ.DATE ELSE
        R.NEW(AMR.SMS.FREQ.DATE)<1,Y.I> = TODAY
    END
	RETURN

*-----------------------------------------------------------------------------
UPDATE.PROMOTION:
*-----------------------------------------------------------------------------
    BEGIN CASE
        CASE RIGHT(Y.PROMOTION.PERIOD,1) EQ 'M' OR NUM(Y.PROMOTION.PERIOD)
            Y.PROMOTION.PERIOD = TRIM(Y.PROMOTION.PERIOD,'M','A')
            Y.NO.DAYS = (Y.PROMOTION.PERIOD*30)+(INT(Y.PROMOTION.PERIOD/2))
            Y.NO.DAYS = '+':Y.NO.DAYS:'C'
            Y.REGION = ''
			*CHG0034880
			IF NUM(Y.PROMOTION.DATE) EQ '1' AND LEN(Y.PROMOTION.DATE) EQ '8' THEN
				CALL CDT(Y.REGION,Y.PROMOTION.DATE,Y.NO.DAYS)
			END
            R.NEW(AMR.SMS.PROMOTION.END.DATE)<1,Y.I> = Y.PROMOTION.DATE
            R.NEW(AMR.SMS.FREQ.DATE)<1,Y.I> = Y.PROMOTION.DATE
        
        CASE RIGHT(Y.PROMOTION.PERIOD,1) EQ 'D'
            Y.PROMOTION.PERIOD = TRIM(Y.PROMOTION.PERIOD,'D','A')
            Y.NO.DAYS = '+':Y.PROMOTION.PERIOD:'C'
            Y.REGION = ''
			*CHG0034880
			IF NUM(Y.PROMOTION.DATE) EQ '1' AND LEN(Y.PROMOTION.DATE) EQ '8' THEN
				CALL CDT(Y.REGION,Y.PROMOTION.DATE,Y.NO.DAYS)
			END
            R.NEW(AMR.SMS.PROMOTION.END.DATE)<1,Y.I> = Y.PROMOTION.DATE
            R.NEW(AMR.SMS.FREQ.DATE)<1,Y.I> = Y.PROMOTION.DATE
        
        CASE RIGHT(Y.PROMOTION.PERIOD,1) EQ 'Y'
            Y.PROMOTION.PERIOD = TRIM(Y.PROMOTION.PERIOD,'Y','A')
            Y.PROMOTION.YEAR = Y.PROMOTION.DATE[1,4] + Y.PROMOTION.PERIOD
            Y.MONTH.DAY = Y.PROMOTION.DATE[5,4]

            IF Y.MONTH.DAY EQ '0229' THEN
                Y.MONTH.DAY -=1
            END

            Y.PROMOTION.DATE = Y.PROMOTION.YEAR:Y.MONTH.DAY
            R.NEW(AMR.SMS.PROMOTION.END.DATE)<1,Y.I> = Y.PROMOTION.DATE
            R.NEW(AMR.SMS.FREQ.DATE)<1,Y.I> = Y.PROMOTION.DATE
           
        CASE 1
            AF = AMR.SMS.PROMOTION.PERIOD
            AV = Y.I
            ETEXT = 'EB-INVALID.ENTRY'
            CALL STORE.END.ERROR
    END CASE
	RETURN
END
