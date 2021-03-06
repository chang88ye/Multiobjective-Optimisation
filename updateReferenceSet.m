% updata refence set by achived solutions
function [pop, W]=updateReferenceSet(pop, arch, W, zmin, zmax)
[N1,M]=size(pop.objs);
N2=size(arch.objs,1);

if (N2<1)
    return;
end

% maximum number of reference points to be added
limit=min(floor(sqrt(N1)), N2);
dist=pdist2(pop.objs,arch.objs);


% add points
add=0;
while (add<limit)
    K_dist=mink(dist,1,1); %sort(dist,1);
    [~,max_index]=max(K_dist);
    
    new_sol=arch(max_index);
    pop(end+1)=new_sol;
    
    dist(end+1,:)=pdist2(pop(end).objs,arch.objs);
    tmp=(new_sol.objs-zmin)./(zmax-zmin);    
    W(end+1,:)=tmp-(sum(tmp)-1)/M;
    
    add=add+1;
end

% normalisation
zmin_=repmat(zmin, length(pop.objs),1);
zmax_=repmat(zmax,length(pop.objs),1);
popObj=(pop.objs-zmin_)./(zmax_-zmin_);

zmin_=repmat(zmin, N2,1);
zmax_=repmat(zmax, N2,1);

% remove points
ToRemove=size(popObj,1)-N1;
if ToRemove>0
    fit=fitnessMat(popObj,W);
    I =fit<diag(fit)';
    score=sum(I,1);
    [sortS,sortI]=sort(score,'descend');
    
    poorS=sum(sortS>0);
    if (poorS>=ToRemove) % more than [limit] solutions better than the current one for each reference
        pop(sortI(1:ToRemove))=[];
        W(sortI(1:ToRemove),:)=[];
        popObj(sortI(1:ToRemove),:)=[];
    else
        pop(sortI(1:poorS))=[];
        W(sortI(1:poorS),:)=[];
        popObj(sortI(1:poorS),:)=[];
        del=truncate(pop.objs,ToRemove-poorS);
        W(del,:)=[];
        pop(del)=[];
        popObj(del,:)=[];

    end
end

end