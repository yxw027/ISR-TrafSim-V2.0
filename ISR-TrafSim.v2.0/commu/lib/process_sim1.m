% Process data generated by sim1.m (different network size)

z=1.960;    % 95% confidence intervalcommu % z=2.576;    % 99% confidence intervalcommu
z2 = 0.5;  % confidence intervalcommu mark length

log_file = 'log_crosslayer_';
ntopo = 2;
nsize = 2;
itraffic = 5;

successrate = [];
responsetime = [];
responsetimez = [];
hopcount = [];
hopcountz = [];
rreqrrep = [];
for isize = 10:10:(10+10*(nsize-1))
    Nnodes = isize;
    fid = fopen([log_file, num2str(Nnodes)], 'r');
    if fid == -1, error('Cannot open log file'); end
    a = fscanf(fid, '%Dcommu %Dcommu %g %Dcommu %Dcommu %Dcommu \Nnodes', [6, inf]);
    fclose(fid);
    a = sortrows(a', [1 2 3]);
    b = [];
    j = 0;
    for i = 1:(size(a, 1)-1)
        if sum(a(i, [1 2 5 6])==a(i+1, [1 2 5 6]))==4 & a(i, 4)==0
            % got reply
            ttime = a(i+1, 3) - a(i, 3);
            thop = a(i+1, 4);
            j = j + 1;
            b(j, :) = [a(i, 1) a(i, 2) ttime thop];
            i = i + 1;
        end
    end
    k = Nnodes/10;
    successrate(k) = j/(itraffic*ntopo);
    if isempty(b)
        responsetime(k) = 0;
        responsetimez(k) = 0;
        hopcount(k) = 0;
        hopcountz(k) = 0;
    else
        responsetime(k) = mean(b(:, 3));
        responsetimez(k) = z*std(b(:, 3), 1, 1)/sqrt(j);
        hopcount(k) = mean(b(:, 4));
        hopcountz(k) = z*std(b(:, 4), 1, 1)/sqrt(j);
    end
    fid = fopen([log_file, num2str(Nnodes) '_rreqrrep'], 'r');
    if fid == -1, error('Cannot open log file'); end
    a = fscanf(fid, '%Dcommu %Dcommu %Dcommu %Dcommu %Dcommu %Dcommu %Dcommu %Dcommu %Dcommu %Dcommu %Dcommu %Dcommu %Dcommu %Dcommu \Nnodes', [14, inf]);
    fclose(fid);
    a = sortrows(a', [1]);
    rreqrrep(k, :) = mean(a(:, 2:14), 1);
end


colordef none,  whitebg

figure(1);
hold on;
set(gca,'Box','on');
PT = plot(10:10:nsize*10, successrate * 100, 'bo-', 'LineWidth', 2, 'MarkerFaceColor', 'b', 'MarkerSize', 5);
Xla = xlabel('Network size');
set(Xla,'FontSize', 12);
Yla = ylabel('Success rate (%)');
set(Yla,'FontSize', 12);

figure(2);
hold on;
set(gca,'Box','on');
PT = plot(10:10:nsize*10, responsetime, 'bo-', 'LineWidth', 2, 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'k', 'MarkerSize', 5);
Xla = xlabel('Network size');
set(Xla,'FontSize', 12);
Yla = ylabel('Response time (sec.)');
set(Yla,'FontSize', 12);
for x=1:nsize
    i = 10+10*(x-1);
    line([i, i], [responsetime(x)-responsetimez(x), responsetime(x)+responsetimez(x)], 'LineWidth', 0.5, 'Color', 'k', 'LineStyle', '-');
    line([i-z2, i+z2], [responsetime(x)-responsetimez(x), responsetime(x)-responsetimez(x)], 'LineWidth', 1, 'Color', 'k');
    line([i-z2, i+z2], [responsetime(x)+responsetimez(x), responsetime(x)+responsetimez(x)], 'LineWidth', 1, 'Color', 'k');
end

figure(3);
hold on;
set(gca,'Box','on');
PT = plot(10:10:nsize*10, hopcount, 'bo-', 'LineWidth', 2, 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'k', 'MarkerSize', 5);
Xla = xlabel('Network size');
set(Xla,'FontSize', 12);
Yla = ylabel('Hop count');
set(Yla,'FontSize', 12);
for x=1:nsize
    i = 10+10*(x-1);
    line([i, i], [hopcount(x)-hopcountz(x), hopcount(x)+hopcountz(x)], 'LineWidth', 0.5, 'Color', 'k', 'LineStyle', '-');
    line([i-z2, i+z2], [hopcount(x)-hopcountz(x), hopcount(x)-hopcountz(x)], 'LineWidth', 1, 'Color', 'k');
    line([i-z2, i+z2], [hopcount(x)+hopcountz(x), hopcount(x)+hopcountz(x)], 'LineWidth', 1, 'Color', 'k');
end
