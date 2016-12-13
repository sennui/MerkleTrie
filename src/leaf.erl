-module(leaf).
-compile(export_all).
-record(leaf, {key = 0, weight = 0, value = 0}).
serialize(X, CFG) ->
    W = cfg:weight(CFG) * 8,
    S = cfg:value(CFG),
    P = cfg:path(CFG) * 8,
    S = size(X#leaf.value),
    
    <<(X#leaf.key):P, (X#leaf.weight):W, (X#leaf.value)/binary>>.
deserialize(A, CFG) ->
    W = cfg:weight(CFG) * 8,
    L = cfg:value(CFG) * 8,
    P = cfg:path(CFG) * 8,
    <<Key:P, Weight:W, Value:L>> = A,
    #leaf{key = Key, weight = Weight, value = <<Value:L>>}. 
new(Key, Weight, Value, CFG) ->
    true = Key > 0,
    L = cfg:value(CFG) * 8,
    <<_:L>> = Value,
    #leaf{key = Key, weight = Weight, value = Value}. 
key(L) -> L#leaf.key.
path(L, CFG) ->
    K = key(L),
    path_maker(K, CFG).
path_maker(K, CFG) ->
    T = cfg:path(CFG)*8,
    flip_bytes(<<K:T>>).
value(L) -> L#leaf.value.
weight(L) ->
    L#leaf.weight.
put(Leaf, CFG) ->
    dump:put(serialize(Leaf, CFG), 
	     ids:leaf(CFG)).
get(Pointer, CFG) ->
    L = dump:get(Pointer, ids:leaf(CFG)),
    deserialize(L, CFG).
hash(L, CFG) ->   
    hash:doit(serialize(L, CFG)).
flip_bytes(X) -> flip_bytes(X, <<>>).
flip_bytes(<<>>, X) -> X;
flip_bytes(<<N:4, T/bitstring>>, X) -> 
    flip_bytes(T, <<N:4, X/bitstring>>).
