*------------------------------------------------------------------------------
SUBROUTINE AMR.C.GET.FEE.AMT(DATA.IN, ARG2, ARG3, DATA.OUT, ARG5)
*------------------------------------------------------------------------------
* VERSION             : 1.0
* DATE CREATED        :
* CREATED BY          :
* DESCRIPTION         : This routine is fetch from customer for credit txn.
* ATTACHED TO         : DE.FORMAT.XML>8230.1.2.GB,8230.1.3.GB
* ATTACHED AS         : CONVERSION ROUTINE
* IN/OUT ARGUMENTS    : DATA.IN,DATA.OUT
*-------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.TELLER

    GOSUB PROCESS.OPENFILES
    GOSUB PROCESS.CONVERT
RETURN

*---------------------------
PROCESS.OPENFILES:
*---------------------------

    FN.FUNDSTFR = 'F.FUNDS.TRANSFER'
    F.FUNDSTFR = ''
    CALL OPF(FN.FUNDSTFR,F.FUNDSTFR)
    
    FN.TELLER = 'F.TELLER'
    F.TELLER = ''
    CALL OPF(FN.TELLER,F.TELLER)

RETURN

*---------------------------
PROCESS.CONVERT:
*---------------------------
    
    Y.TRANS.REF = DATA.IN
    
    IF Y.TRANS.REF[1,2] EQ 'FT' THEN

        CALL F.READ(FN.FUNDSTFR,Y.TRANS.REF,R.FUNDSTFR,F.FUNDSTFR,E.FUNDSTFR)
        Y.CHARGE.AMT = R.FUNDSTFR<FT.TOTAL.CHARGE.AMOUNT>
        
        IF Y.CHARGE.AMT ELSE
            Y.CHARGE.AMT = R.FUNDSTFR<FT.CREDIT.CURRENCY>:'0'
        END
        
    END ELSE

        CALL F.READ(FN.TELLER,Y.TRANS.REF,R.TELLER,F.TELLER,E.TELLER)
        Y.CURRENCY = R.TELLER<TT.TE.CURRENCY.1>
        Y.CHRG.AMT.LOCAL = R.TELLER<TT.TE.CHRG.AMT.LOCAL>
        Y.CHRG.AMT.FCCY = R.TELLER<TT.TE.CHRG.AMT.FCCY>
        
        BEGIN CASE
            
            CASE Y.CURRENCY EQ LCCY AND Y.CHRG.AMT.LOCAL
                Y.CHARGE.AMT = Y.CURRENCY:SUM(Y.CHRG.AMT.LOCAL)
        
            CASE Y.CURRENCY NE LCCY AND Y.CHRG.AMT.FCCY
                Y.CHARGE.AMT = Y.CURRENCY:SUM(Y.CHRG.AMT.FCCY)
            
            CASE 1
                Y.CHARGE.AMT = Y.CURRENCY:'0'
                
        END CASE
        
    END
               
    DATA.OUT = Y.CHARGE.AMT
    
RETURN
    
END