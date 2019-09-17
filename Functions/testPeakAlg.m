clear all
N = 3000;
t = linspace(0,N);fs = 800;
t = t./fs;
f1 = 10; f2 = 70;f3 = 5;
Volt = sin(2*pi*f1.*t)+sin(2*pi*f2.*t) + 0.5*sin(2*pi*f3.*t)+0.1.*rand(1,length(t));
           Y = detrend((Volt)); N = length(Volt);
           L = ceil(N/2)-1;
           %L = 250;
           m = zeros(L,N);
           for k = 1:L
               %w = 2*k;
               for i = (k+2):(N-k+1)
                   if and((Volt(i-1) > Volt(i-k-1)),Volt(i-1) > Volt(i+k-1))
                        m(k,i) = 0;
                   else
                       r = rand();
                       m(k,i) = r+1;
                   end
               end
           end
           gamma = sum(m,2);
           [~,lambda]= min(detrend(gamma));
           figure(1); hold off; plot(1:L,gamma);
           figure(2);hold off;plot(t,Volt);
           figure(4);imagesc(t,1:L,m)
           %lambda = 500;
           M = m(1:lambda,:);
           j = 1;
           for i = 1:N
               %{
               X = (1/lambda)*sum(m(:,i));
               Y = (m(:,i)-X).^2; Y = Y.^(0.5);
               Y = sum(Y);
               sigma(i) = (1/(lambda-1))*Y;
               %}
               %sigma = std(M(:,i));
               sigma(i) = (lambda-1)^(-1)*sum(((M(:,i)-(1/lambda)*sum(M(:,i))).^2).^(0.5));
               if sigma(i) ==0
                   p(j) = i;
                   j = j+1;
               end
           end
           p(1:2) = [];
           figure(5);hold off;plot(t(p),Volt(p),'bo'); hold on; plot(t,Volt);
           P = p;
           