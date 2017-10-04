% Copyright (C) 2010-2017, Raytheon BBN Technologies and contributors listed 
% in the AUTHORS file in TASBE analytics package distribution's top directory.
%
% This file is part of the TASBE analytics package, and is distributed
% under the terms of the GNU General Public License, with a linking
% exception, as described in the file LICENSE in the TASBE analytics
% package distribution's top directory.

function plot_plusminus_comparison(pm_results,outputsettings)

step = outputsettings.PlotEveryN;
ticks = outputsettings.PlotTickMarks;

variable = getInducerLevelsToFiles(getExperiment(pm_results.PlusResults),1);
n_var = numel(variable);

AP = getAnalysisParameters(pm_results.PlusResults);
hues = (1:n_var)./n_var;
bin_centers = get_bin_centers(getBins(AP));
in_units = getChannelUnits(AP,'input');
out_units = getChannelUnits(AP,'output');
cfp_units = getChannelUnits(AP,'constitutive');

legendentries = cell(0);
% fill in entries, trimming those that won't get graphed
for i=1:step:n_var
    which = pm_results.Valid(:,i,1) & pm_results.Valid(:,i,2);
    entrystr = num2str(variable(i));
    if numel(which)>0 && sum(which)>0
        legendentries{end+1} = entrystr; % not pre-allocated because we don't know how many are valid
    else
        warning('PlotPlusMinus:EmptyResults','No active results for %s: not enough data or bad active component fit',entrystr);
    end
end;

% Enhance or modify for plus/minus graphs
if n_var == 1, 
    pmlegendentries{1} = 'Plus';
else
    pmlegendentries = legendentries;
end

% set tick marks, if any
if ticks, ptick = '+'; ntick = 'o'; 
else ptick = []; ntick = [];
end
    
%%% I/O plots:
% Plain I/O plot:
h = figure('PaperPosition',[1 1 5 3.66]);
set(h,'visible','off');
for i=1:step:n_var
    which = pm_results.Valid(:,i,1) & pm_results.Valid(:,i,2);
    loglog(pm_results.InMeans(which,i,1),pm_results.OutMeans(which,i,1),[ptick '-'],'Color',hsv2rgb([hues(i) 1 0.9])); hold on;
end;
for i=1:step:n_var
    which = pm_results.Valid(:,i,1) & pm_results.Valid(:,i,2);
    loglog(pm_results.InMeans(which,i,2),pm_results.OutMeans(which,i,2),[ntick '--'],'Color',hsv2rgb([hues(i) 1 0.9]));
    loglog(pm_results.InMeans(which,i,1),pm_results.OutMeans(which,i,1).*pm_results.OutStandardDevs(which,i,1),':','Color',hsv2rgb([hues(i) 1 0.9]));
    loglog(pm_results.InMeans(which,i,1),pm_results.OutMeans(which,i,1)./pm_results.OutStandardDevs(which,i,1),':','Color',hsv2rgb([hues(i) 1 0.9]));
    loglog(pm_results.InMeans(which,i,2),pm_results.OutMeans(which,i,2).*pm_results.OutStandardDevs(which,i,2),':','Color',hsv2rgb([hues(i) 1 0.9]));
    loglog(pm_results.InMeans(which,i,2),pm_results.OutMeans(which,i,2)./pm_results.OutStandardDevs(which,i,2),':','Color',hsv2rgb([hues(i) 1 0.9]));
end;
xlabel(['IFP ' in_units]); ylabel(['OFP ' out_units]);
set(gca,'XScale','log'); set(gca,'YScale','log');
legend(legendentries,'Location','Best');
if(outputsettings.FixedInputAxis), xlim(outputsettings.FixedInputAxis); end;
if(outputsettings.FixedOutputAxis), ylim(outputsettings.FixedOutputAxis); end;
title(['Raw ',outputsettings.StemName,' transfer curves']);
outputfig(h,[outputsettings.StemName,'-',outputsettings.DeviceName,'-mean'],outputsettings.Directory);


