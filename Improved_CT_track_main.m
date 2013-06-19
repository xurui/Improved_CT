% Email: xurui011@gmail.com
% Date: 06/06/2013

clc;clear all;close all;
%----------------------------------
rand('state',0);
%----------------------------------
addpath('./girl');
%----------------------------------
load init.txt;
initstate = init;%initial tracker
%----------------------------Set path
img_dir = dir('./girl/*.png');
%---------------------------
img = imread(img_dir(1).name);
img = double(img(:,:,1));
%----------------------------------------------------------------
trparams.init_negnumtrain = 50;%number of trained negative samples
trparams.init_postrainrad = 4.0;%radical scope of positive samples
trparams.initstate = initstate;% object position [x y width height]
trparams.srchwinsz = 25;% size of search window
% Sometimes, it affects the results.
%-------------------------
% classifier parameters
clfparams.width = trparams.initstate(3);
clfparams.height= trparams.initstate(4);
%-------------------------
% feature parameters
% number of rectangle from 2 to 4.
ftrparams.minNumRect = 2;
ftrparams.maxNumRect = 4;
%-------------------------
M = 60;% number of all weaker classifiers, i.e,feature pool
Pre_len = 50;% number of previous frames
%-------------------------
cur_posx.mu = zeros(M,1);% mean of positive features
negx.mu = zeros(M,1);
cur_posx.sig= ones(M,1);% variance of positive features
negx.sig= ones(M,1);
pre_posx.mu = zeros(M,1);
pre_posx.sig= ones(M,1);
%-------------------------Learning rate parameter
lRate = 0.85;
%-------------------------
%compute feature template
[ftr.px,ftr.py,ftr.pw,ftr.ph,ftr.pwt] = HaarFtr(clfparams,ftrparams,M);
%-------------------------
%compute sample templates
cur_posx.sampleImage = sort_pos_sampleImg(img,initstate,trparams.init_postrainrad,0,100000);
negx.sampleImage = sampleImg(img,initstate,1.5*trparams.srchwinsz,4+trparams.init_postrainrad,50);
%-----------------------------------
%--------Feature extraction
iH = integral(img);%Compute integral image
cur_posx.feature = getFtrVal(iH,cur_posx.sampleImage,ftr);
pre_posx.feature(:,1) = cur_posx.feature(:,1);
negx.feature = getFtrVal(iH,negx.sampleImage,ftr);
%--------------------------------------------------
[cur_posx.mu,cur_posx.sig,negx.mu,negx.sig] = classiferUpdate(cur_posx,negx,cur_posx.mu,cur_posx.sig,negx.mu,negx.sig,lRate);% update distribution parameters
%-------------------------------------------------
num = length(img_dir);% number of frames
%--------------------------------------------------------
x = initstate(1);% x axis at the Top left corner
y = initstate(2);
w = initstate(3);% width of the rectangle
h = initstate(4);% height of the rectangle
%--------------------------------------------------------
for i = 2:Pre_len
    img = imread(img_dir(i).name);
    imgSr = img;% imgSr is used for showing tracking results.
    img = double(img(:,:,1));
    detectx.sampleImage = sampleImg(img,initstate,trparams.srchwinsz,0,100000);
    iH = integral(img);%Compute integral image
    detectx.feature = getFtrVal(iH,detectx.sampleImage,ftr);
    %------------------------------------
    r = ratioClassifier(cur_posx,negx,detectx);% compute the classifier for all samples
    clf = sum(r);% linearly combine the ratio classifiers in r to the final classifier
    %-------------------------------------
    [c,index] = max(clf);
    %--------------------------------
    x = detectx.sampleImage.sx(index);
    y = detectx.sampleImage.sy(index);
    w = detectx.sampleImage.sw(index);
    h = detectx.sampleImage.sh(index);
    initstate = [x y w h];
    %-------------------------------Show the tracking results
    imshow(uint8(imgSr));
    rectangle('Position',initstate,'LineWidth',4,'EdgeColor','r');
    hold on;
    text(5, 18, strcat('#',num2str(i)), 'Color','y', 'FontWeight','bold', 'FontSize',20);
    set(gca,'position',[0 0 1 1]); 
    pause(0.00001); 
    hold off;
    %------------------------------Extract samples  
    cur_posx.sampleImage = sort_pos_sampleImg(img,initstate,trparams.init_postrainrad,0,100000);
    l_len = cur_posx.sampleImage.num;
    negx.sampleImage = sampleImg(img,initstate,1.5*trparams.srchwinsz,4+trparams.init_postrainrad,trparams.init_negnumtrain);
    %--------------------------------------------------Update all the features
    cur_posx.feature = getFtrVal(iH,cur_posx.sampleImage,ftr);
    pre_posx.feature(:,i) = cur_posx.feature(:,1);
    negx.feature = getFtrVal(iH,negx.sampleImage,ftr);
    %--------------------------------------------------
    [cur_posx.mu,cur_posx.sig,negx.mu,negx.sig] = classiferUpdate(cur_posx,negx,cur_posx.mu,cur_posx.sig,negx.mu,negx.sig,lRate);% update distribution parameters
