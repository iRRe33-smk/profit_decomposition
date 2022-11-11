%Need to change paths to suit your computer, on lines with comment *. 
%If not mac, need to download files from lab5 and change paths on lines **.

function [fAll] = create_curve()
    amplFolderPath =  '/Users/linus/Desktop/TATA62/PCA/';    %*
    amplSetupFilename = strcat(amplFolderPath,"amplapi/matlab/setUp.m"); %**
    amplPath = strcat(amplFolderPath, "ampl_macos64"); %**
    solverFile = strcat(amplPath, "/ipopt"); %**

    if (~exist(amplSetupFilename,'file') || ~exist(amplPath, 'dir'))
      error('It is necessary to follow the lab instructions to obtain ampl, then change the amplFolderPath to your own path. If another operating system than win64, the folder names in the code has to be changed.');
    end

    ipoptFilename = strcat(amplFolderPath, "ampl_macos64/ipopt"); %**
    if (~exist(ipoptFilename,'file') && ~exist(strcat(ipoptFilename,'.exe'),'file'))
      error('It is necessary to follow the lab instructions and copy Ipopt to the correct folder.');
    end

    if (~exist('AMPL', 'file'))
      run(amplSetupFilename); % Only initialize ampl once
    end

    if (exist('ampl', 'var')) % Ensure that ampl is closed if matlab program ended prematurely the previous time
      ampl.close();
      clear ampl;
    end

    if (~exist('dates', 'var') || ~exist('ric', 'var') || ~exist('data', 'var')) % Only load data once
      [dates, ric, data] = loadFromExcel('forwardRates.xlsx');
    end

    LeastSquare = true;
    p = 1E+04;   
    dt = 1/365; % Daily discretization in forward rates
    T = [1/12 ; 2/12 ; 3/12 ; 6/12 ; 9/12 ; 1 ; 2 ; 3 ; 4 ; 5 ; 6 ; 7 ; 8 ; 9 ; 10]; % Maturities
    T0 = [0 ; T];
    M = round(T*1/dt); % Maturities (measured in number of time periods)

    nOIS = length(ric{1});

    K = length(dates{1}); % Number of historical dates
    nF = M(end);
    fAll = zeros(K, nF);
    zAll = zeros(K, nOIS);

    ampl = AMPL(amplPath);
    if (LeastSquare)
      ampl.read('forwardRatesLS.mod')
      ampl.getParameter('p').set(p);
    else
      ampl.read('forwardRates.mod')
    end
    ampl.getParameter('dt').set(dt)
    ampl.getParameter('n').set(nF);
    ampl.getParameter('m').set(length(T));
    ampl.getParameter('M').setValues(M);

    figure(1);
    for k=1:K
      mid = (data{1}(k,:) + data{2}(k,:))'/200;
      r = zeros(nOIS,1);

      %error('Todo: Bootsrapping');
      r = bootstrapping(mid,T);


      f = [r(1) ; (r(2:end).*T(2:end)-r(1:end-1).*T(1:end-1))./(T(2:end)-T(1:end-1))];

      ampl.getParameter('r').setValues(r);
      ampl.setOption('solver', solverFile)
      ampl.solve();

      [xx,yy] = stairs(T0, [f ; f(end)]);

      fS = ampl.getVariable('f').getValues().getColumnAsDoubles('f.val'); % Smooth forward rates
      if (LeastSquare)
        z = ampl.getVariable('z').getValues().getColumnAsDoubles('z.val'); % Price errors
        midT = (T0(1:end-1)+T0(2:end))/2;
        plot(xx,yy, (0:M(end)-1)*dt, fS, midT, fS(1+round(midT*1/dt))+z, '+'); % + indicates the direction that forward rates should be adjusted
        title(['Least squares (p = ' sprintf('%.0e',p) '), ' datestr(dates{1}(k))]);
      else
        z = zeros(nOIS,1);
        plot(xx,yy, (0:M(end)-1)*dt, fS);
        title(['Exact, ' datestr(dates{1}(k))]);
      end
      %pause(.1); % Pause 0.1 second (to be able to view the curve)
      fAll(k,:) = fS;
      zAll(k,:) = z;
    end

    ampl.close();
    clear ampl;

end