% normalized I/O plot
h = figure('PaperPosition',[1 1 5 3.66]);
set(h,'visible','off');
for i=1:step:n_var
    which = pm_results.Valid(:,i,1) & pm_results.Valid(:,i,2);
    loglog(pm_results.InMeans(which,i,1),pm_results.OutMeans(which,i,1)./bin_centers(which)',[ptick '-'],'Color',hsv2rgb([hues(i) 1 0.9])); hold on;
end
for i=1:step:n_var
    which = pm_results.Valid(:,i,1) & pm_results.Valid(:,i,2);
    loglog(pm_results.InMeans(which,i,2),pm_results.OutMeans(which,i,2)./bin_centers(which)',[ntick '--'],'Color',hsv2rgb([hues(i) 1 0.9]));
    loglog(pm_results.InMeans(which,i,1),pm_results.OutMeans(which,i,1)./bin_centers(which)'.*pm_results.OutStandardDevs(which,i,1),':','Color',hsv2rgb([hues(i) 1 0.9]));
    loglog(pm_results.InMeans(which,i,1),pm_results.OutMeans(which,i,1)./bin_centers(which)'./pm_results.OutStandardDevs(which,i,1),':','Color',hsv2rgb([hues(i) 1 0.9]));
    loglog(pm_results.InMeans(which,i,2),pm_results.OutMeans(which,i,2)./bin_centers(which)'.*pm_results.OutStandardDevs(which,i,2),':','Color',hsv2rgb([hues(i) 1 0.9]));
    loglog(pm_results.InMeans(which,i,2),pm_results.OutMeans(which,i,2)./bin_centers(which)'./pm_results.OutStandardDevs(which,i,2),':','Color',hsv2rgb([hues(i) 1 0.9]));
end;
xlabel(['IFP ' in_units]); ylabel(['OFP ' out_units ' / CFP ' cfp_units]);
set(gca,'XScale','log'); set(gca,'YScale','log');
legend(legendentries,'Location','Best');
if(outputsettings.FixedInputAxis), xlim(outputsettings.FixedInputAxis); end;
if(outputsettings.FixedOutputAxis), ylim(outputsettings.FixedOutputAxis); end;
title([outputsettings.StemName,' transfer curves normalized by CFP']);
outputfig(h,[outputsettings.StemName,'-',outputsettings.DeviceName,'-mean-norm'],outputsettings.Directory);

% IFP vs. CFP
h = figure('PaperPosition',[1 1 5 3.66]);
set(h,'visible','off');
for i=1:step:n_var
    which = pm_results.Valid(:,i,1) & pm_results.Valid(:,i,2);
    loglog(bin_centers(which),pm_results.InMeans(which,i,1),[ptick '-'],'Color',hsv2rgb([hues(i) 1 0.9])); hold on;
end;
for i=1:step:n_var
    which = pm_results.Valid(:,i,1) & pm_results.Valid(:,i,2);
    loglog(bin_centers(which),pm_results.InMeans(which,i,2),[ntick '--'],'Color',hsv2rgb([hues(i) 1 0.9]));
    loglog(bin_centers(which),pm_results.InMeans(which,i,1).*pm_results.InStandardDevs(which,i,1),':','Color',hsv2rgb([hues(i) 1 0.9]));
    loglog(bin_centers(which),pm_results.InMeans(which,i,1)./pm_results.InStandardDevs(which,i,1),':','Color',hsv2rgb([hues(i) 1 0.9]));
    loglog(bin_centers(which),pm_results.InMeans(which,i,2).*pm_results.InStandardDevs(which,i,2),':','Color',hsv2rgb([hues(i) 1 0.9]));
    loglog(bin_centers(which),pm_results.InMeans(which,i,2)./pm_results.InStandardDevs(which,i,2),':','Color',hsv2rgb([hues(i) 1 0.9]));
end;
xlabel(['CFP ' cfp_units]); ylabel(['IFP ' out_units]);
set(gca,'XScale','log'); set(gca,'YScale','log');
legend({pmlegendentries{:} 'Minus'},'Location','Best');
if(outputsettings.FixedInputAxis), xlim(outputsettings.FixedInputAxis); end;
if(outputsettings.FixedInputAxis), ylim(outputsettings.FixedInputAxis); end;
title([outputsettings.StemName,' IFP vs. CFP']);
outputfig(h,[outputsettings.StemName,'-',outputsettings.DeviceName,'-input-v-cfp'],outputsettings.Directory);


% OFP vs. CFP
h = figure('PaperPosition',[1 1 5 3.66]);
set(h,'visible','off');
for i=1:step:n_var
    which = pm_results.Valid(:,i,1) & pm_results.Valid(:,i,2);
    loglog(bin_centers(which),pm_results.OutMeans(which,i,1),[ptick '-'],'Color',hsv2rgb([hues(i) 1 0.9])); hold on;
end;
for i=1:step:n_var
    which = pm_results.Valid(:,i,1) & pm_results.Valid(:,i,2);
    loglog(bin_centers(which),pm_results.OutMeans(which,i,2),[ntick '--'],'Color',hsv2rgb([hues(i) 1 0.9]));
    loglog(bin_centers(which),pm_results.OutMeans(which,i,1).*pm_results.OutStandardDevs(which,i,1),':','Color',hsv2rgb([hues(i) 1 0.9]));
    loglog(bin_centers(which),pm_results.OutMeans(which,i,1)./pm_results.OutStandardDevs(which,i,1),':','Color',hsv2rgb([hues(i) 1 0.9]));
    loglog(bin_centers(which),pm_results.OutMeans(which,i,2).*pm_results.OutStandardDevs(which,i,2),':','Color',hsv2rgb([hues(i) 1 0.9]));
    loglog(bin_centers(which),pm_results.OutMeans(which,i,2)./pm_results.OutStandardDevs(which,i,2),':','Color',hsv2rgb([hues(i) 1 0.9]));
end;
xlabel(['CFP ' cfp_units]); ylabel(['OFP ' out_units]);
set(gca,'XScale','log'); set(gca,'YScale','log');
legend({pmlegendentries{:} 'Minus'},'Location','Best');
if(outputsettings.FixedInputAxis), xlim(outputsettings.FixedInputAxis); end;
if(outputsettings.FixedOutputAxis), ylim(outputsettings.FixedOutputAxis); end;
title([outputsettings.StemName,' OFP vs. CFP']);
outputfig(h,[outputsettings.StemName,'-',outputsettings.DeviceName,'-v-cfp'],outputsettings.Directory);

% % Relative change in OFP vs. CFP
% Removed because it wasn't ever useful
% h = figure('PaperPosition',[1 1 5 3.66]);
% set(h,'visible','off');
% for i=1:step:n_var
%     which = find(pm_results.Valid(1:(end-1),i,1) & pm_results.Valid(1:(end-1),i,2) & ...
%         pm_results.Valid(2:end,i,1) & pm_results.Valid(2:end,i,2));
%     marginal_centers = (bin_centers(which) + bin_centers(which+1)) / 2;
%     p_ofp_difference = pm_results.OutMeans(which+1,i,1) ./ pm_results.OutMeans(which,i,1);
%     m_ofp_difference = pm_results.OutMeans(which+1,i,2) ./ pm_results.OutMeans(which,i,2);
%     cfp_difference = (bin_centers(which+1) ./ bin_centers(which));
%     semilogx(marginal_centers,p_ofp_difference./cfp_difference',[ptick '-'],'Color',hsv2rgb([hues(i) 1 0.9])); hold on;
% end
% for i=1:step:n_var
%     which = find(pm_results.Valid(1:(end-1),i,1) & pm_results.Valid(1:(end-1),i,2) & ...
%         pm_results.Valid(2:end,i,1) & pm_results.Valid(2:end,i,2));
%     marginal_centers = (bin_centers(which) + bin_centers(which+1)) / 2;
%     p_ofp_difference = pm_results.OutMeans(which+1,i,1) ./ pm_results.OutMeans(which,i,1);
%     m_ofp_difference = pm_results.OutMeans(which+1,i,2) ./ pm_results.OutMeans(which,i,2);
%     cfp_difference = (bin_centers(which+1) ./ bin_centers(which));
%     semilogx(marginal_centers,m_ofp_difference./cfp_difference',[ntick '--'],'Color',hsv2rgb([hues(i) 1 0.9]));
% end;
% xlabel(['CFP ' cfp_units]); ylabel(['OFP ' out_units ' / CFP ' cfp_units]);
% set(gca,'XScale','log'); set(gca,'YScale','linear');
% legend('Location','Best',pmlegendentries,'Minus');
% if(outputsettings.FixedInputAxis), xlim(outputsettings.FixedInputAxis); end;
% if(outputsettings.FixedOutputAxis), ylim(outputsettings.FixedOutputAxis); end;
% title([outputsettings.StemName,' marginal change in OFP vs. CFP']);
% outputfig(h,[outputsettings.StemName,'-',outputsettings.DeviceName,'-marginal-ofp'],outputsettings.Directory);
% 

% ratio plot
h = figure('PaperPosition',[1 1 5 3.66]);
set(h,'visible','off');
for i=1:step:n_var
    which = pm_results.Valid(:,i,1) & pm_results.Valid(:,i,2);
    semilogx(bin_centers(which),pm_results.Ratios(which,i),'-','Color',hsv2rgb([hues(i) 1 0.9])); hold on;
end;
xlabel(['CFP ' cfp_units]); ylabel('Fold Activation');
set(gca,'XScale','log'); set(gca,'YScale','log');
legend(legendentries,'Location','Best');
if(outputsettings.FixedInputAxis), xlim(outputsettings.FixedInputAxis); end;
if(outputsettings.FixedOutputAxis), ylim(outputsettings.FixedOutputAxis); end;
title(['+/- Ratios for ',outputsettings.StemName]);
outputfig(h,[outputsettings.StemName,'-',outputsettings.DeviceName,'-ratios'],outputsettings.Directory);

% ratio plot
h = figure('PaperPosition',[1 1 5 3.66]);
set(h,'visible','off');
for i=1:step:n_var
    which = pm_results.Valid(:,i,1) & pm_results.Valid(:,i,2);
    semilogx(bin_centers(which),pm_results.Ratios(which,i),'-','Color',hsv2rgb([hues(i) 1 0.9])); hold on;
end;
xlabel(['CFP ' cfp_units]); ylabel('Fold Activation');
set(gca,'XScale','log'); set(gca,'YScale','log');
legend(legendentries,'Location','Best');
if(outputsettings.FixedInputAxis), xlim(outputsettings.FixedInputAxis); end;
if(outputsettings.FixedOutputAxis), ylim(outputsettings.FixedOutputAxis); end;
title(['+/- Ratios for ',outputsettings.StemName]);
outputfig(h,[outputsettings.StemName,'-',outputsettings.DeviceName,'-ratios'],outputsettings.Directory);

% SNR plots
if n_var == 1, 
    pmlegendentries{1} = 'Output SNR';
end

h = figure('PaperPosition',[1 1 5 3.66]);
set(h,'visible','off');
for i=1:step:n_var
    which = pm_results.Valid(:,i,1) & pm_results.Valid(:,i,2);
    semilogx(bin_centers(which),pm_results.OutputSNR(which,i),[ptick '-'],'Color',hsv2rgb([hues(i) 1 0.9])); hold on;
end;
for i=1:step:n_var
    which = pm_results.Valid(:,i,1) & pm_results.Valid(:,i,2);
    loglog(bin_centers(which),pm_results.InputSNR(which,i),[ntick '--'],'Color',hsv2rgb([hues(i) 1 0.9])); hold on;
end;
xlabel(['CFP ' cfp_units]); ylabel('SNR (db)');
set(gca,'XScale','log');
legend({pmlegendentries{:} 'Input SNR'},'Location','Best');
title([outputsettings.StemName,' SNR vs. CFP']);
outputfig(h,[outputsettings.StemName,'-',outputsettings.DeviceName,'-SNR'],outputsettings.Directory);

if n_var == 1, 
    pmlegendentries{1} = '\Delta SNR';
end

h = figure('PaperPosition',[1 1 5 3.66]);
set(h,'visible','off');
for i=1:step:n_var
    which = pm_results.Valid(:,i,1) & pm_results.Valid(:,i,2);
    semilogx(bin_centers(which),pm_results.OutputSNR(which,i)-pm_results.InputSNR(which,i),[ptick '-'],'Color',hsv2rgb([hues(i) 1 0.9])); hold on;
end;
xlabel(['CFP ' cfp_units]); ylabel('\Delta SNR (db)');
set(gca,'XScale','log');
legend(pmlegendentries,'Location','Best');
title([outputsettings.StemName,'\Delta SNR vs. CFP']);
outputfig(h,[outputsettings.StemName,'-',outputsettings.DeviceName,'-dSNR'],outputsettings.Directory);
