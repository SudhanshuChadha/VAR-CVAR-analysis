function create_graph_var(axes2,X1, YMatrix1)
%Generates multiple plots displaying Performance of portfolio against VAR/CVAR
    % Create title xlabel ylabel
    xlabel(axes2,'Time');
    ylabel(axes2,'$$');
    title(axes2,'Absolute PNL vs VaR');
    
    % Create multiple lines using matrix input to plot
    plot1 = plot(X1,YMatrix1,'Parent',axes2);
    set(plot1(1),'DisplayName','Absolute PNL');
    set(plot1(2),'DisplayName','VAR95');
    set(plot1(3),'DisplayName','VAR99');
    set(plot1(4),'DisplayName','CVAR95');
    set(plot1(5),'DisplayName','CVAR99');

    % Create legend
    legend1 = legend(axes2,'show');
    %set(legend1,'Position',[0.4536 -0.01766 0.1468 0.1301]);
end