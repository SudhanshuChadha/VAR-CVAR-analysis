function [ret_string,Xvalues,CumPNL,CumPNLminusTXN,PNL10day,VAR95,VAR99,CVAR95,CVAR99]=...
    Engine_Pf_Analysis(stringPath,Method,Simulation,RisklessRate,TransactionCostRate)
%Portfolio engine to analyse the performance of portfolio 
%for 4 years with a rolling window of 2 years.
%With passage of 10 days P/L of portfolio calculated and checked if it exceeded Var/CVAR
    data=(xlsread(stringPath,'Sheet1','b2:f1010')); 
    %data until june 2004 are obtained - d8 corresponds to this datapoint
    switch(Method)
       case 'Constrained'
        disp('Method is Constrained with short sell');
            Groups = [1 1 0 0; 1 1 1 1];
            Groupbounds = [0.5 .75; 1 1];  
            %ACLUBounds =[0.3 0.2 0.1 0.2;0.75 0.5 0.5 0.5];
            ACLUBounds =[-0.1 -0.1 -0.1 -0.1;0.75 0.5 0.5 0.5];
       case 'Unconstrained'
          disp('Method is Unconstrained but no shortsell')
       case 'ShortSell'
          disp('Method is Shortsell ')
          ACLUBounds =[-0.3 -0.3 -0.3 -0.3;1.30 1.30 1.30 1.30];
          Groups = [ 1 1 1 1];
          Groupbounds = [1 1];
       case 'ConstrainedTurnover'
          disp('Method is ConstrainedTurnover!')
          ACLUBounds =[0 0 0 0;1 1 1 1];
          Groups = [ 1 1 1 1;1 0 0 0;0 1 0 0;0 0 1 0;0 0 0 1];
          Groupbounds = [1 1;0 1;0 1;0 1;0 1];

    end
    %RisklessRate = Riskfree;
    InvestmentValue = 1000000;
    [rowcount columncount] = size(data);
    Prices=data(:,1:4);
    BenchmarkPrices = data(:,5);
    PricesStart = data(1,:);
    Returns=tick2ret(Prices,[],'Continuous'); %calculates return
    Returns= [0 0 0 0; Returns];
    DaysinWindow = 504;%BusinessDays Less Public Holidays
    DaysInYear = 252;
    EndRow = (floor((rowcount-DaysinWindow)/10)*10);
    InitialInvestment = 1000000;
    PortStartVal = InitialInvestment;
    weightsprev = [0 0 0 0];
    counter = 1;
    %TransactionCostRate = 0.01;

    for windowIndexStart = 1:10:EndRow    
        windowIndexEnd = windowIndexStart+DaysinWindow;
        PriceStart = Prices(windowIndexEnd,:);
        ExpReturn=mean(Returns(1:windowIndexEnd,:));
        ExpCovariance=cov(Returns(1:windowIndexEnd,:));     


        %Efficient Frontier
        switch(Method)
            case 'Constrained'
                [PortRisk, PortReturn, PortWts]=...
                    frontcon(ExpReturn,ExpCovariance,[],[],ACLUBounds,Groups,Groupbounds);
            case 'Unconstrained'
                [PortRisk, PortReturn, PortWts]=...
                    frontcon(ExpReturn, ExpCovariance);
            case 'ShortSell'
                [PortRisk, PortReturn, PortWts]=...
                    frontcon(ExpReturn,ExpCovariance,[],[],ACLUBounds,Groups,Groupbounds);
            case 'ConstrainedTurnover'
                [PortRisk, PortReturn, PortWts]=...
                    frontcon(ExpReturn,ExpCovariance,[],[],ACLUBounds,Groups,Groupbounds);
                weights = PortWts(1,:);
                weightB=weights.*0.05;
                %Weights are contrained to change by +/- 5% only 
                ACLUBounds =[weights-weightB;weights+weightB];
            
        end
        
        %set weights equal to the minimum variance portfolio
        weights = PortWts(1,:);
        NumofShares = PortStartVal*weights./PriceStart;
        %Simulate returns using Portsim
        NumbObs=10; %number of days holding period for var
        NumSim = str2num(Simulation); %number of simulations
        randn('state',sum(100*clock));
        %Simulates asset returns and outputs a matrix for each Simulation
        AssetSimulatedReturns=portsim(ExpReturn,ExpCovariance,NumbObs,1,NumSim,'Expected');

        %Convert Asset Returns to Portfolio returns 
        PortSimulatedReturns=[];
        for i=1:NumSim
            PortSimulatedReturns(:,i) = AssetSimulatedReturns(:,:,i)*weights';
        end
        %Convert the weighted simulated returns to prices
        PortSimulatedValues=...
            ret2tick(PortSimulatedReturns,repmat(PortStartVal,1,NumSim),[],[],'Continuous');


        %for i=1:NumSim
        %    plot(PortSimulatedValues(:,i))
        %    hold on
        %end
        %grid on
        %hold off
        %ylabel('Portfolio Value')
        %title('Expected Method')

        PortSimPNL = PortSimulatedValues(end,:)-PortStartVal;
        %figure(2);
        %hist(PortSimPNL);
        %Calculation of VAR
        VAR95(counter) = prctile(PortSimPNL,5);
        CVAR95(counter) = mean(PortSimPNL(PortSimPNL(end,:)<VAR95(counter))');
        VAR99(counter) = prctile(PortSimPNL,1);
        CVAR99(counter) = mean(PortSimPNL(PortSimPNL(end,:)<VAR99(counter))');

        %Calculate 10 day Pnl
        Prices10day = Prices(windowIndexEnd+10,:);
        PortEndVal = Prices10day*NumofShares';
        PNL10day(counter) = PortEndVal-PortStartVal;
        Return10day(counter) = PNL10day(counter)/PortStartVal;
        %VarBreaches

        VAR95Breach(counter) = BreachofVARAmount(PNL10day(counter),VAR95(counter));
        VAR99Breach(counter) = BreachofVARAmount(PNL10day(counter),VAR99(counter));
        CVAR95Breach(counter) = BreachofVARAmount(PNL10day(counter),CVAR95(counter));
        CVAR99Breach(counter) = BreachofVARAmount(PNL10day(counter),CVAR99(counter));

        PortfolioTurnover(counter) = sum(abs(weights-weightsprev));
        %Note here we are mutiplying by the PortEndval for finding the Txn
        %cost
        TransactionCosts(counter) = sum(abs((weights-weightsprev)*PortEndVal))*TransactionCostRate;
        Return10dayminusTxn(counter) = (PNL10day(counter)-TransactionCosts(counter))/PortStartVal;
        PortStartVal = PortEndVal;
        weightsprev = weights;
        counter = counter + 1;
    end

    [AvVARs] = abs([mean(VAR95) mean(VAR99) mean(CVAR95) mean(CVAR99)]);

    %VAR Breaches
    [VAR95BreachCount VAR95Percent VAR95BreachMean] = VARBreachesCount(VAR95Breach);
    [VAR99BreachCount VAR99Percent VAR99BreachMean] = VARBreachesCount(VAR99Breach);
    [CVAR95BreachCount CVAR95Percent CVAR95BreachMean] = VARBreachesCount(CVAR95Breach);
    [CVAR99BreachCount CVAR99Percent CVAR99BreachMean] = VARBreachesCount(CVAR99Breach);
    temp1=sprintf('\nVAR Type \t Average VAR \t Breaches \t%%Percent \t Mean Of Breach');
    temp2=sprintf('\nVAR 95     \t\t%6.0f               \t\t\t%6.0f             \t\t%6.0f       \t\t%6.0f\t', AvVARs(1), VAR95BreachCount, VAR95Percent*100, VAR95BreachMean);
    temp3=sprintf('\nVAR 99     \t\t%6.0f               \t\t\t%6.0f             \t\t%6.0f       \t\t%6.0f\t', AvVARs(2), VAR99BreachCount, VAR99Percent*100, VAR99BreachMean);
    temp4=sprintf('\nCVAR 95    \t%6.0f             \t\t\t%6.0f             \t\t%6.0f       \t\t%6.0f \t', AvVARs(3), CVAR95BreachCount, CVAR95Percent*100, CVAR95BreachMean);
    temp5=sprintf('\nCVAR 99    \t%6.0f             \t\t\t%6.0f             \t\t%6.0f       \t\t%6.0f \t', AvVARs(4), CVAR99BreachCount, CVAR99Percent*100, CVAR99BreachMean);
    ret_string = strvcat(temp1,temp2,temp3,temp4,temp5);

    %Summary Statistics
    CumPNL = cumsum(PNL10day);
    %Subtracting the txn costs from PNL
    CumPNLminusTXN = cumsum(PNL10day-TransactionCosts);
    TotalReturn = (CumPNL(:,end)/InitialInvestment);
    TotalReturnminusTXN = (CumPNLminusTXN(:,end)/InitialInvestment);
    AnnualisedReturn = (TotalReturn+1)^(1/(EndRow/(DaysInYear))) - 1;
    AnnualisedReturnminusTXN = (TotalReturnminusTXN+1)^(1/(EndRow/(DaysInYear))) - 1;
    PortStanDev = std(Return10day)*sqrt(DaysInYear);
    %Standard deviation calculated when Transaction cost have been
    %accounted for in the returns - TOCHECK
    PortStanDevminusTxn = std(Return10dayminusTxn)*sqrt(DaysInYear);
    
    %BenchMarkStats
    BenchMarkReturns = tick2ret(BenchmarkPrices,[],'Continuous');
    BenchMarkTotalReturn = (BenchmarkPrices(EndRow) - BenchmarkPrices(1))/BenchmarkPrices(EndRow);
    BenchMarkAnnualisedReturn = (BenchMarkTotalReturn+1)^(1/(EndRow/(DaysInYear))) - 1;
    BenchMarkStanDev = std(BenchMarkReturns)*sqrt(DaysInYear);
    temp1=sprintf('\nSummary Statistics\n');
    temp2=sprintf('                                   \t\t\t\t\t\tPortfolio                 \t Pf-TxnCost       \t Benchmark \n');
    temp3=sprintf('Annualized return        \t\t%%%6.2f                 \t%%%6.2f                 \t%%%6.2f \n', AnnualisedReturn*100,AnnualisedReturnminusTXN*100, BenchMarkAnnualisedReturn*100);
    temp4=sprintf('Standard Deviation       \t\t%%%6.2f                 \t%%%6.2f                  \t%%%6.2f\n', PortStanDev*100,PortStanDevminusTxn*100, BenchMarkStanDev*100);
    temp5=sprintf('Sharpe Ratio                 \t\t\t%6.2f                     \t%6.2f                     \t%6.2f\n', (AnnualisedReturn-RisklessRate)/PortStanDev,(AnnualisedReturnminusTXN-RisklessRate)/PortStanDevminusTxn,(BenchMarkAnnualisedReturn-RisklessRate)/BenchMarkStanDev);
    temp6=sprintf('Portfolio PNL                \t\t\t%6.0f                 \n', sum(PNL10day));
    temp7=sprintf('TransactionCosts         \t\t%6.0f                   \n', sum(TransactionCosts));
    temp8=sprintf('PfPNL-TxnCosts           \t\t%6.0f                   \n', sum(PNL10day-TransactionCosts));
    ret_string = strvcat(ret_string,temp1,temp2,temp3,temp4,temp5,temp6,temp7,temp8);
    Xvalues = 1:counter-1;

end

%determines if there has been a breach of VAR
function BreachofVARAmount = BreachofVARAmount(PNL,VAR)
    if PNL<VAR
        BreachofVARAmount = PNL;
    else
        BreachofVARAmount = 0;
    end
end

%Counts the number of VAR Breaches
function [VARBreachesCount Perctge VARBreachMean]=VARBreachesCount(VARBreaches)
    VARBreachesCount=sum(abs(VARBreaches)>0);
    VARBreachMean = mean(abs(VARBreaches(VARBreaches<0)));
    rowcount = size(VARBreaches,2);
    Perctge = VARBreachesCount/rowcount;
end