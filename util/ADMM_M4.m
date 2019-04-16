function [xf, Zf] = ADMM_M4(feat, yf, opts)
[row,col] = size(feat);

lambda = opts.lambda;
gama = opts.gama;
miu = opts.miu;
stepsize = opts.stepsize;

iteration = opts.iteration;%迭代次数

Zf = cell(1,col);%滤波器
Z = cell(1,col);
P = cell(1,col);
YP = cell(1,col);
Q = cell(1,col);
YQ = cell(1,col);


xf = cell(1,col);
sz = size(feat{1});
for ii = 1:col%高维
    xf{ii} = fft2(feat{ii});
   Zf{1,ii} = zeros(sz);
   Z{1,ii} = zeros(sz);
   P{1,ii} = zeros(sz);
   YP{1,ii} = zeros(sz);
   Q{1,ii} = zeros(sz);
   YQ{1,ii} = zeros(sz);
end
% yf = fft2(yf);

for step = 1:iteration    %iteration for convergance   3
    %% Update Z
    Zpref = Zf;
    for moldal = 1:col
        Zf{1,moldal} = (conj(xf{1,moldal}) .* yf  +  miu*(fft2(P{1,moldal} + Q{1,moldal}))  -  (fft2(YP{1,moldal} + YQ{1,moldal})))...%分子
            ./ ( sum(xf{1,moldal} .* conj(xf{1,moldal}),3)/numel(xf{1,moldal}) +  2*miu);%分母
        Z{1,moldal} = real(ifft2(Zf{1,moldal}));
        check_Z(moldal) = max(abs(real(Zf{1,moldal}(:) - Zpref{1,moldal}(:))));
    end
    %% Update P
    Ppre = P;
    for moldal = 1:col
        %结果为非傅里叶域
        P{1,moldal} = sign(Z{1,moldal} + YP{1,moldal}/miu) .* max(0,abs(Z{1,moldal} + YP{1,moldal}/miu) - lambda / miu);
        
        check_P(moldal) = max(abs(P{1,moldal}(:) - Ppre{1,moldal}(:)));
    end
    %% UPdate Q
    Qpre = Q;
    H2 = zeros(size(feat{1},1), size(feat{1},2));
    for ii = 1:col
        H{1,ii} = Z{1,ii} + YQ{1,ii}/miu;
        
        H2 = H2 + H{1,ii} .* H{1,ii};
    end
    H2 = sqrt(H2);
    
    maxw = max(0,1 - (gama)./(miu * H2));
    
    for moldal = 1:col
        %结果为非傅里叶域
        Q{1,moldal} = maxw .* H{1,moldal};
        
        check_Q(moldal) = max(abs(Q{1,moldal}(:) - Qpre{1,moldal}(:)));
    end
    
    %% update YP,YQ miu
    for moldal = 1:col
        YP{1,moldal} = YP{1,moldal} + miu*(Z{1,moldal} - P{1,moldal});
        YQ{1,moldal} = YQ{1,moldal} + miu*(Z{1,moldal} - Q{1,moldal});
    end
    miu = min(10^10, stepsize*miu);
    %% check for aonvergence
    if step > 1
       checkZ = max(check_Z);
       checkP = max(check_P);
       checkQ = max(check_Q);
       check = max(checkZ,max(checkP,checkQ));
       con(step - 1) = check;
       if check < opts.ABSTOL
           break;
       end
    end
end
end
