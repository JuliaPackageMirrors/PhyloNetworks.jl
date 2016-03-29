# test of preordering and cladewise ordering, used for plotting
# Cecile March 2016

using PhyloNetworks

#----- test of directEdges! ----------#
println("\n\nTesting directEdges! on a tree, then on a network with h=2")

tre = readTopology("(((((((1,2),3),4),5),(6,7)),(8,9)),10);");
net = readTopology("(((Ag,(#H1:7.159::0.056,((Ak,(E:0.08,#H2:0.0::0.004):0.023):0.078,(M:0.0)#H2:::0.996):2.49):2.214):0.026,(((((Az:0.002,Ag2:0.023):2.11,As:2.027):1.697)#H1:0.0::0.944,Ap):0.187,Ar):0.723):5.943,(P,20):1.863,165);");

tre.edge[1].isChild1=false; tre.edge[17].isChild1=false
PhyloNetworks.directEdges!(tre)
tre.edge[1].isChild1  || error("directEdges! didn't correct the direction of 1st edge")
tre.edge[17].isChild1 || error("directEdges! didn't correct the direction of 17th edge")

# 9th node = node number -4. Edge 9: connects nodes -4 and -3.
tre.root = 9;
PhyloNetworks.directEdges!(tre)
!tre.edge[9].isChild1 || error("directEdges! didn't correct the direction of 9th edge")

# 5th node = node number -6.
net.root = 5
PhyloNetworks.directEdges!(net)
!net.edge[12].isChild1 || error("directEdges! didn't correct the direction of 12th edge")
!net.edge[23].isChild1 || error("directEdges! didn't correct the direction of 23th edge")

#----- test of preorder! -------------#
println("\n\nTesting preorder! on a tree, then on a network with h=2")

tre = readTopology("(((((((1,2),3),4),5),(6,7)),(8,9)),10);");
net = readTopology("(((Ag,(#H1:7.159::0.056,((Ak,(E:0.08,#H2:0.0::0.004):0.023):0.078,(M:0.0)#H2:::0.996):2.49):2.214):0.026,(((((Az:0.002,Ag2:0.023):2.11,As:2.027):1.697)#H1:0.0::0.944,Ap):0.187,Ar):0.723):5.943,(P,20):1.863,165);");

preorder!(tre)
num = [-1,10,-2,-9,9,8,-3,-8,7,6,-4,5,-5,4,-6,3,-7,2,1];
for i=1:length(tre.node)
  tre.nodes_changed[i].number==num[i] ||
    error("node pre-ordered $i is node number $(tre.nodes_changed[i].number) instead of $(num[i])")
end

preorder!(net)
num = [-1,14,-14,13,12,-2,-9,11,-10,10,-3,-4,-5,-6,-7,5,6,4,3,2,-12,9,-13,8,7,1];
for i=1:length(net.node)
  net.nodes_changed[i].number==num[i] ||
    error("node pre-ordered $i is node number $(net.nodes_changed[i].number) instead of $(num[i])")
end

#----- test of cladewiseorder! --------#
println("\n\nTesting cladewiseorder! on a tree, then on a network with h=2")

PhyloNetworks.cladewiseorder!(tre)
num = collect(19:-1:1);
for i=1:length(tre.node)
  tre.cladewiseorder_nodeIndex[i]==num[i] ||
    error("node clade-wise ordered $i is $(tre.cladewiseorder_nodeIndex[i])th node instead of $(num[i])th")
end

PhyloNetworks.cladewiseorder!(net)
num = collect(26:-1:1);
for i=1:length(net.node)
  net.cladewiseorder_nodeIndex[i]==num[i] ||
    error("node clade-wise ordered $i is $(net.cladewiseorder_nodeIndex[i])th node instead of $(num[i])th")
end


#----- test of plot -------------------#
println("\n\nTesting plot() on a tree, then on a network with h=2 and various options")

# keep ";" below to avoid creating a new file
plot(tre);
plot(net);
plot(net, useEdgeLength=true);
println("(A message is normal here: about missing BL being given length 1.0)")
plot(net, mainTree=true);
plot(net, showTipLabel=false);
plot(net, showNodeNumber=true);
plot(net, showEdgeLength=false, showEdgeNumber=true);
plot(net, showGamma=false);

using Colors
plot(net, edgeColor=colorant"olive",
          minorHybridEdgeColor=colorant"tan",
          majorHybridEdgeColor=colorant"skyblue");

#----- test of rotate! ----------------#
println("\n\nTesting rotate! to change the order of children edges at a given node")

net = readTopology("(A:1.0,((B:1.1,#H1:0.2::0.2):1.2,(((C:0.52,(E:0.5)#H2:0.02::0.7):0.6,(#H2:0.01::0.3,F:0.7):0.8):0.9,(D:0.8)#H1:0.3::0.8):1.3):0.7):0.1;");
rotate!(net, -4)
[e.number for e in net.node[13].edge] == [14,12,15] || error("rotate didn't work at node -4");
plot(net); # just to check no error.

net=readTopology("(4,((1,(2)#H7:::0.864):2.069,(6,5):3.423):0.265,(3,#H7:::0.136):10.0);");
rotate!(net, -1, enumOrder=[1,12,9])
[e.number for e in net.node[12].edge] == [1,12,9] || error("rotate didn't work at node -1");
rotate!(net, -3)
[e.number for e in net.node[5].edge] == [4,2,5] || error("rotate didn't work at node -3");
plot(net);