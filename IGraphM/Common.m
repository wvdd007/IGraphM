(* Mathematica Package *)
(* Created by Mathematica Plugin for IntelliJ IDEA, see http://wlplugin.halirutan.de/ *)

(* :Author: szhorvat *)
(* :Date: 2016-06-12 *)

(* :Copyright: (c) 2018 Szabolcs Horvát *)


(* The following definitions are used in multiple, independently loadable packages. *)

(* General::invopt is not present before Mathematica version 10.3. We set it up manually when needed. *)
If[Not@ValueQ[General::invopt],
  General::invopt = "Invalid value `1` for parameter `2`. Using default value `3`.";
]

IGraphM::mixed = "Mixed graphs are not supported by IGraph/M.";

igGraphQ::usage = "igGraphQ[g] checks if g is an igraph-compatible graph.";
igGraphQ = GraphQ[#] && If[MixedGraphQ[#], Message[IGraphM::mixed]; False, True] &;

igDirectedQ::usage = "igDirectedQ[g] checks if g is a directed graph. Empty graphs are considered undirected.";
igDirectedQ[graph_] := DirectedGraphQ[graph] && Not@EmptyGraphQ[graph]

amendUsage::usage = "amendUsage[symbol, stringTempl, templArg1, templArg2, ...] amends the usage message of symbol.";
amendUsage[sym_Symbol, amend_, args___] :=
    Module[{lines},
      lines = StringSplit[sym::usage, "\n"];
      lines[[1]] = lines[[1]] <> " " <> StringTemplate[amend, InsertionFunction -> (ToString[#, InputForm]&)][args];
      sym::usage = StringJoin@Riffle[lines, "\n"]
    ]

optNames::usage = "optNames[sym1, sym2, ...] returns the option names associated with the given symbols.";
optNames[syms___] := Union @@ (Options[#][[All, 1]]& /@ {syms})


applyGraphOpt::usage = "applyGraphOpt[options][graph] applies the given options to graph.";
applyGraphOpt[opt___][graph_] := Graph[graph, Sequence@@FilterRules[{opt}, Options[Graph]]]

applyGraphOpt3D::usage = "applyGraphOpt3D[options][graph] applies the given options to graph using Graph3D.";
applyGraphOpt3D[opt___][graph_] := Graph3D[graph, Sequence@@FilterRules[{opt}, Options[Graph3D]]]


zeroDiagonal::usage = "zeroDiagonal[mat] replaces the diagonal of a square matrix with zeros.";
zeroDiagonal[mat_] := UpperTriangularize[mat, 1] + LowerTriangularize[mat, -1]


removeSelfLoops::usage = "removeSelfLoops[graph] removes any self loops from graph.";
removeSelfLoops[g_?LoopFreeGraphQ] := g
removeSelfLoops[g_?igGraphQ] := AdjacencyGraph[VertexList[g], zeroDiagonal@AdjacencyMatrix[g], DirectedEdges -> DirectedGraphQ[g]]

removeMultiEdges::usage = "removeMultiEdges[graph] removes any multi-edges from graph.";
removeMultiEdges[g_ /; igGraphQ[g] && MultigraphQ[g]] := AdjacencyGraph[VertexList[g], Unitize@AdjacencyMatrix[g], DirectedEdges -> DirectedGraphQ[g]]
removeMultiEdges[g_] := g


(*
	Numeric codes are for certain special types of completions. Zero means 'don't complete':

	Normal argument     0
	AbsoluteFilename    2
	RelativeFilename    3
	Color               4
	PackageName         7
	DirectoryName       8
	InterpreterType     9
*)

addCompletion::usage = "addCompletion[symbol, argSpec] adds FE auto-completion for symbol.";
addCompletion[fun_Symbol, argSpec_List] :=
    If[$Notebooks,
      With[{compl = SymbolName[fun] -> argSpec},
        FE`Evaluate[FEPrivate`AddSpecialArgCompletion[compl]]
      ]
    ]
