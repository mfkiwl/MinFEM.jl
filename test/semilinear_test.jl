using MinFEM

function semilinear(mesh::Mesh, L::AbstractMatrix, M::AbstractMatrix,
                    s::AbstractVector, BoundaryIndices::Set{Int64}=[], tol=1e-10)

  y = zeros(mesh.nnodes)

  res = Inf
  while res > tol
    A = L + MinFEM.asmCubicDerivativeMatrix(mesh, y)
    rhs = -L*y + M*s - MinFEM.asmCubicTerm(mesh, y)

    if(BoundaryIndices != [])
      asmDirichletCondition(A, BoundaryIndices, rhs, zeros(mesh.nnodes))
    end
    dy = A\rhs
    y += dy
    res = L2norm(M, dy)
  end
  return y
end

function solve_semilinear(file_name::String)

  mesh = import_mesh(file_name)

  L = asmLaplacian(mesh)
  M = asmMassMatrix(mesh)

  f(x) = 100.0*x[1]*x[2]
  s = evaluateMeshFunction(mesh, f)

  boundary = union!(mesh.Boundaries[1001].Nodes,
                    mesh.Boundaries[1002].Nodes,
                    mesh.Boundaries[1003].Nodes,
                    mesh.Boundaries[1004].Nodes);

  y = semilinear(mesh, L, M, s, boundary);
  return true
end

@test solve_semilinear("test_v4.msh")
