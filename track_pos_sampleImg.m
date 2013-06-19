function samples = track_pos_sampleImg(pos_sampleimg,initstate,frame_t,frame_len)

pos_sampleimg.sx(frame_t-frame_len) = initstate(1);
pos_sampleimg.sy(frame_t-frame_len) = initstate(2);
pos_sampleimg.sw(frame_t-frame_len) = initstate(3);
pos_sampleimg.sh(frame_t-frame_len) = initstate(4);

samples.sx = pos_sampleimg.sx;
samples.sy = pos_sampleimg.sy;
samples.sw = pos_sampleimg.sw;
samples.sh = pos_sampleimg.sh;

