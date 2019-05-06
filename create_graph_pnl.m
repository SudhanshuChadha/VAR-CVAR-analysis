function create_graph_pnl(axes1,X1, YMatrix1)
%Generates Graph for cumlative PnL
    % Create title xlabel ylabel
    title(axes1,'Portfolio Performance');
    xlabel(axes1,'Time');
    ylabel(axes1,'Cumulative PNL');
    grid(axes1,'on');
    % Create plot
    plot1 =plot(X1,YMatrix1,'Parent',axes1);
    set(plot1(1),'DisplayName','CumPNL');
    set(plot1(2),'DisplayName','CumPNL-Txncost');
    legend1 = legend(axes1,'show');
end