end
%--------------------------------------------------------
j = 1;
for i = (Pre_len+1):num
    img = imread(img_dir(i).name);
    imgSr = img;% imgSr is used for showing tracking results.
    img = double(img(:,:,1));
    detectx.sampleImage = sampleImg(img,initstate,trparams.srchwinsz,0,100000);   
    iH = integral(img);%Compute integral image
    detectx.feature = getFtrVal(iH,detectx.sampleImage,ftr);
    %------------------------------------
    r1 = ratioClassifier(cur_posx,negx,detectx);% compute r1 classifier for current samples
    r2 = ratioClassifier(pre_posx,negx,detectx);% compute r2 classifier for previous samples
    clf = (l_len/(Pre_len+l_len)).*sum(r1)+(Pre_len/(Pre_len+l_len)).*sum(r2);% linearly combine the ratio classifiers in r to the final classifier
%    clf = sum(r2);
    %-------------------------------------
    [c,index] = max(clf);
    %--------------------------------
    x = detectx.sampleImage.sx(index);
    y = detectx.sampleImage.sy(index);
    w = detectx.sampleImage.sw(index);
    h = detectx.sampleImage.sh(index);
    initstate = [x y w h];
    %-------------------------------Show the tracking results
    imshow(uint8(imgSr));
    rectangle('Position',initstate,'LineWidth',4,'EdgeColor','r');
    hold on;
    text(5, 18, strcat('#',num2str(i)), 'Color','y', 'FontWeight','bold', 'FontSize',20);
    set(gca,'position',[0 0 1 1]); 
    pause(0.00001); 
    hold off;
    %------------------------------Extract samples  
    cur_posx.sampleImage = sort_pos_sampleImg(img,initstate,trparams.init_postrainrad,0,100000);
    l_len = cur_posx.sampleImage.num;
    negx.sampleImage = sampleImg(img,initstate,1.5*trparams.srchwinsz,4+trparams.init_postrainrad,trparams.init_negnumtrain);
    %--------------------------------------------------Update all the features
    cur_posx.feature = getFtrVal(iH,cur_posx.sampleImage,ftr);
    if mod(i,Pre_len)==0
        j = 1;
        pre_posx.feature(:,Pre_len) = cur_posx.feature(:,1);
    else
        pre_posx.feature(:,j) = cur_posx.feature(:,1);
        j = j+1;
    end
    negx.feature = getFtrVal(iH,negx.sampleImage,ftr);
    %--------------------------------------------------
    [cur_posx.mu,cur_posx.sig,negx.mu,negx.sig] = classiferUpdate(cur_posx,negx,cur_posx.mu,cur_posx.sig,negx.mu,negx.sig,lRate);% update distribution parameters
    [pre_posx.mu,pre_posx.sig,negx.mu,negx.sig] = classiferUpdate(pre_posx,negx,pre_posx.mu,pre_posx.sig,negx.mu,negx.sig,lRate);% update distribution parameters
%    [negx.mu,negx.sig] = negx_classiferUpdate(negx,negx.mu,negx.sig,lRate);
end