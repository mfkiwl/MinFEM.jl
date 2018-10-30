using MinFEM
using WriteVTK

mesh = import_mesh("../meshes/rounded.msh")

L = asmLaplacian(mesh)

f(x) = x[1]^2 + x[2]^2
s = evaluateMeshFunction(mesh, f, region=union(mesh.Boundaries[1003].Nodes,
                                               mesh.Boundaries[1004].Nodes))

s = asmBoundarySource(mesh, s, union(mesh.Boundaries[1003].Edges,
                                     mesh.Boundaries[1004].Edges))

pde = PDESystem(L, s, zeros(mesh.nnodes), union(mesh.Boundaries[1001].Nodes,
                                                mesh.Boundaries[1002].Nodes))
solve(pde)

vtkfile = write_vtk_mesh(mesh, "boundary_source.vtu")
vtk_point_data(vtkfile, pde.state, "y")
vtk_point_data(vtkfile, s, "s")
vtk_save(vtkfile)

