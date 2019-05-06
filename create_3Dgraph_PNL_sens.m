function ret_string=create_3Dgraph_PNL_sens(GraphObj)
%Creates a 3D graph displaying sentivity of portfolio with change in risk
%free rate
Counter = 0;
for TransactionCostRate = 0.01:0.02:0.15
    Counter =Counter + 1;
[ret_string,Xvalues,CumPNL,CumPNLminusTXN,PNL10day,VAR95,VAR99,CVAR95,CVAR99]=...
    Engine_Pf_Analysis('AssetPrices.xls','Unconstrained','100',0.05,TransactionCostRate);
CumPNLMatrix(Counter,:) =CumPNLminusTXN;
end

TransactionCostvalues=0.01:0.02:0.15;
surf(Xvalues,TransactionCostvalues,CumPNLMatrix)
xlabel('Time');
ylabel('TransactionCost');
zlabel('CumulativePnL');
title('TransactionCost Vs Portfolio Performance Senstivity');
