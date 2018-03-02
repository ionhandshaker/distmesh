DistMesh - A Simple Mesh Generator in MATLAB
============================================

About
-----

Consolidated and refactored version of DistMesh. This version of
DistMesh can also conveniently be used from a graphical user interface
GUI together with the
[FEATool Multiphysics MATLAB and Octave FEM Toolbox](https://www.featool.com).

<table align="center">
<tr>
<td width="30%"><img src="https://www.featool.com/images/featool-multiphysics-easy-to-use-gui.jpg" style="width:100%"></td>
<td width="30%"><img src="https://www.featool.com/doc/grid_main_50.png" style="width: 100%;"></td>
<td width="30%"><img src="http://persson.berkeley.edu/distmesh/ex06zoom.png" style="width: 100%;"></td>
</tr>
</table>


Description
-----------

DistMesh is a simple MATLAB and
[GNU Octave](https://www.gnu.org/software/octave/) code for generation
of unstructured 2D triangular and 3D tetrahedral meshes. It was
developed by Per-Olof Persson and Gilbert Strang in the Department of
Mathematics at MIT. A detailed description of the program is provided
in the SIAM Review paper and other references linked below.

One reason that the code is short and simple is that the geometries
are specified by Signed Distance Functions (level set). These give the
shortest distance from any point in space to the boundary of the
domain. The sign is negative inside the region and positive outside. A
simple example is the unit circle in two dimensions, which has the
distance function _d = r-1_, where _r_ is the distance from the
origin. For more complicated geometries the distance function can be
computed by interpolation between values on a grid, a common
representation for level set methods.

For the mesh generation procedure, DistMesh uses the Delaunay
triangulation routine in MATLAB and Octave and tries to optimize the
node locations by a force-based smoothing procedure. The topology is
regularly updated by Delaunay. The boundary points are only allowed to
move tangentially to the boundary by projections using the distance
function. This iterative procedure typically results in very uniform
and well-shaped high quality meshes.


Examples
--------

To use the code, simply download the
[distmesh](https://github.com/precisesimulation/distmesh/blob/master/distmesh.m)
source code and run it in MATLAB or Octave. To run the collection of
examples below, type
[distmesh_demo](https://github.com/precisesimulation/distmesh/blob/master/distmesh_demo.m)

- Example 1: Uniform mesh on unit circle

        fd = @(p) sqrt(sum(p.^2,2)) - 1;
        fh = @(p) ones(size(p,1),1);
        [p,t] = distmesh( fd, fh, 0.2, [-1,-1;1,1] );
        patch( 'vertices', p, 'faces', t, 'facecolor', [.9, .9, .9] )

- Example 2: Uniform mesh on ellipse

        fd = @(p) p(:,1).^2/2^2 + p(:,2).^2/1^2 - 1;
        fh = @(p) ones(size(p,1),1);
        [p,t] = distmesh( fd, fh, 0.2, [-2,-1;2,1] );
        patch( 'vertices', p, 'faces', t, 'facecolor', [.9, .9, .9] )

- Example 3: Uniform mesh on unit square

        fd = @(p) -min(min(min(1+p(:,2),1-p(:,2)),1+p(:,1)),1-p(:,1));
        fh = @(p) ones(size(p,1),1);
        [p,t] = distmesh( fd, fh, 0.2, [-1,-1;1,1], [-1,-1;-1,1;1,-1;1,1] );
        patch( 'vertices', p, 'faces', t, 'facecolor', [.9, .9, .9] )

- Example 4: Uniform mesh on complex polygon

        pv = [-0.4 -0.5;0.4 -0.2;0.4 -0.7;1.5 -0.4;0.9 0.1;
              1.6 0.8;0.5 0.5;0.2 1;0.1 0.4;-0.7 0.7;-0.4 -0.5];
        fd = { 'l_dpolygon', [], pv };
        fh = @(p) ones(size(p,1),1);
        [p,t] = distmesh( fd, fh, 0.1, [-1,-1; 2,1], pv );
        patch( 'vertices', p, 'faces', t, 'facecolor', [.9, .9, .9] )

- Example 5: Rectangle with circular hole, refined at circle boundary

        drectangle = @(p,x1,x2,y1,y2) -min(min(min(-y1+p(:,2),y2-p(:,2)),-x1+p(:,1)),x2-p(:,1));
        fd = @(p) max( drectangle(p,-1,1,-1,1), -(sqrt(sum(p.^2,2))-0.5) );
        fh = @(p) 0.05 + 0.3*(sqrt(sum(p.^2,2))-0.5);
        [p,t] = distmesh( fd, fh, 0.05, [-1,-1;1,1], [-1,-1;-1,1;1,-1;1,1] );
        patch( 'vertices', p, 'faces', t, 'facecolor', [.9, .9, .9] )

- Example 6: Square, with size function point and line sources

        dcircle = @(p,xc,yc,r) sqrt((p(:,1)-xc).^2+(p(:,2)-yc).^2)-r;
        fd = @(p) -min(min(min(p(:,2),1-p(:,2)),p(:,1)),1-p(:,1));
        dpolygon = @(p,v) feval('l_dpolygon',p,v);
        fh = @(p) min(min(0.01+0.3*abs(dcircle(p,0,0,0)), ...
                          0.025+0.3*abs(dpolygon(p,[0.3,0.7;0.7,0.5;0.3,0.7]))),0.15);
        [p,t] = distmesh( fd, fh, 0.01, [0,0;1,1], [0,0;1,0;0,1;1,1] );

        patch( 'vertices', p, 'faces', t, 'facecolor', [.9, .9, .9] )

- Example 7: NACA0012 airfoil

        hlead = 0.01; htrail = 0.04; hmax = 2; circx = 2; circr = 4;
        a = 0.12/0.2*[0.2969,-0.126,-0.3516,0.2843,-0.1036];
        fd = @(p) max( dcircle(p,circx,0,circr), ...
                       -((abs(p(:,2))-polyval([a(5:-1:2),0],p(:,1))).^2-a(1)^2*p(:,1)) );
        fh = @(p) min(min(hlead+0.3*dcircle(p,0,0,0),htrail+0.3*dcircle(p,1,0,0)),hmax);

        fixx = 1 - htrail*cumsum(1.3.^(0:4)');
        fixy = a(1)*sqrt(fixx) + polyval([a(5:-1:2),0],fixx);
        pfix = [[circx+[-1,1,0,0]*circr; 0,0,circr*[-1,1]]'; 0,0; 1,0; fixx,fixy; fixx,-fixy];
        bbox = [circx-circr,-circr; circx+circr,circr];
        h0   = min([hlead,htrail,hmax]);
        [p,t] = distmesh( fd, fh, h0, bbox, pfix );
        patch( 'vertices', p, 'faces', t, 'facecolor', [.9, .9, .9] )

- Example 8: Uniform mesh on unit sphere

        fd = @(p) sqrt(sum(p.^2,2)) - 1;
        fh = @(p) ones(size(p,1),1);
        [p,t] = distmesh( fd, fh, 0.2, [-1,-1,-1;1,1,1] );
        f = [t(:,[1:3]); t(:,[1,2,4]); t(:,[2,3,4]); t(:,[3,1,4])];
        patch( 'vertices', p, 'faces', f, 'facecolor', [.9, .9, .9] )

- Example 9: Uniform mesh on unit cube

        fd = @(p) -min(min(min(min(min(p(:,3),1-p(:,3) ),p(:,2)),1-p(:,2)),p(:,1)),1-p(:,1));
        fh = @(p) ones(size(p,1),1);
        pfix = [-1,-1,-1;-1,1,-1;1,-1,-1;1,1,-1; -1,-1,1;-1,1,1;1,-1,1;1,1,1];
        [p,t] = distmesh( fd, fh, 0.2, [-1,-1,-1;1,1,1], pfix );
        f = [t(:,[1:3]); t(:,[1,2,4]); t(:,[2,3,4]); t(:,[3,1,4])];
        patch( 'vertices', p, 'faces', f, 'facecolor', [.9, .9, .9] ), view(3)

- Example 10: Uniform mesh on cylinder

        fd = @(p) -min(min(p(:,3),4-p(:,3)),1-sqrt(sum(p(:,1:2).^2,2)));
        fh = @(p) ones(size(p,1),1);
        pfix = [-1,-1,-1;-1,1,-1;1,-1,-1;1,1,-1; -1,-1,1;-1,1,1;1,-1,1;1,1,1];
        [p,t] = distmesh( fd, fh, 0.5, [-1,-1,0;1,1,4], [] );
        f = [t(:,[1:3]); t(:,[1,2,4]); t(:,[2,3,4]); t(:,[3,1,4])];
        patch( 'vertices', p, 'faces', f, 'facecolor', [.9, .9, .9] ), view(3)


References
----------

[1] [P.-O. Persson, G. Strang, A Simple Mesh Generator in MATLAB. SIAM Review, Volume 46 (2), pp. 329-345, June 2004.](http://persson.berkeley.edu/distmesh/persson04mesh.pdf)

[2] [P.-O. Persson, Mesh Generation for Implicit Geometries. Ph.D. thesis, Department of Mathematics, MIT, Dec 2004.](http://persson.berkeley.edu/thesis/persson-thesis-color.pdf)

[3] [DistMesh website](http://persson.berkeley.edu/distmesh/)

[4] [FEATool Multiphysics grid generation documentation](https://www.featool.com/doc/grid.html)


License
-------

DistMesh is distributed under the GNU GPL; see the License and
Copyright notice for more information.
