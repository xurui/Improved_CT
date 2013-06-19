function samples = sort_pos_sampleImg(img,initstate,inrad,outrad,maxnum)


inrad = ceil(inrad);
outrad= ceil(outrad);

[row,col] = size(img);
x = initstate(1);
y = initstate(2);
w = initstate(3);
h = initstate(4);

rowsz = row - h - 1;
colsz = col - w - 1;

inradsq  = inrad^2;
outradsq = outrad^2;

minrow = max(1, y - inrad+1);
maxrow = min(rowsz-1, y+inrad);
mincol = max(1, x-inrad+1);
maxcol = min(colsz-1, x+inrad);

prob = maxnum/((maxrow-minrow+1)*(maxcol-mincol+1));
i = 1;
%--------------------------------------------------
%--------------------------------------------------
[r,c] = meshgrid(minrow:maxrow,mincol:maxcol);
dist  = (y-r).^2+(x-c).^2;
rd = rand(size(r));

ind = (rd<prob)&(dist<inradsq)&(dist>=outradsq);
c = c(ind==1);
r = r(ind==1);

dist1  = (y-r).^2+(x-c).^2;
[~,seq] = sort(dist1);
r1 = r(seq);
c1 = c(seq);

samples.num = length(r1);
samples.sx = c1';
samples.sy = r1';
samples.sw = w*ones(1,length(r(:)));
samples.sh = h*ones(1,length(r(:)));
