function distmesh_demo( cases )
close all
clc

if( ~nargin )
  cases = 1:10;
end

for i=cases
  feval( ['test_case',num2str(i)] )
  pause
  fprintf('\n\n')
end


function test_case1()
s = 'Example 1: (Uniform mesh on unit circle)';
disp(s)
fd = @(p) sqrt(sum(p.^2,2)) - 1;
fh = @(p) ones(size(p,1),1);
[p,t] = distmesh( fd, fh, 0.2, [-1,-1;1,1] );

clf
patch( 'vertices', p, 'faces', t, 'facecolor', [.9, .9, .9] )
title(s)
axis equal

function test_case2()
s = 'Example 2: (Uniform mesh on ellipse)';
disp(s)
fd = @(p) p(:,1).^2/2^2 + p(:,2).^2/1^2 - 1;
fh = @(p) ones(size(p,1),1);
[p,t] = distmesh( fd, fh, 0.2, [-2,-1;2,1] );

clf
patch( 'vertices', p, 'faces', t, 'facecolor', [.9, .9, .9] )
title(s)
axis equal

function test_case3()
s = 'Example 3: (Uniform mesh on unit square)';
disp(s)
fd = @(p) -min(min(min(p(:,2),1-p(:,2)),p(:,1)),1-p(:,1));
fh = @(p) ones(size(p,1),1);
[p,t] = distmesh( fd, fh, 0.2, [-1,-1;1,1], [-1,-1;-1,1;1,-1;1,1] );

clf
patch( 'vertices', p, 'faces', t, 'facecolor', [.9, .9, .9] )
title(s)
axis equal

function test_case4()
s = 'Example 4: (Uniform mesh on complex polygon)';
disp(s)
pv = [-0.4 -0.5;0.4 -0.2;0.4 -0.7;1.5 -0.4;0.9 0.1;
      1.6 0.8;0.5 0.5;0.2 1;0.1 0.4;-0.7 0.7;-0.4 -0.5];
fd = { 'l_dpolygon', [], pv };
fh = @(p) ones(size(p,1),1);
[p,t] = distmesh( fd, fh, 0.1, [-1,-1; 2,1], pv );

clf
patch( 'vertices', p, 'faces', t, 'facecolor', [.9, .9, .9] )
title(s)
axis equal

function test_case5()
s = 'Example 5: (Rectangle with circular hole, refined at circle boundary)';
disp(s)
drectangle = @(p,x1,x2,y1,y2) -min(min(min(-y1+p(:,2),y2-p(:,2)),-x1+p(:,1)),x2-p(:,1));
fd = @(p) max( drectangle(p,-1,1,-1,1), -(sqrt(sum(p.^2,2))-0.5) );
fh = @(p) 0.05 + 0.3*(sqrt(sum(p.^2,2))-0.5);
[p,t] = distmesh( fd, fh, 0.05, [-1,-1;1,1], [-1,-1;-1,1;1,-1;1,1] );

clf
patch( 'vertices', p, 'faces', t, 'facecolor', [.9, .9, .9] )
title(s)
axis equal

function test_case6()
s = 'Example 6: (Square, with size function point and line sources)';
disp(s)
dcircle = @(p,xc,yc,r) sqrt((p(:,1)-xc).^2+(p(:,2)-yc).^2)-r;
fd = @(p) -min(min(min(p(:,2),1-p(:,2)),p(:,1)),1-p(:,1));
fh = @(p) min(min(0.01+0.3*abs(dcircle(p,0,0,0)), ...
                  0.025+0.3*abs(dpolygon(p,[0.3,0.7; 0.7,0.5]))),0.15);
[p,t] = distmesh( fd, fh, 0.01, [0,0;1,1], [0,0;1,0;0,1;1,1] );

clf
patch( 'vertices', p, 'faces', t, 'facecolor', [.9, .9, .9] )
title(s)
axis equal

function test_case7()
s = 'Example 7: (NACA0012 airfoil)';
disp(s)
hlead = 0.01; htrail = 0.04; hmax = 2; circx = 2; circr = 4;
a = 0.12/0.2*[0.2969,-0.126,-0.3516,0.2843,-0.1036];
dcircle = @(p,xc,yc,r) sqrt((p(:,1)-xc).^2+(p(:,2)-yc).^2)-r;
fd = @(p) max( dcircle(p,circx,0,circr), ...
               -((abs(p(:,2))-polyval([a(5:-1:2),0],p(:,1))).^2-a(1)^2*p(:,1)) );
fh = @(p) min(min(hlead+0.3*dcircle(p,0,0,0),htrail+0.3*dcircle(p,1,0,0)),hmax);

fixx = 1 - htrail*cumsum(1.3.^(0:4)');
fixy = a(1)*sqrt(fixx) + polyval([a(5:-1:2),0],fixx);
pfix = [[circx+[-1,1,0,0]*circr; 0,0,circr*[-1,1]]'; 0,0; 1,0; fixx,fixy; fixx,-fixy];
bbox = [circx-circr,-circr; circx+circr,circr];
h0   = min([hlead,htrail,hmax]);

[p,t] = distmesh( fd, fh, h0, bbox, pfix );

clf
patch( 'vertices', p, 'faces', t, 'facecolor', [.9, .9, .9] )
title(s)
axis equal

function test_case8()
s = 'Example 8: (Uniform mesh on unit sphere)';
disp(s)
fd = @(p) sqrt(sum(p.^2,2)) - 1;
fh = @(p) ones(size(p,1),1);
[p,t] = distmesh( fd, fh, 0.2, [-1,-1,-1;1,1,1] );

clf
f = [t(:,[1:3]); t(:,[1,2,4]); t(:,[2,3,4]); t(:,[3,1,4])];
patch( 'vertices', p, 'faces', f, 'facecolor', [.9, .9, .9] )
title(s)
view(3)
rotate3d('on')
axis equal

function test_case9()
s = 'Example 9: (Uniform mesh on unit cube)';
disp(s)
fd = @(p) -min(min(min(min(min(p(:,3),1-p(:,3) ),p(:,2)),1-p(:,2)),p(:,1)),1-p(:,1));
fh = @(p) ones(size(p,1),1);
pfix = [-1,-1,-1;-1,1,-1;1,-1,-1;1,1,-1; -1,-1,1;-1,1,1;1,-1,1;1,1,1];
[p,t] = distmesh( fd, fh, 0.2, [-1,-1,-1;1,1,1], pfix );

clf
f = [t(:,[1:3]); t(:,[1,2,4]); t(:,[2,3,4]); t(:,[3,1,4])];
patch( 'vertices', p, 'faces', f, 'facecolor', [.9 .9 .9] )
title(s)
view(3)
rotate3d('on')
axis equal

function test_case10()
s = 'Example 10: (Uniform mesh on cylinder)';
disp(s)
fd = @(p) -min(min(p(:,3),4-p(:,3)),1-sqrt(sum(p(:,1:2).^2,2)));
fh = @(p) ones(size(p,1),1);
pfix = [-1,-1,-1;-1,1,-1;1,-1,-1;1,1,-1; -1,-1,1;-1,1,1;1,-1,1;1,1,1];
[p,t] = distmesh( fd, fh, 0.5, [-1,-1,0;1,1,4], [] );

clf
f = [t(:,[1:3]); t(:,[1,2,4]); t(:,[2,3,4]); t(:,[3,1,4])];
patch( 'vertices', p, 'faces', f, 'facecolor', [.9 .9 .9] )
title(s)
view(3)
rotate3d('on')
axis equal
